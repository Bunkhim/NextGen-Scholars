import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/services/user_firestore_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final countryController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  final RxBool isSaving = false.obs;
  final RxBool isLoading = true.obs;
  final Rxn<File> pickedPhoto = Rxn<File>();
  final RxnString existingPhotoUrl = RxnString();

  final RxnString nameError = RxnString();
  final RxnString emailError = RxnString();
  final RxnString phoneError = RxnString();
  final RxnString dobError = RxnString();
  final RxnString countryError = RxnString();

  final List<String> countryNameKeys = const [
    'countryNameCambodia',
    'countryNameUSA',
    'countryNameUK',
    'countryNameIndia',
    'countryNameChina',
    'countryNameJapan',
    'countryNameSouthKorea',
    'countryNameVietnam',
    'countryNameThailand',
    'countryNameSingapore',
    'countryNameMalaysia',
    'countryNameIndonesia',
    'countryNamePhilippines',
    'countryNameAustralia',
    'countryNameFrance',
    'countryNameGermany',
  ];

  RxList<bool> selectedFields = List<bool>.filled(4, false).obs;
  final RxList<String> savedInterests = <String>[].obs;

  String originalName = '';
  String originalEmail = '';
  String originalPhone = '';
  String originalDob = '';
  String originalCountry = '';
  List<String> originalInterests = <String>[];

  List<String> getInterestedFields(AppLocalizations t) => [
        t.translate('editProfileInterestArt'),
        t.translate('editProfileInterestMedical'),
        t.translate('editProfileInterestFullScholarship'),
        t.translate('editProfileInterestUSA'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    countryController.dispose();
    super.onClose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserFirestoreService().getProfile();
      final jwtName = JwtService().displayNameSync;
      final jwtEmail = JwtService().emailSync;

      if (profile != null) {
        nameController.text = profile['name'] ?? jwtName ?? '';
        emailController.text = profile['email'] ?? jwtEmail ?? '';
        phoneController.text = profile['phone'] ?? '';
        dobController.text = profile['dob'] ?? '';
        countryController.text = profile['country'] ?? '';
        existingPhotoUrl.value = profile['photoUrl'];
        savedInterests.assignAll(
          List<String>.from(profile['interestedFields'] ?? []),
        );

        final t = AppLocalizations.of(Get.context!);
        final fields = getInterestedFields(t);
        for (int i = 0; i < fields.length; i++) {
          selectedFields[i] = savedInterests.contains(fields[i]);
        }
      } else {
        nameController.text = jwtName ?? '';
        emailController.text = jwtEmail ?? '';
      }

      _snapshotOriginalValues();
    } catch (_) {
      final jwtName = JwtService().displayNameSync;
      final jwtEmail = JwtService().emailSync;
      nameController.text = jwtName ?? '';
      emailController.text = jwtEmail ?? '';
      _snapshotOriginalValues();
    }

    isLoading.value = false;
  }

  void _snapshotOriginalValues() {
    originalName = nameController.text;
    originalEmail = emailController.text;
    originalPhone = phoneController.text;
    originalDob = dobController.text;
    originalCountry = countryController.text;
    originalInterests = List<String>.from(savedInterests);
  }

  bool get hasUnsavedChanges {
    return nameController.text != originalName ||
        emailController.text != originalEmail ||
        phoneController.text != originalPhone ||
        dobController.text != originalDob ||
        countryController.text != originalCountry ||
        pickedPhoto.value != null ||
        interestsChanged;
  }

  bool get interestsChanged {
    final current = <String>[];
    final t = AppLocalizations.of(Get.context!);
    final fields = getInterestedFields(t);
    for (int i = 0; i < fields.length; i++) {
      if (selectedFields[i]) current.add(fields[i]);
    }
    if (current.length != originalInterests.length) return true;
    for (final item in current) {
      if (!originalInterests.contains(item)) return true;
    }
    return false;
  }

  void toggleInterest(int index) {
    if (index < 0 || index >= selectedFields.length) return;
    selectedFields[index] = !selectedFields[index];
    selectedFields.refresh();
  }

  void setCountry(String value) {
    countryController.text = value;
    validateCountryLive(value);
  }

  String? validateName(String value, AppLocalizations t) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return t.translate('editProfileNameRequired');
    if (trimmed.length < 2 || trimmed.length > 50) {
      return t.translate('editProfileNameLength');
    }
    if (!RegExp(r"^[\p{L}\s'\-.]+$", unicode: true).hasMatch(trimmed)) {
      return t.translate('editProfileNameLength');
    }
    return null;
  }

  String? validateEmail(String value, AppLocalizations t) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return t.translate('editProfileEmailRequired');
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return t.translate('editProfileEmailInvalid');
    }
    return null;
  }

  String? validatePhone(String value, AppLocalizations t) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return t.translate('editProfilePhoneRequired');
    final cleaned = trimmed.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      return t.translate('editProfilePhoneInvalid');
    }
    if (cleaned.length < 7 || cleaned.length > 15) {
      return t.translate('editProfilePhoneInvalid');
    }
    return null;
  }

  String? validateDob(String value, AppLocalizations t) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return t.translate('editProfileDobRequired');
    final parts = trimmed.split('/');
    if (parts.length != 3) return t.translate('editProfileDobInvalid');
    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return t.translate('editProfileDobInvalid');
    }
    if (month < 1 || month > 12 || year < 1900 || year > DateTime.now().year - 13) {
      return t.translate('editProfileDobInvalid');
    }
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return t.translate('editProfileDobInvalid');
    }
    if (date.isAfter(DateTime.now())) {
      return t.translate('editProfileDobInvalid');
    }
    return null;
  }

  String? validateCountry(String value, AppLocalizations t) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return t.translate('editProfileCountryRequired');
    if (trimmed.length < 2 || trimmed.length > 56) {
      return t.translate('editProfileCountryInvalid');
    }
    if (!RegExp(r"^[\p{L}\s'\-.]+$", unicode: true).hasMatch(trimmed)) {
      return t.translate('editProfileCountryInvalid');
    }
    return null;
  }

  void validateNameLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    nameError.value = validateName(value, t);
  }

  void validateEmailLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    emailError.value = validateEmail(value, t);
  }

  void validatePhoneLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    phoneError.value = validatePhone(value, t);
  }

  void validateDobLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    dobError.value = validateDob(value, t);
  }

  void validateCountryLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    countryError.value = validateCountry(value, t);
  }

  void validateForm() {
    final t = AppLocalizations.of(Get.context!);
    nameError.value = validateName(nameController.text, t);
    emailError.value = validateEmail(emailController.text, t);
    phoneError.value = validatePhone(phoneController.text, t);
    dobError.value = validateDob(dobController.text, t);
    countryError.value = validateCountry(countryController.text, t);
  }

  bool hasErrors() {
    return nameError.value != null ||
        emailError.value != null ||
        phoneError.value != null ||
        dobError.value != null ||
        countryError.value != null;
  }

  Future<void> handleSave() async {
    final t = AppLocalizations.of(Get.context!);
    validateForm();
    if (hasErrors()) {
      Get.snackbar('', t.translate('editProfileFixErrors'));
      return;
    }

    isSaving.value = true;
    try {
      String? photoPath = existingPhotoUrl.value;
      if (pickedPhoto.value != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final ext = p.extension(pickedPhoto.value!.path);
        final dest = File('${appDir.path}/profile_photo$ext');
        await pickedPhoto.value!.copy(dest.path);
        photoPath = dest.path;
        await FileImage(dest).evict();
      }

      ProfileScreen.activePhotoPath = photoPath;
      ProfileScreen.photoRefreshNotifier.value++;

      final fields = getInterestedFields(t);
      final interests = <String>[];
      for (int i = 0; i < fields.length; i++) {
        if (selectedFields[i]) interests.add(fields[i]);
      }

      await UserFirestoreService().updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        dob: dobController.text.trim(),
        country: countryController.text.trim(),
        photoUrl: photoPath,
        interestedFields: interests,
      );

      _snapshotOriginalValues();
      pickedPhoto.value = null;
      existingPhotoUrl.value = photoPath;

      ProfileScreen.refreshNotifier.value++;
      Get.back(result: true);
      Get.snackbar('', t.translate('editProfileSaveSuccess'));
    } catch (e) {
      Get.snackbar('', 'Error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickPhoto(ImageSource source) async {
    try {
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null) {
        pickedPhoto.value = File(picked.path);
      }
    } catch (e) {
      Get.snackbar('', 'Failed to pick image: $e');
    }
  }

  Future<bool> confirmDiscardChanges() async {
    if (!hasUnsavedChanges) return true;
    final t = AppLocalizations.of(Get.context!);
    final result = await showDialog<bool>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text(t.translate('editProfileUnsavedTitle')),
        content: Text(t.translate('editProfileUnsavedMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.translate('editProfileDiscard')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.translate('editProfileKeepEditing')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  bool get hasPhotoToShow {
    final photo = existingPhotoUrl.value;
    if (photo == null || photo.isEmpty) return false;
    if (photo.startsWith('http')) return true;
    return File(photo).existsSync();
  }

  ImageProvider? get photoProvider {
    final photo = existingPhotoUrl.value;
    if (photo == null || photo.isEmpty) return null;
    if (photo.startsWith('http')) return NetworkImage(photo);
    final file = File(photo);
    if (file.existsSync()) return FileImage(file);
    return null;
  }

  String get initials {
    final name = nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
