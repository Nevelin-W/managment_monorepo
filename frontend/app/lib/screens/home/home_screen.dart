import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/subscriptions/add_subscription_dialog.dart';
import '../../widgets/subscriptions/edit_subscription_dialog.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/subscription_card.dart';
import '../../widgets/common/screen_background.dart';
import '../../widgets/common/orbital_loading_indicator.dart';
import '../../widgets/common/confirmation_dialog.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../models/subscription_model.dart';

enum SubscriptionFilter {
  mostExpensive,
  upcoming,
  recent,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SubscriptionFilter _selectedFilter = SubscriptionFilter.upcoming;

  @override
  void initState() {
    super.initState();
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

  List<Subscription> _getFilteredSubscriptions(List<Subscription> subs) {
    switch (_selectedFilter) {
      case SubscriptionFilter.mostExpensive:
        final sorted = List<Subscription>.from(subs);
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        return sorted.take(5).toList();
      case SubscriptionFilter.upcoming:
        final sorted = List<Subscription>.from(subs);
        sorted.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
        return sorted.take(5).toList();
      case SubscriptionFilter.recent:
        final sorted = List<Subscription>.from(subs);
        sorted.sort((a, b) => b.id.compareTo(a.id));
        return sorted.take(5).toList();
    }
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
        child: SafeArea(
          child: Consumer2<AuthProvider, SubscriptionProvider>(
            builder: (context, authProvider, subProvider, _) {
              if (subProvider.isLoading) {
                return Center(
                  child: OrbitalLoadingIndicator(
                    colors: themeColors,
                    size: 100,
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  _ModernAppBar(
                    userName: authProvider.user?.name ?? "User",
                    themeColors: themeColors,
                  ),
                  if (subProvider.subscriptions.isEmpty)
                    SliverFillRemaining(
                      child: EmptyStateWidget(
                        themeColors: themeColors,
                        onAddPressed: _showAddSubscriptionDialog,
                      ),
                    )
                  else ...[
                    _CompactStatsGrid(
                      themeColors: themeColors,
                      subscriptions: subProvider.subscriptions,
                    ),
                    _SpendingOverview(
                      themeColors: themeColors,
                      subscriptions: subProvider.subscriptions,
                    ),
                    _SubscriptionsSection(
                      themeColors: themeColors,
                      subscriptions:
                          _getFilteredSubscriptions(subProvider.subscriptions),
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() => _selectedFilter = filter);
                      },
                      onEdit: _showEditSubscriptionDialog,
                      onDelete: _confirmDelete,
                      onViewAll: () => context.go('/home/subscriptions'),
                    ),
                  ],
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
        label: const Text(
          'Add',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ModernAppBar extends StatelessWidget {
  final String userName;
  final ThemeColors themeColors;

  const _ModernAppBar({
    required this.userName,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $userName',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your subscriptions',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _IconButton(
                  icon: Icons.settings_outlined,
                  onPressed: () => context.go('/home/settings'),
                  themeColors: themeColors,
                ),
                const SizedBox(width: 8),
                _IconButton(
                  icon: Icons.logout,
                  onPressed: () async {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  themeColors: themeColors,
                  color: themeColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final ThemeColors themeColors;
  final Color? color;

  const _IconButton({
    required this.icon,
    required this.onPressed,
    required this.themeColors,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: themeColors.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: IconButton(
        icon: Icon(icon, color: color ?? Colors.grey[400], size: 20),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(),
      ),
    );
  }
}

class _CompactStatsGrid extends StatelessWidget {
  final ThemeColors themeColors;
  final List<Subscription> subscriptions;

  const _CompactStatsGrid({
    required this.themeColors,
    required this.subscriptions,
  });

  double _getTotalMonthlySpend() {
    return subscriptions.fold(0.0, (sum, sub) => sum + sub.amount);
  }

  @override
  Widget build(BuildContext context) {
    final totalMonthly = _getTotalMonthlySpend();
    
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeColors.primary.withValues(alpha: 0.15),
                themeColors.secondary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Active',
                  value: subscriptions.length.toString(),
                  icon: Icons.subscriptions_outlined,
                  themeColors: themeColors,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Monthly',
                  value: '\$${totalMonthly.toStringAsFixed(0)}',
                  icon: Icons.payments_outlined,
                  themeColors: themeColors,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Yearly',
                  value: '\$${(totalMonthly * 12).toStringAsFixed(0)}',
                  icon: Icons.calendar_today_outlined,
                  themeColors: themeColors,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final ThemeColors themeColors;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: themeColors.primary, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }
}

class _SpendingOverview extends StatelessWidget {
  final ThemeColors themeColors;
  final List<Subscription> subscriptions;

  const _SpendingOverview({
    required this.themeColors,
    required this.subscriptions,
  });

  @override
  Widget build(BuildContext context) {
    final nextRenewal = _getNextRenewal();
    final mostExpensive = _getMostExpensive();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          children: [
            if (nextRenewal != null)
              _InsightCard(
                icon: Icons.schedule,
                title: 'Next Renewal',
                subtitle:
                    '${nextRenewal.name} • ${_getDaysUntil(nextRenewal.nextBillingDate)} days',
                amount: '\$${nextRenewal.amount.toStringAsFixed(2)}',
                themeColors: themeColors,
                gradientColors: [
                  themeColors.secondary.withValues(alpha: 0.2),
                  themeColors.tertiary.withValues(alpha: 0.1),
                ],
              ),
            if (nextRenewal != null && mostExpensive != null)
              const SizedBox(height: 12),
            if (mostExpensive != null)
              _InsightCard(
                icon: Icons.trending_up,
                title: 'Highest Cost',
                subtitle: mostExpensive.name,
                amount: '\$${mostExpensive.amount.toStringAsFixed(2)}/mo',
                themeColors: themeColors,
                gradientColors: [
                  themeColors.primary.withValues(alpha: 0.2),
                  themeColors.secondary.withValues(alpha: 0.1),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Subscription? _getNextRenewal() {
    if (subscriptions.isEmpty) return null;
    final sorted = List<Subscription>.from(subscriptions);
    sorted.sort((a, b) => a.nextBillingDate.compareTo(b.nextBillingDate));
    return sorted.first;
  }

  Subscription? _getMostExpensive() {
    if (subscriptions.isEmpty) return null;
    return subscriptions.reduce((a, b) => a.amount > b.amount ? a : b);
  }

  int _getDaysUntil(DateTime date) {
    return date.difference(DateTime.now()).inDays;
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String amount;
  final ThemeColors themeColors;
  final List<Color> gradientColors;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.themeColors,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: themeColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              color: themeColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscriptionsSection extends StatelessWidget {
  final ThemeColors themeColors;
  final List<Subscription> subscriptions;
  final SubscriptionFilter selectedFilter;
  final Function(SubscriptionFilter) onFilterChanged;
  final void Function(Subscription) onEdit;
  final void Function(Subscription) onDelete;
  final VoidCallback onViewAll;

  const _SubscriptionsSection({
    required this.themeColors,
    required this.subscriptions,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subscriptions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                _ViewAllButton(
                  onTap: onViewAll,
                  themeColors: themeColors,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FilterChips(
              selectedFilter: selectedFilter,
              onFilterChanged: onFilterChanged,
              themeColors: themeColors,
            ),
            const SizedBox(height: 16),
            ...subscriptions.map((sub) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SubscriptionCard(
                    key: ValueKey(sub.id),
                    subscription: sub,
                    themeColors: themeColors,
                    isCompact: true,
                    onEdit: () => onEdit(sub),
                    onDelete: () => onDelete(sub),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final SubscriptionFilter selectedFilter;
  final Function(SubscriptionFilter) onFilterChanged;
  final ThemeColors themeColors;

  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'Upcoming',
          icon: Icons.schedule,
          isSelected: selectedFilter == SubscriptionFilter.upcoming,
          onTap: () => onFilterChanged(SubscriptionFilter.upcoming),
          themeColors: themeColors,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Most Expensive',
          icon: Icons.trending_up,
          isSelected: selectedFilter == SubscriptionFilter.mostExpensive,
          onTap: () => onFilterChanged(SubscriptionFilter.mostExpensive),
          themeColors: themeColors,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Recent',
          icon: Icons.access_time,
          isSelected: selectedFilter == SubscriptionFilter.recent,
          onTap: () => onFilterChanged(SubscriptionFilter.recent),
          themeColors: themeColors,
        ),
      ],
    );
  }
}

class _ViewAllButton extends StatefulWidget {
  final VoidCallback onTap;
  final ThemeColors themeColors;

  const _ViewAllButton({
    required this.onTap,
    required this.themeColors,
  });

  @override
  State<_ViewAllButton> createState() => _ViewAllButtonState();
}

class _ViewAllButtonState extends State<_ViewAllButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.themeColors.surface.withValues(
              alpha: _isHovered ? 0.45 : 0.3,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Text(
                'View All',
                style: TextStyle(
                  color: widget.themeColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward,
                size: 14,
                color: widget.themeColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors themeColors;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    themeColors.primary.withValues(alpha: 0.3),
                    themeColors.secondary.withValues(alpha: 0.2),
                  ],
                )
              : null,
          color: isSelected ? null : themeColors.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? themeColors.primary.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? themeColors.primary : Colors.grey[400],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[400],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}