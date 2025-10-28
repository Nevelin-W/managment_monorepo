import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subscription_provider.dart';
import '../../widgets/add_subscription_dialog.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  void _showAddSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddSubscriptionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Subscriptions'),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.subscriptions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No subscriptions yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking your subscriptions by adding one',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddSubscriptionDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Subscription'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.subscriptions.length,
            itemBuilder: (context, index) {
              final sub = provider.subscriptions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    child: Icon(
                      Icons.subscriptions,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                  ),
                  title: Text(
                    sub.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        'Next billing: ${sub.nextBillingDate.day}/${sub.nextBillingDate.month}/${sub.nextBillingDate.year}',
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub.billingCycle.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${sub.amount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: sub.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          sub.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sub.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSubscriptionDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}