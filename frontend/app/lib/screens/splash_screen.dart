import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _showGlitch = false;

  @override
  void initState() {
    super.initState();
    _startGlitchEffect();
    _navigateToNextScreen();
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
            // Scanlines effect
            // Positioned.fill(
            //   child: Opacity(
            //     opacity: 0.1,
            //     child: CustomPaint(
            //       painter: ScanlinesPainter(),
            //     ),
            //   ),
            // ),

            // Grid background
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: CustomPaint(
                  painter: GridPainter(),
                ),
              ).animate().fadeIn(duration: 1000.ms, delay: 300.ms),
            ),

            // Glow effects
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
                        const Color(0xFF10B981).withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                )),

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
                      const Color(0xFF059669).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 2000.ms, delay: 800.ms),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pixel Bear
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glitch copies
                      if (_showGlitch) ...[
                        Transform.translate(
                          offset: const Offset(-2, -2),
                          child: const Opacity(
                            opacity: 0.7,
                            child: PixelBear(
                              color: Color(0xFF10B981),
                              phase: 4,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(2, 2),
                          child: const Opacity(
                            opacity: 0.7,
                            child: PixelBear(
                              color: Colors.red,
                              phase: 4,
                            ),
                          ),
                        ),
                      ],
                      // Main bear
                      const PixelBear(phase: 4).animate().scale(
                            begin: const Offset(0.75, 0.75),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                            curve: Curves.easeOutBack,
                          )
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Brand name with glitch effect
                  Stack(
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
                  ).animate().fadeIn(duration: 700.ms, delay: 200.ms).slideY(
                      begin: 0.2, end: 0, duration: 700.ms, delay: 200.ms),

                  const SizedBox(height: 16),

                  // Tagline
                  const Text(
                    '> Just the essentials_',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontFamily: 'monospace',
                      letterSpacing: 2,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 700.ms, delay: 400.ms).slideY(
                      begin: 0.2, end: 0, duration: 700.ms, delay: 400.ms),

                  const SizedBox(height: 48),

                  // Loading bar
                  Column(
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
                        child: Stack(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: const Duration(seconds: 2),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Container(
                                  width: 192 * value,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF059669),
                                        Color(0xFF10B981),
                                        Color(0xFF34D399),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981)
                                            .withOpacity(0.5),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                )
                                    // shimmer animation overlay
                                    .animate(
                                        onPlay: (controller) =>
                                            controller.repeat())
                                    .shimmer(
                                      duration: 2000.ms,
                                      color: Colors.white.withOpacity(0.3),
                                    );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
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
                          const Text('.',
                                  style: TextStyle(color: Color(0xFF10B981)))
                              .animate(onPlay: (c) => c.repeat())
                              .fadeIn(duration: 500.ms)
                              .fadeOut(duration: 500.ms),
                          const Text('.',
                                  style: TextStyle(color: Color(0xFF10B981)))
                              .animate(onPlay: (c) => c.repeat())
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .fadeOut(duration: 500.ms, delay: 200.ms),
                          const Text('.',
                                  style: TextStyle(color: Color(0xFF10B981)))
                              .animate(onPlay: (c) => c.repeat())
                              .fadeIn(duration: 500.ms, delay: 400.ms)
                              .fadeOut(duration: 500.ms, delay: 400.ms),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Vignette effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
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
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 40,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          color: color,
          shadows: [
            Shadow(
              color: const Color(0xFF10B981).withOpacity(0.5),
              blurRadius: 20,
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

// Custom painters for effects
class ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981).withOpacity(0.1)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Pixel Bear Widget
class PixelBear extends StatelessWidget {
  final int phase;
  final Color? color;

  const PixelBear({super.key, this.phase = 4, this.color});

  // Cache for pre-rendered PixelBear pictures
  static final Map<int, ui.Picture> _cache = {};

  @override
  Widget build(BuildContext context) {
    // Only render and cache if not already cached
    if (!_cache.containsKey(phase)) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      PixelBearPainter(phase: phase, pixelSize: 5)
          .paint(canvas, const Size(200, 200));
      _cache[phase] = recorder.endRecording();
    }

    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: PicturePainter(_cache[phase]!),
      ),
    );
  }
}

// CustomPainter that draws a cached Picture
class PicturePainter extends CustomPainter {
  final ui.Picture picture;
  const PicturePainter(this.picture);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPicture(picture);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Original PixelBearPainter (your previous painter, unchanged)
class PixelBearPainter extends CustomPainter {
  final int phase;
  final double pixelSize;

  PixelBearPainter({required this.phase, required this.pixelSize});

