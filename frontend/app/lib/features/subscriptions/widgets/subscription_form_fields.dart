import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/subscriptions/models/subscription_model.dart';

/// Utility class for subscription form fields
class SubscriptionFormFields {
  /// Format billing cycle for display
  static String formatBillingCycle(BillingCycle cycle) {
    final name = cycle.toString().split('.').last;
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Validator for subscription name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a subscription name';
    }
    return null;
  }

  /// Validator for amount
  static String? validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter an amount';
    }
    final amount = double.tryParse(value.trim());
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    return null;
  }

  /// Input formatter for amount field
  static List<TextInputFormatter> get amountFormatters => [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ];

  /// Build billing cycle dropdown items
  static List<DropdownMenuItem<BillingCycle>> buildBillingCycleItems(
    TextTheme textTheme,
  ) {
    return BillingCycle.values.map((cycle) {
      return DropdownMenuItem(
        value: cycle,
        child: Text(
          formatBillingCycle(cycle),
          style: textTheme.bodyLarge,
        ),
      );
    }).toList();
  }
}