import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../utils/app_logger.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();
  late final Logger logger;
  
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;

  SubscriptionProvider() {
    logger = AppLogger.createLogger('SubscriptionProvider');
  }

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get totalMonthlySpend {
    return _subscriptions
        .where((s) => s.billingCycle == BillingCycle.monthly)
        .fold(0, (sum, sub) => sum + sub.amount);
  }

  Future<void> fetchSubscriptions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _subscriptions = await _service.getSubscriptions();
      _error = null;
    } catch (e) {
      logger.e('Failed to fetch subscriptions in provider', error: e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSubscription(Subscription subscription) async {
    _error = null;
    
    try {
      final newSub = await _service.createSubscription(subscription);
      _subscriptions.add(newSub);
      notifyListeners();
      
      // Fetch fresh data to ensure sync
      await fetchSubscriptions();
    } catch (e) {
      logger.e('Failed to add subscription in provider', error: e);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    _error = null;
    
    try {
      await _service.updateSubscription(subscription);
      final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
      if (index != -1) {
        _subscriptions[index] = subscription;
        notifyListeners();
      } else {
        logger.w('Subscription not found in local state: ${subscription.id}');
      }
    } catch (e) {
      logger.e('Failed to update subscription in provider', error: e);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    _error = null;
    
    try {
      await _service.deleteSubscription(id);
      _subscriptions.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      logger.e('Failed to delete subscription in provider', error: e);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}