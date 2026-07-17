import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/core/api/services/auth_api_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class ResetPasswordController extends GetxController {
  final String email;
  ResetPasswordController({required this.email});

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool isLoading = false.obs;
  final RxnString passwordError = RxnString();
  final RxnString confirmError = RxnString();
  final RxnString errorMessage = RxnString();

  final _authApi = AuthApiService();

  @override
  void onClose() {
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() => obscurePassword.value = !obscurePassword.value;
  void toggleConfirmVisibility() => obscureConfirm.value = !obscureConfirm.value;

  void clearPasswordError() {
    if (passwordError.value != null) passwordError.value = null;
  }

  void clearConfirmError() {
    if (confirmError.value != null) confirmError.value = null;
  }

  bool _isValidPassword(String p) {
    return p.length >= 8 &&
        p.contains(RegExp(r'[A-Z]')) &&
        p.contains(RegExp(r'[a-z]')) &&
        p.contains(RegExp(r'[0-9]')) &&
        p.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  Future<void> handleReset(AppLocalizations t) async {
    errorMessage.value = null;
    passwordError.value = null;
    confirmError.value = null;

    final pwd = passwordController.text;
    final confirm = confirmController.text;

    if (pwd.isEmpty) {
      passwordError.value = t.translate('registerPasswordRequired');
      return;
    }
    if (!_isValidPassword(pwd)) {
      passwordError.value = t.translate('registerPasswordInvalid');
      return;
    }
    if (confirm != pwd) {
      confirmError.value = t.translate('registerPasswordsMismatch');
      return;
    }

    if (email.isEmpty) {
      errorMessage.value = t.translate('resetPasswordSessionExpired');
      return;
    }

    isLoading.value = true;

    try {
      final res = await _authApi.resetPassword(
        email: email,
        newPassword: pwd,
      );

      isLoading.value = false;

      if (res.containsKey('success')) {
        Get.snackbar(
          '',
          t.translate('resetPasswordSuccess'),
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 1200));
        Get.offAllNamed(AppRoutes.loginScreen);
      } else {
        errorMessage.value =
            res['detail'] as String? ?? t.translate('resetPasswordFailed');
      }
    } catch (_) {
      isLoading.value = false;
      errorMessage.value = t.translate('resetPasswordFailed');
    }
  }
}
