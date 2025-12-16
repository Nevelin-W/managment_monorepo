import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../features/home/providers/theme_provider.dart';
import '../../../features/subscriptions/providers/subscription_provider.dart';
import '../../../features/subscriptions/providers/subscription_preferences_provider.dart'; // ADD THIS
import '../../../core/config/theme.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/widgets/common/grid_painter.dart';
import '../../../features/settings/widgets/settings_tile.dart';
import '../../../features/settings/widgets/settings_divider.dart';
import '../../../features/settings/widgets/settings_section.dart';
import '../../../features/settings/widgets/settings_card.dart';

class SubscriptionSettingsScreen extends StatelessWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColors = context.watch<ThemeProvider>().themeColors;
    final prefsProvider = context.watch<SubscriptionPreferencesProvider>(); // USE PROVIDER
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: themeColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColors.background,
              themeColors.surface.withValues(alpha: 0.3),
              themeColors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Grid background
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(
                  painter: GridPainter(
                    color: themeColors.primary,
                    step: isWeb ? 60 : 50,
                    strokeWidth: 1,
                  ),
                ),
              ),
            ),

            // Gradient orbs
            _buildGradientOrb(
              top: -100,
              right: -100,
              size: 250,
              colors: [
                themeColors.primary.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ),

            // Main content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, themeColors, isWeb),
                  _buildStatsCard(context, themeColors, isWeb),
                  _buildNotificationSettings(context, themeColors, prefsProvider),
                  _buildDisplaySettings(context, themeColors, prefsProvider),
                  _buildDataPrivacySettings(context, themeColors, prefsProvider),
                  _buildDataManagement(context, themeColors),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required List<Color> colors,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeColors themeColors, bool isWeb) {
    return SliverAppBar(
      expandedHeight: isWeb ? 140 : 120,
      floating: false,
      pinned: true,
      backgroundColor: themeColors.background.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[400], size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: isWeb ? 72 : 60, bottom: 16),
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isCollapsed = constraints.maxHeight <= 100;
            return AnimatedOpacity(
              opacity: isCollapsed ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeColors.primary, themeColors.secondary],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.credit_card, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Subscription Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        background: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWeb ? 32 : 24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [themeColors.primary, themeColors.secondary],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: themeColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subscription Settings',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your subscription tracking experience',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ThemeColors themeColors, bool isWeb) {
    final subProvider = context.watch<SubscriptionProvider>();
    final prefsProvider = context.watch<SubscriptionPreferencesProvider>();
    final totalSubs = subProvider.subscriptions.length;
    final totalMonthly = subProvider.subscriptions.fold<double>(
      0.0,
      (sum, sub) => sum + sub.amount,
    );

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(isWeb ? 32 : 24, isWeb ? 32 : 24, isWeb ? 32 : 24, 16),
        child: SettingsCard(
          themeColors: themeColors,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.subscriptions_outlined,
                    label: 'Active',
                    value: totalSubs.toString(),
                    color: themeColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.payments_outlined,
                    label: 'Monthly',
                    value: prefsProvider.formatAmount(totalMonthly),
                    color: themeColors.secondary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Yearly',
                    value: prefsProvider.formatAmount(totalMonthly * 12),
                    color: themeColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
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

  Widget _buildNotificationSettings(BuildContext context, ThemeColors themeColors, SubscriptionPreferencesProvider prefs) {
    return SliverToBoxAdapter(
      child: SettingsSection(
        title: 'NOTIFICATIONS',
        themeColors: themeColors,
        children: [
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Renewal Reminders',
            subtitle: 'Get notified before subscriptions renew',
            value: prefs.renewalReminders,
            themeColors: themeColors,
            onChanged: (value) => prefs.setRenewalReminders(value),
          ),
          if (prefs.renewalReminders) ...[
            SettingsDivider(themeColors: themeColors),
            Padding(
              padding: const EdgeInsets.only(left: 56),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.calendar_month,
                    title: 'Week Before',
                    subtitle: '7 days before renewal',
                    value: prefs.weekBeforeReminder,
                    themeColors: themeColors,
                    onChanged: (value) => prefs.setWeekBeforeReminder(value),
                    isSubOption: true,
                  ),
                  SettingsDivider(themeColors: themeColors),
                  _buildSwitchTile(
                    icon: Icons.calendar_today,
                    title: 'Day Before',
                    subtitle: '24 hours before renewal',
                    value: prefs.dayBeforeReminder,
                    themeColors: themeColors,
                    onChanged: (value) => prefs.setDayBeforeReminder(value),
                    isSubOption: true,
                  ),
                  SettingsDivider(themeColors: themeColors),
                  _buildSwitchTile(
                    icon: Icons.alarm,
                    title: 'On Renewal Day',
                    subtitle: 'Morning of renewal',
                    value: prefs.onDayReminder,
                    themeColors: themeColors,
                    onChanged: (value) => prefs.setOnDayReminder(value),
                    isSubOption: true,
                  ),
                ],
              ),
            ),
          ],
          SettingsDivider(themeColors: themeColors),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Receive reminders via email',
            value: prefs.emailNotifications,
            themeColors: themeColors,
            onChanged: (value) => prefs.setEmailNotifications(value),
          ),
          SettingsDivider(themeColors: themeColors),
          _buildSwitchTile(
            icon: Icons.phone_iphone,
            title: 'Push Notifications',
            subtitle: 'Receive push notifications',
            value: prefs.pushNotifications,
            themeColors: themeColors,
            onChanged: (value) => prefs.setPushNotifications(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplaySettings(BuildContext context, ThemeColors themeColors, SubscriptionPreferencesProvider prefs) {
    final currencies = ['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY'];
    final dateFormats = ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'];
    final sortOrders = [
      {'value': 'upcoming', 'label': 'Next Billing Date'},
      {'value': 'expensive', 'label': 'Most Expensive'},
      {'value': 'recent', 'label': 'Recently Added'},
      {'value': 'alphabetical', 'label': 'Alphabetical'},
    ];

    return SliverToBoxAdapter(
      child: SettingsSection(
        title: 'DISPLAY',
        themeColors: themeColors,
        children: [
          _buildDropdownTile(
            icon: Icons.attach_money,
            title: 'Currency',
            subtitle: 'Default currency for new subscriptions',
            value: prefs.currency,
            items: currencies,
            themeColors: themeColors,
            onChanged: (value) => prefs.setCurrency(value!),
          ),
          SettingsDivider(themeColors: themeColors),
          _buildDropdownTile(
            icon: Icons.date_range,
            title: 'Date Format',
            subtitle: 'How dates are displayed',
            value: prefs.dateFormat,
            items: dateFormats,
            themeColors: themeColors,
            onChanged: (value) => prefs.setDateFormat(value!),
          ),
          SettingsDivider(themeColors: themeColors),
          _buildSwitchTile(
            icon: Icons.money_outlined,
            title: 'Show Cents',
            subtitle: 'Display decimal values',
            value: prefs.showCents,
            themeColors: themeColors,
            onChanged: (value) => prefs.setShowCents(value),
          ),
          SettingsDivider(themeColors: themeColors),
          _buildSwitchTile(
            icon: Icons.view_compact_outlined,
            title: 'Compact View',
            subtitle: 'Show more subscriptions on screen',
            value: prefs.compactView,
            themeColors: themeColors,
            onChanged: (value) => prefs.setCompactView(value),
          ),
          SettingsDivider(themeColors: themeColors),
          _buildDropdownTile(
            icon: Icons.sort,
            title: 'Default Sort Order',
            subtitle: 'How subscriptions are sorted by default',
            value: prefs.defaultSortOrder,
            items: sortOrders.map((e) => e['value']!).toList(),
            itemLabels: {for (var e in sortOrders) e['value']!: e['label']!},
            themeColors: themeColors,
            onChanged: (value) => prefs.setDefaultSortOrder(value!),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacySettings(BuildContext context, ThemeColors themeColors, SubscriptionPreferencesProvider prefs) {
    return SliverToBoxAdapter(
      child: SettingsSection(
        title: 'DATA & PRIVACY',
        themeColors: themeColors,
        children: [
          _buildSwitchTile(
            icon: Icons.cloud_sync_outlined,
            title: 'Cloud Sync',
            subtitle: 'Sync subscriptions across devices',
            value: prefs.syncEnabled,
            themeColors: themeColors,
            onChanged: (value) => prefs.setSyncEnabled(value),
          ),
          SettingsDivider(themeColors: themeColors),
          _buildSwitchTile(
            icon: Icons.analytics_outlined,
            title: 'Usage Analytics',
            subtitle: 'Help improve the app',
            value: prefs.analyticsEnabled,
            themeColors: themeColors,
            onChanged: (value) => prefs.setAnalyticsEnabled(value),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.security_outlined,
            title: 'Data Security',
            subtitle: 'Learn how we protect your data',
            themeColors: themeColors,
            onTap: () => _showSnackBar(context, 'Data security info', themeColors),
          ),
        ],
      ),
    );
  }

  Widget _buildDataManagement(BuildContext context, ThemeColors themeColors) {
    return SliverToBoxAdapter(
      child: SettingsSection(
        title: 'DATA MANAGEMENT',
        themeColors: themeColors,
        children: [
          SettingsTile(
            icon: Icons.upload_file_outlined,
            title: 'Export Data',
            subtitle: 'Download your subscription data',
            themeColors: themeColors,
            onTap: () => _handleExportData(context, themeColors),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.download_outlined,
            title: 'Import Data',
            subtitle: 'Import from CSV or JSON',
            themeColors: themeColors,
            onTap: () => _showSnackBar(context, 'Import not implemented', themeColors),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.delete_sweep_outlined,
            title: 'Clear All Data',
            subtitle: 'Delete all subscriptions',
            themeColors: themeColors,
            iconColor: Colors.red,
            onTap: () => _handleClearAllData(context, themeColors),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ThemeColors themeColors,
    required ValueChanged<bool> onChanged,
    bool isSubOption = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value
                  ? themeColors.primary.withValues(alpha: 0.15)
                  : themeColors.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: value
                    ? themeColors.primary.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon,
              color: value ? themeColors.primary : Colors.grey[600],
              size: isSubOption ? 18 : 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isSubOption ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: themeColors.primary,
            activeTrackColor: themeColors.primary.withValues(alpha: 0.5),
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    Map<String, String>? itemLabels,
    required ThemeColors themeColors,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColors.surface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.grey[400],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: themeColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButton<String>(
              value: value,
              onChanged: onChanged,
              underline: const SizedBox(),
              isDense: true,
              icon: Icon(Icons.arrow_drop_down, color: themeColors.primary),
              dropdownColor: themeColors.surface,
              style: TextStyle(
                color: themeColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(itemLabels?[item] ?? item),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExportData(BuildContext context, ThemeColors themeColors) async {
    final subProvider = context.read<SubscriptionProvider>();
    
    if (subProvider.subscriptions.isEmpty) {
      _showSnackBar(context, 'No subscriptions to export', themeColors);
      return;
    }

    // Show export format dialog
    final format = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Export Format',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildExportOption(
              context,
              icon: Icons.table_chart,
              title: 'CSV',
              subtitle: 'Spreadsheet format',
              value: 'csv',
              themeColors: themeColors,
            ),
            const SizedBox(height: 12),
            _buildExportOption(
              context,
              icon: Icons.code,
              title: 'JSON',
              subtitle: 'Developer format',
              value: 'json',
              themeColors: themeColors,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
        ],
      ),
    );

    if (format != null && context.mounted) {
      _showSnackBar(
        context,
        'Export to $format not yet implemented',
        themeColors,
      );
    }
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required ThemeColors themeColors,
  }) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeColors.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: themeColors.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Future<void> _handleClearAllData(BuildContext context, ThemeColors themeColors) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 28),
            const SizedBox(width: 12),
            const Text(
              'Clear All Data?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all your subscriptions. This action cannot be undone.',
          style: TextStyle(color: Colors.grey[400], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Delete All',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _showSnackBar(
        context,
        'Clear all data not yet implemented',
        themeColors,
      );
    }
  }

  void _showSnackBar(BuildContext context, String message, ThemeColors themeColors) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: themeColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}