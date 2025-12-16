import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/home/providers/theme_provider.dart';
import '../../../core/config/theme.dart';
import '../../../core/utils/app_constants.dart';

// Reusable widgets
import '../../../core/widgets/common/grid_painter.dart';
import '../../../features/settings/widgets/settings_tile.dart';
import '../../../features/settings/widgets/settings_divider.dart';
import '../../../features/settings/widgets/settings_section.dart';
import '../../../features/settings/widgets/settings_profile_card.dart';
import '../../../features/settings/widgets/theme_picker_dialog.dart';
import '../../../features/settings/widgets/edit_profile_dialog.dart';
import '../../../features/settings/widgets/change_password_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final themeColors = context.read<ThemeProvider>().themeColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
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
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _showSnackBar(
        context,
        'Account deletion not implemented yet',
        themeColors,
      );
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const EditProfileDialog(),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  Future<void> _showThemePickerDialog(BuildContext context) async {
    final themeProvider = context.read<ThemeProvider>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ThemePickerDialog(themeProvider: themeProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.watch<ThemeProvider>().themeColors;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
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
            // Animated grid background
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
            _buildGradientOrb(
              bottom: -150,
              left: -100,
              size: 300,
              colors: [
                themeColors.secondary.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),

            // Main content
            SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  _buildAppBar(context, themeColors, isWeb),
                  _buildTabBar(themeColors),
                ],
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    // General Settings Tab
                    _buildGeneralTab(context, themeColors, user, isWeb),
                    // App Modules Tab
                    _buildAppModulesTab(context, themeColors, isWeb),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTab(BuildContext context, ThemeColors themeColors, user, bool isWeb) {
    return CustomScrollView(
      slivers: [
        // Profile Card
        SliverToBoxAdapter(
          child: SettingsProfileCard(
            user: user,
            themeColors: themeColors,
            onTap: () => _showEditProfileDialog(context),
          ),
        ),

        // Quick Actions Grid
        _buildQuickActionsGrid(context, themeColors, isWeb),

        // Account Section
        _buildAccountSection(context, themeColors),

        // Preferences Section
        _buildPreferencesSection(context, themeColors),

        // Support Section
        _buildSupportSection(context, themeColors),

        // Danger Zone
        _buildDangerZone(context, themeColors),

        // Footer spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildAppModulesTab(BuildContext context, ThemeColors themeColors, bool isWeb) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWeb ? 32 : 24, isWeb ? 32 : 24, isWeb ? 32 : 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'App Modules',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage settings for each app',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ),

        // App Module Cards
        _buildAppModuleCard(
          context: context,
          themeColors: themeColors,
          isWeb: isWeb,
          title: 'Subscriptions',
          icon: Icons.credit_card,
          description: 'Track your recurring payments',
          gradientColors: [themeColors.primary, themeColors.secondary],
          isEnabled: true,
          stats: '5 active • \$124/mo',
          onTap: () {
            // Navigate to subscription-specific settings
            _showSnackBar(context, 'Subscription settings coming soon', themeColors);
          },
        ),

        _buildAppModuleCard(
          context: context,
          themeColors: themeColors,
          isWeb: isWeb,
          title: 'Family Calendar',
          icon: Icons.calendar_today,
          description: 'Shared events and schedules',
          gradientColors: [themeColors.secondary, themeColors.tertiary],
          isEnabled: false,
          stats: 'Coming Soon',
          onTap: null,
        ),

        _buildAppModuleCard(
          context: context,
          themeColors: themeColors,
          isWeb: isWeb,
          title: 'Workouts',
          icon: Icons.fitness_center,
          description: 'Track your fitness journey',
          gradientColors: [themeColors.tertiary, themeColors.primary],
          isEnabled: false,
          stats: 'Coming Soon',
          onTap: null,
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildAppModuleCard({
    required BuildContext context,
    required ThemeColors themeColors,
    required bool isWeb,
    required String title,
    required IconData icon,
    required String description,
    required List<Color> gradientColors,
    required bool isEnabled,
    required String stats,
    required VoidCallback? onTap,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(isWeb ? 32 : 24, 0, isWeb ? 32 : 24, 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradientColors[0].withValues(alpha: isEnabled ? 0.15 : 0.05),
                    gradientColors[1].withValues(alpha: isEnabled ? 0.1 : 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isEnabled ? 0.1 : 0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isEnabled ? gradientColors : [Colors.grey[700]!, Colors.grey[800]!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isEnabled
                          ? [
                              BoxShadow(
                                color: gradientColors[0].withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isEnabled ? Colors.white : Colors.grey[600],
                      size: 24,
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isEnabled ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 13,
                            color: isEnabled ? Colors.grey[400] : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isEnabled
                                ? gradientColors[0].withValues(alpha: 0.2)
                                : Colors.grey[800]!.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isEnabled
                                  ? gradientColors[0].withValues(alpha: 0.3)
                                  : Colors.grey[700]!.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            stats,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isEnabled ? gradientColors[0] : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEnabled)
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[600],
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
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
      expandedHeight: isWeb ? 120 : 100,
      floating: false,
      pinned: true,
      backgroundColor: themeColors.background.withValues(alpha: 0.95),
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 4.0),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.grey[400], size: 20),
          onPressed: () => context.go('/home'),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: isWeb ? 72 : 60, bottom: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [themeColors.primary, themeColors.secondary],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.settings, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeColors themeColors) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _StickyTabBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: themeColors.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[500],
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'App Modules'),
          ],
        ),
        themeColors,
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, ThemeColors themeColors, bool isWeb) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(isWeb ? 32 : 24, 8, isWeb ? 32 : 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = isWeb ? 4 : 2;
                final spacing = 12.0;
                final itemWidth = (constraints.maxWidth - (spacing * (crossAxisCount - 1))) / crossAxisCount;
                
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    SizedBox(
                      width: itemWidth,
                      child: _buildQuickActionCard(
                        icon: Icons.palette_outlined,
                        label: 'Theme',
                        color: themeColors.primary,
                        onTap: () => _showThemePickerDialog(context),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildQuickActionCard(
                        icon: Icons.lock_outline,
                        label: 'Password',
                        color: themeColors.secondary,
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildQuickActionCard(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        color: themeColors.tertiary,
                        onTap: () => _showSnackBar(
                          context,
                          'Notifications not implemented',
                          themeColors,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: itemWidth,
                      child: _buildQuickActionCard(
                        icon: Icons.language_outlined,
                        label: 'Language',
                        color: themeColors.primary,
                        onTap: () => _showSnackBar(
                          context,
                          'Language selection not implemented',
                          themeColors,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, ThemeColors themeColors) {
    return SliverToBoxAdapter(
      child: SettingsSection(
        title: 'ACCOUNT',
        themeColors: themeColors,
        children: [
          SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            themeColors: themeColors,
            onTap: () => _showEditProfileDialog(context),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            themeColors: themeColors,
            onTap: () => _showChangePasswordDialog(context),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.email_outlined,
            title: 'Email Preferences',
            subtitle: 'Manage email notifications',
            themeColors: themeColors,
            onTap: () => _showSnackBar(
              context,
              'Email preferences not implemented',
              themeColors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context, ThemeColors themeColors) {
    return SliverToBoxAdapter(
      child: SettingsSection(
        title: 'PREFERENCES',
        themeColors: themeColors,
        children: [
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage app notifications',
            themeColors: themeColors,
            onTap: () => _showSnackBar(
              context,
              'Notifications not implemented',
              themeColors,
            ),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            subtitle: 'Current: ${context.watch<ThemeProvider>().themeName}',
            themeColors: themeColors,
            onTap: () => _showThemePickerDialog(context),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            subtitle: 'English (US)',
            themeColors: themeColors,
            onTap: () => _showSnackBar(
              context,
              'Language selection not implemented',
              themeColors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context, ThemeColors themeColors) {
    return SliverToBoxAdapter(
      child: SettingsSection(
        title: 'SUPPORT',
        themeColors: themeColors,
        children: [
          SettingsTile(
            icon: Icons.help_outline,
            title: 'Help Center',
            subtitle: 'Get help and support',
            themeColors: themeColors,
            onTap: () => _showSnackBar(
              context,
              'Help Center not implemented',
              themeColors,
            ),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            themeColors: themeColors,
            onTap: () => _showSnackBar(
              context,
              'Privacy Policy not implemented',
              themeColors,
            ),
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'View our terms of service',
            themeColors: themeColors,
            onTap: () => _showSnackBar(
              context,
              'Terms of Service not implemented',
              themeColors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, ThemeColors themeColors) {
    return SliverToBoxAdapter(
      child: SettingsSection(
        title: 'DANGER ZONE',
        titleColor: Colors.red[400],
        themeColors: themeColors,
        children: [
          SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            themeColors: themeColors,
            iconColor: Colors.orange,
            onTap: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) context.go('/login');
            },
          ),
          SettingsDivider(themeColors: themeColors),
          SettingsTile(
            icon: Icons.delete_forever_outlined,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account',
            themeColors: themeColors,
            iconColor: Colors.red,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
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

// Custom delegate for sticky tab bar
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final ThemeColors themeColors;

  _StickyTabBarDelegate(this.tabBar, this.themeColors);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: themeColors.background.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}