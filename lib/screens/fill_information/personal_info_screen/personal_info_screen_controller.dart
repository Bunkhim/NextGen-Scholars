part of 'personal_info_screen_view.dart';

class PersonalInfoScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final appData = ApplicationData();

  final selectedGender = Rxn<String>();
  final selectedNationality = Rxn<String>();
  final selectedDate = Rxn<DateTime>();
  final profileImage = Rxn<File>();

  final genderError = Rxn<String>();
  final nationalityError = Rxn<String>();
  final dateError = Rxn<String>();
  final imageError = Rxn<String>();
  final firstNameError = Rxn<String>();
  final lastNameError = Rxn<String>();
  final phoneError = Rxn<String>();
  final emailError = Rxn<String>();

  final hasAttemptedSubmit = false.obs;

  static const _genderKeys = ['male', 'female', 'other'];
  static const _genderTranslationKeys = [
    'personalInfoGenderMale',
    'personalInfoGenderFemale',
    'personalInfoGenderOther',
  ];

  static const _nationalityKeys = [
    'cambodian',
    'vietnamese',
    'laotian',
    'chinese',
    'american',
    'japanese',
    'korean',
    'other',
  ];
  static const _nationalityTranslationKeys = [
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
      _genderTranslationKeys.map((k) => t.translate(k)).toList();

  List<String> getNationalities(AppLocalizations t) =>
      _nationalityTranslationKeys.map((k) => t.translate(k)).toList();

  String? genderKeyToDisplay(String? key, AppLocalizations t) {
    if (key == null) return null;
    final idx = _genderKeys.indexOf(key);
    if (idx >= 0) return t.translate(_genderTranslationKeys[idx]);
    final genders = getGenders(t);
    if (genders.contains(key)) return key;
    return null;
  }

  String? nationalityKeyToDisplay(String? key, AppLocalizations t) {
    if (key == null) return null;
    final idx = _nationalityKeys.indexOf(key);
    if (idx >= 0) return t.translate(_nationalityTranslationKeys[idx]);
    final nationalities = getNationalities(t);
    if (nationalities.contains(key)) return key;
    return null;
  }

  String? genderDisplayToKey(String? display, AppLocalizations t) {
    if (display == null) return null;
    final genders = getGenders(t);
    final idx = genders.indexOf(display);
    if (idx >= 0) return _genderKeys[idx];
    if (_genderKeys.contains(display)) return display;
    return display;
  }

  String? nationalityDisplayToKey(String? display, AppLocalizations t) {
    if (display == null) return null;
    final nationalities = getNationalities(t);
    final idx = nationalities.indexOf(display);
    if (idx >= 0) return _nationalityKeys[idx];
    if (_nationalityKeys.contains(display)) return display;
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

  void _loadSavedData() {
    firstNameController.text = appData.firstName ?? '';
    lastNameController.text = appData.lastName ?? '';
    phoneController.text = appData.phoneNumber ?? '';
    emailController.text = appData.email ?? '';
    selectedGender.value = _normalizeGenderToKey(appData.gender);
    selectedNationality.value = _normalizeNationalityToKey(appData.nationality);
    selectedDate.value = appData.dateOfBirth;
    profileImage.value = appData.profileImage;
  }

  String? _normalizeGenderToKey(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (_genderKeys.contains(raw)) return raw;
    const enGenders = ['Male', 'Female', 'Other'];
    final idx = enGenders.indexWhere((g) => g.toLowerCase() == raw.toLowerCase());
    if (idx >= 0) return _genderKeys[idx];
    const kmGenders = ['ប្រុស', 'ស្រី', 'ផ្សេងទៀត'];
    final kidx = kmGenders.indexOf(raw);
    if (kidx >= 0) return _genderKeys[kidx];
    return raw;
  }

  String? _normalizeNationalityToKey(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (_nationalityKeys.contains(raw)) return raw;
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
    if (idx >= 0) return _nationalityKeys[idx];
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
    if (kidx >= 0) return _nationalityKeys[kidx];
    return raw;
  }

  void _saveData() {
    appData.firstName = firstNameController.text;
    appData.lastName = lastNameController.text;
    appData.phoneNumber = phoneController.text;
    appData.email = emailController.text;
    appData.gender = selectedGender.value;
    appData.nationality = selectedNationality.value;
    appData.dateOfBirth = selectedDate.value;
    appData.profileImage = profileImage.value;
  }

  void onSave() {
    _saveData();
    ApplicationData().saveToPrefs();
    ScaffoldMessenger.of(Get.context!).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(Get.context!).translate('fillInfoSaved')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onTextFieldChanged() {
    if (hasAttemptedSubmit.value) {
      final ctx = Get.context;
      if (ctx == null) return;
      firstNameError.value = _validateName(firstNameController.text, ctx);
      lastNameError.value = _validateName(lastNameController.text, ctx);
      phoneError.value = _validatePhone(phoneController.text, ctx);
      emailError.value = _validateEmail(emailController.text, ctx);
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'GB'),
      helpText: AppLocalizations.of(context).translate('personalInfoDobHint'),
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: cs.copyWith(primary: cs.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
      dateError.value = null;
    }
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        profileImage.value = File(image.path);
        imageError.value = null;
      }
    } catch (e) {
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${t.translate('personalInfoErrorPickingImage')}: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        final t = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(t.translate('personalInfoImageSourceTitle'),
              style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt,
                    color: WallpaperService().themedPrimary(colorScheme)),
                title: Text(t.translate('personalInfoCameraOption'),
                    style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera, context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: WallpaperService().themedPrimary(colorScheme),
                ),
                title: Text(t.translate('personalInfoGalleryOption'),
                    style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery, context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateName(String? value, BuildContext context) {
    final t = AppLocalizations.of(context);
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

  String? _validateEmail(String? value, BuildContext context) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('personalInfoEmailRequired');
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return t.translate('personalInfoEmailInvalid');
    }
    return null;
  }

  String? _validatePhone(String? value, BuildContext context) {
    final t = AppLocalizations.of(context);
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

  void submitForm() {
    final ctx = Get.context;
    if (ctx == null) return;
    final t = AppLocalizations.of(ctx);

    hasAttemptedSubmit.value = true;

    firstNameError.value = _validateName(firstNameController.text, ctx);
    lastNameError.value = _validateName(lastNameController.text, ctx);
    phoneError.value = _validatePhone(phoneController.text, ctx);
    emailError.value = _validateEmail(emailController.text, ctx);

    if (selectedGender.value == null) {
      genderError.value = t.translate('personalInfoSelectGender');
    }
    if (selectedNationality.value == null) {
      nationalityError.value = t.translate('personalInfoSelectNationality');
    }
    if (selectedDate.value == null) {
      dateError.value = t.translate('personalInfoSelectDob');
    }
    if (profileImage.value == null) {
      imageError.value = t.translate('personalInfoSelectImage');
    }

    bool isFormValid = firstNameError.value == null &&
        lastNameError.value == null &&
        phoneError.value == null &&
        emailError.value == null &&
        genderError.value == null &&
        nationalityError.value == null &&
        dateError.value == null &&
        imageError.value == null;

    if (isFormValid) {
      _saveData();
      ApplicationData().saveToPrefs();
      Get.toNamed(Routes.educationBackground);
    }
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
}
