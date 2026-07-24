import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/core/api/services/auth_api_service.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/session_security_service.dart';
import 'package:scholarship_app/services/user_data_sync_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isFacebookLoading = false.obs;
  bool _isDisposed = false;

  // Per-method rate limit cooldown state
  final RxBool isEmailRateLimited = false.obs;
  final RxInt emailRateLimitCountdown = 0.obs;
  Timer? _emailRateLimitTimer;

  final RxBool isGoogleRateLimited = false.obs;
  final RxInt googleRateLimitCountdown = 0.obs;
  Timer? _googleRateLimitTimer;

  final RxBool isFacebookRateLimited = false.obs;
  final RxInt facebookRateLimitCountdown = 0.obs;
  Timer? _facebookRateLimitTimer;

  final _authApi = AuthApiService();
  final _jwt = JwtService();

  bool get anyLoading =>
      isLoading.value || isGoogleLoading.value || isFacebookLoading.value;

  @override
  void onClose() {
    _isDisposed = true;
    _emailRateLimitTimer?.cancel();
    _googleRateLimitTimer?.cancel();
    _facebookRateLimitTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  void _startEmailRateLimitCooldown() {
    isEmailRateLimited.value = true;
    emailRateLimitCountdown.value = 60;
    _emailRateLimitTimer?.cancel();
    _emailRateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      emailRateLimitCountdown.value--;
      if (emailRateLimitCountdown.value <= 0) {
        timer.cancel();
        isEmailRateLimited.value = false;
        emailRateLimitCountdown.value = 0;
      }
    });
  }

  void _startGoogleRateLimitCooldown() {
    isGoogleRateLimited.value = true;
    googleRateLimitCountdown.value = 60;
    _googleRateLimitTimer?.cancel();
    _googleRateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      googleRateLimitCountdown.value--;
      if (googleRateLimitCountdown.value <= 0) {
        timer.cancel();
        isGoogleRateLimited.value = false;
        googleRateLimitCountdown.value = 0;
      }
    });
  }

  void _startFacebookRateLimitCooldown() {
    isFacebookRateLimited.value = true;
    facebookRateLimitCountdown.value = 60;
    _facebookRateLimitTimer?.cancel();
    _facebookRateLimitTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      facebookRateLimitCountdown.value--;
      if (facebookRateLimitCountdown.value <= 0) {
        timer.cancel();
        isFacebookRateLimited.value = false;
        facebookRateLimitCountdown.value = 0;
      }
    });
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // ============ VALIDATION ============

  String? validateEmail(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('loginEmailRequired');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return t.translate('loginEmailInvalid');
    }
    return null;
  }

  String? validatePassword(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('loginPasswordRequired');
    }
    if (value.length < 8) {
      return t.translate('loginPasswordMinLength');
    }
    return null;
  }

  // ============ MESSAGES ============

  void _showSuccessMessage(String message, String subtitle) {
    Get.snackbar(
      message,
      subtitle,
      backgroundColor: const Color(0xff10B981),
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: const Color(0xffEF4444),
      colorText: Colors.white,
      icon: const Icon(Icons.error_rounded, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  void _showLoadingDialog(String message) {
    Get.dialog(
      Builder(
        builder: (context) {
          final colorScheme = Theme.of(context).colorScheme;
          return Dialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: true,
    );
  }

  // ============ POST-AUTH HELPERS ============

  Future<void> _postAuthActions(String uid) async {
    await FillInfoPersistenceService().onUserLoggedIn(uid);
    await SessionSecurityService().recordLogin();
    await UserDataSyncService().restoreAll(uid);
  }

  // ============ AUTHENTICATION ============

  Future<void> handleLogin(AppLocalizations t, {required bool formValid}) async {
    if (!formValid) return;
    if (isEmailRateLimited.value) return;

    isLoading.value = true;

    try {
      final res = await _authApi.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (_isDisposed) return;

      // Check for rate limit (429)
      if (res['statusCode'] == 429 || 
          (res['message'] as String?)?.contains('429') == true ||
          (res['message'] as String?)?.toLowerCase().contains('too many') == true) {
        isLoading.value = false;
        _startEmailRateLimitCooldown();
        _showErrorMessage(t.translate('loginErrorTooManyRequests'));
        return;
      }

      if (res.containsKey('token')) {
        final uid = res['uid'] as String;
        final token = res['token'] as String;
        final displayName = (res['displayName'] as String?) ??
            emailController.text.split('@')[0];

        await _jwt.saveUserSession(
          uid: uid,
          token: token,
          email: res['email'] as String?,
          displayName: displayName,
        );

        await _postAuthActions(uid);

        if (_isDisposed) return;
        isLoading.value = false;
        _showSuccessMessage(
          t.translate('loginSuccess'),
          t.translate('loginWelcomeUser').replaceAll('\$userName', displayName),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (_isDisposed) return;
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        isLoading.value = false;
        final msg = res['detail'] as String? ??
            res['message'] as String? ??
            t.translate('loginFailed');
        _showErrorMessage(msg);
      }
    } catch (e) {
      if (_isDisposed) return;
      isLoading.value = false;
      _showErrorMessage(t.translate('loginFailed'));
    }
  }

  Future<void> handleGoogleSignIn(AppLocalizations t) async {
    debugPrint('[LoginController] handleGoogleSignIn START');
    if (isGoogleRateLimited.value) return;
    isGoogleLoading.value = true;

    try {
      _showLoadingDialog(t.translate('loginGoogleSigningIn'));
      debugPrint('[LoginController] Loading dialog shown');

      // serverClientId must be the "Web application" OAuth client ID from
      // Google Cloud Console — NOT the Android/iOS client ID.  It must match
      // the GOOGLE_CLIENT_ID configured in the backend .env, since that's
      // the audience the backend validates against.
      final serverClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      debugPrint('[LoginController] GOOGLE_WEB_CLIENT_ID is ${serverClientId == null ? "NULL — signIn will likely fail" : "set (${serverClientId.length} chars)"}');

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: serverClientId,
        scopes: <String>['email', 'profile'],
      );
      debugPrint('[LoginController] GoogleSignIn created, calling signIn()...');

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn()
          .timeout(const Duration(seconds: 30), onTimeout: () {
        debugPrint('[LoginController] signIn() TIMED OUT after 30s');
        return null;
      });

      debugPrint('[LoginController] signIn() returned: ${googleUser?.email ?? "null"}');

      if (_isDisposed) return;
      if (Get.isDialogOpen ?? false) {
        debugPrint('[LoginController] Dismissing loading dialog');
        Get.back();
      }

      if (googleUser == null) {
        debugPrint('[LoginController] googleUser is null — possible causes: (1) user cancelled, (2) serverClientId is wrong/missing, (3) iOS client ID in Info.plist is invalid, (4) bundle ID mismatch with Google Cloud Console');
        isGoogleLoading.value = false;
        _showErrorMessage(t.translate('loginGoogleCancelled'));
        return;
      }

      debugPrint('[LoginController] Getting authentication...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final idToken = googleAuth.idToken;
      debugPrint('[LoginController] idToken is ${idToken == null ? "NULL" : "present (${idToken.length} chars)"}');

      if (idToken == null) {
        debugPrint(
          'Google sign-in: idToken is null. This is usually caused by a missing '
          'or incorrect serverClientId / GOOGLE_WEB_CLIENT_ID configuration. '
          'Ensure the Web OAuth client ID is set in .env and matches the '
          'backend GOOGLE_CLIENT_ID.',
        );
        isGoogleLoading.value = false;
        _showErrorMessage(t.translate('loginGoogleFailed'));
        return;
      }

      debugPrint('[LoginController] Calling socialAuth API...');
      final res = await _authApi.socialAuth(
        provider: 'google',
        token: idToken,
      );
      debugPrint('[LoginController] socialAuth response: $res');

      if (_isDisposed) return;

      // Check for rate limit (429)
      if (res['statusCode'] == 429 || 
          (res['message'] as String?)?.contains('429') == true ||
          (res['message'] as String?)?.toLowerCase().contains('too many') == true) {
        isGoogleLoading.value = false;
        _startGoogleRateLimitCooldown();
        _showErrorMessage(t.translate('loginErrorTooManyRequests'));
        return;
      }

      if (res.containsKey('token')) {
        final uid = res['uid'] as String;
        final token = res['token'] as String;
        final userName = (res['displayName'] as String?) ?? 'User';

        await _jwt.saveUserSession(
          uid: uid,
          token: token,
          email: res['email'] as String?,
          displayName: userName,
        );

        await _postAuthActions(uid);

        if (_isDisposed) return;
        isGoogleLoading.value = false;
        _showSuccessMessage(
          t.translate('loginGoogleWelcomeUser').replaceAll('\$userName', userName),
          t.translate('loginGoogleSignInSuccess'),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (_isDisposed) return;
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        isGoogleLoading.value = false;
        final msg = res['detail'] as String? ??
            res['message'] as String? ??
            t.translate('loginGoogleFailed');
        debugPrint('[LoginController] socialAuth failed: $msg');
        _showErrorMessage(msg);
      }
    } catch (e) {
      debugPrint('[LoginController] handleGoogleSignIn EXCEPTION: $e');
      if (_isDisposed) return;
      if (Get.isDialogOpen ?? false) Get.back();
      isGoogleLoading.value = false;
      _showErrorMessage(t.translate('loginGoogleFailed'));
    }
  }

  Future<void> handleFacebookSignIn(AppLocalizations t) async {
    debugPrint('[LoginController] handleFacebookSignIn START');
    if (isFacebookRateLimited.value) return;
    isFacebookLoading.value = true;

    try {
      _showLoadingDialog(t.translate('loginFacebookSigningIn'));
      debugPrint('[LoginController] Facebook loading dialog shown');

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );
      debugPrint('[LoginController] Facebook login result: status=${result.status}');

      if (_isDisposed) return;
      if (Get.isDialogOpen ?? false) {
        debugPrint('[LoginController] Dismissing Facebook loading dialog');
        Get.back();
      }

      if (result.status == LoginStatus.cancelled) {
        isFacebookLoading.value = false;
        _showErrorMessage(t.translate('loginFacebookCancelled'));
        return;
      }

      if (result.status != LoginStatus.success || result.accessToken == null) {
        debugPrint('[LoginController] Facebook login failed: status=${result.status}, message=${result.message}');
        isFacebookLoading.value = false;
        _showErrorMessage(t.translate('loginFacebookFailed'));
        return;
      }

      debugPrint('[LoginController] Calling socialAuth for Facebook...');
      final res = await _authApi.socialAuth(
        provider: 'facebook',
        token: result.accessToken!.tokenString,
      );
      debugPrint('[LoginController] Facebook socialAuth response: $res');

      if (_isDisposed) return;

      // Check for rate limit (429)
      if (res['statusCode'] == 429 || 
          (res['message'] as String?)?.contains('429') == true ||
          (res['message'] as String?)?.toLowerCase().contains('too many') == true) {
        isFacebookLoading.value = false;
        _startFacebookRateLimitCooldown();
        _showErrorMessage(t.translate('loginErrorTooManyRequests'));
        return;
      }

      if (res.containsKey('token')) {
        final uid = res['uid'] as String;
        final token = res['token'] as String;
        final userName = (res['displayName'] as String?) ?? 'User';

        await _jwt.saveUserSession(
          uid: uid,
          token: token,
          email: res['email'] as String?,
          displayName: userName,
        );

        await _postAuthActions(uid);

        if (_isDisposed) return;
        isFacebookLoading.value = false;
        _showSuccessMessage(
          t.translate('loginFacebookSignInSuccess'),
          userName,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (_isDisposed) return;
        Get.offAllNamed(AppRoutes.homeScreen);
      } else {
        isFacebookLoading.value = false;
        final msg = res['detail'] as String? ??
            res['message'] as String? ??
            t.translate('loginFacebookFailed');
        debugPrint('[LoginController] Facebook socialAuth failed: $msg');
        _showErrorMessage(msg);
      }
    } catch (e) {
      debugPrint('[LoginController] handleFacebookSignIn EXCEPTION: $e');
      if (_isDisposed) return;
      if (Get.isDialogOpen ?? false) Get.back();
      isFacebookLoading.value = false;
      _showErrorMessage(t.translate('loginFacebookFailed'));
    }
  }

  void handleEmailSignIn() {
    emailFocusNode.requestFocus();
  }
}
