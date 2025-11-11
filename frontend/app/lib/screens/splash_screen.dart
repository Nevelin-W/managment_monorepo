import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../config/theme.dart';
import '../utils/app_constants.dart';
import '../widgets/common/bear_logo.dart';
import '../widgets/common/grid_painter.dart';
import '../widgets/common/orbital_loading_indicator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _navigated = false;

  static const _animationDuration = Duration(milliseconds: 1200);
  static const _navigationDelay = Duration(milliseconds: 2500);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _scheduleNavigation();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: _animationDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  void _scheduleNavigation() {
    Future.delayed(_navigationDelay, _navigateToNextScreen);
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted || _navigated) return;
    _navigated = true;

    final authProvider = context.read<AuthProvider>();
    final route = authProvider.isAuthenticated ? '/home' : '/login';

    if (mounted) {
      context.go(route);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = context.select<ThemeProvider, ThemeColors>(
      (provider) => provider.themeColors,
    );

    return Scaffold(
      body: _SplashBody(
        themeColors: themeColors,
        fadeAnimation: _fadeAnimation,
      ),
    );
  }
}

class _SplashBody extends StatelessWidget {
  final ThemeColors themeColors;
  final Animation<double> fadeAnimation;

  const _SplashBody({
    required this.themeColors,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildGridBackground(),
          _buildGlowEffects(context),
          _buildMainContent(),
          _buildVignette(),
        ],
      ),
    );
  }

  Widget _buildGridBackground() {
    return Positioned.fill(
      child: Opacity(
        opacity: AppOpacity.subtle,
        child: CustomPaint(
          painter: GridPainter(
            color: themeColors.primary,
            step: AppGridConstants.gridSpacing,
          ),
        ),
      ),
    );
  }

  Widget _buildGlowEffects(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        _buildGlow(
          top: size.height * 0.2,
          left: size.width * 0.15,
          size: AppGridConstants.glowSize,
          color: themeColors.primary,
          opacity: AppOpacity.light,
        ),
        _buildGlow(
          bottom: size.height * 0.2,
          right: size.width * 0.15,
          size: AppGridConstants.glowSize,
          color: themeColors.tertiary,
          opacity: 0.15,
        ),
      ],
    );
  }

  Widget _buildGlow({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
    required double opacity,
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
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: opacity),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildBearLogo(),
            SizedBox(height: AppSpacing.xxxl + AppSpacing.lg),
            _buildBrandName(),
            SizedBox(height: AppSpacing.lg),
            _buildTagline(),
            SizedBox(height: AppSpacing.xxxl * 2),
            OrbitalLoadingIndicator(colors: themeColors),
          ],
        ),
      ),
    );
  }

  Widget _buildBearLogo() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeColors.primary.withValues(alpha: AppOpacity.light),
            themeColors.tertiary.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(AppBorderRadius.cardLarge * 2),
        border: Border.all(
          color: themeColors.primary.withValues(
            alpha: AppOpacity.medium + AppOpacity.subtle,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: themeColors.primary.withValues(
              alpha: AppOpacity.medium + AppOpacity.subtle,
            ),
            blurRadius: 40,
            spreadRadius: 0,
          ),
        ],
      ),
      child: const Center(
        child: BearLogo(
          width: 120,
          height: 120,
        ),
      ),
    );
  }

  Widget _buildBrandName() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          Colors.white,
          themeColors.primary,
          Colors.white,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text.rich(
        TextSpan(
          style: TextStyle(
            fontSize: AppFontSize.xxxl + AppBorderRadius.xl,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -1,
          ),
          children: const [
            TextSpan(text: 'Bear'),
            TextSpan(
              text: 'Minimum',
              style: TextStyle(fontWeight: FontWeight.w300),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTagline() {
    return Text(
      '> Just the essentials_',
      style: TextStyle(
        color: themeColors.primary,
        fontSize: AppFontSize.caption,
        fontFamily: 'monospace',
        letterSpacing: 2,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildVignette() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: AppOpacity.medium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}