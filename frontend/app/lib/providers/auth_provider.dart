import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    print('=== AUTH PROVIDER INITIALIZED ===');
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    print('=== CHECK AUTH STATUS ===');
    _isLoading = true;
    notifyListeners();
    
    try {
      print('Checking if user is authenticated...');
      _user = await _authService.getCurrentUser();
      print('Auth status check result: ${_user != null ? "Authenticated" : "Not authenticated"}');
      if (_user != null) {
        print('User: ${_user!.email}');
      }
    } catch (e) {
      print('Error checking auth status: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('Auth status check completed');
    }
  }

  Future<bool> login(String email, String password) async {
    print('=== LOGIN PROVIDER ===');
    print('Email: $email');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Calling auth service login...');
      _user = await _authService.login(email, password);
      
      if (_user != null) {
        print('✓ Login successful');
        print('User ID: ${_user!.id}');
        print('User email: ${_user!.email}');
        print('User name: ${_user!.name}');
      } else {
        print('❌ Login returned null user');
      }
      
      _isLoading = false;
      notifyListeners();
      print('Login provider completed successfully');
      return true;
    } catch (e) {
      print('❌ Login error: $e');
      print('Error type: ${e.runtimeType}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    print('=== SIGNUP PROVIDER ===');
    print('Email: $email');
    print('Name: $name');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Calling auth service signup...');
      final result = await _authService.signup(email, password, name);
      print('Signup result: $result');
      
      final success = result['success'] ?? false;
      print(success ? '✓ Signup successful' : '❌ Signup failed');
      
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('❌ Signup error: $e');
      print('Error type: ${e.runtimeType}');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    print('=== LOGOUT PROVIDER ===');
    print('Current user: ${_user?.email}');
    
    try {
      await _authService.logout();
      _user = null;
      print('✓ Logout successful, user cleared');
      notifyListeners();
    } catch (e) {
      print('❌ Logout error: $e');
      // Clear user anyway
      _user = null;
      notifyListeners();
    }
  }

  void clearError() {
    print('Clearing error: $_error');
    _error = null;
    notifyListeners();
  }
}