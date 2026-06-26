import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/session_security_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'splash_screen_binding.dart';
part 'splash_screen_controller.dart';

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bgRotation;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;

  late final ctrl = Get.find<SplashScreenViewController>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _bgRotation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(_backgroundController);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat();
    _pulseAnimation =
        Tween<double>(begin: 0.8, end: 1.4).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeOut,
    ));

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
    ));
    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) ctrl.navigateToNext();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF1976D2),
                  Color(0xFF2196F3),
                  Color(0xFF42A5F5),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _bgRotation,
            builder: (context, child) {
              return CustomPaint(
                size: size,
                painter: _SplashBgPainter(
                  rotation: _bgRotation.value,
                  size: size,
                ),
              );
            },
          ),

          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _logoFade,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Opacity(
                              opacity:
                                  (1.4 - _pulseAnimation.value).clamp(0.0, 0.3),
                              child: Container(
                                width: size.width * 0.45,
                                height: size.width * 0.45,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ScaleTransition(
                            scale: _logoScale,
                            child: Container(
                              width: size.width * 0.38,
                              height: size.width * 0.38,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0D47A1)
                                        .withOpacity(0.3),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(size.width * 0.06),
                              child: Image.asset(
                                "assets/icons/NextGen_LOGO.jpeg",
                                fit: BoxFit.contain,
                                cacheWidth: 512,
                                cacheHeight: 512,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.school_rounded,
                                    size: size.width * 0.15,
                                    color: const Color(0xFF1976D2),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: Column(
                      children: [
                        Text(
                          'NextGen Scholars',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [
                              Shadow(
                                color: const Color(0xFF0D47A1).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your Future Starts Here',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.85),
                            letterSpacing: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBgPainter extends CustomPainter {
  final double rotation;
  final Size size;

  _SplashBgPainter({required this.rotation, required this.size});

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;

    paint.color = Colors.white.withOpacity(0.04);
    canvas.drawCircle(
      Offset(
        cx + math.cos(rotation) * size.width * 0.3,
        cy + math.sin(rotation) * size.height * 0.2,
      ),
      size.width * 0.6,
      paint,
    );

    paint.color = Colors.white.withOpacity(0.03);
    canvas.drawCircle(
      Offset(
        cx + math.cos(rotation + math.pi) * size.width * 0.2,
        cy + math.sin(rotation + math.pi) * size.height * 0.3,
      ),
      size.width * 0.45,
      paint,
    );

    paint.color = Colors.white.withOpacity(0.05);
    canvas.drawCircle(
      Offset(
        cx + math.cos(rotation * 0.5 + 1) * size.width * 0.4,
        cy * 0.3 + math.sin(rotation * 0.7) * size.height * 0.1,
      ),
      size.width * 0.3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SplashBgPainter old) =>
      old.rotation != rotation;
}
