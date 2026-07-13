import 'package:flutter/material.dart';
import 'package:scholarship_app/services/session_security_service.dart';

// import 'package:your_app/services/session_security_service.dart';

class SessionSecurityController extends ChangeNotifier {
  final SessionSecurityService _service = SessionSecurityService();

  bool _isValidating = false;
  bool _isSessionExpired = false;

  // Getters for the UI (e.g., to show a loading spinner on the splash screen)
  bool get isValidating => _isValidating;
  
  // Useful if you want to show a specific "Session Expired. Please log in again." dialog
  bool get isSessionExpired => _isSessionExpired;

  /// Validates the current session. 
  /// Automatically triggers a forced logout if the 7-day window has expired.
  /// Returns `true` if valid, `false` if expired or no user is logged in.
  Future<bool> validateSession() async {
    _isValidating = true;
    notifyListeners();

    try {
      final isValid = await _service.isSessionValid();
      
      if (!isValid) {
        _isSessionExpired = true;
        await _service.forceLogout();
      } else {
        _isSessionExpired = false;
      }
      
      return isValid;
    } catch (e) {
      debugPrint('Error validating session: $e');
      return false;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  /// Records the login timestamp. 
  /// ⚠️ MUST call this immediately after a successful Firebase login.
  Future<void> recordSuccessfulLogin() async {
    try {
      await _service.recordLogin();
      _isSessionExpired = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error recording login: $e');
    }
  }

  /// Handles explicit user logout actions.
  Future<void> handleManualLogout() async {
    try {
      await _service.clearLoginTimestamp();
      await _service.forceLogout();
      _isSessionExpired = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during manual logout: $e');
    }
  }
}