// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ── Swipe hint ──────────────────────────────────────────────────────────
  Timer? _hintTimer;
  Timer? _hintAutoHideTimer;
  bool _showHint = false;
  late final AnimationController _hintSlide;
  late final AnimationController _hintFade;

  static const _hintDelay = Duration(seconds: 10);
  static const _hintVisible = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();

    // Repeating left-slide animation for the hand icon
    _hintSlide = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Fade-in / fade-out for the whole overlay
    _hintFade = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _hintFade.addStatusListener((status) {
      // After fade-out completes, hide the widget
      if (status == AnimationStatus.dismissed && _showHint) {
        if (mounted) setState(() => _showHint = false);
        _hintSlide.stop();
      }
    });

    _startHintTimer();
  }

  void _startHintTimer() {
    _hintTimer?.cancel();
    _hintTimer = Timer(_hintDelay, () {
      if (!mounted) return;
      setState(() => _showHint = true);
      _hintFade.forward();
      _hintSlide.repeat();
      // Auto-hide after _hintVisible seconds
      _hintAutoHideTimer?.cancel();
      _hintAutoHideTimer = Timer(_hintVisible, () {
        if (!mounted) return;
        _hintFade.reverse(); // triggers fade-out → StatusListener hides widget
        _hintSlide.stop();
      });
    });
  }

  void _dismissHint() {
    _hintTimer?.cancel();
    _hintAutoHideTimer?.cancel();
    if (_showHint) {
      setState(() => _showHint = false);
      _hintSlide.stop();
      _hintFade.reset();
    }
  }

  void _onUserInteracted() {
    _dismissHint();
    // Restart timer for the new page (except last page)
    if (_currentPage < 2) _startHintTimer();
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _hintAutoHideTimer?.cancel();
    _hintSlide.dispose();
    _hintFade.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // PageView Content (ផ្នែកខាងលើ)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _onUserInteracted();
                    },
                    children: [
                      OnboardingContent(
                        image: 'assets/images/onboarding/onboarding1.png',
                        title: t.translate('onboardingTitle1'),
                        description: t.translate('onboardingDescription1'),
                      ),
                      OnboardingContent(
                        image: 'assets/images/onboarding/onboarding2.png',
                        title: t.translate('onboardingTitle2'),
                        description: t.translate('onboardingDescription2'),
                      ),
                      OnboardingContent(
                        image: 'assets/images/onboarding/onboarding3.png',
                        title: t.translate('onboardingTitle3'),
                        description: t.translate('onboardingDescription3'),
                      ),
                    ],
                  ),
                ),

                // Bottom Section (Indicators + Button)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          3,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? const Color(0xFF2196F3)
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Next / Get Started Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              _onUserInteracted();
                              if (_currentPage == 2) {
                                // ទំព័រចុងក្រោយ: ទៅ Login
                                final pref =
                                    await SharedPreferences.getInstance();
                                await pref.setBool('isLogin', true);
                                if (!mounted) return;
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.loginScreen,
                                );
                              } else {
                                // ទំព័របន្ទាប់
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _currentPage == 2
                                      ? t.translate(
                                          'onboardingGetStartedButton')
                                      : t.translate('onboardingNextButton'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Skip button at top-right (visible on pages 1 & 2 only)
            if (_currentPage < 2)
              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: () async {
                    _onUserInteracted();
                    final pref = await SharedPreferences.getInstance();
                    await pref.setBool('isLogin', true);
                    if (!mounted) return;
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.loginScreen,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    t.translate('onboardingSkipButton'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // ── Swipe hint overlay ──────────────────────────────────
            if (_showHint)
              Positioned(
                bottom: 140,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _hintFade,
                  child: GestureDetector(
                    onTap: _dismissHint,
                    behavior: HitTestBehavior.translucent,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _hintSlide,
                              builder: (context, child) {
                                // Slide the icon left then back
                                final dx = -12.0 *
                                    Curves.easeInOut
                                        .transform(_hintSlide.value);
                                return Transform.translate(
                                  offset: Offset(dx, 0),
                                  child: child,
                                );
                              },
                              child: const Icon(
                                Icons.swipe_left_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Swipe',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
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

class OnboardingContent extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnboardingContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Image.asset(image, height: 280, fit: BoxFit.contain),

            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff212121),
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xff757575),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
