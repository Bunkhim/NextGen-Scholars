import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/email_otp_service.dart';
import 'package:scholarship_app/services/phone_otp_service.dart';

class VerifyEmailController extends GetxController {
  final String type; // 'phone' or 'email'
  final String destination; // phone number or email
  final String purpose; // 'forgotPassword' or 'register'

  VerifyEmailController({
    required this.type,
    required this.destination,
    this.purpose = 'forgotPassword',
  });

  final List<TextEditingController> codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  final PhoneOTPService _phoneOtpService = PhoneOTPService();
  final EmailOTPService _emailOtpService = EmailOTPService();

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxInt remainingSeconds = 60.obs;
  final RxBool canResend = false.obs;
  final RxInt codeVersion = 0.obs; // bumped to trigger OTP box rebuilds

  @override
  void onInit() {
    super.onInit();
    _startResendTimer();
  }

  @override
  void onClose() {
    for (var c in codeControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }

  // ── Timer ────────────────────────────────────────────────────────────────
  void _startResendTimer() {
    remainingSeconds.value = 60;
    canResend.value = false;
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      remainingSeconds.value--;
      if (remainingSeconds.value <= 0) {
        canResend.value = true;
      } else {
        _tick();
      }
    });
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  String getOTPCode() => codeControllers.map((c) => c.text).join();

  String maskedDestination() {
    final d = destination;
    if (d.contains('@')) {
      final parts = d.split('@');
      final name = parts[0];
      return '${name.substring(0, name.length.clamp(0, 3))}***@${parts[1]}';
    }
    if (d.length > 4) {
      return '${d.substring(0, d.length - 4)}****';
    }
    return d;
  }

  void onDigitChanged(int index, String val) {
    codeVersion.value++;
    if (val.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    }
    if (val.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
    if (error.value != null) error.value = null;
  }

  void onBackspaceAt(int index) {
    if (codeControllers[index].text.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }
  }

  // ── Verify ───────────────────────────────────────────────────────────────
  Future<void> verifyCode(AppLocalizations t) async {
    error.value = null;

    final code = getOTPCode();
    if (code.length < 6) {
      error.value = t.translate('verifyCodeEnterAllDigits');
      return;
    }

    isLoading.value = true;

    String? errorMsg;
    if (type == 'phone') {
      errorMsg = await _phoneOtpService.verifyOTP(
        phoneNumber: destination,
        code: code,
      );
    } else {
      errorMsg = await _emailOtpService.verifyOTP(
        email: destination,
        code: code,
      );
    }

    if (errorMsg == null) {
      isLoading.value = false;
      Get.snackbar(
        '',
        t.translate('verifyCodeSuccess'),
        backgroundColor: const Color(0xff10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 900));

      if (purpose == 'forgotPassword') {
        String email = destination;
        if (type == 'phone') {
          try {
            final snap = await FirebaseFirestore.instance
                .collection('users')
                .where('phone', isEqualTo: destination)
                .limit(1)
                .get();
            if (snap.docs.isNotEmpty) {
              email = snap.docs.first.data()['email'] ?? '';
            }
          } catch (_) {}
        }
        Get.offAllNamed(
          AppRoutes.resetPasswordScreen,
          arguments: {'email': email},
        );
      } else {
        Get.offAllNamed(AppRoutes.homeScreen);
      }
    } else {
      isLoading.value = false;
      error.value = errorMsg;
    }
  }

  // ── Resend ───────────────────────────────────────────────────────────────
  Future<void> resendCode(AppLocalizations t) async {
    if (!canResend.value) return;
    error.value = null;
    isLoading.value = true;

    String? errorMsg;

    if (type == 'phone') {
      errorMsg = await _phoneOtpService.sendOTP(phoneNumber: destination);
    } else {
      errorMsg = await _emailOtpService.sendOTP(email: destination);
    }

    if (errorMsg == null) {
      isLoading.value = false;
      canResend.value = false;
      Get.snackbar(
        '',
        t.translate('verifyCodeNewCodeSent'),
        backgroundColor: const Color(0xff2196F3),
        colorText: Colors.white,
        icon: const Icon(Icons.send_rounded, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      _startResendTimer();
    } else {
      isLoading.value = false;
      error.value = errorMsg;
    }
  }
}