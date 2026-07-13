import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class AwardAchievementController extends GetxController {
  final _appData = ApplicationData();

  final Rxn<String> selectedAwardAchievement = Rxn<String>();
  final Rxn<String> selectedProgramName = Rxn<String>();
  final Rxn<String> selectedOrganization = Rxn<String>();
  final Rxn<String> selectedLocation = Rxn<String>();
  final Rxn<String> selectedDescription = Rxn<String>();

  final RxnString awardAchievementError = RxnString();
  final RxnString programNameError = RxnString();
  final RxnString organizationError = RxnString();
  final RxnString locationError = RxnString();
  final RxnString descriptionError = RxnString();

  final RxBool hasAttemptedSubmit = false.obs;

  List<String> getAwardAchievements(AppLocalizations t) => [
        t.translate('awardNone'),
        t.translate('awardAcademicExcellence'),
        t.translate('awardScholarshipRecipient'),
        t.translate('awardCompetitionWinner'),
        t.translate('awardDeansList'),
        t.translate('awardHonorRoll'),
        t.translate('awardBestStudent'),
        t.translate('awardResearchGrant'),
        t.translate('awardLeadership'),
        t.translate('awardCommunityService'),
        t.translate('awardSports'),
        t.translate('awardArtsCulture'),
        t.translate('awardOther'),
      ];

  List<String> getProgramNames(AppLocalizations t) => [
        t.translate('awardProgScholarship'),
        t.translate('awardProgAcademic'),
        t.translate('awardProgCompetition'),
        t.translate('awardProgResearch'),
        t.translate('awardProgLeadership'),
        t.translate('awardProgCommunity'),
        t.translate('awardProgSports'),
        t.translate('awardProgArts'),
        t.translate('awardProgInnovation'),
        t.translate('awardProgEntrepreneurship'),
        t.translate('awardProgExchange'),
        t.translate('awardProgOther'),
      ];

  List<String> getOrganizations(AppLocalizations t) => [
        t.translate('awardOrgUniversity'),
        t.translate('awardOrgGovernment'),
        t.translate('awardOrgPrivate'),
        t.translate('awardOrgNonProfit'),
        t.translate('awardOrgInternational'),
        t.translate('awardOrgResearch'),
        t.translate('awardOrgProfessional'),
        t.translate('awardOrgCommunity'),
        t.translate('awardOrgEduFoundation'),
        t.translate('awardOrgCorpFoundation'),
        t.translate('awardOrgOther'),
      ];

  List<String> getLocations(AppLocalizations t) => [
        t.translate('awardLocCambodia'),
        t.translate('awardLocVietnam'),
        t.translate('awardLocSingapore'),
        t.translate('awardLocMalaysia'),
        t.translate('awardLocIndonesia'),
        t.translate('awardLocPhilippines'),
        t.translate('awardLocUS'),
        t.translate('awardLocUK'),
        t.translate('awardLocAustralia'),
        t.translate('awardLocJapan'),
        t.translate('awardLocSouthKorea'),
        t.translate('awardLocChina'),
        t.translate('awardLocInternational'),
        t.translate('awardLocOther'),
      ];

  List<String> getDescriptions(AppLocalizations t) => [
        t.translate('awardDescTop1'),
        t.translate('awardDescTop5'),
        t.translate('awardDescTop10'),
        t.translate('awardDescFirst'),
        t.translate('awardDescSecond'),
        t.translate('awardDescThird'),
        t.translate('awardDescHonorable'),
        t.translate('awardDescFinalist'),
        t.translate('awardDescParticipant'),
        t.translate('awardDescCertAchievement'),
        t.translate('awardDescCertCompletion'),
        t.translate('awardDescOther'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
  }

  void _loadSavedData() {
    selectedAwardAchievement.value = _appData.awardAchievement;
    selectedProgramName.value = _appData.programName;
    selectedOrganization.value = _appData.organization;
    selectedLocation.value = _appData.awardLocation;
    selectedDescription.value = _appData.awardDescription;
  }

  void _saveData() {
    _appData.awardAchievement = selectedAwardAchievement.value;
    _appData.programName = selectedProgramName.value;
    _appData.organization = selectedOrganization.value;
    _appData.awardLocation = selectedLocation.value;
    _appData.awardDescription = selectedDescription.value;
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

  void selectAwardAchievement(String? value) {
    selectedAwardAchievement.value = value;
    awardAchievementError.value = null;
  }

  void selectProgramName(String? value) {
    selectedProgramName.value = value;
    programNameError.value = null;
  }

  void selectOrganization(String? value) {
    selectedOrganization.value = value;
    organizationError.value = null;
  }

  void selectLocation(String? value) {
    selectedLocation.value = value;
    locationError.value = null;
  }

  void selectDescription(String? value) {
    selectedDescription.value = value;
    descriptionError.value = null;
  }

  /// Returns true if the whole form is valid.
  bool submitForm(AppLocalizations t) {
    hasAttemptedSubmit.value = true;

    awardAchievementError.value = selectedAwardAchievement.value == null
        ? t.translate('awardSelectAchievement')
        : null;
    programNameError.value = selectedProgramName.value == null
        ? t.translate('awardSelectProgram')
        : null;
    organizationError.value = selectedOrganization.value == null
        ? t.translate('awardSelectOrganization')
        : null;
    locationError.value =
        selectedLocation.value == null ? t.translate('awardSelectLocation') : null;
    descriptionError.value = selectedDescription.value == null
        ? t.translate('awardSelectDescription')
        : null;

    final isValid = awardAchievementError.value == null &&
        programNameError.value == null &&
        organizationError.value == null &&
        locationError.value == null &&
        descriptionError.value == null;

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
