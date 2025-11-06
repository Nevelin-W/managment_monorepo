import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

// Platform-aware storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _secureStorage = const FlutterSecureStorage();
  late final LoggerScope _log;

  AuthService() {
    _log = AppLogger.scope('AuthService');
  }

  // Platform-aware storage methods
  Future<void> _writeToken(String key, String value) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      } else {
        await _secureStorage.write(key: key, value: value);
      }
      _log.debug('Token stored successfully', {'key': key});
    } catch (e, stackTrace) {
      _log.error('Failed to store token', error: e, stackTrace: stackTrace, context: {'key': key});
      rethrow;
    }
  }

  Future<String?> _readToken(String key) async {
    try {
      String? token;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(key);
      } else {
        token = await _secureStorage.read(key: key);
      }
      
      _log.debug('Token read', {'key': key, 'present': token != null});
      return token;
    } catch (e, stackTrace) {
      _log.error('Failed to read token', error: e, stackTrace: stackTrace, context: {'key': key});
      return null;
    }
  }

  Future<void> _deleteToken(String key) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(key);
      } else {
        await _secureStorage.delete(key: key);
      }
      _log.debug('Token deleted', {'key': key});
    } catch (e, stackTrace) {
      _log.error('Failed to delete token', error: e, stackTrace: stackTrace, context: {'key': key});
    }
  }

  Future<User?> getCurrentUser() async {
    _log.debug('Checking current user authentication');
    
    try {
      final token = await _readToken('auth_token');
      if (token == null) {
        _log.debug('No authentication token found');
        return null;
      }

      _log.debug('Validating token with server');
      final response = await http.get(
        Uri.parse(AppConfig.authMeUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sanitizedEmail = LogSanitizer.email(data['email']);
        _log.info('User authenticated', {'email': sanitizedEmail});
        return User.fromJson(data);
      }
      
      _log.warning('Token validation failed', {'statusCode': response.statusCode});
      await _deleteToken('auth_token');
      return null;
    } catch (e, stackTrace) {
      _log.error('Authentication check failed', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    final sanitizedEmail = LogSanitizer.email(email);
    _log.info('Login attempt', {'email': sanitizedEmail});
    
    try {
      final requestBody = jsonEncode({
        'email': email,
        'password': password,
      });

      _log.debug('Sending login request', {
        'email': sanitizedEmail,
        'password': LogSanitizer.password(),
      });

      final response = await http.post(
        Uri.parse(AppConfig.authLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      _log.debug('Login response received', {'statusCode': response.statusCode});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['idToken'] != null) {
          await _writeToken('auth_token', data['idToken']);
          _log.info('ID token stored successfully');
          
          // Validate token structure in debug mode only
          if (kDebugMode && AppConfig.logLevel == LogLevel.debug) {
            try {
              final parts = data['idToken'].split('.');
              if (parts.length == 3) {
                final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
                final claims = jsonDecode(payload);
                _log.debug('Token validated', {
                  'tokenType': claims['token_use'],
                  'subPrefix': claims['sub']?.substring(0, 8),
                });
              }
            } catch (e) {
              _log.debug('Could not parse token structure');
            }
          }
        } else {
          _log.error('Missing idToken in login response');
          throw Exception('Invalid login response: missing idToken');
        }
        
        // Store additional tokens
        if (data['token'] != null) {
          await _writeToken('access_token', data['token']);
          _log.debug('Access token stored');
        }
        
        if (data['refreshToken'] != null) {
          await _writeToken('refresh_token', data['refreshToken']);
          _log.debug('Refresh token stored');
        }

        final user = User.fromJson(data);
        _log.info('Login successful', {'email': sanitizedEmail, 'userId': user.id});
        return user;
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['error'] ?? 'Login failed';
        _log.warning('Login failed', {'error': errorMsg, 'statusCode': response.statusCode});
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _log.error('Login error', error: e, stackTrace: stackTrace, context: {'email': sanitizedEmail});
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    final sanitizedEmail = LogSanitizer.email(email);
    _log.info('Signup attempt', {'email': sanitizedEmail, 'name': name});
    
    try {
      final requestBody = jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      });

      _log.debug('Sending signup request', {
        'email': sanitizedEmail,
        'name': name,
        'password': LogSanitizer.password(),
      });

      final response = await http.post(
        Uri.parse(AppConfig.authSignupUrl),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      _log.debug('Signup response received', {'statusCode': response.statusCode});

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _log.info('Signup successful', {'email': sanitizedEmail});
        return {
          'success': true,
          'email': data['email'],
          'message': data['message'],
          'emailVerified': data['emailVerified'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['error'] ?? 'Signup failed';
        _log.warning('Signup failed', {'error': errorMsg, 'statusCode': response.statusCode});
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _log.error('Signup error', error: e, stackTrace: stackTrace, context: {'email': sanitizedEmail});
      rethrow;
    }
  }

  Future<bool> confirmEmail(String email, String code) async {
    final sanitizedEmail = LogSanitizer.email(email);
    _log.info('Email confirmation attempt', {'email': sanitizedEmail});
    
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
        _log.info('Email confirmed successfully', {'email': sanitizedEmail});
        return true;
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['error'] ?? 'Email confirmation failed';
        _log.warning('Email confirmation failed', {'error': errorMsg, 'email': sanitizedEmail});
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _log.error('Confirmation error', error: e, stackTrace: stackTrace, context: {'email': sanitizedEmail});
      rethrow;
    }
  }

  Future<bool> resendCode(String email) async {
    final sanitizedEmail = LogSanitizer.email(email);
    _log.info('Resending verification code', {'email': sanitizedEmail});
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authResendCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        _log.info('Verification code resent', {'email': sanitizedEmail});
        return true;
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['error'] ?? 'Failed to resend code';
        _log.warning('Failed to resend code', {'error': errorMsg, 'email': sanitizedEmail});
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _log.error('Resend code error', error: e, stackTrace: stackTrace, context: {'email': sanitizedEmail});
      rethrow;
    }
  }

  Future<void> logout() async {
    _log.info('User logout initiated');
    try {
      await _deleteToken('auth_token');
      await _deleteToken('access_token');
      await _deleteToken('refresh_token');
      _log.info('Logout completed - all tokens cleared');
    } catch (e, stackTrace) {
      _log.error('Logout error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}