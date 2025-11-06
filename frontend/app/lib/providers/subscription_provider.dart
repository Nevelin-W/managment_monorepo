import 'package:flutter/foundation.dart';
import '../models/subscription_model.dart';
import '../services/subscription_service.dart';
import '../utils/app_logger.dart';

class SubscriptionProvider with ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();
  late final LoggerScope _log;

  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _error;

  SubscriptionProvider() {
    _log = AppLogger.scope('SubscriptionProvider');
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

    _log.debug('Fetching subscriptions from provider');

    try {
      _subscriptions = await _service.getSubscriptions();
      _log.info('Fetched subscriptions successfully', {'count': _subscriptions.length});
      _error = null;
    } catch (e, stackTrace) {
      _log.error('Failed to fetch subscriptions in provider', error: e, stackTrace: stackTrace);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addSubscription(Subscription subscription) async {
    _error = null;
    _log.info('Adding new subscription', {'name': subscription.name});

    try {
      final newSub = await _service.createSubscription(subscription);
      _subscriptions.add(newSub);
      notifyListeners();

      // Ensure state sync with server
      await fetchSubscriptions();
      _log.info('Subscription added successfully', {'id': newSub.id});
    } catch (e, stackTrace) {
      _log.error('Failed to add subscription in provider', error: e, stackTrace: stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateSubscription(Subscription subscription) async {
    _error = null;
    _log.info('Updating subscription', {'id': subscription.id, 'name': subscription.name});

    try {
      await _service.updateSubscription(subscription);
      final index = _subscriptions.indexWhere((s) => s.id == subscription.id);
      if (index != -1) {
        _subscriptions[index] = subscription;
        _log.debug('Local state updated for subscription', {'id': subscription.id});
        notifyListeners();
      } else {
        _log.warning('Subscription not found in local list', {'id': subscription.id});
      }
    } catch (e, stackTrace) {
      _log.error('Failed to update subscription in provider', error: e, stackTrace: stackTrace);
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteSubscription(String id) async {
    _error = null;
    _log.info('Deleting subscription', {'id': id});

    try {
      await _service.deleteSubscription(id);
      _subscriptions.removeWhere((s) => s.id == id);
      _log.info('Subscription deleted successfully', {'id': id});
      notifyListeners();
    } catch (e, stackTrace) {
      _log.error('Failed to delete subscription in provider', error: e, stackTrace: stackTrace);
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