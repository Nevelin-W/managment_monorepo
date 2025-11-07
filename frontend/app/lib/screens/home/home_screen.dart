import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/subscriptions/add_subscription_dialog.dart';
import '../../widgets/subscriptions/edit_subscription_dialog.dart';
import '../../widgets/common/subscription_card.dart';
import '../../widgets/common/stat_card.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/screen_background.dart';
import '../../models/subscription_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch subscriptions after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SubscriptionProvider>().fetchSubscriptions();
      }
    });
  }

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
        child: SafeArea(
          child: Consumer2<AuthProvider, SubscriptionProvider>(
            builder: (context, authProvider, subProvider, _) {
              if (subProvider.isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(themeColors.primary),
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  _HomeAppBar(
                    userName: authProvider.user?.name ?? "User",
                    themeColors: themeColors,
                  ),
                  _StatsSection(
                    themeColors: themeColors,
                    activeCount: subProvider.subscriptions.length,
                    monthlySpend: subProvider.totalMonthlySpend,
                  ),
                  _SubscriptionsHeader(
                    themeColors: themeColors,
                    hasSubscriptions: subProvider.subscriptions.isNotEmpty,
                  ),
                  if (subProvider.subscriptions.isEmpty)
                    SliverFillRemaining(
                      child: EmptyStateWidget(
                        themeColors: themeColors,
                        onAddPressed: _showAddSubscriptionDialog,
                      ),
                    )
                  else
                    _SubscriptionsList(
                      subscriptions: subProvider.subscriptions.take(3).toList(),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSubscriptionDialog,
        backgroundColor: themeColors.primary,
        elevation: 8,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Subscription',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// Extracted App Bar widget for better performance
class _HomeAppBar extends StatelessWidget {
  final String userName;
  final ThemeColors themeColors;

  const _HomeAppBar({
    required this.userName,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back,',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: Colors.grey[400]),
          onPressed: () => context.go('/home/settings'),
        ),
        IconButton(
          icon: Icon(Icons.logout, color: themeColors.primary),
          onPressed: () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              context.go('/login');
            }
          },
        ),
      ],
    );
  }
}

/// Extracted stats section for better performance
class _StatsSection extends StatelessWidget {
  final ThemeColors themeColors;
  final int activeCount;
  final double monthlySpend;

  const _StatsSection({
    required this.themeColors,
    required this.activeCount,
    required this.monthlySpend,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Active',
                value: activeCount.toString(),
                icon: Icons.subscriptions_outlined,
                themeColors: themeColors,
                gradientColors: [themeColors.primary, themeColors.secondary],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Monthly',
                value: '\$${monthlySpend.toStringAsFixed(0)}',
                icon: Icons.payments_outlined,
                themeColors: themeColors,
                gradientColors: [themeColors.secondary, themeColors.tertiary],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extracted header section
class _SubscriptionsHeader extends StatelessWidget {
  final ThemeColors themeColors;
  final bool hasSubscriptions;

  const _SubscriptionsHeader({
    required this.themeColors,
    required this.hasSubscriptions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Subscriptions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (hasSubscriptions)
              TextButton.icon(
                onPressed: () => context.go('/home/subscriptions'),
                icon: Icon(Icons.arrow_forward,
                    size: 16, color: themeColors.primary),
                label: Text(
                  'View All',
                  style: TextStyle(
                      color: themeColors.primary, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Extracted subscriptions list with keys for efficient updates
class _SubscriptionsList extends StatelessWidget {
  final List<Subscription> subscriptions;
  final ThemeColors themeColors;
  final void Function(Subscription) onEdit;
  final void Function(Subscription) onDelete;

  const _SubscriptionsList({
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
              isCompact: true,
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