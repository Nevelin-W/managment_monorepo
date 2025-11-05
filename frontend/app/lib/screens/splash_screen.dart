import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../config/theme.dart';  // Import ThemeColors from here
import '../widgets/bear_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme colors from provider
    final themeColors = context.watch<ThemeProvider>().themeColors;
    
    return Scaffold(
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
            // Dynamic grid background
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: GridPainter(color: themeColors.primary),
                ),
              ),
            ),

            // Animated glow effects with theme colors
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.2,
                      left: MediaQuery.of(context).size.width * 0.15,
                      child: Container(
                        width: 250 * _pulseAnimation.value,
                        height: 250 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              themeColors.primary
                                  .withValues(alpha: 0.2 * _pulseAnimation.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: MediaQuery.of(context).size.height * 0.2,
                      right: MediaQuery.of(context).size.width * 0.15,
                      child: Container(
                        width: 250 * _pulseAnimation.value,
                        height: 250 * _pulseAnimation.value,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              themeColors.tertiary
                                  .withValues(alpha: 0.15 * _pulseAnimation.value),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Bear Logo with themed styling
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  themeColors.primary.withValues(alpha: 0.2),
                                  themeColors.tertiary.withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(
                                color: themeColors.primary.withValues(alpha: 0.4),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColors.primary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 40,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: BearLogo(
                                width: 120,
                                height: 120,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // Brand name with theme-colored accent
                    ShaderMask(
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
                          style: const TextStyle(
                            fontSize: 48,
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
                    ),

                    const SizedBox(height: 16),

                    // Tagline with theme color
                    Text(
                      '> Just the essentials_',
                      style: TextStyle(
                        color: themeColors.primary,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 64),

                    // Themed orbital loading indicator
                    OrbitalLoadingIndicator(colors: themeColors),
                  ],
                ),
              ),
            ),

            // Subtle vignette
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Orbital loading indicator with custom colors
class OrbitalLoadingIndicator extends StatefulWidget {
  final ThemeColors colors;

  const OrbitalLoadingIndicator({
    super.key,
    required this.colors,
  });

  @override
  State<OrbitalLoadingIndicator> createState() =>
      _OrbitalLoadingIndicatorState();
}

class _OrbitalLoadingIndicatorState extends State<OrbitalLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Orbital rings
              for (int i = 0; i < 3; i++)
                Transform.rotate(
                  angle: (_controller.value * 6.28) + (i * 2.09),
                  child: Container(
                    width: 60 - (i * 15.0),
                    height: 60 - (i * 15.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getRingColor(i).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              // Orbiting dots with different colors
              for (int i = 0; i < 3; i++)
                Transform.rotate(
                  angle: (_controller.value * 6.28) + (i * 2.09),
                  child: Transform.translate(
                    offset: Offset(30 - (i * 7.5), 0),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.9),
                            _getRingColor(i),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getRingColor(i).withValues(alpha: 0.8),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Center pulse
              Transform.scale(
                scale: 1.0 + (0.2 * (1 - (_controller.value * 2 - 1).abs())),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        widget.colors.primary,
                        widget.colors.secondary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.colors.primary.withValues(alpha: 0.8),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getRingColor(int index) {
    switch (index) {
      case 0:
        return widget.colors.primary;
      case 1:
        return widget.colors.secondary;
      case 2:
        return widget.colors.tertiary;
      default:
        return widget.colors.primary;
    }
  }
}

// Grid painter with custom color
class GridPainter extends CustomPainter {
  final Color color;

  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..isAntiAlias = false;

    const step = 50.0;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}