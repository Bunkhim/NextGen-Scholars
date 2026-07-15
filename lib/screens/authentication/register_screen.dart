// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/authentication/register_controller.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
    _animController.dispose();
    super.dispose();
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
      padding: const EdgeInsets.only(top: 6, left: 0),
      child: Text(
        error,
        style: TextStyle(fontSize: 12, color: cs.error, height: 1.2),
      ),
    );
  }

  Widget _buildPasswordRequirements(AppLocalizations t, ColorScheme cs, RegisterController controller) {
    final pwd = controller.passwordController.text;
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
      padding: const EdgeInsets.only(top: 8, left: 0),
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
    final controller = Get.put(RegisterController());

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
                    child: Obx(
                      () => Column(
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
                            controller: controller.nameController,
                            focusNode: controller.nameFocusNode,
                            textInputAction: TextInputAction.next,
                            cursorHeight: 20,
                            style: TextStyle(
                              fontSize: 15,
                              color: cs.onSurface,
                            ),
                            decoration: _inputDecoration(
                              hint: t.translate('registerFullNameHint'),
                              prefixIcon: Icons.person_outlined,
                              hasError: controller.nameError.value.isNotEmpty,
                              cs: cs,
                            ),
                            onChanged: (_) {
                              if (controller.nameError.value.isNotEmpty) {
                                controller.nameError.value = '';
                              }
                            },
                          ),
                          _buildErrorText(
                              controller.nameError.value.isEmpty
                                  ? null
                                  : controller.nameError.value,
                              cs),

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
                          // Email field — always required
                          TextField(
                            controller: controller.emailController,
                            focusNode: controller.emailFocusNode,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            cursorHeight: 20,
                            style: TextStyle(
                              fontSize: 15,
                              color: cs.onSurface,
                            ),
                            decoration: _inputDecoration(
                              hint: t.translate('registerEmailHint'),
                              prefixIcon: Icons.email_outlined,
                              hasError: controller.emailError.value.isNotEmpty,
                              cs: cs,
                            ),
                            onChanged: (_) {
                              if (controller.emailError.value.isNotEmpty) {
                                controller.emailError.value = '';
                              }
                            },
                          ),
                          _buildErrorText(
                              controller.emailError.value.isEmpty
                                  ? null
                                  : controller.emailError.value,
                              cs),
                          const SizedBox(height: 8),
                          // Toggle to also add a phone number
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => controller.toggleAuthMethod(),
                              child: Text(
                                controller.useEmail.value
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
                          if (!controller.useEmail.value) ...[
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
                                      color:
                                          cs.outlineVariant.withOpacity(0.5),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: DropdownButton<String>(
                                    value: controller.selectedCountryCode.value,
                                    items: controller.countryCodes.entries
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
                                        controller.setCountryCode(v);
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
                                    controller: controller.phoneController,
                                    focusNode: controller.phoneFocusNode,
                                    textInputAction: TextInputAction.next,
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
                                      hintText:
                                          t.translate('registerPhoneHint'),
                                      hintStyle: TextStyle(
                                        color: cs.onSurfaceVariant
                                            .withOpacity(0.5),
                                        fontSize: 14,
                                      ),
                                      filled: true,
                                      fillColor: cs.surfaceContainerHighest
                                          .withOpacity(0.4),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: controller
                                                  .phoneError.value.isNotEmpty
                                              ? cs.error
                                              : cs.outlineVariant
                                                  .withOpacity(0.5),
                                          width: controller.phoneError.value
                                                  .isNotEmpty
                                              ? 1.5
                                              : 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                          color: cs.primary,
                                          width: 1.8,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                    ),
                                    onChanged: (_) {
                                      if (controller.phoneError.value
                                          .isNotEmpty) {
                                        controller.phoneError.value = '';
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            _buildErrorText(
                                controller.phoneError.value.isEmpty
                                    ? null
                                    : controller.phoneError.value,
                                cs),
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
                            controller: controller.passwordController,
                            focusNode: controller.passwordFocusNode,
                            textInputAction: TextInputAction.next,
                            obscureText: controller.obscurePassword.value,
                            cursorHeight: 20,
                            style: TextStyle(
                              fontSize: 15,
                              color: cs.onSurface,
                            ),
                            decoration: _inputDecoration(
                              hint: t.translate('registerPasswordHint'),
                              prefixIcon: Icons.lock_outlined,
                              hasError: controller.passwordError.value.isNotEmpty,
                              cs: cs,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    controller.togglePasswordVisibility(),
                              ),
                            ),
                            onChanged: (_) {
                              if (controller.passwordError.value.isNotEmpty) {
                                controller.passwordError.value = '';
                              }
                            },
                          ),
                          _buildErrorText(
                              controller.passwordError.value.isEmpty
                                  ? null
                                  : controller.passwordError.value,
                              cs),
                          _buildPasswordRequirements(t, cs, controller),

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
                            controller: controller.confirmPasswordController,
                            focusNode: controller.confirmPasswordFocusNode,
                            textInputAction: TextInputAction.done,
                            obscureText:
                                controller.obscureConfirmPassword.value,
                            cursorHeight: 20,
                            style: TextStyle(
                              fontSize: 15,
                              color: cs.onSurface,
                            ),
                            decoration: _inputDecoration(
                              hint: t.translate(
                                  'registerConfirmPasswordHint'),
                              prefixIcon: Icons.lock_outlined,
                              hasError: controller
                                  .confirmPasswordError.value.isNotEmpty,
                              cs: cs,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.obscureConfirmPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: cs.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () => controller
                                    .toggleConfirmPasswordVisibility(),
                              ),
                            ),
                            onChanged: (_) {
                              if (controller.confirmPasswordError.value
                                  .isNotEmpty) {
                                controller.confirmPasswordError.value = '';
                              }
                            },
                          ),
                          _buildErrorText(
                              controller.confirmPasswordError.value.isEmpty
                                  ? null
                                  : controller.confirmPasswordError.value,
                              cs),

                          const SizedBox(height: 16),

                          // ── Register Button ──────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.handleRegister(t),
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
                              child: controller.isLoading.value
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
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SocialCircle(
                            onTap: controller.anyLoading
                                ? null
                                : () => FocusScope.of(context).unfocus(),
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
                            onTap: controller.anyLoading
                                ? null
                                : () => controller.handleFacebookSignIn(t),
                            isLoading: controller.isFacebookLoading.value,
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
                            onTap: controller.anyLoading
                                ? null
                                : () => controller.handleGoogleSignIn(t),
                            isLoading: controller.isGoogleLoading.value,
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
