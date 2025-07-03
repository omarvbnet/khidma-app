import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _routeController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _backgroundOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _routeController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    ));

    // Text animations
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    // Background animations
    _backgroundOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    ));

    // Start animations in sequence
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Wait for logo animation to complete then start text animation
    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    // Start route animation
    _routeController.repeat(reverse: false);

    // Navigate to login screen after animations complete
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _routeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appName = AppLocalizations.of(context)?.appTitle ?? 'Waddiny';
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Logo section
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _logoScaleAnimation.value,
                  child: Opacity(
                    opacity: _logoOpacityAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/waddiny.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // App name section
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return SlideTransition(
                  position: _textSlideAnimation,
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Column(
                      children: [
                        // Main app title
                        Text(
                          appName,
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 5,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          AppLocalizations.of(context)?.appSubtitle ??
                              'Smart Transportation Service',
                          style: TextStyle(
                            color: const Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),

            // Animated route/map
            SizedBox(
              width: 180,
              height: 80,
              child: AnimatedBuilder(
                animation: _routeController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _RoutePainter(_routeController.value),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Loading indicator
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _textFadeAnimation,
                  child: Container(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF3B82F6),
                      ),
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // Decorative elements
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _backgroundOpacityAnimation.value,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDecorativeDot(
                          const Color(0xFF3B82F6).withOpacity(0.3)),
                      const SizedBox(width: 8),
                      _buildDecorativeDot(
                          const Color(0xFF3B82F6).withOpacity(0.5)),
                      const SizedBox(width: 8),
                      _buildDecorativeDot(
                          const Color(0xFF3B82F6).withOpacity(0.7)),
                    ],
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final double progress;
  _RoutePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final carPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;

    // Draw a simple polyline (route)
    final path = Path();
    path.moveTo(20, size.height - 20);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.7,
      size.height * 0.9,
      size.width - 20,
      20,
    );
    canvas.drawPath(path, routePaint);

    // Animate car along the path
    final metric = path.computeMetrics().first;
    final pos = metric.getTangentForOffset(metric.length * progress);
    if (pos != null) {
      // Draw car as a circle (or you can use an icon)
      canvas.save();
      canvas.translate(pos.position.dx, pos.position.dy);
      canvas.rotate(pos.angle);
      // Car body
      canvas.drawRect(
          Rect.fromCenter(center: Offset(0, 0), width: 22, height: 12),
          carPaint);
      // Car roof
      canvas.drawRect(
          Rect.fromCenter(center: Offset(0, -4), width: 10, height: 6),
          Paint()..color = const Color(0xFF60A5FA));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
