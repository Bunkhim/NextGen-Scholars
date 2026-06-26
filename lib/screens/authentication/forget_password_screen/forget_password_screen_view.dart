import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/authentication/email_otp_service.dart';
import 'package:scholarship_app/screens/authentication/phone_otp_service.dart';

part 'forget_password_screen_binding.dart';
part 'forget_password_screen_controller.dart';

class ForgetPasswordScreenView extends StatefulWidget {
  const ForgetPasswordScreenView({super.key});

  @override
  State<ForgetPasswordScreenView> createState() =>
      _ForgetPasswordScreenViewState();
}

class _ForgetPasswordScreenViewState extends State<ForgetPasswordScreenView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late final ctrl = Get.find<ForgetPasswordScreenViewController>();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    ctrl.phoneFocusNode.addListener(() => setState(() {}));
    ctrl.emailFocusNode.addListener(() => setState(() {}));
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
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('forgotPasswordPhoneRequired');
    }
    final clean = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^[\d]+$').hasMatch(clean)) {
      return t.translate('forgotPasswordPhoneDigitsOnly');
    }
    if (clean.length < 6 || clean.length > 13) {
      return t.translate('forgotPasswordPhoneLength');
    }
    if (clean.startsWith('0')) {
      return t.translate('forgotPasswordRemoveLeadingZero');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return t.translate('forgotPasswordEmailRequired');
    }
    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return t.translate('forgotPasswordEmailInvalid');
    }
    return null;
  }

  void _showCountryPicker() {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.6,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                t.translate('forgotPasswordSelectCountry'),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            Divider(height: 1, color: cs.outlineVariant),
            Expanded(
              child: ListView.builder(
                itemCount: ctrl.countryCodes.length,
                itemBuilder: (_, index) {
                  final code = ctrl.countryCodes.keys.elementAt(index);
                  final country = ctrl.countryCodes[code]!;
                  final isSelected = code == ctrl.selectedCountryCode.value;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ctrl.selectedCountryCode.value = code;
                        if (ctrl.error.value != null) ctrl.error.value = null;
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        color: isSelected
                            ? cs.primary.withOpacity(0.08)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Text(
                              country['flag']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                t.translate(country['nameKey']!),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected ? cs.primary : cs.onSurface,
                                ),
                              ),
                            ),
                            Text(
                              country['code']!,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: cs.primary,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendPhoneOTP() async {
    final t = AppLocalizations.of(context);
    FocusScope.of(context).unfocus();
    ctrl.error.value = null;

    final value = ctrl.phoneController.text.trim();
    final validationError = _validatePhone(value);
    if (validationError != null) {
      ctrl.error.value = validationError;
      return;
    }

    ctrl.isLoading.value = true;

    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final fullPhoneNumber = '${ctrl.selectedCountryCode.value}$cleanPhone';

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: fullPhoneNumber)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        if (!mounted) return;
        ctrl.isLoading.value = false;
        ctrl.error.value = t.translate('forgotPasswordAccountNotFound');
        return;
      }
    } catch (_) {}

    final errorMsg =
        await ctrl.phoneOtpService.sendOTP(phoneNumber: fullPhoneNumber);

    if (!mounted) return;

    if (errorMsg == null) {
      ctrl.isLoading.value = false;
      _showSuccessMessage(t
          .translate('forgotPasswordOtpSent')
          .replaceAll('\$phone', fullPhoneNumber));
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Get.toNamed(
            Routes.verifyEmail,
            arguments: {
              'type': 'phone',
              'destination': fullPhoneNumber,
              'purpose': 'forgotPassword',
            },
          );
        }
      });
    } else {
      ctrl.isLoading.value = false;
      ctrl.error.value = errorMsg;
    }
  }

  Future<void> _sendEmailOTP() async {
    FocusScope.of(context).unfocus();
    ctrl.error.value = null;

    final email = ctrl.emailController.text.trim();
    final validationError = _validateEmail(email);
    if (validationError != null) {
      ctrl.error.value = validationError;
      return;
    }

    ctrl.isLoading.value = true;

    final t = AppLocalizations.of(context);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) {
        if (!mounted) return;
        ctrl.isLoading.value = false;
        ctrl.error.value = t.translate('forgotPasswordAccountNotFound');
        return;
      }
    } catch (_) {}

    final errorMsg = await ctrl.emailOtpService.sendOTP(email: email);

    if (!mounted) return;

    if (errorMsg == null) {
      ctrl.isLoading.value = false;
      _showSuccessMessage(t
          .translate('forgotPasswordOtpSentEmail')
          .replaceAll('\$email', email));
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Get.toNamed(
            Routes.verifyEmail,
            arguments: {
              'type': 'email',
              'destination': email,
              'purpose': 'forgotPassword',
            },
          );
        }
      });
    } else {
      ctrl.isLoading.value = false;
      ctrl.error.value = errorMsg;
    }
  }

  void _showSuccessMessage(String message) {
    final t = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.translate('forgotPasswordSuccess'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xff10B981),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 150,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
        elevation: 8,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final currentCountry = ctrl.countryCodes[ctrl.selectedCountryCode.value]!;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
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
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 48),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => Get.back(),
                          ),
                          Expanded(
                            child: Text(
                              t.translate('forgotPasswordTitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          size: 38,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        t.translate('forgotPasswordResetTitle'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          t.translate('forgotPasswordDescription'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => _buildTabSelector(cs),
                            ),
                            const SizedBox(height: 20),
                            Obx(
                              () => AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: ctrl.selectedTab.value == 0
                                    ? _buildPhoneTab(t, cs, currentCountry)
                                    : _buildEmailTab(t, cs),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            t.translate('forgotPasswordRememberPassword'),
                            style: TextStyle(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              t.translate('forgotPasswordBackToLogin'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(ColorScheme cs) {
    final t = AppLocalizations.of(context);
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withOpacity(0.35)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            alignment: ctrl.selectedTab.value == 0
                ? const Alignment(-1.0, 0)
                : const Alignment(1.0, 0),
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: cs.primary.withOpacity(0.30),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ctrl.selectedTab.value = 0;
                    ctrl.error.value = null;
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_android_rounded,
                          size: 18,
                          color: ctrl.selectedTab.value == 0
                              ? cs.onPrimary
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          t.translate('forgotPasswordTabPhone'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: ctrl.selectedTab.value == 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: ctrl.selectedTab.value == 0
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    ctrl.selectedTab.value = 1;
                    ctrl.error.value = null;
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 54,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 18,
                          color: ctrl.selectedTab.value == 1
                              ? cs.onPrimary
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          t.translate('forgotPasswordTabEmail'),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: ctrl.selectedTab.value == 1
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: ctrl.selectedTab.value == 1
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneTab(
    AppLocalizations t,
    ColorScheme cs,
    Map<String, String> currentCountry,
  ) {
    return Column(
      key: const ValueKey('phone_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.phone_android_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              t.translate('forgotPasswordPhoneLabel'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ctrl.error.value != null
                  ? cs.error
                  : ctrl.phoneFocusNode.hasFocus
                      ? cs.primary
                      : cs.outlineVariant,
              width: ctrl.phoneFocusNode.hasFocus ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showCountryPicker,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentCountry['flag']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          currentCountry['code']!,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 40, color: cs.outlineVariant),
              Expanded(
                child: TextFormField(
                  controller: ctrl.phoneController,
                  focusNode: ctrl.phoneFocusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _sendPhoneOTP(),
                  cursorColor: cs.primary,
                  cursorHeight: 20,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: t.translate('forgotPasswordPhoneHint'),
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (_) {
                    if (ctrl.error.value != null) ctrl.error.value = null;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => ctrl.error.value != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 16, color: cs.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ctrl.error.value!,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: ctrl.isLoading.value ? null : _sendPhoneOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: ctrl.isLoading.value
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(cs.onPrimary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded,
                            size: 20, color: cs.onPrimary),
                        const SizedBox(width: 8),
                        Text(
                          t.translate('forgotPasswordSendButton'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailTab(AppLocalizations t, ColorScheme cs) {
    return Column(
      key: const ValueKey('email_tab'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.email_outlined, size: 18, color: cs.primary),
            const SizedBox(width: 6),
            Text(
              t.translate('forgotPasswordEmailLabel'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withOpacity(0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ctrl.error.value != null
                  ? cs.error
                  : ctrl.emailFocusNode.hasFocus
                      ? cs.primary
                      : cs.outlineVariant,
              width: ctrl.emailFocusNode.hasFocus ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Icon(
                  Icons.email_outlined,
                  size: 22,
                  color: cs.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: ctrl.emailController,
                  focusNode: ctrl.emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _sendEmailOTP(),
                  cursorColor: cs.primary,
                  cursorHeight: 20,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                  decoration: InputDecoration(
                    hintText: t.translate('forgotPasswordEmailHint'),
                    hintStyle: TextStyle(
                      color: cs.onSurfaceVariant.withOpacity(0.5),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (_) {
                    if (ctrl.error.value != null) ctrl.error.value = null;
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.translate('forgotPasswordEmailDescription'),
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant.withOpacity(0.6),
            height: 1.4,
          ),
        ),
        Obx(
          () => ctrl.error.value != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 16, color: cs.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ctrl.error.value!,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 24),
        Obx(
          () => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: ctrl.isLoading.value ? null : _sendEmailOTP,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: cs.onSurface.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: ctrl.isLoading.value
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(cs.onPrimary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded,
                            size: 20, color: cs.onPrimary),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)
                              .translate('forgotPasswordSendButton'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
