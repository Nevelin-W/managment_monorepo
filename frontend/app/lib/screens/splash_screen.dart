import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showGlitch = false;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Scale animation for bear
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    
    // Single fade controller for all fade animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _scaleController.forward();
    _fadeController.forward();
    _startGlitchEffect();
    _navigateToNextScreen();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();

    if (authProvider.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  void _startGlitchEffect() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _triggerRandomGlitch();
    });
  }

  void _triggerRandomGlitch() {
    if (!mounted) return;
    if (math.Random().nextDouble() > 0.7) {
      setState(() => _showGlitch = true);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) setState(() => _showGlitch = false);
      });
    }
    Future.delayed(const Duration(seconds: 2), _triggerRandomGlitch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF111827),
              Color(0xFF1F2937),
              Color(0xFF111827),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Static grid background - no animation
            const Positioned.fill(
              child: RepaintBoundary(
                child: GridBackground(),
              ),
            ),

            // Static glow effects - simplified
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              left: MediaQuery.of(context).size.width * 0.25,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF10B981).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.25,
              right: MediaQuery.of(context).size.width * 0.25,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF059669).withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pixel Bear - cached and optimized
                  RepaintBoundary(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _showGlitch
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.translate(
                                  offset: const Offset(-2, -2),
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF10B981),
                                      BlendMode.modulate,
                                    ),
                                    child: Opacity(
                                      opacity: 0.7,
                                      child: Image.asset(
                                        'assets/images/pixel_bear.png',
                                        width: 200,
                                        height: 200,
                                        filterQuality: FilterQuality.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(2, 2),
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.red,
                                      BlendMode.modulate,
                                    ),
                                    child: Opacity(
                                      opacity: 0.7,
                                      child: Image.asset(
                                        'assets/images/pixel_bear.png',
                                        width: 200,
                                        height: 200,
                                        filterQuality: FilterQuality.none,
                                      ),
                                    ),
                                  ),
                                ),
                                Image.asset(
                                  'assets/images/pixel_bear.png',
                                  width: 200,
                                  height: 200,
                                  filterQuality: FilterQuality.none,
                                ),
                              ],
                            )
                          : Image.asset(
                              'assets/images/pixel_bear.png',
                              width: 200,
                              height: 200,
                              filterQuality: FilterQuality.none,
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Brand name - single animation controller
                  RepaintBoundary(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (_showGlitch) ...[
                              Transform.translate(
                                offset: const Offset(-2, -2),
                                child: Opacity(
                                  opacity: 0.7,
                                  child: _buildBrandText(const Color(0xFF10B981)),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(2, 2),
                                child: Opacity(
                                  opacity: 0.7,
                                  child: _buildBrandText(Colors.red),
                                ),
                              ),
                            ],
                            _buildBrandText(Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tagline - simplified animation
                  RepaintBoundary(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        '> Just the essentials_',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Loading bar
                  const RepaintBoundary(
                    child: LoadingBar(),
                  ),
                ],
              ),
            ),

            // Vignette effect - static
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.center,
                      radius: 1.0,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
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

  Widget _buildBrandText(Color color) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: 40,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: color,
          shadows: const [
            Shadow(
              color: Color(0xFF10B981),
              blurRadius: 15,
            ),
          ],
        ),
        children: const [
          TextSpan(text: 'Bear'),
          TextSpan(
            text: 'Minimum',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

// Static grid background - no animations
class GridBackground extends StatelessWidget {
  const GridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.15,
      child: CustomPaint(
        painter: GridPainter(),
      ),
    );
  }
}

// Optimized loading bar - single animation controller
class LoadingBar extends StatefulWidget {
  const LoadingBar({super.key});

  @override
  State<LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<LoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 192,
          height: 12,
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            border: Border.all(
              color: const Color(0xFF4B5563),
              width: 2,
            ),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 192 * _progressAnimation.value,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF059669),
                        Color(0xFF10B981),
                        Color(0xFF34D399),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        const LoadingDots(),
      ],
    );
  }
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LOADING',
              style: TextStyle(
                color: Color(0xFF10B981),
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w500,
              ),
            ),
            _buildDot(0),
            _buildDot(1),
            _buildDot(2),
          ],
        );
      },
    );
  }

  Widget _buildDot(int index) {
    final value = ((_controller.value * 3) - index).clamp(0.0, 1.0);
    final opacity = (1 - (1 - value).abs()).clamp(0.0, 1.0);

    return Text(
      '.',
      style: TextStyle(
        color: Color.fromRGBO(16, 185, 129, opacity),
        fontSize: 10,
        fontFamily: 'monospace',
      ),
    );
  }
}

// Grid painter - cached
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..isAntiAlias = false;

    const step = 40.0;
    
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