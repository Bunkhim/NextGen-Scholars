part of 'reference_screen_view.dart';

class ReferenceScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  final hasAttemptedSubmit = false.obs;

  final appData = ApplicationData();

  final selectedPosition = Rxn<String>();
  final selectedWorkPlace = Rxn<String>();

  final fullNameError = Rxn<String>();
  final positionError = Rxn<String>();
  final workPlaceError = Rxn<String>();
  final phoneError = Rxn<String>();
  final emailError = Rxn<String>();

  List<String> getPositions(AppLocalizations t) => [
        t.translate('referenceProfessor'),
        t.translate('referenceAssocProfessor'),
        t.translate('referenceAsstProfessor'),
        t.translate('referenceLecturer'),
        t.translate('referenceTeacher'),
        t.translate('referenceDeptHead'),
        t.translate('referenceAcademicAdvisor'),
        t.translate('referenceResearchSupervisor'),
        t.translate('referenceManager'),
        t.translate('referenceDirector'),
        t.translate('referenceSupervisor'),
        t.translate('referenceTeamLeader'),
        t.translate('referenceHRManager'),
        t.translate('referenceOther'),
      ];

  List<String> getWorkPlaces(AppLocalizations t) => [
        t.translate('referenceWpUniversity'),
        t.translate('referenceWpCollege'),
        t.translate('referenceWpHighSchool'),
        t.translate('referenceWpResearchInst'),
        t.translate('referenceWpPrivateCompany'),
        t.translate('referenceWpGovernment'),
        t.translate('referenceWpNonProfit'),
        t.translate('referenceWpInternational'),
        t.translate('referenceWpEducational'),
        t.translate('referenceWpCorporate'),
        t.translate('referenceWpOther'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    fullNameController.addListener(_onFullNameChanged);
    phoneController.addListener(_onPhoneChanged);
    emailController.addListener(_onEmailChanged);
  }

  void _loadSavedData() {
    fullNameController.text = appData.referenceFullName ?? '';
    phoneController.text = appData.referencePhone ?? '';
    emailController.text = appData.referenceEmail ?? '';
    selectedPosition.value = appData.referencePosition;
    selectedWorkPlace.value = appData.referenceWorkPlace;
  }

  void _saveData() {
    appData.referenceFullName = fullNameController.text;
    appData.referencePhone = phoneController.text;
    appData.referenceEmail = emailController.text;
    appData.referencePosition = selectedPosition.value;
    appData.referenceWorkPlace = selectedWorkPlace.value;
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

  void _onFullNameChanged() {
    if (hasAttemptedSubmit.value) {
      final ctx = Get.context;
      if (ctx == null) return;
      fullNameError.value = _validateName(fullNameController.text, ctx);
    }
  }

  void _onPhoneChanged() {
    if (hasAttemptedSubmit.value) {
      final ctx = Get.context;
      if (ctx == null) return;
      phoneError.value = _validatePhone(phoneController.text, ctx);
    }
  }

  void _onEmailChanged() {
    if (hasAttemptedSubmit.value) {
      final ctx = Get.context;
      if (ctx == null) return;
      emailError.value = _validateEmail(emailController.text, ctx);
    }
  }

  String? _validateName(String? value, BuildContext context) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('referenceNameRequired');
    }
    if (value.length < 2) {
      return t.translate('referenceNameMinLength');
    }
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(value)) {
      return t.translate('referenceNameAllowUnicode');
    }
    return null;
  }

  String? _validatePhone(String? value, BuildContext context) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('referencePhoneRequired');
    }
    final digitsOnly = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return t.translate('referencePhoneDigitsOnly');
    }
    if (digitsOnly.length < 8) {
      return t.translate('referencePhoneMinDigits');
    }
    if (digitsOnly.length > 15) {
      return t.translate('referencePhoneMaxDigits');
    }
    return null;
  }

  String? _validateEmail(String? value, BuildContext context) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('referenceEmailRequired');
    }
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return t.translate('referenceEmailInvalid');
    }
    return null;
  }

  void submitForm() {
    final ctx = Get.context;
    if (ctx == null) return;
    final t = AppLocalizations.of(ctx);

    hasAttemptedSubmit.value = true;

    fullNameError.value = _validateName(fullNameController.text, ctx);
    phoneError.value = _validatePhone(phoneController.text, ctx);
    emailError.value = _validateEmail(emailController.text, ctx);

    positionError.value = selectedPosition.value == null
        ? t.translate('referenceSelectPosition')
        : null;
    workPlaceError.value = selectedWorkPlace.value == null
        ? t.translate('referenceSelectWorkPlace')
        : null;

    bool isFormValid = fullNameError.value == null &&
        phoneError.value == null &&
        emailError.value == null &&
        positionError.value == null &&
        workPlaceError.value == null;

    if (!isFormValid) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(t.translate('referenceSubmitSuccess')),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    Get.back(result: true);
  }

  @override
  void onClose() {
    fullNameController.removeListener(_onFullNameChanged);
    phoneController.removeListener(_onPhoneChanged);
    emailController.removeListener(_onEmailChanged);
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
