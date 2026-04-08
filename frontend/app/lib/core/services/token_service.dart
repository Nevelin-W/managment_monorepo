import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Centralized token storage service.
/// Uses FlutterSecureStorage on native platforms and SharedPreferences on web.
class TokenService {
  static final TokenService _instance = TokenService._internal();
  factory TokenService() => _instance;
  TokenService._internal();

  final _secureStorage = const FlutterSecureStorage();
  late final LoggerScope _log = AppLogger.scope('TokenService');

  static const authTokenKey = 'auth_token';
  static const accessTokenKey = 'access_token';
  static const refreshTokenKey = 'refresh_token';

  Future<void> write(String key, String value) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(key, value);
      } else {
        await _secureStorage.write(key: key, value: value);
      }
      _log.debug('Token stored', {'key': key});
    } catch (e, stackTrace) {
      _log.error('Failed to store token', error: e, stackTrace: stackTrace, context: {'key': key});
      rethrow;
    }
  }

  Future<String?> read(String key) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(key);
      } else {
        return await _secureStorage.read(key: key);
      }
    } catch (e, stackTrace) {
      _log.error('Failed to read token', error: e, stackTrace: stackTrace, context: {'key': key});
      return null;
    }
  }

  Future<void> delete(String key) async {
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

  Future<void> clearAll() async {
    await delete(authTokenKey);
    await delete(accessTokenKey);
    await delete(refreshTokenKey);
    _log.info('All tokens cleared');
  }

  /// Get the auth (ID) token, or null if not stored.
  Future<String?> getAuthToken() => read(authTokenKey);

  /// Get the access token, or null if not stored.
  Future<String?> getAccessToken() => read(accessTokenKey);
}
