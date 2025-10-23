enum BillingCycle { monthly, yearly, weekly }

class Subscription {
  final String id;
  final String name;
  final double amount;
  final BillingCycle billingCycle;
  final DateTime nextBillingDate;
  final String? category;
  final String? description;
  final bool isActive;

  Subscription({
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
      id: json['id'],
      name: json['name'],
      amount: json['amount'].toDouble(),
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.toString() == 'BillingCycle.${json['billing_cycle']}',
      ),
      nextBillingDate: DateTime.parse(json['next_billing_date']),
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
      'billing_cycle': billingCycle.toString().split('.').last,
      'next_billing_date': nextBillingDate.toIso8601String(),
      'category': category,
      'description': description,
      'is_active': isActive,
    };
  }
}