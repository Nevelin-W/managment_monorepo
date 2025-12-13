import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/home/providers/theme_provider.dart';

// Reusable widgets
import '../../../core/widgets/common/grid_painter.dart';
import '../../../features/settings/widgets/settings_tile.dart';
import '../../../features/settings/widgets/settings_divider.dart';
import '../../../features/settings/widgets/settings_section.dart';
import '../../../features/settings/widgets/settings_profile_card.dart';
import '../../../features/settings/widgets/theme_picker_dialog.dart';
import '../../../features/settings/widgets/edit_profile_dialog.dart';
import '../../../features/settings/widgets/change_password_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              child: CustomScrollView(
                slivers: [
                  // Modern App Bar
                  _buildAppBar(context, themeColors, isWeb),

                  // Profile Card
                  SliverToBoxAdapter(
                    child:                     SettingsProfileCard(
                      user: user,
                      themeColors: themeColors,
                      onTap: () => _showEditProfileDialog(context),
                    ),
                  ),

                  // Quick Actions (Web only)
                  if (isWeb) _buildQuickActions(context, themeColors),

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

  Widget _buildAppBar(BuildContext context, dynamic themeColors, bool isWeb) {
    return SliverAppBar(
      expandedHeight: isWeb ? 160 : 140,
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
                        Icons.settings_outlined,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 32,
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
                  'Manage your account and preferences',
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

  Widget _buildQuickActions(BuildContext context, dynamic themeColors) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 16),
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.palette_outlined,
                label: 'Theme',
                color: themeColors.primary,
                onTap: () => _showThemePickerDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                color: themeColors.secondary,
                onTap: () => _showSnackBar(
                  context,
                  'Notifications not implemented',
                  themeColors,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.lock_outline,
                label: 'Security',
                color: themeColors.tertiary,
                onTap: () => _showSnackBar(
                  context,
                  'Security not implemented',
                  themeColors,
                ),
              ),
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
          padding: const EdgeInsets.all(16),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, dynamic themeColors) {
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

  Widget _buildPreferencesSection(BuildContext context, dynamic themeColors) {
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

  Widget _buildSupportSection(BuildContext context, dynamic themeColors) {
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

  Widget _buildDangerZone(BuildContext context, dynamic themeColors) {
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

  void _showSnackBar(BuildContext context, String message, dynamic themeColors) {
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