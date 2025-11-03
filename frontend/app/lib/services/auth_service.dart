import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';
import '../utils/app_talker.dart';

// Platform-aware storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  late final TalkerScope talker;

  AuthService() {
    talker = AppTalker.createLogger('AuthService');
  }

  // Platform-aware storage methods
  Future<void> _writeToken(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
    talker.debug('Stored token: $key');
  }

  Future<String?> _readToken(String key) async {
    String? token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(key);
    } else {
      token = await _secureStorage.read(key: key);
    }
    
    talker.debug('Read token [$key]: ${token != null ? "present" : "absent"}');
    return token;
  }

  Future<void> _deleteToken(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
    talker.debug('Deleted token: $key');
  }

  Future<User?> getCurrentUser() async {
    talker.debug('Checking current user authentication');
    
    try {
      final token = await _readToken('auth_token');
      if (token == null) {
        talker.debug('No authentication token found');
        return null;
      }

      talker.debug('Validating token with server');
      final response = await http.get(
        Uri.parse(AppConfig.authMeUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        talker.info('User authenticated: ${AppTalker.sanitizeEmail(data['email'])}');
        return User.fromJson(data);
      }
      
      talker.warning('Token validation failed: ${response.statusCode}');
      await _deleteToken('auth_token');
      return null;
    } catch (e, stackTrace) {
      talker.error('Authentication check failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    talker.info('Login attempt for: ${AppTalker.sanitizeEmail(email)}');
    
    try {
      // Create the actual request body
      final requestBody = jsonEncode({
        'email': email,
        'password': password,
      });

      // Log the request with sanitized password
      if (kDebugMode && AppConfig.enableLogging) {
        talker.debug('Request: email=$email, password=[REDACTED]');
      }

      final response = await http.post(
        Uri.parse(AppConfig.authLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      talker.debug('Login response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['idToken'] != null) {
          await _writeToken('auth_token', data['idToken']);
          talker.info('ID token stored successfully');
          
          // Validate token structure in debug mode only
          if (kDebugMode && AppConfig.enableLogging) {
            try {
              final parts = data['idToken'].split('.');
              if (parts.length == 3) {
                final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
                final claims = jsonDecode(payload);
                talker.debug('Token type: ${claims['token_use']}, Sub: ${claims['sub']?.substring(0, 8)}...');
              }
            } catch (e) {
              talker.warning('Could not parse token structure');
            }
          }
        } else {
          talker.error('No idToken in login response');
          throw Exception('Invalid login response: missing idToken');
        }
        
        // Store additional tokens
        if (data['token'] != null) {
          await _writeToken('access_token', data['token']);
        }
        
        if (data['refreshToken'] != null) {
          await _writeToken('refresh_token', data['refreshToken']);
        }

        final user = User.fromJson(data);
        talker.info('Login successful for: ${AppTalker.sanitizeEmail(user.email)}');
        return user;
      } else {
        final error = jsonDecode(response.body);
        talker.warning('Login failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e, stackTrace) {
      talker.error('Login error', error: e, stackTrace: stackTrace);
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    talker.info('Signup attempt for: ${AppTalker.sanitizeEmail(email)}');
    
    try {
      // Create the actual request body
      final requestBody = jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      });

      // Log the request with sanitized password
      if (kDebugMode && AppConfig.enableLogging) {
        talker.debug('Request: email=$email, name=$name, password=[REDACTED]');
      }

      final response = await http.post(
        Uri.parse(AppConfig.authSignupUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      talker.debug('Signup response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        talker.info('Signup successful');
        return {
          'success': true,
          'email': data['email'],
          'message': data['message'],
          'emailVerified': data['emailVerified'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        talker.warning('Signup failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e, stackTrace) {
      talker.error('Signup error', error: e, stackTrace: stackTrace);
      throw Exception('Signup error: $e');
    }
  }

  Future<bool> confirmEmail(String email, String code) async {
    talker.info('Email confirmation for: ${AppTalker.sanitizeEmail(email)}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authConfirmUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        talker.info('Email confirmed successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        talker.warning('Email confirmation failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Email confirmation failed');
      }
    } catch (e, stackTrace) {
      talker.error('Confirmation error', error: e, stackTrace: stackTrace);
      throw Exception('Confirmation error: $e');
    }
  }

  Future<bool> resendCode(String email) async {
    talker.info('Resending code for: ${AppTalker.sanitizeEmail(email)}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authResendCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        talker.info('Code resent successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        talker.warning('Failed to resend code: ${error['error']}');
        throw Exception(error['error'] ?? 'Failed to resend code');
      }
    } catch (e, stackTrace) {
      talker.error('Resend code error', error: e, stackTrace: stackTrace);
      throw Exception('Resend code error: $e');
    }
  }

  Future<void> logout() async {
    talker.info('User logout');
    await _deleteToken('auth_token');
    await _deleteToken('access_token');
    await _deleteToken('refresh_token');
    talker.info('All tokens cleared');
  }
}