part of 'education_background_screen_view.dart';

class EducationBackgroundScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final institutionController = TextEditingController();
  final gpaController = TextEditingController();

  final appData = ApplicationData();

  final selectedDegree = Rxn<String>();
  final selectedMajor = Rxn<String>();
  final selectedYear = Rxn<int>();

  final institutionError = Rxn<String>();
  final gpaError = Rxn<String>();
  final degreeError = Rxn<String>();
  final majorError = Rxn<String>();
  final yearError = Rxn<String>();

  final hasAttemptedSubmit = false.obs;

  final List<int> years = List.generate(
    30,
    (index) => DateTime.now().year + 5 - index,
  );

  List<String> getDegrees(AppLocalizations t) => [
        t.translate('educationDegreeHighSchool'),
        t.translate('educationDegreeAssociate'),
        t.translate('educationDegreeBachelor'),
        t.translate('educationDegreeMaster'),
        t.translate('educationDegreePhd'),
      ];

  List<String> getMajors(AppLocalizations t) => [
        t.translate('educationMajorCS'),
        t.translate('educationMajorIT'),
        t.translate('educationMajorSE'),
        t.translate('educationMajorEngineering'),
        t.translate('educationMajorBusiness'),
        t.translate('educationMajorEconomics'),
        t.translate('educationMajorFinance'),
        t.translate('educationMajorArts'),
        t.translate('educationMajorSciences'),
        t.translate('educationMajorMedicine'),
        t.translate('educationMajorLaw'),
        t.translate('educationMajorEducation'),
        t.translate('educationMajorArchitecture'),
        t.translate('educationMajorOther'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
    institutionController.addListener(_onInstitutionChanged);
    gpaController.addListener(_onGpaChanged);
  }

  void _loadSavedData() {
    institutionController.text = appData.institution ?? '';
    gpaController.text = appData.gpa ?? '';
    selectedDegree.value = appData.degree;
    selectedMajor.value = appData.major;
    selectedYear.value = appData.graduationYear;
  }

  void _saveData() {
    appData.institution = institutionController.text;
    appData.gpa = gpaController.text;
    appData.degree = selectedDegree.value;
    appData.major = selectedMajor.value;
    appData.graduationYear = selectedYear.value;
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

  void _onInstitutionChanged() {
    if (hasAttemptedSubmit.value) {
      institutionError.value = null;
    }
  }

  void _onGpaChanged() {
    if (hasAttemptedSubmit.value) {
      gpaError.value = _validateGpa(gpaController.text);
    }
  }

  String? _validateGpa(String value) {
    final t = AppLocalizations.of(Get.context!);
    if (value.isEmpty) {
      return t.translate('educationGpaRequired');
    }
    final gpa = double.tryParse(value);
    if (gpa == null) {
      return t.translate('educationGpaInvalid');
    }
    if (gpa < 0.0 || gpa > 4.0) {
      return t.translate('educationGpaRange');
    }
    return null;
  }

  void submitForm() {
    final ctx = Get.context;
    if (ctx == null) return;
    final t = AppLocalizations.of(ctx);

    hasAttemptedSubmit.value = true;

    if (institutionController.text.isEmpty) {
      institutionError.value = t.translate('educationInstitutionRequired');
    } else if (institutionController.text.length < 3) {
      institutionError.value = t.translate('educationInstitutionTooShort');
    } else {
      institutionError.value = null;
    }

    if (gpaController.text.isEmpty) {
      gpaError.value = t.translate('educationGpaRequired');
    } else {
      gpaError.value = _validateGpa(gpaController.text);
    }

    degreeError.value =
        selectedDegree.value == null ? t.translate('educationSelectDegree') : null;
    majorError.value =
        selectedMajor.value == null ? t.translate('educationSelectMajor') : null;
    yearError.value =
        selectedYear.value == null ? t.translate('educationSelectGradYear') : null;

    bool isFormValid = institutionError.value == null &&
        gpaError.value == null &&
        degreeError.value == null &&
        majorError.value == null &&
        yearError.value == null;

    if (!isFormValid) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();
    Get.toNamed(Routes.languages);
  }

  @override
  void onClose() {
    institutionController.removeListener(_onInstitutionChanged);
    gpaController.removeListener(_onGpaChanged);
    institutionController.dispose();
    gpaController.dispose();
    super.onClose();
  }
}
