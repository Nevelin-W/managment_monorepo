import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/app_logger.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  late final Logger logger;
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    logger = AppLogger.createLogger('AuthProvider');
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _user = await _authService.getCurrentUser();
      if (_user != null) {
        logger.i('User session restored: ${AppLogger.sanitizeEmail(_user!.email)}');
      }
    } catch (e) {
      logger.e('Error restoring session', error: e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      logger.w('Login failed in provider', error: e);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.signup(email, password, name);
      final success = result['success'] ?? false;
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      logger.w('Signup failed in provider', error: e);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      notifyListeners();
    } catch (e) {
      logger.e('Logout error in provider', error: e);
      // Clear user anyway
      _user = null;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}