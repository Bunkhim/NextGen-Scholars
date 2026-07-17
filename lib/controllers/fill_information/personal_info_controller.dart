import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/core/api/services/upload_api_service.dart';

class PersonalInfoController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final _appData = ApplicationData();

  final Rxn<String> selectedGender = Rxn<String>();
  final Rxn<String> selectedNationality = Rxn<String>();
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();
  final RxnString profileImage = RxnString();

  final RxnString genderError = RxnString();
  final RxnString nationalityError = RxnString();
  final RxnString dateError = RxnString();
  final RxnString imageError = RxnString();
  final RxnString firstNameError = RxnString();
  final RxnString lastNameError = RxnString();
  final RxnString phoneError = RxnString();
  final RxnString emailError = RxnString();

  final RxBool hasAttemptedSubmit = false.obs;

  // ── Locale-independent keys for Gender & Nationality ───────────────────
  static const genderKeys = ['male', 'female', 'other'];
  static const genderTranslationKeys = [
    'personalInfoGenderMale',
    'personalInfoGenderFemale',
    'personalInfoGenderOther',
  ];

  static const nationalityKeys = [
    'cambodian',
    'vietnamese',
    'laotian',
    'chinese',
    'american',
    'japanese',
    'korean',
    'other',
  ];
  static const nationalityTranslationKeys = [
    'personalInfoNationalityCambodian',
    'personalInfoNationalityVietnamese',
    'personalInfoNationalityLaotian',
    'personalInfoNationalityChinese',
    'personalInfoNationalityAmerican',
    'personalInfoNationalityJapanese',
    'personalInfoNationalityKorean',
    'personalInfoNationalityOther',
  ];

  List<String> getGenders(AppLocalizations t) =>
      genderTranslationKeys.map((k) => t.translate(k)).toList();

  List<String> getNationalities(AppLocalizations t) =>
      nationalityTranslationKeys.map((k) => t.translate(k)).toList();

  String? genderKeyToDisplay(String? key, AppLocalizations t) {
    if (key == null) return null;
    final idx = genderKeys.indexOf(key);
    if (idx >= 0) return t.translate(genderTranslationKeys[idx]);
    final genders = getGenders(t);
    if (genders.contains(key)) return key;
    return null;
  }

  String? nationalityKeyToDisplay(String? key, AppLocalizations t) {
    if (key == null) return null;
    final idx = nationalityKeys.indexOf(key);
    if (idx >= 0) return t.translate(nationalityTranslationKeys[idx]);
    final nationalities = getNationalities(t);
    if (nationalities.contains(key)) return key;
    return null;
  }

  String? genderDisplayToKey(String? display, AppLocalizations t) {
    if (display == null) return null;
    final genders = getGenders(t);
    final idx = genders.indexOf(display);
    if (idx >= 0) return genderKeys[idx];
    if (genderKeys.contains(display)) return display;
    return display;
  }

  String? nationalityDisplayToKey(String? display, AppLocalizations t) {
    if (display == null) return null;
    final nationalities = getNationalities(t);
    final idx = nationalities.indexOf(display);
    if (idx >= 0) return nationalityKeys[idx];
    if (nationalityKeys.contains(display)) return display;
    return display;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();

    firstNameController.addListener(_onTextFieldChanged);
    lastNameController.addListener(_onTextFieldChanged);
    phoneController.addListener(_onTextFieldChanged);
    emailController.addListener(_onTextFieldChanged);
  }

  @override
  void onClose() {
    firstNameController.removeListener(_onTextFieldChanged);
    lastNameController.removeListener(_onTextFieldChanged);
    phoneController.removeListener(_onTextFieldChanged);
    emailController.removeListener(_onTextFieldChanged);
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }

  void _loadSavedData() {
    firstNameController.text = _appData.firstName ?? '';
    lastNameController.text = _appData.lastName ?? '';
    phoneController.text = _appData.phoneNumber ?? '';
    emailController.text = _appData.email ?? '';
    selectedGender.value = _normalizeGenderToKey(_appData.gender);
    selectedNationality.value = _normalizeNationalityToKey(_appData.nationality);
    selectedDate.value = _appData.dateOfBirth;
    profileImage.value = _appData.profileImage;
  }

  String? _normalizeGenderToKey(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (genderKeys.contains(raw)) return raw;
    const enGenders = ['Male', 'Female', 'Other'];
    final idx = enGenders.indexWhere((g) => g.toLowerCase() == raw.toLowerCase());
    if (idx >= 0) return genderKeys[idx];
    const kmGenders = ['ប្រុស', 'ស្រី', 'ផ្សេងទៀត'];
    final kidx = kmGenders.indexOf(raw);
    if (kidx >= 0) return genderKeys[kidx];
    return raw;
  }

  String? _normalizeNationalityToKey(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (nationalityKeys.contains(raw)) return raw;
    const enNats = [
      'Cambodian',
      'Vietnamese',
      'Laotian',
      'Chinese',
      'American',
      'Japanese',
      'Korean',
      'Other',
    ];
    final idx = enNats.indexWhere((n) => n.toLowerCase() == raw.toLowerCase());
    if (idx >= 0) return nationalityKeys[idx];
    const kmNats = [
      'ខ្មែរ',
      'វៀតណាម',
      'ឡាវ',
      'ចិន',
      'អាមេរិកាំង',
      'ជប៉ុន',
      'កូរ៉េ',
      'ផ្សេងទៀត',
    ];
    final kidx = kmNats.indexOf(raw);
    if (kidx >= 0) return nationalityKeys[kidx];
    return raw;
  }

  void _saveData() {
    _appData.firstName = firstNameController.text;
    _appData.lastName = lastNameController.text;
    _appData.phoneNumber = phoneController.text;
    _appData.email = emailController.text;
    _appData.gender = selectedGender.value;
    _appData.nationality = selectedNationality.value;
    _appData.dateOfBirth = selectedDate.value;
    _appData.profileImage = profileImage.value;
  }

  void onSave(AppLocalizations t) {
    _saveData();
    ApplicationData().saveToPrefs();
    Get.snackbar(
      '',
      t.translate('fillInfoSaved'),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _onTextFieldChanged() {
    if (hasAttemptedSubmit.value) {
      // Note: callers must supply `t` via revalidate(t) for translated errors;
      // this listener just marks fields dirty so the screen can call
      // revalidate on next build via a passed-in AppLocalizations.
    }
  }

  void revalidateTextFields(AppLocalizations t) {
    if (!hasAttemptedSubmit.value) return;
    firstNameError.value = validateName(firstNameController.text, t);
    lastNameError.value = validateName(lastNameController.text, t);
    phoneError.value = validatePhone(phoneController.text, t);
    emailError.value = validateEmail(emailController.text, t);
  }

  void selectDate(DateTime picked) {
    selectedDate.value = picked;
    dateError.value = null;
  }

  Future<void> pickImage(ImageSource source, AppLocalizations t) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        try {
          final uploadResult = await UploadApiService().uploadImage(file);
          final uploadedUrl = uploadResult['url'] as String?;
          if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
            profileImage.value = uploadedUrl;
          } else {
            profileImage.value = image.path;
          }
        } catch (_) {
          profileImage.value = image.path;
        }
        imageError.value = null;
      }
    } catch (e) {
      Get.snackbar(
        '',
        '${t.translate('personalInfoErrorPickingImage')}: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void removeImage(AppLocalizations t) {
    profileImage.value = null;
    if (hasAttemptedSubmit.value) {
      imageError.value = t.translate('personalInfoSelectImage');
    }
  }

  void selectGender(String? display, AppLocalizations t) {
    selectedGender.value = genderDisplayToKey(display, t);
    genderError.value = null;
  }

  void selectNationality(String? display, AppLocalizations t) {
    selectedNationality.value = nationalityDisplayToKey(display, t);
    nationalityError.value = null;
  }

  // ── Validation ──────────────────────────────────────────────────────────
  String? validateName(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('personalInfoFieldRequired');
    }
    if (value.length < 2) {
      return t.translate('personalInfoNameMinLength');
    }
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(value)) {
      return t.translate('personalInfoNameAllowUnicode');
    }
    return null;
  }

  String? validateEmail(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('personalInfoEmailRequired');
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return t.translate('personalInfoEmailInvalid');
    }
    return null;
  }

  String? validatePhone(String? value, AppLocalizations t) {
    if (value == null || value.isEmpty) {
      return t.translate('personalInfoPhoneRequired');
    }
    final digitsOnly = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return t.translate('personalInfoPhoneDigitsOnly');
    }
    if (digitsOnly.length < 8) {
      return t.translate('personalInfoPhoneMinDigits');
    }
    if (digitsOnly.length > 15) {
      return t.translate('personalInfoPhoneMaxDigits');
    }
    return null;
  }

  /// Returns true if the whole form is valid.
  bool submitForm(AppLocalizations t) {
    hasAttemptedSubmit.value = true;

    firstNameError.value = validateName(firstNameController.text, t);
    lastNameError.value = validateName(lastNameController.text, t);
    phoneError.value = validatePhone(phoneController.text, t);
    emailError.value = validateEmail(emailController.text, t);

    genderError.value = selectedGender.value == null
        ? t.translate('personalInfoSelectGender')
        : null;
    nationalityError.value = selectedNationality.value == null
        ? t.translate('personalInfoSelectNationality')
        : null;
    dateError.value =
        selectedDate.value == null ? t.translate('personalInfoSelectDob') : null;
    imageError.value =
        profileImage.value == null ? t.translate('personalInfoSelectImage') : null;

    final isValid = firstNameError.value == null &&
        lastNameError.value == null &&
        phoneError.value == null &&
        emailError.value == null &&
        genderError.value == null &&
        nationalityError.value == null &&
        dateError.value == null &&
        imageError.value == null;

    if (isValid) {
      _saveData();
      ApplicationData().saveToPrefs();
    }

    return isValid;
  }

  void goHome() {
    Get.offAllNamed(AppRoutes.homeScreen);
  }
}