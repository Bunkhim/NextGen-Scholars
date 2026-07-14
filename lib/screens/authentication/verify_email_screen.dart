// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/controllers/authentication/verify_email_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String type; // 'phone' or 'email'
  final String destination; // phone number or email
  final String purpose; // 'forgotPassword' or 'register'

  const VerifyEmailScreen({
    super.key,
    required this.type,
    required this.destination,
    this.purpose = 'forgotPassword',
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  late final VerifyEmailController controller;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VerifyEmailController(
      type: widget.type,
      destination: widget.destination,
      purpose: widget.purpose,
    ));
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Gradient Header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1565C0),
                    Color(0xFF1976D2),
                    Color(0xFF2196F3),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 48),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          Expanded(
                            child: Text(
                              t.translate('verifyCodeTitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 38,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.translate('verifyCodeSubtitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                                text: '${t.translate('verifyCodeSentTo')}\n'),
                            TextSpan(
                              text: controller.maskedDestination(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Card Content ────────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.fromLTRB(8, 28, 8, 24),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // 6 OTP Boxes
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (i) {
                                return Obx(() {
                                  controller.codeVersion.value;
                                  final hasValue = controller
                                      .codeControllers[i].text.isNotEmpty;
                                  final isError = controller.error.value != null;

                                  return _OTPBox(
                                    controller: controller.codeControllers[i],
                                    focusNode: controller.focusNodes[i],
                                    hasValue: hasValue,
                                    isError: isError,
                                    colorScheme: cs,
                                    onChanged: (val) =>
                                        controller.onDigitChanged(i, val),
                                    onKeyDown: (event) {
                                      if (event is KeyDownEvent &&
                                          event.logicalKey ==
                                              LogicalKeyboardKey.backspace) {
                                        controller.onBackspaceAt(i);
                                      }
                                    },
                                  );
                                });
                              }),
                            ),

                            Obx(
                              () => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: controller.error.value != null
                                    ? Padding(
                                        key: const ValueKey('error'),
                                        padding: const EdgeInsets.only(top: 16),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline_rounded,
                                              size: 16,
                                              color: cs.error,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                controller.error.value!,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: cs.error,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox(
                                        key: ValueKey('empty'),
                                        height: 0,
                                      ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Obx(
                              () => !controller.canResend.value
                                  ? _TimerBadge(
                                      seconds: controller.remainingSeconds.value,
                                      colorScheme: cs,
                                    )
                                  : GestureDetector(
                                      onTap: () => controller.resendCode(t),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: cs.primary, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.refresh_rounded,
                                                size: 16, color: cs.primary),
                                            const SizedBox(width: 6),
                                            Text(
                                              t.translate('verifyCodeResend'),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: cs.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 24),

                            Obx(
                              () => SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: controller.isLoading.value
                                      ? null
                                      : () => controller.verifyCode(t),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: cs.onPrimary,
                                    disabledBackgroundColor:
                                        cs.onSurface.withOpacity(0.12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: controller.isLoading.value
                                      ? SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    cs.onPrimary),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.verified_user_rounded,
                                                size: 20, color: cs.onPrimary),
                                            const SizedBox(width: 8),
                                            Text(
                                              t.translate('verifyCodeButton'),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── OTP Box Widget ────────────────────────────────────────────────────────────

class _OTPBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasValue;
  final bool isError;
  final ColorScheme colorScheme;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyDown;

  const _OTPBox({
    required this.controller,
    required this.focusNode,
    required this.hasValue,
    required this.isError,
    required this.colorScheme,
    required this.onChanged,
    required this.onKeyDown,
  });

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;

    final Color borderColor = isError
        ? cs.error
        : hasValue
            ? cs.primary
            : cs.outlineVariant;

    final Color fillColor = isError
        ? cs.errorContainer.withOpacity(0.3)
        : hasValue
            ? cs.primaryContainer.withOpacity(0.3)
            : cs.surfaceContainerHighest.withOpacity(0.4);

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyDown,
      child: SizedBox(
        width: 44,
        height: 56,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: hasValue && !isError
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primary.withOpacity(0.12),
                      cs.primary.withOpacity(0.22),
                    ],
                  )
                : null,
            color: hasValue && !isError ? null : fillColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: hasValue ? 2.2 : 1.8,
            ),
            boxShadow: hasValue && !isError
                ? [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
            cursorColor: cs.primary,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isError
                  ? cs.error
                  : hasValue
                      ? cs.primary
                      : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Timer Badge Widget ────────────────────────────────────────────────────────

class _TimerBadge extends StatelessWidget {
  final int seconds;
  final ColorScheme colorScheme;

  const _TimerBadge({required this.seconds, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cs = colorScheme;
    final double progress = seconds / 60.0;

    return Column(
      children: [
        Text(
          t.translate('verifyCodeDidntReceive'),
          style: TextStyle(
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 2.5,
                backgroundColor: cs.outlineVariant,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${t.translate('verifyCodeResendIn')} ${seconds}s',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}