import '../models/subscription_model.dart';

/// Enum for available subscription filters
enum SubscriptionFilter {
  all,
  monthly,
  yearly,
  weekly,
  active,
  inactive,
}

/// Extension methods for filtering subscriptions
extension SubscriptionFilterExtension on SubscriptionFilter {
  String get label {
    switch (this) {
      case SubscriptionFilter.all:
        return 'All';
      case SubscriptionFilter.monthly:
        return 'Monthly';
      case SubscriptionFilter.yearly:
        return 'Yearly';
      case SubscriptionFilter.weekly:
        return 'Weekly';
      case SubscriptionFilter.active:
        return 'Active';
      case SubscriptionFilter.inactive:
        return 'Inactive';
    }
  }

  List<Subscription> apply(List<Subscription> subscriptions) {
    switch (this) {
      case SubscriptionFilter.all:
        return subscriptions;
      case SubscriptionFilter.monthly:
        return subscriptions
            .where((s) => s.billingCycle == BillingCycle.monthly)
            .toList();
      case SubscriptionFilter.yearly:
        return subscriptions
            .where((s) => s.billingCycle == BillingCycle.yearly)
            .toList();
      case SubscriptionFilter.weekly:
        return subscriptions
            .where((s) => s.billingCycle == BillingCycle.weekly)
            .toList();
      case SubscriptionFilter.active:
        return subscriptions.where((s) => s.isActive).toList();
      case SubscriptionFilter.inactive:
        return subscriptions.where((s) => !s.isActive).toList();
    }
  }
}

/// Enum for sorting options
enum SubscriptionSort {
  nameAsc,
  nameDesc,
  amountAsc,
  amountDesc,
  dateAsc,
  dateDesc,
}

/// Extension methods for sorting subscriptions
extension SubscriptionSortExtension on SubscriptionSort {
  String get label {
    switch (this) {
      case SubscriptionSort.nameAsc:
        return 'Name (A-Z)';
      case SubscriptionSort.nameDesc:
        return 'Name (Z-A)';
      case SubscriptionSort.amountAsc:
        return 'Amount (Low to High)';
      case SubscriptionSort.amountDesc:
        return 'Amount (High to Low)';
      case SubscriptionSort.dateAsc:
        return 'Date (Oldest First)';
      case SubscriptionSort.dateDesc:
        return 'Date (Newest First)';
    }
  }

  List<Subscription> apply(List<Subscription> subscriptions) {
    final sortedList = List<Subscription>.from(subscriptions);
    
    switch (this) {
      case SubscriptionSort.nameAsc:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SubscriptionSort.nameDesc:
        sortedList.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SubscriptionSort.amountAsc:
        sortedList.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SubscriptionSort.amountDesc:
        sortedList.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SubscriptionSort.dateAsc:
        sortedList.sort((a, b) =>
            a.nextBillingDate.compareTo(b.nextBillingDate));
        break;
      case SubscriptionSort.dateDesc:
        sortedList.sort((a, b) =>
            b.nextBillingDate.compareTo(a.nextBillingDate));
        break;
    }
    
    return sortedList;
  }
}

/// Utility class for subscription operations
class SubscriptionUtils {
  /// Calculate total monthly cost (normalizing all billing cycles)
  static double calculateMonthlyTotal(List<Subscription> subscriptions) {
    return subscriptions.fold(0.0, (sum, sub) {
      switch (sub.billingCycle) {
        case BillingCycle.monthly:
          return sum + sub.amount;
        case BillingCycle.yearly:
          return sum + (sub.amount / 12);
        case BillingCycle.weekly:
          return sum + (sub.amount * 4.33); // Average weeks per month
      }
    });
  }

  /// Calculate total yearly cost
  static double calculateYearlyTotal(List<Subscription> subscriptions) {
    return subscriptions.fold(0.0, (sum, sub) {
      switch (sub.billingCycle) {
        case BillingCycle.monthly:
          return sum + (sub.amount * 12);
        case BillingCycle.yearly:
          return sum + sub.amount;
        case BillingCycle.weekly:
          return sum + (sub.amount * 52);
      }
    });
  }

  /// Get subscriptions by category
  static Map<String, List<Subscription>> groupByCategory(
    List<Subscription> subscriptions,
  ) {
    final Map<String, List<Subscription>> grouped = {};
    
    for (final sub in subscriptions) {
      final category = sub.category ?? 'Uncategorized';
      grouped.putIfAbsent(category, () => []).add(sub);
    }
    
    return grouped;
  }

  /// Get upcoming subscriptions (within next 7 days)
  static List<Subscription> getUpcoming(List<Subscription> subscriptions) {
    final now = DateTime.now();
    final weekFromNow = now.add(const Duration(days: 7));
    
    return subscriptions.where((sub) {
      final billingDate = sub.nextBillingDate;
      return billingDate.isAfter(now) && billingDate.isBefore(weekFromNow);
    }).toList();
  }

  /// Search subscriptions by name or category
  static List<Subscription> search(
    List<Subscription> subscriptions,
    String query,
  ) {
    if (query.isEmpty) return subscriptions;
    
    final lowerQuery = query.toLowerCase();
    return subscriptions.where((sub) {
      final matchesName = sub.name.toLowerCase().contains(lowerQuery);
      final matchesCategory =
          sub.category?.toLowerCase().contains(lowerQuery) ?? false;
      return matchesName || matchesCategory;
    }).toList();
  }
}