  void drawPixel(Canvas canvas, int x, int y, Color color,
      {double opacity = 1.0}) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(x.toDouble() * pixelSize, y.toDouble() * pixelSize,
          pixelSize, pixelSize),
      paint,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Ears
    if (phase >= 2) {
      for (int i = 0; i < 5; i++) {
        for (int j = 0; j < 5; j++) {
          drawPixel(canvas, 8 + i, 9 + j, const Color(0xFF1F2937));
          drawPixel(canvas, 27 + i, 9 + j, const Color(0xFF1F2937));
        }
      }
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          drawPixel(canvas, 9 + i, 10 + j, const Color(0xFF374151));
          drawPixel(canvas, 28 + i, 10 + j, const Color(0xFF374151));
        }
      }
      drawPixel(canvas, 10, 11, const Color(0xFF4B5563));
      drawPixel(canvas, 29, 11, const Color(0xFF4B5563));
    }

    // Head
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 14; j++) {
        drawPixel(canvas, 12 + i, 12 + j, const Color(0xFF1F2937));
      }
    }
    for (int i = 0; i < 14; i++) {
      for (int j = 0; j < 12; j++) {
        drawPixel(canvas, 13 + i, 13 + j, const Color(0xFF374151));
      }
    }
    for (int i = 0; i < 12; i++) {
      for (int j = 0; j < 10; j++) {
        drawPixel(canvas, 14 + i, 14 + j, const Color(0xFF4B5563));
      }
    }

    // Eyes with emerald glow
    if (phase >= 3) {
      // Left eye
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          drawPixel(canvas, 15 + i, 17 + j, Colors.black);
        }
      }
      drawPixel(canvas, 15, 17, const Color(0xFF10B981));
      drawPixel(canvas, 16, 17, const Color(0xFF10B981));
      drawPixel(canvas, 16, 18, const Color(0xFF6EE7B7));

      // Right eye
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          drawPixel(canvas, 22 + i, 17 + j, Colors.black);
        }
      }
      drawPixel(canvas, 22, 17, const Color(0xFF10B981));
      drawPixel(canvas, 23, 17, const Color(0xFF10B981));
      drawPixel(canvas, 23, 18, const Color(0xFF6EE7B7));

      // Snout
      for (int i = 0; i < 6; i++) {
        for (int j = 0; j < 4; j++) {
          drawPixel(canvas, 17 + i, 22 + j, const Color(0xFF6B7280));
        }
      }
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 2; j++) {
          drawPixel(canvas, 18 + i, 23 + j, const Color(0xFF9CA3AF));
        }
      }
      drawPixel(canvas, 19, 23, const Color(0xFF1F2937));
      drawPixel(canvas, 20, 23, const Color(0xFF1F2937));
      drawPixel(canvas, 19, 24, const Color(0xFF1F2937));
      drawPixel(canvas, 20, 24, const Color(0xFF1F2937));

      // Fangs
      drawPixel(canvas, 17, 25, const Color(0xFFE5E7EB));
      drawPixel(canvas, 22, 25, const Color(0xFFE5E7EB));
    }

    // Body
    if (phase >= 3) {
      for (int i = 0; i < 12; i++) {
        for (int j = 0; j < 8; j++) {
          drawPixel(canvas, 14 + i, 26 + j, const Color(0xFF1F2937));
        }
      }
      for (int i = 0; i < 10; i++) {
        for (int j = 0; j < 6; j++) {
          drawPixel(canvas, 15 + i, 27 + j, const Color(0xFF374151));
        }
      }
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 4; j++) {
          drawPixel(canvas, 16 + i, 28 + j, const Color(0xFF4B5563));
        }
      }
    }

    // Emerald heart
    if (phase >= 4) {
      drawPixel(canvas, 19, 29, const Color(0xFF10B981));
      drawPixel(canvas, 20, 29, const Color(0xFF10B981));
      drawPixel(canvas, 19, 30, const Color(0xFF10B981));
      drawPixel(canvas, 20, 30, const Color(0xFF10B981));
      drawPixel(canvas, 18, 30, const Color(0xFF10B981), opacity: 0.6);
      drawPixel(canvas, 21, 30, const Color(0xFF10B981), opacity: 0.6);
      drawPixel(canvas, 19, 31, const Color(0xFF059669));
      drawPixel(canvas, 20, 31, const Color(0xFF059669));
    }

    // Arms and claws
    if (phase >= 3) {
      // Left arm
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          drawPixel(canvas, 10 + i, 28 + j, const Color(0xFF1F2937));
        }
      }
      drawPixel(canvas, 11, 29, const Color(0xFF374151));
      drawPixel(canvas, 12, 29, const Color(0xFF374151));

      // Right arm
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          drawPixel(canvas, 26 + i, 28 + j, const Color(0xFF1F2937));
        }
      }
      drawPixel(canvas, 27, 29, const Color(0xFF374151));
      drawPixel(canvas, 28, 29, const Color(0xFF374151));
    }

    if (phase >= 4) {
      // Left claws
      for (int i = 0; i < 3; i++) {
        drawPixel(canvas, 9 + i, 32, const Color(0xFFD1D5DB));
        drawPixel(canvas, 9 + i, 33, const Color(0xFFD1D5DB));
        drawPixel(canvas, 9 + i, 32, const Color(0xFF10B981), opacity: 0.4);
      }

      // Right claws
      for (int i = 0; i < 3; i++) {
        drawPixel(canvas, 28 + i, 32, const Color(0xFFD1D5DB));
        drawPixel(canvas, 28 + i, 33, const Color(0xFFD1D5DB));
        drawPixel(canvas, 28 + i, 32, const Color(0xFF10B981), opacity: 0.4);
      }
    }

    // Legs
    if (phase >= 3) {
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          drawPixel(canvas, 14 + i, 34 + j, const Color(0xFF1F2937));
          drawPixel(canvas, 23 + i, 34 + j, const Color(0xFF1F2937));
        }
      }
      drawPixel(canvas, 15, 35, const Color(0xFF374151));
      drawPixel(canvas, 24, 35, const Color(0xFF374151));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
