import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class WorkExperienceController extends GetxController {
  final _appData = ApplicationData();

  final Rxn<String> selectedWorkExperience = Rxn<String>();
  final Rxn<String> selectedWorkDuration = Rxn<String>();
  final Rxn<String> selectedWorkType = Rxn<String>();

  final RxnString workExperienceError = RxnString();
  final RxnString workDurationError = RxnString();
  final RxnString workTypeError = RxnString();

  final RxBool hasAttemptedSubmit = false.obs;

  List<String> getWorkExperiences(AppLocalizations t) => [
        t.translate('workExpNoExperience'),
        t.translate('workExpFreshGraduate'),
        t.translate('workExpIntern'),
        t.translate('workExp1To2Years'),
        t.translate('workExp2To5Years'),
        t.translate('workExp5To10Years'),
        t.translate('workExp10PlusYears'),
      ];

  List<String> getWorkDurations(AppLocalizations t) => [
        t.translate('workExpDurationLess6Months'),
        t.translate('workExpDuration6MonthsTo1Year'),
        t.translate('workExpDuration1To2Years'),
        t.translate('workExpDuration2To3Years'),
        t.translate('workExpDuration3To5Years'),
        t.translate('workExpDuration5PlusYears'),
      ];

  List<String> getWorkTypes(AppLocalizations t) => [
        t.translate('workExpTypeFullTime'),
        t.translate('workExpTypePartTime'),
        t.translate('workExpTypeInternship'),
        t.translate('workExpTypeVolunteer'),
        t.translate('workExpTypeFreelance'),
        t.translate('workExpTypeContract'),
        t.translate('workExpTypeSelfEmployed'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
  }

  void _loadSavedData() {
    selectedWorkExperience.value = _appData.workExperience;
    selectedWorkDuration.value = _appData.workDuration;
    selectedWorkType.value = _appData.workType;
  }

  void _saveData() {
    _appData.workExperience = selectedWorkExperience.value;
    _appData.workDuration = selectedWorkDuration.value;
    _appData.workType = selectedWorkType.value;
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

  void selectWorkExperience(String? value) {
    selectedWorkExperience.value = value;
    workExperienceError.value = null;
  }

  void selectWorkDuration(String? value) {
    selectedWorkDuration.value = value;
    workDurationError.value = null;
  }

  void selectWorkType(String? value) {
    selectedWorkType.value = value;
    workTypeError.value = null;
  }

  /// Returns true if the whole form is valid.
  bool submitForm(AppLocalizations t) {
    hasAttemptedSubmit.value = true;

    workExperienceError.value = selectedWorkExperience.value == null
        ? t.translate('workExpSelectExperience')
        : null;
    workDurationError.value = selectedWorkDuration.value == null
        ? t.translate('workExpSelectDuration')
        : null;
    workTypeError.value =
        selectedWorkType.value == null ? t.translate('workExpSelectType') : null;

    final isValid = workExperienceError.value == null &&
        workDurationError.value == null &&
        workTypeError.value == null;

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
