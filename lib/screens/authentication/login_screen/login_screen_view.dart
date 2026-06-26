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

part 'login_screen_binding.dart';
part 'login_screen_controller.dart';

class LoginScreenView extends StatefulWidget {
  const LoginScreenView({super.key});

  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<LoginScreenView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late final ctrl = Get.find<LoginScreenViewController>();

  @override
  void initState() {
    super.initState();
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
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('loginEmailRequired');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return t.translate('loginEmailInvalid');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('loginPasswordRequired');
    }
    if (value.length < 8) {
      return t.translate('loginPasswordMinLength');
    }
    return null;
  }

  void _showMessage({
    required String message,
    String? subtitle,
    required Color backgroundColor,
    required IconData icon,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  void _showSuccessMessage(String message, String userName) {
    _showMessage(
      message: message,
      subtitle: AppLocalizations.of(context)
          .translate('loginWelcomeUser')
          .replaceAll('\$userName', userName),
      backgroundColor: const Color(0xff10B981),
      icon: Icons.check_circle_rounded,
    );
  }

  void _showErrorMessage(String message) {
    _showMessage(
      message: message,
      backgroundColor: const Color(0xffEF4444),
      icon: Icons.error_rounded,
    );
  }

  Future<void> _handleLogin() async {
    final t = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    ctrl.isLoading.value = true;

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: ctrl.emailController.text.trim(),
        password: ctrl.passwordController.text,
      );

      if (!mounted) return;

      final user = credential.user;
      final userName = user?.displayName ?? ctrl.emailController.text.split('@')[0];

      if (user != null) {
        await UserFirestoreService().updateLastLogin(user.uid);
        await FillInfoPersistenceService().onUserLoggedIn(user.uid);
        await SessionSecurityService().recordLogin();
        await UserDataSyncService().restoreAll(user.uid);
      }

      ctrl.isLoading.value = false;
      _showSuccessMessage(t.translate('loginSuccess'), userName);

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Get.offAllNamed(Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ctrl.isLoading.value = false;

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
      if (!mounted) return;
      ctrl.isLoading.value = false;
      _showErrorMessage(t.translate('loginFailed'));
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final t = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    ctrl.isGoogleLoading.value = true;

    try {
      _showLoadingDialog(t.translate('loginGoogleSigningIn'));

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: null,
        scopes: <String>['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (!mounted) return;
      Navigator.pop(context);

      if (googleUser == null) {
        ctrl.isGoogleLoading.value = false;
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

      if (!mounted) return;

      final User? user = userCredential.user;
      final String userName = user?.displayName ?? 'User';

      if (user != null) {
        await UserFirestoreService().ensureUser(user);
        await FillInfoPersistenceService().onUserLoggedIn(user.uid);
        await SessionSecurityService().recordLogin();
        await UserDataSyncService().restoreAll(user.uid);
      }

      ctrl.isGoogleLoading.value = false;
      _showSuccessMessage(
        t
            .translate('loginGoogleWelcomeUser')
            .replaceAll('\$userName', userName),
        t.translate('loginGoogleSignInSuccess'),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Get.offAllNamed(Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ctrl.isGoogleLoading.value = false;

      String errorMessage = t.translate('loginAuthFailed');
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = t.translate('loginEmailExistsDifferentMethod');
      } else if (e.code == 'invalid-credential') {
        errorMessage = t.translate('loginInvalidCredentials');
      }
      _showErrorMessage(errorMessage);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ctrl.isGoogleLoading.value = false;
      _showErrorMessage(t.translate('loginGoogleFailed'));
    }
  }

  void _showLoadingDialog(String message) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
    );
  }

  Future<void> _handleFacebookSignIn() async {
    final t = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    ctrl.isFacebookLoading.value = true;

    try {
      _showLoadingDialog(t.translate('loginFacebookSigningIn'));

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result.status == LoginStatus.cancelled) {
        ctrl.isFacebookLoading.value = false;
        _showErrorMessage(t.translate('loginFacebookCancelled'));
        return;
      }

      if (result.status != LoginStatus.success || result.accessToken == null) {
        ctrl.isFacebookLoading.value = false;
        _showErrorMessage(t.translate('loginFacebookFailed'));
        return;
      }

      final OAuthCredential facebookCredential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(facebookCredential);

      if (!mounted) return;

      final User? user = userCredential.user;
      final String userName = user?.displayName ?? 'User';

      if (user != null) {
        await UserFirestoreService().ensureUser(user);
        await FillInfoPersistenceService().onUserLoggedIn(user.uid);
        await SessionSecurityService().recordLogin();
        await UserDataSyncService().restoreAll(user.uid);
      }

      ctrl.isFacebookLoading.value = false;
      _showSuccessMessage(
        t.translate('loginFacebookSignInSuccess'),
        userName,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Get.offAllNamed(Routes.home);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      ctrl.isFacebookLoading.value = false;

      String errorMessage = t.translate('loginAuthFailed');
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = t.translate('loginEmailExistsDifferentMethod');
      } else if (e.code == 'invalid-credential') {
        errorMessage = t.translate('loginInvalidCredentials');
      }
      _showErrorMessage(errorMessage);
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      ctrl.isFacebookLoading.value = false;
      _showErrorMessage(t.translate('loginFacebookFailed'));
    }
  }

  void _handleEmailSignIn() {
    ctrl.emailFocusNode.requestFocus();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    required ColorScheme colorScheme,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 4),
        child: Icon(prefixIcon, color: colorScheme.onSurfaceVariant, size: 20),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: colorScheme.error, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      errorStyle: const TextStyle(fontSize: 12, height: 1.2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 20,
                    bottom: 36,
                  ),
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
                  child: Column(
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0D47A1).withOpacity(0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Image.asset(
                            "assets/icons/nextgen_logo.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        t.translate('loginWelcomeTitle'),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.translate('loginSubtitle'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.translate('loginEmailLabel'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: ctrl.emailController,
                            focusNode: ctrl.emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _validateEmail,
                            onFieldSubmitted: (_) =>
                                ctrl.passwordFocusNode.requestFocus(),
                            cursorHeight: 20,
                            style: TextStyle(
                              fontSize: 15,
                              color: colorScheme.onSurface,
                            ),
                            decoration: _inputDecoration(
                              hint: t.translate('loginEmailHint'),
                              prefixIcon: Icons.email_outlined,
                              colorScheme: colorScheme,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            t.translate('loginPasswordLabel'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => TextFormField(
                              controller: ctrl.passwordController,
                              focusNode: ctrl.passwordFocusNode,
                              obscureText: ctrl.obscurePassword.value,
                              textInputAction: TextInputAction.done,
                              validator: _validatePassword,
                              onFieldSubmitted: (_) => _handleLogin(),
                              cursorHeight: 20,
                              style: TextStyle(
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                              decoration: _inputDecoration(
                                hint: t.translate('loginPasswordHint'),
                                prefixIcon: Icons.lock_outlined,
                                colorScheme: colorScheme,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    ctrl.obscurePassword.value
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: () => ctrl.togglePassword(),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Get.toNamed(Routes.forgetPassword),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                t.translate('loginForgotPassword'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
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
                                onPressed: (ctrl.isLoading.value ||
                                        ctrl.isGoogleLoading.value ||
                                        ctrl.isFacebookLoading.value)
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  foregroundColor: colorScheme.onPrimary,
                                  disabledBackgroundColor:
                                      colorScheme.primary.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                child: ctrl.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : Text(
                                        t.translate('loginButton'),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          t.translate('loginOrContinueWith'),
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: colorScheme.outlineVariant.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          onPressed: (ctrl.isLoading.value ||
                                  ctrl.isGoogleLoading.value ||
                                  ctrl.isFacebookLoading.value)
                              ? null
                              : _handleEmailSignIn,
                          child: Icon(
                            Icons.email_outlined,
                            color: colorScheme.onSurfaceVariant,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          onPressed: (ctrl.isLoading.value ||
                                  ctrl.isGoogleLoading.value ||
                                  ctrl.isFacebookLoading.value)
                              ? null
                              : _handleFacebookSignIn,
                          isLoading: ctrl.isFacebookLoading.value,
                          child: Image.asset(
                            "assets/icons/facebook_icon.png",
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          onPressed: (ctrl.isLoading.value ||
                                  ctrl.isGoogleLoading.value ||
                                  ctrl.isFacebookLoading.value)
                              ? null
                              : _handleGoogleSignIn,
                          isLoading: ctrl.isGoogleLoading.value,
                          child: Image.asset(
                            "assets/icons/google_icon.png",
                            width: 22,
                            height: 22,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        t.translate('loginNoAccount'),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed(Routes.register),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 4),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t.translate('loginSignUp'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  const _SocialButton({
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.5),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}
