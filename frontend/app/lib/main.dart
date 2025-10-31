import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load configuration from build-time arguments
  loadConfig();
  
  // Configure global logging
  configureLogging();
  
  runApp(const MyApp());
}

void loadConfig() {
  // Read values from --dart-define arguments
  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  const userPoolId = String.fromEnvironment(
    'USER_POOL_ID',
    defaultValue: '',
  );
  const region = String.fromEnvironment(
    'REGION',
    defaultValue: '',
  );
  
  const enableLogging = String.fromEnvironment(
    'ENABLE_LOGGING',
    defaultValue: 'false',
  );

  // Validate that all required values are provided
  if (apiBaseUrl.isEmpty || userPoolId.isEmpty || region.isEmpty) {
    throw Exception(
      'Missing required configuration. Please provide API_BASE_URL, USER_POOL_ID, and REGION as build arguments.\n'
      'Example: flutter run --dart-define=API_BASE_URL=https://... --dart-define=USER_POOL_ID=... --dart-define=REGION=...'
    );
  }

  // Initialize AppConfig
  AppConfig.initialize(
    apiBaseUrl: apiBaseUrl,
    userPoolId: userPoolId,
    region: region,
    enableLogging: enableLogging == 'true',
  );
}

void configureLogging() {
  if (kIsWeb && AppConfig.enableLogging) {
    // For web, we need to ensure logs go to console
    Logger.level = Level.debug;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp.router(
            title: 'Subscription Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}