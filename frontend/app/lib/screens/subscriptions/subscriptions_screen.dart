import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/subscriptions/add_subscription_dialog.dart';
import '../../widgets/subscriptions/edit_subscription_dialog.dart';
import '../../widgets/common/subscription_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/app_filter_chip.dart';
import '../../widgets/common/screen_background.dart';
import '../../models/subscription_model.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  String _selectedFilter = 'All';

  void _showAddSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddSubscriptionDialog(),
    );
  }

  void _showEditSubscriptionDialog(Subscription subscription) {
    showDialog(
      context: context,
      builder: (context) => EditSubscriptionDialog(subscription: subscription),
    );
  }

  Future<void> _confirmDelete(Subscription subscription) async {
    if (!mounted) return;
    
    final themeColors = context.read<ThemeProvider>().themeColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Subscription',
            style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${subscription.name}"? This action cannot be undone.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context
            .read<SubscriptionProvider>()
            .deleteSubscription(subscription.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${subscription.name} deleted successfully'),
              backgroundColor: themeColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete subscription: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
  }

  List<Subscription> _getFilteredSubscriptions(List<Subscription> subscriptions) {
    switch (_selectedFilter) {
      case 'Monthly':
        return subscriptions
            .where((s) => s.billingCycle == BillingCycle.monthly)
            .toList();
      case 'Yearly':
        return subscriptions
            .where((s) => s.billingCycle == BillingCycle.yearly)
            .toList();
      case 'Weekly':  
        return subscriptions
            .where((s) => s.billingCycle == BillingCycle.weekly)
            .toList();
      default:
        return subscriptions;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use select to only rebuild when themeColors change
    final themeColors = context.select<ThemeProvider, ThemeColors>(
      (provider) => provider.themeColors,
    );

    return Scaffold(
      backgroundColor: themeColors.background,
      body: ScreenBackground(
        themeColors: themeColors,
        glowAlignment: Alignment.topLeft,
        child: SafeArea(
          child: Consumer<SubscriptionProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(themeColors.primary),
                  ),
                );
              }

              if (provider.subscriptions.isEmpty) {
                return Column(
                  children: [
                    _buildAppBar(context, themeColors, 0),
                    Expanded(
                      child: EmptyStateWidget(
                        themeColors: themeColors,
                        onAddPressed: _showAddSubscriptionDialog,
                        isFullPage: true,
                        subtitle: 'Start tracking your subscriptions\nby adding one',
                      ),
                    ),
                  ],
                );
              }

              final filteredSubscriptions = _getFilteredSubscriptions(
                provider.subscriptions,
              );

              return CustomScrollView(
                slivers: [
                  _SubscriptionsAppBar(
                    themeColors: themeColors,
                    totalCount: provider.subscriptions.length,
                  ),
                  _FilterSection(
                    themeColors: themeColors,
                    selectedFilter: _selectedFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                  ),
                  _OptimizedSubscriptionsList(
                    subscriptions: filteredSubscriptions,
                    themeColors: themeColors,
                    onEdit: _showEditSubscriptionDialog,
                    onDelete: _confirmDelete,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubscriptionDialog,
        backgroundColor: themeColors.primary,
        elevation: 8,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeColors themeColors, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[400]),
            onPressed: () => context.go('/home'),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All Subscriptions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                if (count > 0)
                  Text(
                    '$count active',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Extracted App Bar for better performance
class _SubscriptionsAppBar extends StatelessWidget {
  final ThemeColors themeColors;
  final int totalCount;

  const _SubscriptionsAppBar({
    required this.themeColors,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 170,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey[400]),
        onPressed: () => context.go('/home'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Subscriptions',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$totalCount active',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Extracted filter section
class _FilterSection extends StatelessWidget {
  final ThemeColors themeColors;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  const _FilterSection({
    required this.themeColors,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Row(
          children: [
            AppFilterChip(
              label: 'All',
              isSelected: selectedFilter == 'All',
              themeColors: themeColors,
              onTap: () => onFilterChanged('All'),
            ),
            const SizedBox(width: 8),
            AppFilterChip(
              label: 'Monthly',
              isSelected: selectedFilter == 'Monthly',
              themeColors: themeColors,
              onTap: () => onFilterChanged('Monthly'),
            ),
            const SizedBox(width: 8),
            AppFilterChip(
              label: 'Yearly',
              isSelected: selectedFilter == 'Yearly',
              themeColors: themeColors,
              onTap: () => onFilterChanged('Yearly'),
            ),
            AppFilterChip(
              label: 'Weekly',
              isSelected: selectedFilter == 'Weekly',
              themeColors: themeColors,
              onTap: () => onFilterChanged('Weekly'),
            ),
            const Spacer(),
            IconButton(
              icon: Icon(
                Icons.sort,
                color: themeColors.primary,
                size: 24,
              ),
              onPressed: () {
                // TODO: Implement sort functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Optimized subscriptions list with keys
class _OptimizedSubscriptionsList extends StatelessWidget {
  final List<Subscription> subscriptions;
  final ThemeColors themeColors;
  final void Function(Subscription) onEdit;
  final void Function(Subscription) onDelete;

  const _OptimizedSubscriptionsList({
    required this.subscriptions,
    required this.themeColors,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final sub = subscriptions[index];
            return SubscriptionCard(
              key: ValueKey(sub.id), // Key for efficient updates
              subscription: sub,
              themeColors: themeColors,
              isCompact: false,
              onEdit: () => onEdit(sub),
              onDelete: () => onDelete(sub),
            );
          },
          childCount: subscriptions.length,
        ),
      ),
    );
  }
}