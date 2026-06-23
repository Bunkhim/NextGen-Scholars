// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/session_security_service.dart';
import 'package:scholarship_app/services/user_data_sync_service.dart';
import 'package:scholarship_app/services/user_firestore_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _useEmail = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;
  String _selectedCountryCode = '+1';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final Map<String, String> _countryCodes = {
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

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ============ VALIDATION ============

  void _validateForm() {
    final t = AppLocalizations.of(context);
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;

      if (_nameController.text.trim().isEmpty) {
        _nameError = t.translate('registerNameRequired');
      } else if (_nameController.text.trim().length < 2) {
        _nameError = t.translate('registerNameTooShort');
      } else if (!RegExp(r"^[\p{L}\s'-]+$", unicode: true)
          .hasMatch(_nameController.text.trim())) {
        _nameError = t.translate('registerNameInvalidChars');
      }

      // Email is always required — Firebase Auth uses email/password
      if (_emailController.text.trim().isEmpty) {
        _emailError = t.translate('registerEmailRequired');
      } else if (!_isValidEmail(_emailController.text.trim())) {
        _emailError = t.translate('registerEmailInvalid');
      }

      if (!_useEmail) {
        if (_phoneController.text.trim().isEmpty) {
          _phoneError = t.translate('registerPhoneRequired');
        } else if (!_isValidPhone(_phoneController.text.trim())) {
          _phoneError = t.translate('registerPhoneInvalid');
        }
      }

      if (_passwordController.text.isEmpty) {
        _passwordError = t.translate('registerPasswordRequired');
      } else if (!_isValidPassword(_passwordController.text)) {
        _passwordError = t.translate('registerPasswordInvalid');
      }

      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = t.translate('registerConfirmPasswordRequired');
      } else if (_passwordController.text != _confirmPasswordController.text) {
        _confirmPasswordError = t.translate('registerPasswordsMismatch');
      }
    });
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

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    _validateForm();

    if (_nameError == null &&
        _emailError == null &&
        (!_useEmail ? _phoneError == null : true) &&
        _passwordError == null &&
        _confirmPasswordError == null) {
      setState(() => _isLoading = true);

      try {
        final name = _nameController.text.trim();
        final email = _emailController.text.trim();
        final phone = _useEmail
            ? null
            : '$_selectedCountryCode${_phoneController.text.trim()}';
        final password = _passwordController.text;

        // Use email for Firebase Auth (phone flow uses OTPService separately)
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        final user = credential.user;
        if (user != null) {
          // Set display name
          await user.updateDisplayName(name);

          // Create Firestore user doc (matches admin dashboard UserModel)
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

          // Initialize user services and skip directly to home
          await FillInfoPersistenceService().onUserLoggedIn(user.uid);
          await SessionSecurityService().recordLogin();
          await UserDataSyncService().restoreAll(user.uid);
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        _showMessage(
          message: AppLocalizations.of(context)
              .translate('loginGoogleSignInSuccess'),
          subtitle: AppLocalizations.of(context)
              .translate('loginWelcomeUser')
              .replaceAll('\$userName', name),
          backgroundColor: const Color(0xff10B981),
          icon: Icons.check_circle_rounded,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          // Navigate directly to home screen, bypassing OTP verification
          Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
        }
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);

        final t = AppLocalizations.of(context);
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
        _showMessage(
          message: errorMsg,
          backgroundColor: const Color(0xffEF4444),
          icon: Icons.error_rounded,
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showMessage(
          message: 'Registration failed: $e',
          backgroundColor: const Color(0xffEF4444),
          icon: Icons.error_rounded,
        );
      }
    }
  }

  // ============ SOCIAL SIGN-IN ============

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
                  Text(message,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.85))),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
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
                Text(message,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface)),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final t = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    setState(() => _isGoogleLoading = true);

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
        setState(() => _isGoogleLoading = false);
        _showMessage(
          message: t.translate('loginGoogleCancelled'),
          backgroundColor: const Color(0xffEF4444),
          icon: Icons.error_rounded,
        );
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

      setState(() => _isGoogleLoading = false);
      _showMessage(
        message: t.translate('loginGoogleSignInSuccess'),
        subtitle:
            t.translate('loginWelcomeUser').replaceAll('\$userName', userName),
        backgroundColor: const Color(0xff10B981),
        icon: Icons.check_circle_rounded,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      setState(() => _isGoogleLoading = false);

      String errorMessage = t.translate('loginAuthFailed');
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = t.translate('loginEmailExistsDifferentMethod');
      }
      _showMessage(
        message: errorMessage,
        backgroundColor: const Color(0xffEF4444),
        icon: Icons.error_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      setState(() => _isGoogleLoading = false);
      _showMessage(
        message: t.translate('loginGoogleFailed'),
        backgroundColor: const Color(0xffEF4444),
        icon: Icons.error_rounded,
      );
    }
  }

  Future<void> _handleFacebookSignIn() async {
    final t = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    setState(() => _isFacebookLoading = true);

    try {
      _showLoadingDialog(t.translate('loginFacebookSigningIn'));

      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result.status == LoginStatus.cancelled) {
        setState(() => _isFacebookLoading = false);
        _showMessage(
          message: t.translate('loginFacebookCancelled'),
          backgroundColor: const Color(0xffEF4444),
          icon: Icons.error_rounded,
        );
        return;
      }

      if (result.status != LoginStatus.success || result.accessToken == null) {
        setState(() => _isFacebookLoading = false);
        _showMessage(
          message: t.translate('loginFacebookFailed'),
          backgroundColor: const Color(0xffEF4444),
          icon: Icons.error_rounded,
        );
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

      setState(() => _isFacebookLoading = false);
      _showMessage(
        message: t.translate('loginFacebookSignInSuccess'),
        subtitle:
            t.translate('loginWelcomeUser').replaceAll('\$userName', userName),
        backgroundColor: const Color(0xff10B981),
        icon: Icons.check_circle_rounded,
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreen);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      setState(() => _isFacebookLoading = false);

      String errorMessage = t.translate('loginAuthFailed');
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = t.translate('loginEmailExistsDifferentMethod');
      }
      _showMessage(
        message: errorMessage,
        backgroundColor: const Color(0xffEF4444),
        icon: Icons.error_rounded,
      );
    } catch (e) {
      if (!mounted) return;
      if (Navigator.canPop(context)) Navigator.pop(context);
      setState(() => _isFacebookLoading = false);
      _showMessage(
        message: t.translate('loginFacebookFailed'),
        backgroundColor: const Color(0xffEF4444),
        icon: Icons.error_rounded,
      );
    }
  }

  void _handleEmailSignUp() {
    // Email form is already visible on this page, just unfocus other fields
    FocusScope.of(context).unfocus();
  }

  // ============ INPUT DECORATION ============

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool hasError = false,
    required ColorScheme cs,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: cs.onSurfaceVariant.withOpacity(0.5),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 4),
        child: Icon(prefixIcon, color: cs.onSurfaceVariant, size: 20),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: hasError ? cs.error : cs.outlineVariant.withOpacity(0.5),
          width: hasError ? 1.5 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: cs.error, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildErrorText(String? error, ColorScheme cs) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        error,
        style: TextStyle(fontSize: 12, color: cs.error, height: 1.2),
      ),
    );
  }

  Widget _buildPasswordRequirements(AppLocalizations t, ColorScheme cs) {
    final pwd = _passwordController.text;
    final checks = [
      _PasswordCheck(
          t.translate('registerPasswordHint8Chars'), pwd.length >= 8),
      _PasswordCheck(t.translate('registerPasswordHintUppercase'),
          pwd.contains(RegExp(r'[A-Z]'))),
      _PasswordCheck(t.translate('registerPasswordHintLowercase'),
          pwd.contains(RegExp(r'[a-z]'))),
      _PasswordCheck(t.translate('registerPasswordHintNumber'),
          pwd.contains(RegExp(r'[0-9]'))),
      _PasswordCheck(t.translate('registerPasswordHintSpecial'),
          pwd.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: checks.map((check) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                check.passed ? Icons.check_circle : Icons.circle_outlined,
                size: 14,
                color: check.passed ? const Color(0xFF4CAF50) : cs.outline,
              ),
              const SizedBox(width: 4),
              Text(
                check.label,
                style: TextStyle(
                  fontSize: 11,
                  color: check.passed ? const Color(0xFF4CAF50) : cs.outline,
                  fontWeight: check.passed ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ============ BUILD ============

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // ── Gradient Header ─────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    bottom: 32,
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
                      // Back button row
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0D47A1).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          "assets/icons/nextgen_logo.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.translate('registerTitle'),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.translate('registerSubtitle'),
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

                // ── Form Card ───────────────────────────────────────────
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: cs.shadow.withOpacity(0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Full Name ────────────────────────
                        Text(
                          t.translate('registerFullNameLabel'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          cursorHeight: 20,
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurface,
                          ),
                          decoration: _inputDecoration(
                            hint: t.translate('registerFullNameHint'),
                            prefixIcon: Icons.person_outlined,
                            hasError: _nameError != null,
                            cs: cs,
                          ),
                          onChanged: (_) {
                            if (_nameError != null) {
                              setState(() => _nameError = null);
                            }
                          },
                        ),
                        _buildErrorText(_nameError, cs),

                        const SizedBox(height: 18),

                        // ── Email ────────────────────────────
                        Text(
                          t.translate('registerEmailLabel'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Email field — always required for Firebase Auth
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          cursorHeight: 20,
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurface,
                          ),
                          decoration: _inputDecoration(
                            hint: t.translate('registerEmailHint'),
                            prefixIcon: Icons.email_outlined,
                            hasError: _emailError != null,
                            cs: cs,
                          ),
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                        ),
                        _buildErrorText(_emailError, cs),
                        const SizedBox(height: 8),
                        // Toggle to also add a phone number
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _useEmail = !_useEmail;
                                if (_useEmail) {
                                  _phoneError = null;
                                }
                              });
                            },
                            child: Text(
                              _useEmail
                                  ? t.translate('registerUsePhoneInstead')
                                  : t.translate('registerUseEmailInstead'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ),
                        if (!_useEmail) ...[
                          const SizedBox(height: 12),
                          Text(
                            t.translate('registerPhoneLabel'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Country code picker
                              Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest
                                      .withOpacity(0.4),
                                  border: Border.all(
                                    color: cs.outlineVariant.withOpacity(0.5),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedCountryCode,
                                  items: _countryCodes.entries
                                      .map((e) => DropdownMenuItem(
                                            value: e.key,
                                            child: Text(
                                              e.value,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: cs.onSurface,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() {
                                        _selectedCountryCode = v;
                                        _phoneError = null;
                                      });
                                    }
                                  },
                                  underline: const SizedBox(),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  isExpanded: false,
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: cs.onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    _PhoneInputFormatter(),
                                  ],
                                  cursorHeight: 20,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: cs.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: t.translate('registerPhoneHint'),
                                    hintStyle: TextStyle(
                                      color:
                                          cs.onSurfaceVariant.withOpacity(0.5),
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: cs.surfaceContainerHighest
                                        .withOpacity(0.4),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: _phoneError != null
                                            ? cs.error
                                            : cs.outlineVariant
                                                .withOpacity(0.5),
                                        width: _phoneError != null ? 1.5 : 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: cs.primary,
                                        width: 1.8,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  onChanged: (_) {
                                    if (_phoneError != null) {
                                      setState(() => _phoneError = null);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          _buildErrorText(_phoneError, cs),
                        ],

                        const SizedBox(height: 18),

                        // ── Password ─────────────────────────
                        Text(
                          t.translate('registerPasswordLabel'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          cursorHeight: 20,
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurface,
                          ),
                          decoration: _inputDecoration(
                            hint: t.translate('registerPasswordHint'),
                            prefixIcon: Icons.lock_outlined,
                            hasError: _passwordError != null,
                            cs: cs,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: cs.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          onChanged: (_) {
                            setState(() {
                              if (_passwordError != null) {
                                _passwordError = null;
                              }
                            });
                          },
                        ),
                        _buildErrorText(_passwordError, cs),
                        _buildPasswordRequirements(t, cs),

                        const SizedBox(height: 18),

                        // ── Confirm Password ─────────────────
                        Text(
                          t.translate('registerConfirmPasswordLabel'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          cursorHeight: 20,
                          style: TextStyle(
                            fontSize: 15,
                            color: cs.onSurface,
                          ),
                          decoration: _inputDecoration(
                            hint: t.translate('registerConfirmPasswordHint'),
                            prefixIcon: Icons.lock_outlined,
                            hasError: _confirmPasswordError != null,
                            cs: cs,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: cs.onSurfaceVariant,
                                size: 20,
                              ),
                              onPressed: () => setState(() =>
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword),
                            ),
                          ),
                          onChanged: (_) {
                            if (_confirmPasswordError != null) {
                              setState(() => _confirmPasswordError = null);
                            }
                          },
                        ),
                        _buildErrorText(_confirmPasswordError, cs),

                        const SizedBox(height: 16),

                        // ── Register Button ──────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              disabledBackgroundColor:
                                  cs.primary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    t.translate('registerButton'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Divider ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: cs.outlineVariant.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          t.translate('loginOrContinueWith'),
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: cs.outlineVariant.withOpacity(0.5),
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Social Icons ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SocialCircle(
                          onTap: (_isLoading ||
                                  _isGoogleLoading ||
                                  _isFacebookLoading)
                              ? null
                              : _handleEmailSignUp,
                          isLoading: false,
                          child: Icon(
                            Icons.email_outlined,
                            color: cs.onSurfaceVariant,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialCircle(
                          onTap: (_isLoading ||
                                  _isGoogleLoading ||
                                  _isFacebookLoading)
                              ? null
                              : _handleFacebookSignIn,
                          isLoading: _isFacebookLoading,
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
                        child: _SocialCircle(
                          onTap: (_isLoading ||
                                  _isGoogleLoading ||
                                  _isFacebookLoading)
                              ? null
                              : _handleGoogleSignIn,
                          isLoading: _isGoogleLoading,
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

                const SizedBox(height: 24),

                // ── Login Link ──────────────────────────────────────────
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        t.translate('registerAlreadyHaveAccount'),
                        style: TextStyle(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.loginScreen),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.only(left: 4),
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          t.translate('registerLoginLink'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: cs.primary,
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

// ── Social Circle Widget ────────────────────────────────────────────────────

class _SocialCircle extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isLoading;
  const _SocialCircle(
      {required this.child, this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withOpacity(0.35),
          border: Border.all(
            color: cs.outlineVariant.withOpacity(0.5),
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
                    valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                  ),
                )
              : child,
        ),
      ),
    );
  }
}

// ── Phone Input Formatter ───────────────────────────────────────────────────

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;
    if (newText.isNotEmpty && newText.startsWith('0')) {
      newText = newText.substring(1);
    }
    return newValue.copyWith(
      text: newText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: newText.length),
      ),
    );
  }
}

class _PasswordCheck {
  final String label;
  final bool passed;
  _PasswordCheck(this.label, this.passed);
}
