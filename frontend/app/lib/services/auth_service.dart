import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<User?> getCurrentUser() async {
    print('=== GET CURRENT USER SERVICE ===');
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) {
        print('No auth token found');
        return null;
      }

      print('Token exists, checking with /auth/me');
      final response = await http.get(
        Uri.parse(AppConfig.authMeUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Auth me response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✓ User authenticated: ${data['email']}');
        return User.fromJson(data);
      }
      
      print('Auth me failed, clearing token');
      await storage.delete(key: 'auth_token');
      return null;
    } catch (e) {
      print('Error in getCurrentUser: $e');
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    print('=== LOGIN SERVICE ===');
    print('Email: $email');
    print('URL: ${AppConfig.authLoginUrl}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['idToken'] != null) {
          await storage.write(key: 'auth_token', value: data['idToken']);
          print('✓ Stored ID token for API Gateway');
          
          // Debug: Check token type
          try {
            final parts = data['idToken'].split('.');
            if (parts.length == 3) {
              final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
              final claims = jsonDecode(payload);
              print('Token type: ${claims['token_use']}'); // Should be "id"
              print('Token sub (user ID): ${claims['sub']}');
            }
          } catch (e) {
            print('Could not decode token for debugging: $e');
          }
        } else {
          print('❌ WARNING: No idToken in response!');
          throw Exception('No ID token in login response');
        }
        
        // Optional: Store other tokens if needed
        if (data['token'] != null) {
          await storage.write(key: 'access_token', value: data['token']);
          print('✓ Stored access token');
        }
        
        if (data['refreshToken'] != null) {
          await storage.write(key: 'refresh_token', value: data['refreshToken']);
          print('✓ Stored refresh token');
        }

        final user = User.fromJson(data);
        print('✓ Login successful for user: ${user.email}');
        return user;
      } else {
        final error = jsonDecode(response.body);
        print('❌ Login failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      print('Error type: ${e.runtimeType}');
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    print('=== SIGNUP SERVICE ===');
    print('Email: $email, Name: $name');
    print('URL: ${AppConfig.authSignupUrl}');
    
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

      print('Signup response status: ${response.statusCode}');
      print('Signup response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✓ Signup successful');
        return {
          'success': true,
          'email': data['email'],
          'message': data['message'],
          'emailVerified': data['emailVerified'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        print('❌ Signup failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      print('❌ Signup error: $e');
      throw Exception('Signup error: $e');
    }
  }

  Future<bool> confirmEmail(String email, String code) async {
    print('=== CONFIRM EMAIL SERVICE ===');
    print('Email: $email, Code: $code');
    print('URL: ${AppConfig.authConfirmUrl}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authConfirmUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
        }),
      );

      print('Confirm response status: ${response.statusCode}');
      print('Confirm response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✓ Email confirmed successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('❌ Email confirmation failed: ${error['error']}');
        throw Exception(error['error'] ?? 'Email confirmation failed');
      }
    } catch (e) {
      print('❌ Confirmation error: $e');
      throw Exception('Confirmation error: $e');
    }
  }

  Future<bool> resendCode(String email) async {
    print('=== RESEND CODE SERVICE ===');
    print('Email: $email');
    print('URL: ${AppConfig.authResendCodeUrl}');
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authResendCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      print('Resend code response status: ${response.statusCode}');
      print('Resend code response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✓ Code resent successfully');
        return true;
      } else {
        final error = jsonDecode(response.body);
        print('❌ Failed to resend code: ${error['error']}');
        throw Exception(error['error'] ?? 'Failed to resend code');
      }
    } catch (e) {
      print('❌ Resend code error: $e');
      throw Exception('Resend code error: $e');
    }
  }

  Future<void> logout() async {
    print('=== LOGOUT SERVICE ===');
    await storage.delete(key: 'auth_token');
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
    print('✓ All tokens cleared');
  }
}