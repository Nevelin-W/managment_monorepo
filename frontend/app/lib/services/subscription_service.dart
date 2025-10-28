import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/subscription_model.dart';
import '../config/app_config.dart';

class SubscriptionService {
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<List<Subscription>> getSubscriptions() async {
    print('=== GET SUBSCRIPTIONS SERVICE ===');
    final token = await _getToken();
    print('Token exists: ${token != null}');
    print('URL: ${AppConfig.subscriptionsUrl}');
    
    try {
      final response = await http.get(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Subscriptions count: ${data.length}');
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else {
        print('Failed to load subscriptions - Status: ${response.statusCode}');
        throw Exception('Failed to load subscriptions: ${response.body}');
      }
    } catch (e) {
      print('Error in getSubscriptions: $e');
      throw Exception('Error fetching subscriptions: $e');
    }
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    print('=== CREATE SUBSCRIPTION SERVICE ===');
    final token = await _getToken();
    print('Token exists: ${token != null}');
    print('Token (first 20 chars): ${token?.substring(0, 20)}...');
    print('URL: ${AppConfig.subscriptionsUrl}');
    
    final subscriptionJson = subscription.toJson();
    // Remove the id field since backend generates it
    subscriptionJson.remove('id');
    
    print('Subscription data to send: ${jsonEncode(subscriptionJson)}');
    
    try {
      print('Making POST request...');
      final response = await http.post(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscriptionJson),
      );

      print('Response status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Subscription created successfully!');
        final responseData = jsonDecode(response.body);
        print('Parsed response data: $responseData');
        return Subscription.fromJson(responseData);
      } else {
        print('Failed to create subscription');
        print('Status: ${response.statusCode}');
        print('Body: ${response.body}');
        throw Exception('Failed to create subscription: Status ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Exception in createSubscription: $e');
      print('Exception type: ${e.runtimeType}');
      if (e is http.ClientException) {
        print('HTTP Client Exception: ${e.message}');
      }
      throw Exception('Error creating subscription: $e');
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    print('=== UPDATE SUBSCRIPTION SERVICE ===');
    final token = await _getToken();
    print('Token exists: ${token != null}');
    print('URL: ${AppConfig.subscriptionByIdUrl(subscription.id)}');
    print('Subscription data: ${jsonEncode(subscription.toJson())}');
    
    try {
      final response = await http.put(
        Uri.parse(AppConfig.subscriptionByIdUrl(subscription.id)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscription.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update subscription: ${response.body}');
      }
    } catch (e) {
      print('Error in updateSubscription: $e');
      throw Exception('Error updating subscription: $e');
    }
  }

  Future<void> deleteSubscription(String id) async {
    print('=== DELETE SUBSCRIPTION SERVICE ===');
    final token = await _getToken();
    print('Token exists: ${token != null}');
    print('URL: ${AppConfig.subscriptionByIdUrl(id)}');
    
    try {
      final response = await http.delete(
        Uri.parse(AppConfig.subscriptionByIdUrl(id)),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete subscription: ${response.body}');
      }
    } catch (e) {
      print('Error in deleteSubscription: $e');
      throw Exception('Error deleting subscription: $e');
    }
  }
}