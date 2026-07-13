// import 'package:get/get.dart';

// class LoginController extends GetxController {
//   // Add state variables and methods here
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/session_security_service.dart';
import 'package:scholarship_app/services/user_data_sync_service.dart';
import 'package:scholarship_app/services/user_firestore_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isFacebookLoading = false.obs;

  bool get anyLoading =>
      isLoading.value || isGoogleLoading.value || isFacebookLoading.value;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
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
      barrierDismissible: false,
    );
  }

  // ============ AUTHENTICATION ============

  Future<void> handleLogin(AppLocalizations t, {required bool formValid}) async {
    if (!formValid) return;

    isLoading.value = true;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final user = credential.user;
      final userName = user?.displayName ?? emailController.text.split('@')[0];

      if (user != null) {
        await UserFirestoreService().updateLastLogin(user.uid);
        await FillInfoPersistenceService().onUserLoggedIn(user.uid);
        await SessionSecurityService().recordLogin();
        await UserDataSyncService().restoreAll(user.uid);
      }

      isLoading.value = false;
      _showSuccessMessage(
        t.translate('loginSuccess'),
        t.translate('loginWelcomeUser').replaceAll('\$userName', userName),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.homeScreen);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
          errorMsg = t.translate('loginErrorUserNotFound');
          break;
        case 'wrong-password':
          errorMsg = t.translate('loginErrorWrongPassword');
          break;
        case 'invalid-credential':
          errorMsg = t.translate('loginErrorInvalidCredential');
          break;
        case 'user-disabled':
          errorMsg = t.translate('loginErrorUserDisabled');
          break;
        case 'too-many-requests':
          errorMsg = t.translate('loginErrorTooManyRequests');
          break;
        default:
          errorMsg = e.message ?? t.translate('loginFailed');
      }
      _showErrorMessage(errorMsg);
    } catch (e) {
      isLoading.value = false;
      _showErrorMessage(t.translate('loginFailed'));
    }
  }

  Future<void> handleGoogleSignIn(AppLocalizations t) async {
    isGoogleLoading.value = true;

    try {
      _showLoadingDialog(t.translate('loginGoogleSigningIn'));

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: null,
        scopes: <String>['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      Get.back(); // dismiss loading dialog

      if (googleUser == null) {
        isGoogleLoading.value = false;
        _showErrorMessage(t.translate('loginGoogleCancelled'));
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      final String userName = user?.displayName ?? 'User';

      if (user != null) {
        await UserFirestoreService().ensureUser(user);
        await FillInfoPersistenceService().onUserLoggedIn(user.uid);
        await SessionSecurityService().recordLogin();
        await UserDataSyncService().restoreAll(user.uid);
      }

      isGoogleLoading.value = false;
      _showSuccessMessage(
        t.translate('loginGoogleWelcomeUser').replaceAll('\$userName', userName),
        t.translate('loginGoogleSignInSuccess'),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.homeScreen);
    } on FirebaseAuthException catch (e) {
      Get.back();
      isGoogleLoading.value = false;

      String errorMessage = t.translate('loginAuthFailed');
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = t.translate('loginEmailExistsDifferentMethod');
      } else if (e.code == 'invalid-credential') {
        errorMessage = t.translate('loginInvalidCredentials');
      }
      _showErrorMessage(errorMessage);
    } catch (e) {
      Get.back();
      isGoogleLoading.value = false;
      _showErrorMessage(t.translate('loginGoogleFailed'));
    }
  }

  Future<void> handleFacebookSignIn(AppLocalizations t) async {
    isFacebookLoading.value = true;

    try {
      _showLoadingDialog(t.translate('loginFacebookSigningIn'));

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      Get.back(); // dismiss loading dialog

      if (result.status == LoginStatus.cancelled) {
        isFacebookLoading.value = false;
        _showErrorMessage(t.translate('loginFacebookCancelled'));
        return;
      }

      if (result.status != LoginStatus.success || result.accessToken == null) {
        isFacebookLoading.value = false;
        _showErrorMessage(t.translate('loginFacebookFailed'));
        return;
      }

      final OAuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(facebookCredential);

      final User? user = userCredential.user;
      final String userName = user?.displayName ?? 'User';

      if (user != null) {
        await UserFirestoreService().ensureUser(user);
        await FillInfoPersistenceService().onUserLoggedIn(user.uid);
        await SessionSecurityService().recordLogin();
        await UserDataSyncService().restoreAll(user.uid);
      }

      isFacebookLoading.value = false;
      _showSuccessMessage(
        t.translate('loginFacebookSignInSuccess'),
        userName,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.homeScreen);
    } on FirebaseAuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      isFacebookLoading.value = false;

      String errorMessage = t.translate('loginAuthFailed');
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = t.translate('loginEmailExistsDifferentMethod');
      } else if (e.code == 'invalid-credential') {
        errorMessage = t.translate('loginInvalidCredentials');
      }
      _showErrorMessage(errorMessage);
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      isFacebookLoading.value = false;
      _showErrorMessage(t.translate('loginFacebookFailed'));
    }
  }

  void handleEmailSignIn() {
    emailFocusNode.requestFocus();
  }
}