import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/theme.dart';
import 'package:go_router/go_router.dart';
import '../../../features/subscriptions/providers/subscription_provider.dart';
import '../../../features/home/providers/theme_provider.dart';
import '../../../features/subscriptions/widgets/add_subscription_dialog.dart';
import '../../../features/subscriptions/widgets/edit_subscription_dialog.dart';
import '../../../features/subscriptions/widgets/subscription_card.dart';
import '../../../features/subscriptions/widgets/empty_state.dart';
import '../../../core/widgets/common/screen_background.dart';
import '../../../core/widgets/common/confirmation_dialog.dart';
import '../../../core/widgets/common/app_snackbar.dart';
import '../../../features/subscriptions/models/subscription_model.dart';
import '../../../features/subscriptions/widgets/subscription_filter_bar.dart';

class SubscriptionsListScreen extends StatefulWidget {
  const SubscriptionsListScreen({super.key});

  @override
  State<SubscriptionsListScreen> createState() => _SubscriptionsListScreenState();
}

class _SubscriptionsListScreenState extends State<SubscriptionsListScreen> {
  String _selectedFilter = 'All';
  SortOption _selectedSort = SortOption.dateDesc;

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
    final confirmed = await ConfirmationDialog.show(
      context: context,
      themeColors: themeColors,
      title: 'Delete Subscription',
      message:
          'Are you sure you want to delete "${subscription.name}"? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed && mounted) {
      try {
        await context
            .read<SubscriptionProvider>()
            .deleteSubscription(subscription.id);

        if (mounted) {
          AppSnackBar.showSuccess(
            context,
            '${subscription.name} deleted successfully',
            themeColors: themeColors,
          );
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.showError(
            context,
            'Failed to delete subscription: $e',
          );
        }
      }
    }
  }

  List<Subscription> _getFilteredSubscriptions(
    List<Subscription> subscriptions,
  ) {
    List<Subscription> filtered;

    switch (_selectedFilter) {
      case 'Monthly':
        filtered = subscriptions
            .where((s) => s.billingCycle == BillingCycle.monthly)
            .toList();
        break;
      case 'Yearly':
        filtered = subscriptions
            .where((s) => s.billingCycle == BillingCycle.yearly)
            .toList();
        break;
      case 'Weekly':
        filtered = subscriptions
            .where((s) => s.billingCycle == BillingCycle.weekly)
            .toList();
        break;
      default:
        filtered = List.from(subscriptions);
    }

    return _sortSubscriptions(filtered);
  }

  List<Subscription> _sortSubscriptions(List<Subscription> subscriptions) {
    final sorted = List<Subscription>.from(subscriptions);

    switch (_selectedSort) {
      case SortOption.nameAsc:
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
      case SortOption.nameDesc:
        sorted.sort(
          (a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
        );
        break;
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.dateAsc:
        sorted.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
        break;
      case SortOption.dateDesc:
        sorted.sort((a, b) => b.nextBillingDate.compareTo(a.nextBillingDate));
        break;
    }

    return sorted;
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildSimpleAppBar(context, themeColors, 0),
                    Expanded(
                      child: EmptyStateWidget(
                        themeColors: themeColors,
                        onAddPressed: _showAddSubscriptionDialog,
                        isFullPage: true,
                        subtitle:
                            'Start tracking your subscriptions\nby adding one',
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
                  _buildSliverAppBar(themeColors, provider.subscriptions.length),
                  _buildFilterBar(themeColors),
                  _buildSubscriptionsList(
                    themeColors,
                    filteredSubscriptions,
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

  Widget _buildSimpleAppBar(
    BuildContext context,
    ThemeColors themeColors,
    int count,
  ) {
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

  Widget _buildSliverAppBar(ThemeColors themeColors, int count) {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: themeColors.background,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[400]),
          onPressed: () => context.go('/home'),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isCollapsed = constraints.maxHeight <= 100;
            return AnimatedOpacity(
              opacity: isCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Text(
                'Subscriptions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        background: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 4),
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
        ),
      ),
    );
  }

  Widget _buildFilterBar(ThemeColors themeColors) {
    return SliverPersistentHeader(
      pinned: false,
      delegate: _FilterBarDelegate(
        themeColors: themeColors,
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) {
          setState(() => _selectedFilter = filter);
        },
        selectedSort: _selectedSort,
        onSortChanged: (sort) {
          setState(() => _selectedSort = sort);
        },
      ),
    );
  }

  Widget _buildSubscriptionsList(
    ThemeColors themeColors,
    List<Subscription> filteredSubscriptions,
  ) {
    if (filteredSubscriptions.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No subscriptions found for this filter',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final sub = filteredSubscriptions[index];
            return SubscriptionCard(
              key: ValueKey(sub.id),
              subscription: sub,
              themeColors: themeColors,
              isCompact: false,
              onEdit: () => _showEditSubscriptionDialog(sub),
              onDelete: () => _confirmDelete(sub),
            );
          },
          childCount: filteredSubscriptions.length,
        ),
      ),
    );
  }
}

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final ThemeColors themeColors;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final SortOption selectedSort;
  final Function(SortOption) onSortChanged;

  _FilterBarDelegate({
    required this.themeColors,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.selectedSort,
    required this.onSortChanged,
  });

  @override
  double get minExtent => 80.0;

  @override
  double get maxExtent => 80.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: themeColors.background,
      child: SubscriptionFilterBar(
        themeColors: themeColors,
        selectedFilter: selectedFilter,
        onFilterChanged: onFilterChanged,
        selectedSort: selectedSort,
        onSortChanged: onSortChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) {
    return selectedFilter != oldDelegate.selectedFilter ||
        selectedSort != oldDelegate.selectedSort;
  }
}