part of 'edit_profile_view.dart';

class EditProfileViewController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final countryController = TextEditingController();

  final nameError = Rx<String?>(null);
  final emailError = Rx<String?>(null);
  final phoneError = Rx<String?>(null);
  final dobError = Rx<String?>(null);
  final countryError = Rx<String?>(null);
  final isSaving = false.obs;
  final isLoading = true.obs;
  final pickedPhoto = Rx<File?>(null);
  final existingPhotoUrl = Rx<String?>(null);
  final selectedFields = <bool>[].obs;
  final savedInterests = <String>[].obs;

  late String _originalName;
  late String _originalEmail;
  late String _originalPhone;
  late String _originalDob;
  late String _originalCountry;
  late List<String> _originalInterests;

  final List<String> countryNameKeys = const [
    'countryNameCambodia', 'countryNameUSA', 'countryNameUK',
    'countryNameIndia', 'countryNameChina', 'countryNameJapan',
    'countryNameSouthKorea', 'countryNameVietnam', 'countryNameThailand',
    'countryNameSingapore', 'countryNameMalaysia', 'countryNameIndonesia',
    'countryNamePhilippines', 'countryNameAustralia', 'countryNameFrance',
    'countryNameGermany',
  ];

  List<String> getInterestedFields(AppLocalizations t) => [
    t.translate('editProfileFieldArt'),
    t.translate('editProfileFieldMedical'),
    t.translate('editProfileFieldFullScholarship'),
    t.translate('editProfileFieldUSA'),
  ];

  bool get hasPhotoToShow {
    if (existingPhotoUrl.value == null || existingPhotoUrl.value!.isEmpty) return false;
    if (existingPhotoUrl.value!.startsWith('http')) return true;
    return File(existingPhotoUrl.value!).existsSync();
  }

  ImageProvider? get photoProvider {
    if (existingPhotoUrl.value == null || existingPhotoUrl.value!.isEmpty) return null;
    if (existingPhotoUrl.value!.startsWith('http')) {
      return NetworkImage(existingPhotoUrl.value!);
    }
    final f = File(existingPhotoUrl.value!);
    if (f.existsSync()) return FileImage(f);
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

  bool get hasUnsavedChanges {
    return nameController.text != _originalName ||
        emailController.text != _originalEmail ||
        phoneController.text != _originalPhone ||
        dobController.text != _originalDob ||
        countryController.text != _originalCountry ||
        pickedPhoto.value != null ||
        _interestsChanged;
  }

  bool get _interestsChanged {
    final t = AppLocalizations.of(Get.context!);
    final fields = getInterestedFields(t);
    final current = <String>[];
    for (int i = 0; i < fields.length; i++) {
      if (selectedFields[i]) current.add(fields[i]);
    }
    if (current.length != _originalInterests.length) return true;
    for (final item in current) {
      if (!_originalInterests.contains(item)) return true;
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    selectedFields.value = List<bool>.filled(4, false);
    _originalName = '';
    _originalEmail = '';
    _originalPhone = '';
    _originalDob = '';
    _originalCountry = '';
    _originalInterests = [];
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final profile = await UserFirestoreService().getProfile();
      final user = FirebaseAuth.instance.currentUser;

      if (profile != null) {
        nameController.text = profile['name'] ?? user?.displayName ?? '';
        emailController.text = profile['email'] ?? user?.email ?? '';
        phoneController.text = profile['phone'] ?? '';
        dobController.text = profile['dob'] ?? '';
        countryController.text = profile['country'] ?? '';
        existingPhotoUrl.value = profile['photoUrl'] ?? user?.photoURL;
        savedInterests.value = List<String>.from(profile['interestedFields'] ?? []);

        final t = AppLocalizations.of(Get.context!);
        final fields = getInterestedFields(t);
        for (int i = 0; i < fields.length; i++) {
          selectedFields[i] = savedInterests.contains(fields[i]);
        }
      } else if (user != null) {
        nameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
        existingPhotoUrl.value = user.photoURL;
      }

      _originalName = nameController.text;
      _originalEmail = emailController.text;
      _originalPhone = phoneController.text;
      _originalDob = dobController.text;
      _originalCountry = countryController.text;
      _originalInterests = List<String>.from(savedInterests);
    } catch (e) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        nameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
        existingPhotoUrl.value = user.photoURL;
        _originalName = nameController.text;
        _originalEmail = emailController.text;
      }
    }

    isLoading.value = false;
  }

  bool isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return RegExp(r'^\d{7,15}$').hasMatch(cleaned);
  }

  bool isValidName(String name) {
    final trimmed = name.trim();
    if (trimmed.length < 2 || trimmed.length > 50) return false;
    return RegExp(r"^[\p{L}\s'\-.]+$", unicode: true).hasMatch(trimmed);
  }

  bool isValidDOB(String dob) {
    if (dob.isEmpty) return false;
    try {
      final parts = dob.split('/');
      if (parts.length != 3) return false;
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day == null || month == null || year == null) return false;
      if (month < 1 || month > 12) return false;
      if (year < 1900 || year > DateTime.now().year - 13) return false;
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) return false;
      if (date.isAfter(DateTime.now())) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isValidCountry(String country) {
    final value = country.trim();
    if (value.length < 2 || value.length > 56) return false;
    return RegExp(r"^[\p{L}\s'\-\.]+$", unicode: true).hasMatch(value);
  }

  void validateNameLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    if (value.trim().isEmpty) {
      nameError.value = t.translate('editProfileNameRequired');
    } else if (!isValidName(value)) {
      nameError.value = t.translate('editProfileNameLength');
    } else {
      nameError.value = null;
    }
  }

  void validateEmailLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    if (value.trim().isEmpty) {
      emailError.value = t.translate('editProfileEmailRequired');
    } else if (!isValidEmail(value.trim())) {
      emailError.value = t.translate('editProfileEmailInvalid');
    } else {
      emailError.value = null;
    }
  }

  void validatePhoneLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    if (value.trim().isEmpty) {
      phoneError.value = t.translate('editProfilePhoneRequired');
    } else if (!isValidPhone(value.trim())) {
      phoneError.value = t.translate('editProfilePhoneInvalid');
    } else {
      phoneError.value = null;
    }
  }

  void validateDobLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    if (value.trim().isEmpty) {
      dobError.value = t.translate('editProfileDobRequired');
    } else if (!isValidDOB(value.trim())) {
      dobError.value = t.translate('editProfileDobInvalid');
    } else {
      dobError.value = null;
    }
  }

  void validateCountryLive(String value) {
    final t = AppLocalizations.of(Get.context!);
    if (value.trim().isEmpty) {
      countryError.value = t.translate('editProfileCountryRequired');
    } else if (!isValidCountry(value)) {
      countryError.value = t.translate('editProfileCountryInvalid');
    } else {
      countryError.value = null;
    }
  }

  bool _hasErrors() {
    return nameError.value != null ||
        emailError.value != null ||
        phoneError.value != null ||
        dobError.value != null ||
        countryError.value != null;
  }

  void handleSave(BuildContext context) {
    _validateForm(context);
    if (_hasErrors()) {
      final t = AppLocalizations.of(context);
      _showTopMessageFromContext(context, t.translate('editProfileFixErrors'), Colors.red.shade600);
      return;
    }
    _doSave(context);
  }

  void _validateForm(BuildContext context) {
    final t = AppLocalizations.of(context);

    nameError.value = null;
    emailError.value = null;
    phoneError.value = null;
    dobError.value = null;
    countryError.value = null;

    final name = nameController.text.trim();
    if (name.isEmpty) {
      nameError.value = t.translate('editProfileNameRequired');
    } else if (!isValidName(name)) {
      nameError.value = t.translate('editProfileNameLength');
    }

    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = t.translate('editProfileEmailRequired');
    } else if (!isValidEmail(email)) {
      emailError.value = t.translate('editProfileEmailInvalid');
    }

    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      phoneError.value = t.translate('editProfilePhoneRequired');
    } else if (!isValidPhone(phone)) {
      phoneError.value = t.translate('editProfilePhoneInvalid');
    }

    final dob = dobController.text.trim();
    if (dob.isEmpty) {
      dobError.value = t.translate('editProfileDobRequired');
    } else if (!isValidDOB(dob)) {
      dobError.value = t.translate('editProfileDobInvalid');
    }

    final country = countryController.text.trim();
    if (country.isEmpty) {
      countryError.value = t.translate('editProfileCountryRequired');
    } else if (!isValidCountry(country)) {
      countryError.value = t.translate('editProfileCountryInvalid');
    }
  }

  void _showTopMessageFromContext(BuildContext context, String message, Color backgroundColor) {
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16, right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      backgroundColor == Colors.red.shade600
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> _doSave(BuildContext context) async {
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

      ProfileScreenViewController.activePhotoPath = photoPath;
      ProfileScreenViewController.photoRefreshNotifier.value++;

      final t = AppLocalizations.of(context);
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

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newName = nameController.text.trim();
        if (user.displayName != newName) {
          await user.updateDisplayName(newName);
        }
      }

      if (!context.mounted) return;
      final cs = Theme.of(context).colorScheme;
      _showTopMessageFromContext(context, t.translate('editProfileSaveSuccess'), cs.primary);

      ProfileScreenViewController.refreshNotifier.value++;

      Get.back(result: true);
    } catch (e) {
      if (context.mounted) {
        isSaving.value = false;
        _showTopMessageFromContext(context, 'Error: ${e.toString()}', Colors.red.shade600);
      }
    }
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
}
