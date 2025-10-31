import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/subscription_model.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

class SubscriptionService {
  final _secureStorage = const FlutterSecureStorage();
  late final Logger logger;

  SubscriptionService() {
    logger = AppLogger.createLogger('SubscriptionService');
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } else {
      return await _secureStorage.read(key: 'auth_token');
    }
  }

  Future<List<Subscription>> getSubscriptions() async {
    logger.d('Fetching subscriptions');
    
    final token = await _getToken();
    if (token == null) {
      logger.e('No authentication token available');
      throw Exception('Authentication required');
    }
    
    // Log sanitized token for debugging
    if (kDebugMode && AppConfig.enableLogging) {
      logger.d('Using token: ${AppLogger.sanitizeToken(token)}');
    }
    
    try {
      final response = await http.get(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {'Authorization': 'Bearer $token'}, // Use real token here
      );

      logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        logger.i('Retrieved ${data.length} subscription(s)');
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else {
        logger.w('Failed to fetch subscriptions: ${response.statusCode}');
        if (kDebugMode && AppConfig.enableLogging) {
          logger.d('Response body: ${AppLogger.sanitizeResponse(response.body)}');
        }
        throw Exception('Failed to load subscriptions');
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching subscriptions', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    logger.i('Creating subscription: ${subscription.name}');
    
    final token = await _getToken();
    if (token == null) {
      logger.e('No authentication token available');
      throw Exception('Authentication required');
    }
    
    final subscriptionJson = subscription.toJson();
    subscriptionJson.remove('id');
    
    if (kDebugMode && AppConfig.enableLogging) {
      logger.d('Subscription data: ${jsonEncode(subscriptionJson)}');
    }
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {
          'Authorization': 'Bearer $token', // Use real token here
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscriptionJson),
      );

      logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        logger.i('Subscription created successfully');
        return Subscription.fromJson(jsonDecode(response.body));
      } else {
        logger.w('Failed to create subscription: ${response.statusCode}');
        if (kDebugMode && AppConfig.enableLogging) {
          logger.d('Response body: ${AppLogger.sanitizeResponse(response.body)}');
        }
        throw Exception('Failed to create subscription');
      }
    } catch (e, stackTrace) {
      logger.e('Error creating subscription', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    logger.i('Updating subscription: ${subscription.name}');
    
    final token = await _getToken();
    if (token == null) {
      logger.e('No authentication token available');
      throw Exception('Authentication required');
    }
    
    if (kDebugMode && AppConfig.enableLogging) {
      logger.d('Subscription data: ${jsonEncode(subscription.toJson())}');
    }
    
    try {
      final response = await http.put(
        Uri.parse(AppConfig.subscriptionByIdUrl(subscription.id)),
        headers: {
          'Authorization': 'Bearer $token', // Use real token here
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscription.toJson()),
      );

      logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        logger.i('Subscription updated successfully');
      } else {
        logger.w('Failed to update subscription: ${response.statusCode}');
        if (kDebugMode && AppConfig.enableLogging) {
          logger.d('Response body: ${AppLogger.sanitizeResponse(response.body)}');
        }
        throw Exception('Failed to update subscription');
      }
    } catch (e, stackTrace) {
      logger.e('Error updating subscription', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    logger.i('Deleting subscription: $id');
    
    final token = await _getToken();
    if (token == null) {
      logger.e('No authentication token available');
      throw Exception('Authentication required');
    }
    
    try {
      final response = await http.delete(
        Uri.parse(AppConfig.subscriptionByIdUrl(id)),
        headers: {'Authorization': 'Bearer $token'}, // Use real token here
      );

      logger.d('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        logger.i('Subscription deleted successfully');
      } else {
        logger.w('Failed to delete subscription: ${response.statusCode}');
        if (kDebugMode && AppConfig.enableLogging) {
          logger.d('Response body: ${AppLogger.sanitizeResponse(response.body)}');
        }
        throw Exception('Failed to delete subscription');
      }
    } catch (e, stackTrace) {
      logger.e('Error deleting subscription', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}