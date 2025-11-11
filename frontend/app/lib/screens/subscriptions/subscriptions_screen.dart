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
import '../../widgets/common/screen_background.dart';
import '../../models/subscription_model.dart';
import '../../widgets/subscriptions/subscription_filter_bar.dart';

enum SortOption {
  nameAsc,
  nameDesc,
  priceAsc,
  priceDesc,
  dateAsc,
  dateDesc,
}

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
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

  List<Subscription> _getFilteredSubscriptions(
      List<Subscription> subscriptions) {
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
        sorted.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.nameDesc:
        sorted.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
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

  void _showSortMenu(BuildContext context, ThemeColors themeColors) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    
    final Offset buttonPosition = button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;
    final Size overlaySize = overlay.size;
    
    // Menu dimensions
    const double menuWidth = 240.0;
    
    // Position menu below button, aligned to right edge of button
    final double top = buttonPosition.dy + buttonSize.height + 8;
    final double right = overlaySize.width - (buttonPosition.dx + buttonSize.width);
    
    // Ensure menu doesn't go off left edge
    final double left = buttonPosition.dx + buttonSize.width - menuWidth;
    final double adjustedLeft = left < 16 ? 16 : left;
    final double adjustedRight = overlaySize.width - adjustedLeft - menuWidth;

    showMenu<SortOption>(
      context: context,
      position: RelativeRect.fromLTRB(
        adjustedLeft,
        top,
        adjustedRight,
        overlaySize.height - top,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: themeColors.surface,
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 240),
      items: [
        _buildSortMenuItem(
          SortOption.nameAsc,
          'Name (A-Z)',
          Icons.sort_by_alpha,
          themeColors,
        ),
        _buildSortMenuItem(
          SortOption.nameDesc,
          'Name (Z-A)',
          Icons.sort_by_alpha,
          themeColors,
        ),
        _buildSortMenuItem(
          SortOption.priceAsc,
          'Price (Low to High)',
          Icons.arrow_upward,
          themeColors,
        ),
        _buildSortMenuItem(
          SortOption.priceDesc,
          'Price (High to Low)',
          Icons.arrow_downward,
          themeColors,
        ),
        _buildSortMenuItem(
          SortOption.dateAsc,
          'Next Bill Date (Nearest)',
          Icons.calendar_today,
          themeColors,
        ),
        _buildSortMenuItem(
          SortOption.dateDesc,
          'Next Bill Date (Farthest)',
          Icons.calendar_today,
          themeColors,
        ),
      ],
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedSort = value;
        });
      }
    });
  }

  PopupMenuItem<SortOption> _buildSortMenuItem(
    SortOption value,
    String label,
    IconData icon,
    ThemeColors themeColors,
  ) {
    final isSelected = _selectedSort == value;
    return PopupMenuItem<SortOption>(
      value: value,
      height: 48,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? themeColors.primary : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? themeColors.primary : Colors.white,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (isSelected)
            Icon(Icons.check, size: 20, color: themeColors.primary),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_selectedSort) {
      case SortOption.nameAsc:
        return 'Name (A-Z)';
      case SortOption.nameDesc:
        return 'Name (Z-A)';
      case SortOption.priceAsc:
        return 'Price ↑';
      case SortOption.priceDesc:
        return 'Price ↓';
      case SortOption.dateAsc:
        return 'Date ↑';
      case SortOption.dateDesc:
        return 'Date ↓';
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
                  SliverAppBar(
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
                          // Show title when collapsed (constraints.maxHeight will be smaller)
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
                                '${provider.subscriptions.length} active',
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
                  ),
                  SliverPersistentHeader(
                    pinned: false,
                    delegate: _FilterBarDelegate(
                      themeColors: themeColors,
                      selectedFilter: _selectedFilter,
                      onFilterChanged: (filter) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      onSortPressed: (context) => _showSortMenu(context, themeColors),
                      sortLabel: _getSortLabel(),
                    ),
                  ),
                  filteredSubscriptions.isEmpty
                      ? SliverFillRemaining(
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
                        )
                      : SliverPadding(
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
      BuildContext context, ThemeColors themeColors, int count) {
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

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final ThemeColors themeColors;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function(BuildContext) onSortPressed;
  final String sortLabel;

  _FilterBarDelegate({
    required this.themeColors,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSortPressed,
    required this.sortLabel,
  });

  @override
  double get minExtent => 80.0;

  @override
  double get maxExtent => 80.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: themeColors.background,
      child: Builder(
        builder: (context) => SubscriptionFilterBar(
          themeColors: themeColors,
          selectedFilter: selectedFilter,
          onFilterChanged: onFilterChanged,
          onSortPressed: () => onSortPressed(context),
          sortLabel: sortLabel,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) {
    return selectedFilter != oldDelegate.selectedFilter ||
        sortLabel != oldDelegate.sortLabel;
  }
}