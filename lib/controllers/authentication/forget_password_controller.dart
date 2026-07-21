import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/core/api/services/auth_api_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/email_otp_service.dart';
import 'package:scholarship_app/services/phone_otp_service.dart';

class ForgetPasswordController extends GetxController {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final emailFocusNode = FocusNode();

  final PhoneOTPService _phoneOtpService = PhoneOTPService();
  final EmailOTPService _emailOtpService = EmailOTPService();
  final AuthApiService _authApi = AuthApiService();

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final RxString selectedCountryCode = '+855'.obs;
  final RxInt selectedTab = 0.obs;

  final Map<String, Map<String, String>> countryCodes = {
    '+855': {'flag': '\uD83C\uDDF0\uD83C\uDDED', 'nameKey': 'countryNameCambodia', 'code': '+855'},
    '+1': {'flag': '\uD83C\uDDFA\uD83C\uDDF8', 'nameKey': 'countryNameUSA', 'code': '+1'},
    '+44': {'flag': '\uD83C\uDDEC\uD83C\uDDE7', 'nameKey': 'countryNameUK', 'code': '+44'},
    '+91': {'flag': '\uD83C\uDDEE\uD83C\uDDF3', 'nameKey': 'countryNameIndia', 'code': '+91'},
    '+86': {'flag': '\uD83C\uDDE8\uD83C\uDDF3', 'nameKey': 'countryNameChina', 'code': '+86'},
    '+81': {'flag': '\uD83C\uDDEF\uD83C\uDDF5', 'nameKey': 'countryNameJapan', 'code': '+81'},
    '+82': {'flag': '\uD83C\uDDF0\uD83C\uDDF7', 'nameKey': 'countryNameSouthKorea', 'code': '+82'},
    '+84': {'flag': '\uD83C\uDDFB\uD83C\uDDF3', 'nameKey': 'countryNameVietnam', 'code': '+84'},
    '+65': {'flag': '\uD83C\uDDF8\uD83C\uDDEC', 'nameKey': 'countryNameSingapore', 'code': '+65'},
    '+60': {'flag': '\uD83C\uDDF2\uD83C\uDDFE', 'nameKey': 'countryNameMalaysia', 'code': '+60'},
    '+62': {'flag': '\uD83C\uDDEE\uD83C\uDDE9', 'nameKey': 'countryNameIndonesia', 'code': '+62'},
    '+63': {'flag': '\uD83C\uDDF5\uD83C\uDDED', 'nameKey': 'countryNamePhilippines', 'code': '+63'},
    '+61': {'flag': '\uD83C\uDDE6\uD83C\uDDFA', 'nameKey': 'countryNameAustralia', 'code': '+61'},
    '+33': {'flag': '\uD83C\uDDEB\uD83C\uDDF7', 'nameKey': 'countryNameFrance', 'code': '+33'},
    '+49': {'flag': '\uD83C\uDDE9\uD83C\uDDEA', 'nameKey': 'countryNameGermany', 'code': '+49'},
  };

  @override
  void onInit() {
    super.onInit();
    phoneFocusNode.addListener(update);
    emailFocusNode.addListener(update);
  }

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    super.onClose();
  }

  void selectTab(int index) {
    selectedTab.value = index;
    error.value = null;
  }

  void selectCountryCode(String code) {
    selectedCountryCode.value = code;
    error.value = null;
  }

  void clearErrorIfNeeded() {
    if (error.value != null) error.value = null;
  }

  String? validatePhone(String? value, AppLocalizations t) {
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

  String? validateEmail(String? value, AppLocalizations t) {
    if (value == null || value.trim().isEmpty) {
      return t.translate('forgotPasswordEmailRequired');
    }
    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return t.translate('forgotPasswordEmailInvalid');
    }
    return null;
  }

  Future<void> sendPhoneOTP(AppLocalizations t) async {
    error.value = null;
    final value = phoneController.text.trim();
    final validationError = validatePhone(value, t);
    if (validationError != null) {
      error.value = validationError;
      return;
    }

    isLoading.value = true;

    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final fullPhoneNumber = '${selectedCountryCode.value}$cleanPhone';

    try {
      await _authApi.lookupUser(email: fullPhoneNumber);
    } catch (_) {
      isLoading.value = false;
      error.value = t.translate('forgotPasswordAccountNotFound');
      return;
    }

    final errorMsg = await _phoneOtpService.sendOTP(phoneNumber: fullPhoneNumber);

    if (errorMsg == null) {
      isLoading.value = false;
      Get.snackbar(
        t.translate('forgotPasswordSuccess'),
        t.translate('forgotPasswordOtpSent').replaceAll('\$phone', fullPhoneNumber),
        backgroundColor: const Color(0xff10B981),
        colorText: Colors.white,
      );
      await Future.delayed(const Duration(milliseconds: 800));
      Get.toNamed(
        AppRoutes.verifyEmailScreen,
        arguments: {
          'type': 'phone',
          'destination': fullPhoneNumber,
          'purpose': 'forgotPassword',
        },
      );
    } else {
      isLoading.value = false;
      error.value = errorMsg;
    }
  }

  Future<void> sendEmailOTP(AppLocalizations t) async {
    error.value = null;
    final email = emailController.text.trim();
    final validationError = validateEmail(email, t);
    if (validationError != null) {
      error.value = validationError;
      return;
    }

    isLoading.value = true;

    try {
      await _authApi.lookupUser(email: email);
    } catch (_) {
      isLoading.value = false;
      error.value = t.translate('forgotPasswordAccountNotFound');
      return;
    }

    final errorMsg = await _emailOtpService.sendOTP(email: email);

    if (errorMsg == null) {
      isLoading.value = false;
      Get.snackbar(
        t.translate('forgotPasswordSuccess'),
        t.translate('forgotPasswordOtpSentEmail').replaceAll('\$email', email),
        backgroundColor: const Color(0xff10B981),
        colorText: Colors.white,
      );
      await Future.delayed(const Duration(milliseconds: 800));
      Get.toNamed(
        AppRoutes.verifyEmailScreen,
        arguments: {
          'type': 'email',
          'destination': email,
          'purpose': 'forgotPassword',
        },
      );
    } else {
      isLoading.value = false;
      error.value = errorMsg;
    }
  }
}
