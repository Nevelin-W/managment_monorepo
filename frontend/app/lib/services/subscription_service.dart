import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription_model.dart';
import '../config/app_config.dart';
import '../utils/app_logger.dart';

class SubscriptionService {
  final _secureStorage = const FlutterSecureStorage();
  late final LoggerScope _log;

  SubscriptionService() {
    _log = AppLogger.scope('SubscriptionService');
  }

  Future<String?> _readToken(String key) async {
    try {
      String? token;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        token = prefs.getString(key);
      } else {
        token = await _secureStorage.read(key: key);
      }
      _log.debug('Token read', {'key': key, 'present': token != null});
      return token;
    } catch (e, stackTrace) {
      _log.error('Failed to read token', error: e, stackTrace: stackTrace, context: {'key': key});
      return null;
    }
  }

  Future<List<Subscription>> getSubscriptions() async {
    _log.debug('Fetching subscriptions');
    final token = await _readToken('auth_token');

    if (token == null) {
      _log.warning('No authentication token available');
      throw Exception('Authentication required');
    }

    try {
      final response = await http.get(
        Uri.parse(AppConfig.subscriptionsUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      _log.debug('Response received', {'statusCode': response.statusCode});

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _log.info('Retrieved subscriptions', {'count': data.length});
        return data.map((json) => Subscription.fromJson(json)).toList();
      } else {
        _log.warning('Failed to fetch subscriptions', {'statusCode': response.statusCode});
        if (kDebugMode && AppConfig.logLevel == LogLevel.debug) {
          _log.debug('Response body: ${response.body}');
        }
        throw Exception('Failed to load subscriptions');
      }
    } catch (e, stackTrace) {
      _log.error('Error fetching subscriptions', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<Subscription> createSubscription(Subscription subscription) async {
    _log.info('Creating subscription', {'name': subscription.name});

    final token = await _readToken('auth_token');
    if (token == null) {
      _log.warning('No authentication token available');
      throw Exception('Authentication required');
    }

    final subscriptionJson = subscription.toJson()..remove('id');
    if (kDebugMode && AppConfig.logLevel == LogLevel.debug) {
      _log.debug('Subscription payload', {'data': subscriptionJson});
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

      _log.debug('Response received', {'statusCode': response.statusCode});

      if (response.statusCode == 201 || response.statusCode == 200) {
        _log.info('Subscription created successfully');
        return Subscription.fromJson(jsonDecode(response.body));
      } else {
        _log.warning('Failed to create subscription', {'statusCode': response.statusCode});
        if (kDebugMode && AppConfig.logLevel == LogLevel.debug) {
          _log.debug('Response body: ${response.body}');
        }
        throw Exception('Failed to create subscription');
      }
    } catch (e, stackTrace) {
      _log.error('Error creating subscription', error: e, stackTrace: stackTrace, context: {'name': subscription.name});
      rethrow;
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    _log.info('Updating subscription', {'id': subscription.id, 'name': subscription.name});

    final token = await _readToken('auth_token');
    if (token == null) {
      _log.warning('No authentication token available');
      throw Exception('Authentication required');
    }

    if (kDebugMode && AppConfig.logLevel == LogLevel.debug) {
      _log.debug('Subscription update payload', {'data': subscription.toJson()});
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

      _log.debug('Response received', {'statusCode': response.statusCode});

      if (response.statusCode == 200) {
        _log.info('Subscription updated successfully');
      } else {
        _log.warning('Failed to update subscription', {'statusCode': response.statusCode});
        if (kDebugMode && AppConfig.logLevel == LogLevel.debug) {
          _log.debug('Response body: ${response.body}');
        }
        throw Exception('Failed to update subscription');
      }
    } catch (e, stackTrace) {
      _log.error('Error updating subscription', error: e, stackTrace: stackTrace, context: {'id': subscription.id});
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    _log.info('Deleting subscription', {'id': id});

    final token = await _readToken('auth_token');
    if (token == null) {
      _log.warning('No authentication token available');
      throw Exception('Authentication required');
    }

    try {
      final response = await http.delete(
        Uri.parse(AppConfig.subscriptionByIdUrl(id)),
        headers: {'Authorization': 'Bearer $token'},
      );

      _log.debug('Response received', {'statusCode': response.statusCode});

      if (response.statusCode == 200) {
        _log.info('Subscription deleted successfully', {'id': id});
      } else {
        _log.warning('Failed to delete subscription', {'statusCode': response.statusCode});
        if (kDebugMode && AppConfig.logLevel == LogLevel.debug) {
          _log.debug('Response body: ${response.body}');
        }
        throw Exception('Failed to delete subscription');
      }
    } catch (e, stackTrace) {
      _log.error('Error deleting subscription', error: e, stackTrace: stackTrace, context: {'id': id});
      rethrow;
    }
  }
}