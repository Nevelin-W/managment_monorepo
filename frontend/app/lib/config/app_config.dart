/// Application Configuration
/// Values are passed as build-time arguments
class AppConfig {
  static late final String apiBaseUrl;
  static late final String userPoolId;
  static late final String region;

  static bool _initialized = false;

  /// Initialize the configuration with environment values
  static void initialize({
    required String apiBaseUrl,
    required String userPoolId,
    required String region,
  }) {
    if (_initialized) {
      throw StateError('AppConfig has already been initialized');
    }
    
    AppConfig.apiBaseUrl = apiBaseUrl;
    AppConfig.userPoolId = userPoolId;
    AppConfig.region = region;
    _initialized = true;
  }

  /// Check if configuration has been initialized
  static bool get isInitialized => _initialized;

  // API Endpoints
  static String get authLoginUrl => '$apiBaseUrl/auth/login';
  static String get authSignupUrl => '$apiBaseUrl/auth/signup';
  static String get authMeUrl => '$apiBaseUrl/auth/me';
  static String get subscriptionsUrl => '$apiBaseUrl/subscriptions';

  // Helper method to get subscription by ID
  static String subscriptionByIdUrl(String id) => '$subscriptionsUrl/$id';
}