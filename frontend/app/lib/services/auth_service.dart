import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

// Platform-aware storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  late final Logger logger;

  AuthService() {
    logger = AppLogger.createLogger('AuthService');
  }

  // Platform-aware storage methods
  Future<void> _writeToken(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
    logger.d('Stored token: $key');
  }

  Future<String?> _readToken(String key) async {
    String? token;
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(key);
    } else {
      token = await _secureStorage.read(key: key);
    }
    
    logger.t('Read token [$key]: ${token != null ? "present" : "absent"}');
    return token;
  }

  Future<void> _deleteToken(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
    logger.d('Deleted token: $key');
  }

  Future<User?> getCurrentUser() async {
    logger.d('Checking current user authentication');
    
    try {
      final token = await _readToken('auth_token');
      if (token == null) {
        logger.d('No authentication token found');
        return null;
      }

      logger.d('Validating token with server');
      final response = await http.get(
        Uri.parse(AppConfig.authMeUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('User authenticated: ${AppLogger.sanitizeEmail(data['email'])}');
        return User.fromJson(data);
      }
      
      logger.w('Token validation failed: ${response.statusCode}');
      await _deleteToken('auth_token');
      return null;
    } catch (e, stackTrace) {
      logger.e('Authentication check failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    logger.i('Login attempt for: ${AppLogger.sanitizeEmail(email)}');
    
    try {
      // Create the actual request body
      final requestBody = jsonEncode({
        'email': email,
        'password': password,
      });

      // Log the request with sanitized password
      if (kDebugMode && AppConfig.enableLogging) {
        logger.d('Request: email=$email, password=[REDACTED]');
      }

      final response = await http.post(
        Uri.parse(AppConfig.authLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      logger.d('Login response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['idToken'] != null) {
          await _writeToken('auth_token', data['idToken']);
          logger.i('ID token stored successfully');
          
          // Validate token structure in debug mode only
          if (kDebugMode && AppConfig.enableLogging) {
            try {
              final parts = data['idToken'].split('.');
              if (parts.length == 3) {
                final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
                final claims = jsonDecode(payload);
                logger.t('Token type: ${claims['token_use']}, Sub: ${claims['sub']?.substring(0, 8)}...');
              }
            } catch (e) {
              logger.w('Could not parse token structure');
            }
          }
        } else {
          logger.e('No idToken in login response');
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
        logger.i('Login successful for: ${AppLogger.sanitizeEmail(user.email)}');
        return user;
      } else {
        final error = jsonDecode(response.body);
        logger.w('Login failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e, stackTrace) {
      logger.e('Login error', error: e, stackTrace: stackTrace);
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    logger.i('Signup attempt for: ${AppLogger.sanitizeEmail(email)}');
    
    try {
      // Create the actual request body
      final requestBody = jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      });

      // Log the request with sanitized password
      if (kDebugMode && AppConfig.enableLogging) {
        logger.d('Request: email=$email, name=$name, password=[REDACTED]');
      }

      final response = await http.post(
        Uri.parse(AppConfig.authSignupUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      logger.d('Signup response: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        logger.i('Signup successful');
        return {
          'success': true,
          'email': data['email'],
          'message': data['message'],
          'emailVerified': data['emailVerified'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        logger.w('Signup failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e, stackTrace) {
      logger.e('Signup error', error: e, stackTrace: stackTrace);
      throw Exception('Signup error: $e');
    }
  }

  Future<bool> confirmEmail(String email, String code) async {
    logger.i('Email confirmation for: ${AppLogger.sanitizeEmail(email)}');
    
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
        logger.i('Email confirmed successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        logger.w('Email confirmation failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Email confirmation failed');
      }
    } catch (e, stackTrace) {
      logger.e('Confirmation error', error: e, stackTrace: stackTrace);
      throw Exception('Confirmation error: $e');
    }
  }

  Future<bool> resendCode(String email) async {
    logger.i('Resending code for: ${AppLogger.sanitizeEmail(email)}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authResendCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        logger.i('Code resent successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        logger.w('Failed to resend code: ${error['error']}');
        throw Exception(error['error'] ?? 'Failed to resend code');
      }
    } catch (e, stackTrace) {
      logger.e('Resend code error', error: e, stackTrace: stackTrace);
      throw Exception('Resend code error: $e');
    }
  }

  Future<void> logout() async {
    logger.i('User logout');
    await _deleteToken('auth_token');
    await _deleteToken('access_token');
    await _deleteToken('refresh_token');
    logger.i('All tokens cleared');
  }
}