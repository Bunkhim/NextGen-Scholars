part of 'research_experience_screen_view.dart';

class ResearchExperienceScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final hasAttemptedSubmit = false.obs;

  final appData = ApplicationData();

  final selectedResearchExperience = Rxn<String>();
  final selectedAuthors = Rxn<String>();
  final selectedResearchField = Rxn<String>();
  final selectedPublisher = Rxn<String>();
  final selectedLocation = Rxn<String>();

  final researchExperienceError = Rxn<String>();
  final authorsError = Rxn<String>();
  final researchFieldError = Rxn<String>();
  final publisherError = Rxn<String>();
  final locationError = Rxn<String>();

  List<String> getResearchExperiences(AppLocalizations t) => [
        t.translate('researchExpNone'),
        t.translate('researchExpUndergrad'),
        t.translate('researchExpGrad'),
        t.translate('researchExpThesis'),
        t.translate('researchExpConference'),
        t.translate('researchExpAssistant'),
        t.translate('researchExpIndependent'),
        t.translate('researchExpPublished'),
        t.translate('researchExpCollaborative'),
      ];

  List<String> getAuthorsList(AppLocalizations t) => [
        t.translate('researchAuthorSingle'),
        t.translate('researchAuthorFirst'),
        t.translate('researchAuthorCo'),
        t.translate('researchAuthorCorresponding'),
        t.translate('researchAuthorTeamMember'),
      ];

  List<String> getResearchFields(AppLocalizations t) => [
        t.translate('researchFieldCS'),
        t.translate('researchFieldEngineering'),
        t.translate('researchFieldNatural'),
        t.translate('researchFieldSocial'),
        t.translate('researchFieldMedicine'),
        t.translate('researchFieldBusiness'),
        t.translate('researchFieldEnvironmental'),
        t.translate('researchFieldMath'),
        t.translate('researchFieldPhysics'),
        t.translate('researchFieldChemistry'),
        t.translate('researchFieldBiology'),
        t.translate('researchFieldOther'),
      ];

  List<String> getPublishers(AppLocalizations t) => [
        t.translate('researchPubNotPublished'),
        t.translate('researchPubJournal'),
        t.translate('researchPubConference'),
        t.translate('researchPubBookChapter'),
        t.translate('researchPubThesis'),
        t.translate('researchPubWorking'),
        t.translate('researchPubOnline'),
        t.translate('researchPubUniversity'),
      ];

  List<String> getLocations(AppLocalizations t) => [
        t.translate('researchLocCambodia'),
        t.translate('researchLocVietnam'),
        t.translate('researchLocSingapore'),
        t.translate('researchLocMalaysia'),
        t.translate('researchLocUS'),
        t.translate('researchLocUK'),
        t.translate('researchLocAustralia'),
        t.translate('researchLocJapan'),
        t.translate('researchLocSouthKorea'),
        t.translate('researchLocChina'),
        t.translate('researchLocOnline'),
        t.translate('researchLocOther'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
  }

  void _loadSavedData() {
    selectedResearchExperience.value = appData.researchExperience;
    selectedAuthors.value = appData.authors;
    selectedResearchField.value = appData.researchField;
    selectedPublisher.value = appData.publisher;
    selectedLocation.value = appData.researchLocation;
  }

  void _saveData() {
    appData.researchExperience = selectedResearchExperience.value;
    appData.authors = selectedAuthors.value;
    appData.researchField = selectedResearchField.value;
    appData.publisher = selectedPublisher.value;
    appData.researchLocation = selectedLocation.value;
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

    researchExperienceError.value = selectedResearchExperience.value == null
        ? t.translate('researchSelectExperience')
        : null;
    authorsError.value = selectedAuthors.value == null
        ? t.translate('researchSelectAuthors')
        : null;
    researchFieldError.value = selectedResearchField.value == null
        ? t.translate('researchSelectField')
        : null;
    publisherError.value = selectedPublisher.value == null
        ? t.translate('researchSelectPublisher')
        : null;
    locationError.value = selectedLocation.value == null
        ? t.translate('researchSelectLocation')
        : null;

    if (researchExperienceError.value != null ||
        authorsError.value != null ||
        researchFieldError.value != null ||
        publisherError.value != null ||
        locationError.value != null) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();
    Get.toNamed(Routes.awardAchievement);
  }
}
