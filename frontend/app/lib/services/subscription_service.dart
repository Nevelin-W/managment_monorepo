import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/subscription_model.dart';

class SubscriptionService {
  static const String baseUrl = 'https://your-api-endpoint.com/api';
  final storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<List<Subscription>> getSubscriptions() async {
    final token = await _getToken();
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscriptions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load subscriptions');
      }
    } catch (e) {
      throw Exception('Error fetching subscriptions: $e');
    }
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    final token = await _getToken();
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/subscriptions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscription.toJson()),
      );

      if (response.statusCode == 201) {
        return Subscription.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create subscription');
      }
    } catch (e) {
      throw Exception('Error creating subscription: $e');
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    final token = await _getToken();
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/subscriptions/${subscription.id}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(subscription.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update subscription');
      }
    } catch (e) {
      throw Exception('Error updating subscription: $e');
    }
  }

  Future<void> deleteSubscription(String id) async {
    final token = await _getToken();
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/subscriptions/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete subscription');
      }
    } catch (e) {
      throw Exception('Error deleting subscription: $e');
    }
  }
}