import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/config/theme.dart';

import '../../../core/widgets/common/grid_painter.dart';
import '../../../core/widgets/common/screen_background.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../features/home/providers/theme_provider.dart';

/// Main hub screen that displays all available app modules
class MainHomeScreen extends StatelessWidget {
  const MainHomeScreen({super.key});

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
          child: CustomScrollView(
            slivers: [
              _UserAppBar(themeColors: themeColors),
              _QuickStats(themeColors: themeColors),
              _AppModulesGrid(themeColors: themeColors),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserAppBar extends StatelessWidget {
  final ThemeColors themeColors;

  const _UserAppBar({required this.themeColors});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthProvider, dynamic>(
      (provider) => provider.user,
    );
    
    final userName = user?.name ?? "User";
    final userEmail = user?.email ?? "";

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeColors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: themeColors.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                _ProfileButton(
                  userName: userName,
                  userEmail: userEmail,
                  themeColors: themeColors,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose an app to get started',
              style: TextStyle(
                fontSize: 14,
                color: themeColors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String userName;
  final String userEmail;
  final ThemeColors themeColors;

  const _ProfileButton({
    required this.userName,
    required this.userEmail,
    required this.themeColors,
  });

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ProfileBottomSheet(
        userName: userName,
        userEmail: userEmail,
        themeColors: themeColors,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileMenu(context),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              themeColors.primary,
              themeColors.secondary,
            ],
          ),
          border: Border.all(
            color: themeColors.onSurface.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 24,
          backgroundColor: themeColors.surface,
          child: Text(
            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileBottomSheet extends StatelessWidget {
  final String userName;
  final String userEmail;
  final ThemeColors themeColors;

  const _ProfileBottomSheet({
    required this.userName,
    required this.userEmail,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: themeColors.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: themeColors.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        themeColors.primary,
                        themeColors.secondary,
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: themeColors.surface,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: themeColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: themeColors.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to edit profile
            },
            themeColors: themeColors,
          ),
          _ProfileMenuItem(
            icon: Icons.security_outlined,
            title: 'Change Password',
            onTap: () {
              Navigator.pop(context);
              // TODO: Show change password dialog
            },
            themeColors: themeColors,
          ),
          _ProfileMenuItem(
            icon: Icons.palette_outlined,
            title: 'Theme Settings',
            onTap: () {
              Navigator.pop(context);
              // TODO: Show theme picker
            },
            themeColors: themeColors,
          ),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: 'App Settings',
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
            themeColors: themeColors,
          ),
          Divider(
            height: 32,
            color: themeColors.onSurface.withValues(alpha: 0.1),
          ),
          _ProfileMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            themeColors: themeColors,
            isDestructive: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ThemeColors themeColors;
  final bool isDestructive;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.themeColors,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive 
                  ? themeColors.error 
                  : themeColors.onSurface.withValues(alpha: 0.6),
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: isDestructive ? themeColors.error : themeColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: themeColors.onSurface.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final ThemeColors themeColors;

  const _QuickStats({required this.themeColors});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
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
              color: themeColors.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickStatItem(
                icon: Icons.apps,
                label: 'Active Apps',
                value: '1',
                themeColors: themeColors,
              ),
              Container(
                width: 1,
                height: 40,
                color: themeColors.onSurface.withValues(alpha: 0.1),
              ),
              _QuickStatItem(
                icon: Icons.credit_card,
                label: 'Subscriptions',
                value: '—',
                themeColors: themeColors,
              ),
              Container(
                width: 1,
                height: 40,
                color: themeColors.onSurface.withValues(alpha: 0.1),
              ),
              _QuickStatItem(
                icon: Icons.check_circle_outline,
                label: 'This Month',
                value: '—',
                themeColors: themeColors,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeColors themeColors;

  const _QuickStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.themeColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: themeColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: themeColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: themeColors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _AppModulesGrid extends StatelessWidget {
  final ThemeColors themeColors;

  const _AppModulesGrid({required this.themeColors});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        delegate: SliverChildListDelegate([
          _AppModuleCard(
            title: 'Subscriptions',
            description: 'Track your recurring payments',
            icon: Icons.credit_card,
            route: '/subscriptions',
            gradientColors: [
              themeColors.primary,
              themeColors.secondary,
            ],
            stats: 'Active',
            themeColors: themeColors,
            isEnabled: true,
          ),
          _AppModuleCard(
            title: 'Family Calendar',
            description: 'Coming soon...',
            icon: Icons.calendar_today,
            route: '/calendar',
            gradientColors: [
              themeColors.secondary,
              themeColors.tertiary,
            ],
            stats: 'Soon',
            themeColors: themeColors,
            isEnabled: false,
          ),
          _AppModuleCard(
            title: 'Workouts',
            description: 'Coming soon...',
            icon: Icons.fitness_center,
            route: '/workouts',
            gradientColors: [
              themeColors.tertiary,
              themeColors.primary,
            ],
            stats: 'Soon',
            themeColors: themeColors,
            isEnabled: false,
          ),
        ]),
      ),
    );
  }
}

class _AppModuleCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final String route;
  final List<Color> gradientColors;
  final String stats;
  final ThemeColors themeColors;
  final bool isEnabled;

  const _AppModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.route,
    required this.gradientColors,
    required this.stats,
    required this.themeColors,
    this.isEnabled = true,
  });

  @override
  State<_AppModuleCard> createState() => _AppModuleCardState();
}

class _AppModuleCardState extends State<_AppModuleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Create disabled colors from onSurface
    final disabledColor = widget.themeColors.onSurface.withValues(alpha: 0.3);
    final disabledTextColor = widget.themeColors.onSurface.withValues(alpha: 0.4);

    return MouseRegion(
      onEnter: widget.isEnabled ? (_) => setState(() => _isHovered = true) : null,
      onExit: widget.isEnabled ? (_) => setState(() => _isHovered = false) : null,
      child: GestureDetector(
        onTap: widget.isEnabled ? () => context.go(widget.route) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..translate(0.0, widget.isEnabled && _isHovered ? -4.0 : 0.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.gradientColors[0].withValues(
                  alpha: widget.isEnabled ? 0.2 : 0.05,
                ),
                widget.gradientColors[1].withValues(
                  alpha: widget.isEnabled ? 0.1 : 0.03,
                ),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isEnabled && _isHovered
                  ? widget.gradientColors[0].withValues(alpha: 0.4)
                  : widget.themeColors.onSurface.withValues(
                      alpha: widget.isEnabled ? 0.1 : 0.05,
                    ),
              width: widget.isEnabled && _isHovered ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Opacity(
                  opacity: widget.isEnabled ? 0.05 : 0.02,
                  child: CustomPaint(
                    painter: GridPainter(
                      color: widget.gradientColors[0],
                      step: 20,
                    ),
                  ),
                ),
              ),
              // Disabled overlay
              if (!widget.isEnabled)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.themeColors.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: widget.isEnabled
                                  ? widget.gradientColors
                                  : [disabledColor, disabledColor],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: widget.isEnabled
                                ? [
                                    BoxShadow(
                                      color: widget.gradientColors[0]
                                          .withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            widget.icon,
                            color: widget.isEnabled 
                                ? widget.themeColors.onPrimary 
                                : disabledTextColor,
                            size: 28,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: widget.isEnabled
                                ? widget.gradientColors[0].withValues(alpha: 0.2)
                                : disabledColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.isEnabled
                                  ? widget.gradientColors[0].withValues(alpha: 0.3)
                                  : disabledColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            widget.stats,
                            style: TextStyle(
                              color: widget.isEnabled
                                  ? widget.gradientColors[0]
                                  : disabledTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.isEnabled 
                            ? widget.themeColors.onSurface 
                            : disabledTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.isEnabled 
                            ? widget.themeColors.onSurface.withValues(alpha: 0.6)
                            : disabledTextColor.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          widget.isEnabled ? 'Open' : 'Coming Soon',
                          style: TextStyle(
                            color: widget.isEnabled
                                ? widget.gradientColors[0]
                                : disabledTextColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (widget.isEnabled) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            size: 16,
                            color: widget.gradientColors[0],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}