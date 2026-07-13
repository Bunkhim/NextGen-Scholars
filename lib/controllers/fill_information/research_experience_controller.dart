import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class ResearchExperienceController extends GetxController {
  final _appData = ApplicationData();

  final Rxn<String> selectedResearchExperience = Rxn<String>();
  final Rxn<String> selectedAuthors = Rxn<String>();
  final Rxn<String> selectedResearchField = Rxn<String>();
  final Rxn<String> selectedPublisher = Rxn<String>();
  final Rxn<String> selectedLocation = Rxn<String>();

  final RxnString researchExperienceError = RxnString();
  final RxnString authorsError = RxnString();
  final RxnString researchFieldError = RxnString();
  final RxnString publisherError = RxnString();
  final RxnString locationError = RxnString();

  final RxBool hasAttemptedSubmit = false.obs;

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
    selectedResearchExperience.value = _appData.researchExperience;
    selectedAuthors.value = _appData.authors;
    selectedResearchField.value = _appData.researchField;
    selectedPublisher.value = _appData.publisher;
    selectedLocation.value = _appData.researchLocation;
  }

  void _saveData() {
    _appData.researchExperience = selectedResearchExperience.value;
    _appData.authors = selectedAuthors.value;
    _appData.researchField = selectedResearchField.value;
    _appData.publisher = selectedPublisher.value;
    _appData.researchLocation = selectedLocation.value;
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

  void selectResearchExperience(String? value) {
    selectedResearchExperience.value = value;
    researchExperienceError.value = null;
  }

  void selectAuthors(String? value) {
    selectedAuthors.value = value;
    authorsError.value = null;
  }

  void selectResearchField(String? value) {
    selectedResearchField.value = value;
    researchFieldError.value = null;
  }

  void selectPublisher(String? value) {
    selectedPublisher.value = value;
    publisherError.value = null;
  }

  void selectLocation(String? value) {
    selectedLocation.value = value;
    locationError.value = null;
  }

  /// Returns true if the whole form is valid.
  bool submitForm(AppLocalizations t) {
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

    final isValid = researchExperienceError.value == null &&
        authorsError.value == null &&
        researchFieldError.value == null &&
        publisherError.value == null &&
        locationError.value == null;

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