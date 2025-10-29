import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  Future<User?> getCurrentUser() async {
    logger.d('GET CURRENT USER SERVICE');
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        logger.d('No auth token found');
        return null;
      }

      logger.d('Token exists, checking with /auth/me');
      final response = await http.get(
        Uri.parse(AppConfig.authMeUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      logger.d('Auth me response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i('User authenticated: ${data['email']}');
        return User.fromJson(data);
      }
      
      logger.d('Auth me failed, clearing token');
      await storage.delete(key: 'auth_token');
      return null;
    } catch (e) {
      logger.e('Error in getCurrentUser', error: e);
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    logger.d('LOGIN SERVICE');
    logger.d('Email: $email');
    logger.d('URL: ${AppConfig.authLoginUrl}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      logger.d('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['idToken'] != null) {
          await storage.write(key: 'auth_token', value: data['idToken']);
          logger.i('Stored ID token for API Gateway');
          
          // Debug: Check token type
          try {
            final parts = data['idToken'].split('.');
            if (parts.length == 3) {
              final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
              final claims = jsonDecode(payload);
              logger.d('Token type: ${claims['token_use']}'); // Should be "id"
              logger.d('Token sub (user ID): ${claims['sub']}');
            }
          } catch (e) {
            logger.w('Could not decode token for debugging', error: e);
          }
        } else {
          logger.e('WARNING: No idToken in response!');
          throw Exception('No ID token in login response');
        }
        
        // Optional: Store other tokens if needed
        if (data['token'] != null) {
          await storage.write(key: 'access_token', value: data['token']);
          logger.i('Stored access token');
        }
        
        if (data['refreshToken'] != null) {
          await storage.write(key: 'refresh_token', value: data['refreshToken']);
          logger.i('Stored refresh token');
        }

        final user = User.fromJson(data);
        logger.i('Login successful for user: ${user.email}');
        return user;
      } else {
        final error = jsonDecode(response.body);
        logger.e('Login failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      logger.e('Login error: $e');
      logger.d('Error type: ${e.runtimeType}');
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    logger.d('SIGNUP SERVICE');
    logger.d('Email: $email, Name: $name');
    logger.d('URL: ${AppConfig.authSignupUrl}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authSignupUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      logger.d('Signup response status: ${response.statusCode}');
      logger.d('Signup response body: ${response.body}');

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
        logger.e('Signup failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      logger.e('Signup error', error: e);
      throw Exception('Signup error: $e');
    }
  }

  Future<bool> confirmEmail(String email, String code) async {
    logger.d('CONFIRM EMAIL SERVICE');
    logger.d('Email: $email, Code: $code');
    logger.d('URL: ${AppConfig.authConfirmUrl}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authConfirmUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      logger.d('Confirm response status: ${response.statusCode}');
      logger.d('Confirm response body: ${response.body}');

      if (response.statusCode == 200) {
        logger.i('Email confirmed successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        logger.e('Email confirmation failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Email confirmation failed');
      }
    } catch (e) {
      logger.e('Confirmation error', error: e);
      throw Exception('Confirmation error: $e');
    }
  }

  Future<bool> resendCode(String email) async {
    logger.d('RESEND CODE SERVICE');
    logger.d('Email: $email');
    logger.d('URL: ${AppConfig.authResendCodeUrl}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authResendCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      logger.d('Resend code response status: ${response.statusCode}');
      logger.d('Resend code response body: ${response.body}');

      if (response.statusCode == 200) {
        logger.i('Code resent successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        logger.e('Failed to resend code: ${error['error']}');
        throw Exception(error['error'] ?? 'Failed to resend code');
      }
    } catch (e) {
      logger.e('Resend code error', error: e);
      throw Exception('Resend code error: $e');
    }
  }

  Future<void> logout() async {
    logger.d('LOGOUT SERVICE');
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    logger.i('All tokens cleared');
  }
}