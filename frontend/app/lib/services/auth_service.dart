import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';
import '../config/app_config.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<User?> getCurrentUser() async {
    try {
      final token = await storage.read(key: 'auth_token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse(AppConfig.authMeUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        if (user.token != null) {
          await storage.write(key: 'auth_token', value: user.token);
        }

        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
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

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'email': data['email'],
          'message': data['message'],
          'emailVerified': data['emailVerified'] ?? false,
        };
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  Future<bool> confirmEmail(String email, String code) async {
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
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Email confirmation failed');
      }
    } catch (e) {
      throw Exception('Confirmation error: $e');
    }
  }

  Future<bool> resendCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse(AppConfig.authResendCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to resend code');
      }
    } catch (e) {
      throw Exception('Resend code error: $e');
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'auth_token');
  }
}