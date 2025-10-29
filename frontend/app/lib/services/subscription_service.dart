import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../models/subscription_model.dart';
import '../config/app_config.dart';

class SubscriptionService {
  final storage = const FlutterSecureStorage();
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<List<Subscription>> getSubscriptions() async {
    logger.d('GET SUBSCRIPTIONS SERVICE');
    final token = await _getToken();
    logger.d('Token exists: ${token != null}');
    logger.d('URL: ${AppConfig.subscriptionsUrl}');
    
    try {
      final response = await http.get(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        logger.i('Subscriptions count: ${data.length}');
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else {
        logger.e('Failed to load subscriptions - Status: ${response.statusCode}');
        throw Exception('Failed to load subscriptions: ${response.body}');
      }
    } catch (e) {
      logger.e('Error in getSubscriptions', error: e);
      throw Exception('Error fetching subscriptions: $e');
    }
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    logger.d('CREATE SUBSCRIPTION SERVICE');
    final token = await _getToken();
    logger.d('Token exists: ${token != null}');
    logger.d('Token (first 20 chars): ${token?.substring(0, 20)}...');
    logger.d('URL: ${AppConfig.subscriptionsUrl}');
    
    final subscriptionJson = subscription.toJson();
    // Remove the id field since backend generates it
    subscriptionJson.remove('id');
    
    logger.d('Subscription data to send: ${jsonEncode(subscriptionJson)}');
    
    try {
      logger.d('Making POST request...');
      final response = await http.post(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscriptionJson),
      );

      logger.d('Response status code: ${response.statusCode}');
      logger.d('Response headers: ${response.headers}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        logger.i('Subscription created successfully!');
        final responseData = jsonDecode(response.body);
        logger.d('Parsed response data: $responseData');
        return Subscription.fromJson(responseData);
      } else {
        logger.e('Failed to create subscription');
        logger.e('Status: ${response.statusCode}');
        logger.e('Body: ${response.body}');
        throw Exception('Failed to create subscription: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      logger.e('Exception in createSubscription', error: e);
      logger.d('Exception type: ${e.runtimeType}');
      if (e is http.ClientException) {
        logger.e('HTTP Client Exception: ${e.message}');
      }
      throw Exception('Error creating subscription: $e');
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    logger.d('UPDATE SUBSCRIPTION SERVICE');
    final token = await _getToken();
    logger.d('Token exists: ${token != null}');
    logger.d('URL: ${AppConfig.subscriptionByIdUrl(subscription.id)}');
    logger.d('Subscription data: ${jsonEncode(subscription.toJson())}');
    
    try {
      final response = await http.put(
        Uri.parse(AppConfig.subscriptionByIdUrl(subscription.id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscription.toJson()),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update subscription: ${response.body}');
      }
    } catch (e) {
      logger.e('Error in updateSubscription', error: e);
      throw Exception('Error updating subscription: $e');
    }
  }

  Future<void> deleteSubscription(String id) async {
    logger.d('DELETE SUBSCRIPTION SERVICE');
    final token = await _getToken();
    logger.d('Token exists: ${token != null}');
    logger.d('URL: ${AppConfig.subscriptionByIdUrl(id)}');
    
    try {
      final response = await http.delete(
        Uri.parse(AppConfig.subscriptionByIdUrl(id)),
        headers: {'Authorization': 'Bearer $token'},
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete subscription: ${response.body}');
      }
    } catch (e) {
      logger.e('Error in deleteSubscription', error: e);
      throw Exception('Error deleting subscription: $e');
    }
  }
}