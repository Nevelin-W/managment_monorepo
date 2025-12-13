import 'package:flutter/foundation.dart';
import '../../../core/services/auth_service.dart';
import '../../../features/auth/models/user_model.dart';
import '../../../core/utils/app_logger.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  late final LoggerScope _log;

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _log = AppLogger.scope('AuthProvider');
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _log.debug('Checking existing user session');
      _user = await _authService.getCurrentUser();
      if (_user != null) {
        _log.info('User session restored', {
          'email': LogSanitizer.email(_user!.email),
          'userId': _user!.id,
        });
      } else {
        _log.debug('No existing session found');
      }
    } catch (e, stackTrace) {
      _log.error('Error restoring session', error: e, stackTrace: stackTrace);
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

    final sanitizedEmail = LogSanitizer.email(email);
    _log.info('Login request from provider', {'email': sanitizedEmail});

    try {
      _user = await _authService.login(email, password);
      _log.info('Login successful', {'email': sanitizedEmail, 'userId': _user?.id});
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      _log.warning('Login failed in provider', {'email': sanitizedEmail});
      _log.error('Login error details', error: e, stackTrace: stackTrace);
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

    final sanitizedEmail = LogSanitizer.email(email);
    _log.info('Signup request from provider', {'email': sanitizedEmail, 'name': name});

    try {
      final result = await _authService.signup(email, password, name);
      final success = result['success'] ?? false;
      if (success) {
        _log.info('Signup successful', {'email': sanitizedEmail});
      } else {
        _log.warning('Signup response unsuccessful', {'email': sanitizedEmail});
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e, stackTrace) {
      _log.warning('Signup failed in provider', {'email': sanitizedEmail});
      _log.error('Signup error details', error: e, stackTrace: stackTrace);
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _log.info('Logout initiated');
    try {
      await _authService.logout();
      _user = null;
      _log.info('Logout completed - user cleared');
      notifyListeners();
    } catch (e, stackTrace) {
      _log.error('Logout error in provider', error: e, stackTrace: stackTrace);
      _user = null;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

   /// Refresh current user data from server
  Future<void> refreshUser() async {
    _log.info('Refreshing user data');
    
    try {
      _user = await _authService.getCurrentUser();
      if (_user != null) {
        _log.info('User data refreshed', {'userId': _user!.id});
      }
      notifyListeners();
    } catch (e, stackTrace) {
      _log.error('Failed to refresh user data', error: e, stackTrace: stackTrace);
      // Don't throw - just log the error
    }
  }
}