import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../features/auth/models/user_model.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/app_logger.dart';
import './token_service.dart';

class AuthService {
  final TokenService _tokens = TokenService();
  late final LoggerScope _log;

  AuthService() {
    _log = AppLogger.scope('AuthService');
  }

  Future<User?> getCurrentUser() async {
    _log.debug('Checking current user authentication');
    
    try {
      final token = await _tokens.getAuthToken();
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
      await _tokens.delete(TokenService.authTokenKey);
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
          await _tokens.write(TokenService.authTokenKey, data['idToken']);
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
          await _tokens.write(TokenService.accessTokenKey, data['token']);
          _log.debug('Access token stored');
        }
        
        if (data['refreshToken'] != null) {
          await _tokens.write(TokenService.refreshTokenKey, data['refreshToken']);
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

    
    final requestBody = jsonEncode({
      'email': email,
      'code': code,
    });
    
    final response = await http.post(
      Uri.parse(AppConfig.authConfirmUrl),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
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

  /// Update user profile information
  Future<bool> updateProfile({String? name}) async {
    _log.info('Profile update attempt');
    
    try {
      final token = await _tokens.getAuthToken();
      if (token == null) {
        _log.warning('No auth token found for profile update');
        throw Exception('Not authenticated');
      }

      final Map<String, dynamic> updateData = {};
      if (name != null) {
        updateData['name'] = name;
        _log.debug('Updating name');
      }

      if (updateData.isEmpty) {
        _log.debug('No fields to update');
        return true;
      }

      final requestBody = jsonEncode(updateData);

      _log.debug('Sending profile update request');

      final response = await http.put(
        Uri.parse(AppConfig.authUpdateProfileUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody,
      );

      _log.debug('Profile update response received', {
        'statusCode': response.statusCode,
      });

      if (response.statusCode == 200) {
        _log.info('Profile updated successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        final errorMsg = error['error'] ?? 'Profile update failed';
        _log.warning('Profile update failed', {
          'error': errorMsg,
          'statusCode': response.statusCode,
        });
        throw Exception(errorMsg);
      }
    } catch (e, stackTrace) {
      _log.error('Profile update error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  Future<bool> changePassword({
  required String oldPassword,
  required String newPassword,
}) async {
  _log.info('Password change attempt');
  
  try {
    final idToken = await _tokens.getAuthToken();
    if (idToken == null) {
      _log.warning('No auth token found for password change');
      throw Exception('Not authenticated');
    }

    final accessToken = await _tokens.getAccessToken();
    if (accessToken == null) {
      _log.warning('No access token found for password change');
      throw Exception('Not authenticated - missing access token');
    }

    final requestBody = jsonEncode({
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'accessToken': accessToken,  // ← Send in body
    });

    _log.debug('Sending password change request', {
      'oldPassword': LogSanitizer.password(),
      'newPassword': LogSanitizer.password(),
    });

    final response = await http.post(
      Uri.parse(AppConfig.authChangePasswordUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',  // ← ID token for API Gateway
      },
      body: requestBody,
    );

    _log.debug('Password change response received', {
      'statusCode': response.statusCode,
    });

    if (response.statusCode == 200) {
      _log.info('Password changed successfully');
      return true;
    } else {
      final error = jsonDecode(response.body);
      final errorMsg = error['error'] ?? 'Password change failed';
      _log.warning('Password change failed', {
        'error': errorMsg,
        'statusCode': response.statusCode,
      });
      throw Exception(errorMsg);
    }
  } catch (e, stackTrace) {
    _log.error('Password change error', error: e, stackTrace: stackTrace);
    rethrow;
  }
}

  Future<void> logout() async {
    _log.info('User logout initiated');
    try {
      await _tokens.clearAll();
      _log.info('Logout completed - all tokens cleared');
    } catch (e, stackTrace) {
      _log.error('Logout error', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}