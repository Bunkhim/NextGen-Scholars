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

class RegisterController extends GetxController {
  // ============ TEXT CONTROLLERS ============
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ============ FOCUS NODES ============
  final nameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final phoneFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  // ============ REACTIVE STATE ============
  final RxBool useEmail = true.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool isFacebookLoading = false.obs;
  final RxString selectedCountryCode = '+1'.obs;

  // ============ ERROR STATE ============
  final RxString nameError = ''.obs;
  final RxString emailError = ''.obs;
  final RxString phoneError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString confirmPasswordError = ''.obs;

  // ============ COUNTRY CODES ============
  final Map<String, String> countryCodes = {
    '+1': '🇺🇸 +1',
    '+44': '🇬🇧 +44',
    '+91': '🇮🇳 +91',
    '+86': '🇨🇳 +86',
    '+81': '🇯🇵 +81',
    '+33': '🇫🇷 +33',
    '+49': '🇩🇪 +49',
    '+39': '🇮🇹 +39',
    '+34': '🇪🇸 +34',
    '+61': '🇦🇺 +61',
    '+55': '🇧🇷 +55',
    '+54': '🇦🇷 +54',
    '+52': '🇲🇽 +52',
    '+27': '🇿🇦 +27',
    '+234': '🇳🇬 +234',
    '+20': '🇪🇬 +20',
    '+60': '🇲🇾 +60',
    '+65': '🇸🇬 +65',
    '+82': '🇰🇷 +82',
    '+84': '🇻🇳 +84',
    '+62': '🇮🇩 +62',
    '+63': '🇵🇭 +63',
    '+855': '🇰🇭 +855',
    '+90': '🇹🇷 +90',
    '+966': '🇸🇦 +966',
    '+971': '🇦🇪 +971',
  };

  bool get anyLoading =>
      isLoading.value || isGoogleLoading.value || isFacebookLoading.value;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    phoneFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }

  // ============ TOGGLE METHODS ============
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void toggleAuthMethod() {
    useEmail.value = !useEmail.value;
    clearErrors();
  }

  void setCountryCode(String code) {
    selectedCountryCode.value = code;
  }

  void clearErrors() {
    nameError.value = '';
    emailError.value = '';
    phoneError.value = '';
    passwordError.value = '';
    confirmPasswordError.value = '';
  }

  // ============ VALIDATION ============

  String? validateName(String? value, AppLocalizations t) {
    if (value == null || value.trim().isEmpty) {
      return t.translate('registerNameRequired');
    }
    if (value.trim().length < 2) {
      return t.translate('registerNameTooShort');
    }
    if (!RegExp(r"^[\p{L}\s'-]+$", unicode: true).hasMatch(value.trim())) {
      return t.translate('registerNameInvalidChars');
    }
    return null;
  }

  String? validateEmail(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('registerEmailRequired');
    }
    if (!_isValidEmail(value.trim())) {
      return t.translate('registerEmailInvalid');
    }
    return null;
  }

  String? validatePhone(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('registerPhoneRequired');
    }
    if (!_isValidPhone(value.trim())) {
      return t.translate('registerPhoneInvalid');
    }
    return null;
  }

  String? validatePassword(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('registerPasswordRequired');
    }
    if (!_isValidPassword(value)) {
      return t.translate('registerPasswordInvalid');
    }
    return null;
  }

  String? validateConfirmPassword(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('registerConfirmPasswordRequired');
    }
    if (passwordController.text != value) {
      return t.translate('registerPasswordsMismatch');
    }
    return null;
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^[1-9][0-9]{7,14}$').hasMatch(cleaned);
  }

  bool _isValidPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[a-z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return false;
    return true;
  }

  bool validateForm(AppLocalizations t) {
    clearErrors();
    bool isValid = true;

    final nameErr = validateName(nameController.text, t);
    if (nameErr != null) {
      nameError.value = nameErr;
      isValid = false;
    }

    final emailErr = validateEmail(emailController.text, t);
    if (emailErr != null) {
      emailError.value = emailErr;
      isValid = false;
    }

    if (!useEmail.value) {
      final phoneErr = validatePhone(phoneController.text, t);
      if (phoneErr != null) {
        phoneError.value = phoneErr;
        isValid = false;
      }
    }

    final passwordErr = validatePassword(passwordController.text, t);
    if (passwordErr != null) {
      passwordError.value = passwordErr;
      isValid = false;
    }

    final confirmErr = validateConfirmPassword(confirmPasswordController.text, t);
    if (confirmErr != null) {
      confirmPasswordError.value = confirmErr;
      isValid = false;
    }

    return isValid;
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

  Future<void> handleRegister(AppLocalizations t) async {
    if (!validateForm(t)) return;

    isLoading.value = true;

    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final phone = useEmail.value
          ? null
          : '${selectedCountryCode.value}${phoneController.text.trim()}';
      final password = passwordController.text;

      // Create user with email and password
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Set display name
        await user.updateDisplayName(name);

        // Create Firestore user document
        await UserFirestoreService().createUser(
          uid: user.uid,
          name: name,
          email: email,
          phone: phone,
        );

        // Send email verification
        if (!user.emailVerified) {
          await user.sendEmailVerification();
        }

        // Initialize user services
        await FillInfoPersistenceService().onUserLoggedIn(user.uid);
        await SessionSecurityService().recordLogin();
        await UserDataSyncService().restoreAll(user.uid);
      }

      isLoading.value = false;
      _showSuccessMessage(
        t.translate('loginGoogleSignInSuccess'),
        t.translate('loginWelcomeUser').replaceAll('\$userName', name),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.homeScreen);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;

      String errorMsg;
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = t.translate('registerErrorEmailInUse');
          break;
        case 'weak-password':
          errorMsg = t.translate('registerErrorWeakPassword');
          break;
        case 'invalid-email':
          errorMsg = t.translate('registerErrorInvalidEmail');
          break;
        default:
          errorMsg = e.message ?? t.translate('registerErrorGeneric');
      }
      _showErrorMessage(errorMsg);
    } catch (e) {
      isLoading.value = false;
      _showErrorMessage(t.translate('registerErrorGeneric'));
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
        t.translate('loginFacebookWelcomeUser').replaceAll('\$userName', userName),
        t.translate('loginFacebookSignInSuccess'),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(AppRoutes.homeScreen);
    } on FirebaseAuthException catch (e) {
      Get.back();
      isFacebookLoading.value = false;

      String errorMessage = t.translate('loginAuthFailed');
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = t.translate('loginEmailExistsDifferentMethod');
      } else if (e.code == 'invalid-credential') {
        errorMessage = t.translate('loginInvalidCredentials');
      }
      _showErrorMessage(errorMessage);
    } catch (e) {
      Get.back();
      isFacebookLoading.value = false;
      _showErrorMessage(t.translate('loginFacebookFailed'));
    }
  }
}
