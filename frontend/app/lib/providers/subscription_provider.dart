import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();
  
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get totalMonthlySpend {
    return _subscriptions
        .where((s) => s.billingCycle == BillingCycle.monthly)
        .fold(0, (sum, sub) => sum + sub.amount);
  }

  Future<void> fetchSubscriptions() async {
    print('=== FETCH SUBSCRIPTIONS PROVIDER ===');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('Calling service.getSubscriptions()...');
      _subscriptions = await _service.getSubscriptions();
      print('Fetched ${_subscriptions.length} subscriptions');
      _error = null;
    } catch (e) {
      print('Error in fetchSubscriptions: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
      print('fetchSubscriptions completed. Error: $_error');
    }
  }

  Future<void> addSubscription(Subscription subscription) async {
    print('=== ADD SUBSCRIPTION PROVIDER ===');
    print('Subscription to add: ${subscription.toJson()}');
    _error = null;
    
    try {
      print('Calling service.createSubscription()...');
      final newSub = await _service.createSubscription(subscription);
      print('Service returned new subscription: ${newSub.toJson()}');
      
      _subscriptions.add(newSub);
      print('Added to local list. Total subscriptions: ${_subscriptions.length}');
      
      notifyListeners();
      print('notifyListeners() called');
      
      // Fetch fresh data to ensure sync
      print('Fetching fresh subscription list...');
      await fetchSubscriptions();
      
    } catch (e) {
      print('Error in addSubscription provider: $e');
      print('Error type: ${e.runtimeType}');
      _error = e.toString();
      notifyListeners();
      rethrow; // Re-throw so the UI can handle it
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    print('=== UPDATE SUBSCRIPTION PROVIDER ===');
    print('Subscription to update: ${subscription.toJson()}');
    _error = null;
    
    try {
      await _service.updateSubscription(subscription);
      final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
      if (index != -1) {
        _subscriptions[index] = subscription;
        print('Updated subscription at index $index');
        notifyListeners();
      } else {
        print('Warning: Subscription with id ${subscription.id} not found in local list');
      }
    } catch (e) {
      print('Error in updateSubscription: $e');
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    print('=== DELETE SUBSCRIPTION PROVIDER ===');
    print('Subscription ID to delete: $id');
    _error = null;
    
    try {
      await _service.deleteSubscription(id);
      _subscriptions.removeWhere((s) => s.id == id);
      print('Removed subscription. Remaining: ${_subscriptions.length}');
      notifyListeners();
    } catch (e) {
      print('Error in deleteSubscription: $e');
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