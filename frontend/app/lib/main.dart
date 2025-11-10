import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/theme_provider.dart';
import 'config/app_config.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load configuration from build-time arguments
  loadConfig();
  
  // Initialize Logger
  AppLogger.initialize();
  
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
  
  const logLevelStr = String.fromEnvironment(
    'LOG_LEVEL',
    defaultValue: 'warning',
  );

  // Validate that all required values are provided
  if (apiBaseUrl.isEmpty || userPoolId.isEmpty || region.isEmpty) {
    throw Exception(
      'Missing required configuration. Please provide API_BASE_URL, USER_POOL_ID, and REGION as build arguments.\n'
      'Example: flutter run --dart-define=API_BASE_URL=https://... --dart-define=USER_POOL_ID=... --dart-define=REGION=... --dart-define=LOG_LEVEL=info'
    );
  }

  // Initialize AppConfig with parsed log level
  AppConfig.initialize(
    apiBaseUrl: apiBaseUrl,
    userPoolId: userPoolId,
    region: region,
    logLevel: LogLevel.fromString(logLevelStr),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, _) {
          // Initialize router with auth state
          AppRouter().initialize(
            isAuthenticated: () => authProvider.isAuthenticated,
            enableLogging: AppConfig.logLevel == LogLevel.debug,
          );
          
          return MaterialApp.router(
            title: 'Subscription Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: themeProvider.themeData,
            themeMode: ThemeMode.dark,
            routerConfig: AppRouter().router,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}