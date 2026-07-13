import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class EducationBackgroundController extends GetxController {
  final institutionController = TextEditingController();
  final gpaController = TextEditingController();

  final _appData = ApplicationData();

  final Rxn<String> selectedDegree = Rxn<String>();
  final Rxn<String> selectedMajor = Rxn<String>();
  final Rxn<int> selectedYear = Rxn<int>();

  final RxnString institutionError = RxnString();
  final RxnString gpaError = RxnString();
  final RxnString degreeError = RxnString();
  final RxnString majorError = RxnString();
  final RxnString yearError = RxnString();

  final RxBool hasAttemptedSubmit = false.obs;

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
    gpaController.addListener(_onGpaChangedNoContext);
  }

  @override
  void onClose() {
    institutionController.removeListener(_onInstitutionChanged);
    gpaController.removeListener(_onGpaChangedNoContext);
    institutionController.dispose();
    gpaController.dispose();
    super.onClose();
  }

  void _loadSavedData() {
    institutionController.text = _appData.institution ?? '';
    gpaController.text = _appData.gpa ?? '';
    selectedDegree.value = _appData.degree;
    selectedMajor.value = _appData.major;
    selectedYear.value = _appData.graduationYear;
  }

  void _saveData() {
    _appData.institution = institutionController.text;
    _appData.gpa = gpaController.text;
    _appData.degree = selectedDegree.value;
    _appData.major = selectedMajor.value;
    _appData.graduationYear = selectedYear.value;
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

  void _onInstitutionChanged() {
    if (hasAttemptedSubmit.value) {
      institutionError.value = null;
    }
  }

  // Text listener can't access AppLocalizations directly (needs context),
  // so it just clears; the screen calls revalidateGpa(t) to set the real message.
  void _onGpaChangedNoContext() {
    if (hasAttemptedSubmit.value) {
      gpaError.value = null;
    }
  }

  void revalidateGpa(AppLocalizations t) {
    if (!hasAttemptedSubmit.value) return;
    gpaError.value = validateGpa(gpaController.text, t);
  }

  String? validateGpa(String value, AppLocalizations t) {
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

  void selectDegree(String? value) {
    selectedDegree.value = value;
    degreeError.value = null;
  }

  void selectMajor(String? value) {
    selectedMajor.value = value;
    majorError.value = null;
  }

  void selectYear(int? value) {
    selectedYear.value = value;
    yearError.value = null;
  }

  /// Returns true if the whole form is valid.
  bool submitForm(AppLocalizations t) {
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
      gpaError.value = validateGpa(gpaController.text, t);
    }

    degreeError.value =
        selectedDegree.value == null ? t.translate('educationSelectDegree') : null;
    majorError.value =
        selectedMajor.value == null ? t.translate('educationSelectMajor') : null;
    yearError.value =
        selectedYear.value == null ? t.translate('educationSelectGradYear') : null;

    final isValid = institutionError.value == null &&
        gpaError.value == null &&
        degreeError.value == null &&
        majorError.value == null &&
        yearError.value == null;

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