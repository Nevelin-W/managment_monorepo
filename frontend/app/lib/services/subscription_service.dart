import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/subscription_model.dart';
import '../config/app_config.dart';
import '../utils/app_talker.dart';

class SubscriptionService {
  final _secureStorage = const FlutterSecureStorage();
  late final TalkerScope talker;

  SubscriptionService() {
    talker = AppTalker.createLogger('SubscriptionService');
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
    talker.debug('Fetching subscriptions');
    
    final token = await _getToken();
    if (token == null) {
      talker.error('No authentication token available');
      throw Exception('Authentication required');
    }
    
    // Log sanitized token for debugging
    if (kDebugMode && AppConfig.enableLogging) {
      talker.debug('Using token: ${AppTalker.sanitizeToken(token)}');
    }
    
    try {
      final response = await http.get(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      talker.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        talker.info('Retrieved ${data.length} subscription(s)');
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else {
        talker.warning('Failed to fetch subscriptions: ${response.statusCode}');
        if (kDebugMode && AppConfig.enableLogging) {
          talker.debug('Response body: ${AppTalker.sanitizeResponse(response.body)}');
        }
        throw Exception('Failed to load subscriptions');
      }
    } catch (e, stackTrace) {
      talker.error('Error fetching subscriptions', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    talker.info('Creating subscription: ${subscription.name}');
    
    final token = await _getToken();
    if (token == null) {
      talker.error('No authentication token available');
      throw Exception('Authentication required');
    }
    
    final subscriptionJson = subscription.toJson();
    subscriptionJson.remove('id');
    
    if (kDebugMode && AppConfig.enableLogging) {
      talker.debug('Subscription data: ${jsonEncode(subscriptionJson)}');
    }
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscriptionJson),
      );

      talker.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        talker.info('Subscription created successfully');
        return Subscription.fromJson(jsonDecode(response.body));
      } else {
        talker.warning('Failed to create subscription: ${response.statusCode}');
        if (kDebugMode && AppConfig.enableLogging) {
          talker.debug('Response body: ${AppTalker.sanitizeResponse(response.body)}');
        }
        throw Exception('Failed to create subscription');
      }
    } catch (e, stackTrace) {
      talker.error('Error creating subscription', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    talker.info('Updating subscription: ${subscription.name}');
    
    final token = await _getToken();
    if (token == null) {
      talker.error('No authentication token available');
      throw Exception('Authentication required');
    }
    
    if (kDebugMode && AppConfig.enableLogging) {
      talker.debug('Subscription data: ${jsonEncode(subscription.toJson())}');
    }
    
    try {
      final response = await http.put(
        Uri.parse(AppConfig.subscriptionByIdUrl(subscription.id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscription.toJson()),
      );

      talker.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        talker.info('Subscription updated successfully');
      } else {
        talker.warning('Failed to update subscription: ${response.statusCode}');
        if (kDebugMode && AppConfig.enableLogging) {
          talker.debug('Response body: ${AppTalker.sanitizeResponse(response.body)}');
        }
        throw Exception('Failed to update subscription');
      }
    } catch (e, stackTrace) {
      talker.error('Error updating subscription', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    talker.info('Deleting subscription: $id');
    
    final token = await _getToken();
    if (token == null) {
      talker.error('No authentication token available');
      throw Exception('Authentication required');
    }
    
    try {
      final response = await http.delete(
        Uri.parse(AppConfig.subscriptionByIdUrl(id)),
        headers: {'Authorization': 'Bearer $token'},
      );

      talker.debug('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        talker.info('Subscription deleted successfully');
      } else {
        talker.warning('Failed to delete subscription: ${response.statusCode}');
        if (kDebugMode && AppConfig.enableLogging) {
          talker.debug('Response body: ${AppTalker.sanitizeResponse(response.body)}');
        }
        throw Exception('Failed to delete subscription');
      }
    } catch (e, stackTrace) {
      talker.error('Error deleting subscription', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}