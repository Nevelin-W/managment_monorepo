enum BillingCycle { monthly, yearly, weekly }

extension BillingCycleExtension on BillingCycle {
  String get value => name; // 'monthly', 'yearly', 'weekly'

  static BillingCycle fromString(String value) {
    switch (value.toLowerCase()) {
      case 'monthly':
        return BillingCycle.monthly;
      case 'yearly':
        return BillingCycle.yearly;
      case 'weekly':
        return BillingCycle.weekly;
      default:
        return BillingCycle.monthly;
    }
  }
}

class Subscription {
  final String id;
  final String name;
  final double amount;
  final BillingCycle billingCycle;
  final DateTime nextBillingDate;
  final String? category;
  final String? description;
  final bool isActive;

  const Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.billingCycle,
    required this.nextBillingDate,
    this.category,
    this.description,
    this.isActive = true,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      billingCycle: BillingCycleExtension.fromString(json['billing_cycle'] ?? 'monthly'),
      nextBillingDate: DateTime.tryParse(json['next_billing_date'] ?? '') ?? DateTime.now(),
      category: json['category'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'billing_cycle': billingCycle.value,
      'next_billing_date': nextBillingDate.toIso8601String(),
      'category': category,
      'description': description,
      'is_active': isActive,
    };
  }

  Subscription copyWith({
    String? id,
    String? name,
    double? amount,
    BillingCycle? billingCycle,
    DateTime? nextBillingDate,
    String? category,
    String? description,
    bool? isActive,
  }) {
    return Subscription(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      category: category ?? this.category,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscription && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}