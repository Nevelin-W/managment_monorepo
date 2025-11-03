import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../utils/app_talker.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();
  late final TalkerScope talker;
  
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;

  SubscriptionProvider() {
    talker = AppTalker.createLogger('SubscriptionProvider');
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
    } catch (e, stackTrace) {
      talker.error('Failed to fetch subscriptions in provider', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      talker.error('Failed to add subscription in provider', error: e, stackTrace: stackTrace);
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
        talker.warning('Subscription not found in local state: ${subscription.id}');
      }
    } catch (e, stackTrace) {
      talker.error('Failed to update subscription in provider', error: e, stackTrace: stackTrace);
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
    } catch (e, stackTrace) {
      talker.error('Failed to delete subscription in provider', error: e, stackTrace: stackTrace);
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