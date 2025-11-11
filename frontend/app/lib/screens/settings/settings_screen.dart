import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

// Reusable widgets
import '../../widgets/common/grid_painter.dart';
import '../../widgets/settings/settings_card.dart';
import '../../widgets/settings/settings_tile.dart';
import '../../widgets/settings/settings_divider.dart';
import '../../widgets/settings/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final themeColors = context.read<ThemeProvider>().themeColors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Text('Delete Account', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
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

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account deletion not implemented yet'),
          backgroundColor: themeColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _showThemePickerDialog(BuildContext context) async {
    final themeProvider = context.read<ThemeProvider>();
    final themeColors = themeProvider.themeColors;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: themeColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title:
              const Text('Choose Theme', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              children: themeProvider.availableThemes.map((themeType) {
                final themeName = themeType.name[0].toUpperCase() +
                    themeType.name.substring(1);
                final selected = themeProvider.currentTheme == themeType;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    themeName,
                    style: TextStyle(
                      color: selected ? themeColors.primary : Colors.grey[300],
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_circle, color: themeColors.primary)
                      : null,
                  onTap: () {
                    themeProvider.setTheme(themeType);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.watch<ThemeProvider>().themeColors;
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: themeColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              themeColors.background,
              themeColors.surface,
              themeColors.background,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Subtle grid background
            Positioned.fill(
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(
                  painter: GridPainter(
                    color: themeColors.primary,
                    step: 50,
                    strokeWidth: 1,
                  ),
                ),
              ),
            ),

            // Glow effects
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      themeColors.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  // App Bar
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
                          final isCollapsed = constraints.maxHeight <= 100;
                          return AnimatedOpacity(
                            opacity: isCollapsed ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: const Text(
                              'Settings',
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
                                'Settings',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                  ),

                  // Profile Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: SettingsCard(
                        themeColors: themeColors,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      themeColors.primary,
                                      themeColors.secondary
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 32),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.name ?? 'User',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.email ?? 'user@example.com',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[400]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Account Section
                  SliverToBoxAdapter(
                    child: SettingsSection(
                      title: 'ACCOUNT',
                      themeColors: themeColors,
                      children: [
                        SettingsTile(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Update your personal information',
                          themeColors: themeColors,
                          onTap: () => _showSnack(context, themeColors,
                              'Edit profile not implemented'),
                        ),
                        SettingsDivider(themeColors: themeColors),
                        SettingsTile(
                          icon: Icons.lock_outline,
                          title: 'Change Password',
                          subtitle: 'Update your password',
                          themeColors: themeColors,
                          onTap: () => _showSnack(context, themeColors,
                              'Change password not implemented'),
                        ),
                        SettingsDivider(themeColors: themeColors),
                        SettingsTile(
                          icon: Icons.email_outlined,
                          title: 'Email Preferences',
                          subtitle: 'Manage email notifications',
                          themeColors: themeColors,
                          onTap: () => _showSnack(context, themeColors,
                              'Email preferences not implemented'),
                        ),
                      ],
                    ),
                  ),

                  // Preferences Section
                  SliverToBoxAdapter(
                    child: SettingsSection(
                      title: 'PREFERENCES',
                      themeColors: themeColors,
                      children: [
                        SettingsTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage app notifications',
                          themeColors: themeColors,
                          onTap: () => _showSnack(context, themeColors,
                              'Notifications not implemented'),
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
                          subtitle: 'English',
                          themeColors: themeColors,
                          onTap: () => _showSnack(
                              context, themeColors, 'Language not implemented'),
                        ),
                      ],
                    ),
                  ),

                  // Support Section
                  SliverToBoxAdapter(
                    child: SettingsSection(
                      title: 'SUPPORT',
                      themeColors: themeColors,
                      children: [
                        SettingsTile(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          subtitle: 'Get help and support',
                          themeColors: themeColors,
                          onTap: () => _showSnack(context, themeColors,
                              'Help Center not implemented'),
                        ),
                        SettingsDivider(themeColors: themeColors),
                        SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'View our privacy policy',
                          themeColors: themeColors,
                          onTap: () => _showSnack(context, themeColors,
                              'Privacy Policy not implemented'),
                        ),
                        SettingsDivider(themeColors: themeColors),
                        SettingsTile(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          subtitle: 'View our terms of service',
                          themeColors: themeColors,
                          onTap: () => _showSnack(context, themeColors,
                              'Terms of Service not implemented'),
                        ),
                      ],
                    ),
                  ),

                  // Danger Zone
                  SliverToBoxAdapter(
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, dynamic themeColors, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: themeColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
