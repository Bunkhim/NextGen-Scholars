import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/session_security_service.dart';

class SessionSecurityController extends GetxController {
  final SessionSecurityService _service = SessionSecurityService();

  final RxBool isValidating = false.obs;
  final RxBool isSessionExpired = false.obs;

  Future<bool> validateSession() async {
    isValidating.value = true;

    try {
      final isValid = await _service.isSessionValid();

      if (!isValid) {
        isSessionExpired.value = true;
        await _service.forceLogout();
      } else {
        isSessionExpired.value = false;
      }

      return isValid;
    } catch (e) {
      debugPrint('Error validating session: $e');
      return false;
    } finally {
      isValidating.value = false;
    }
  }

  Future<void> recordSuccessfulLogin() async {
    try {
      await _service.recordLogin();
      isSessionExpired.value = false;
    } catch (e) {
      debugPrint('Error recording login: $e');
    }
  }

  Future<void> handleManualLogout() async {
    try {
      await _service.clearLoginTimestamp();
      await _service.forceLogout();
      isSessionExpired.value = true;
    } catch (e) {
      debugPrint('Error during manual logout: $e');
    }
  }
}
