part of 'work_experience_screen_view.dart';

class WorkExperienceScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final hasAttemptedSubmit = false.obs;

  final appData = ApplicationData();

  final selectedWorkExperience = Rxn<String>();
  final selectedWorkDuration = Rxn<String>();
  final selectedWorkType = Rxn<String>();

  final workExperienceError = Rxn<String>();
  final workDurationError = Rxn<String>();
  final workTypeError = Rxn<String>();

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
    selectedWorkExperience.value = appData.workExperience;
    selectedWorkDuration.value = appData.workDuration;
    selectedWorkType.value = appData.workType;
  }

  void _saveData() {
    appData.workExperience = selectedWorkExperience.value;
    appData.workDuration = selectedWorkDuration.value;
    appData.workType = selectedWorkType.value;
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

  void submitForm() {
    final ctx = Get.context;
    if (ctx == null) return;
    final t = AppLocalizations.of(ctx);

    hasAttemptedSubmit.value = true;
    workExperienceError.value = selectedWorkExperience.value == null
        ? t.translate('workExpSelectExperience')
        : null;
    workDurationError.value = selectedWorkDuration.value == null
        ? t.translate('workExpSelectDuration')
        : null;
    workTypeError.value = selectedWorkType.value == null
        ? t.translate('workExpSelectType')
        : null;

    if (workExperienceError.value != null ||
        workDurationError.value != null ||
        workTypeError.value != null) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();
    Get.toNamed(Routes.researchExperience);
  }
}
