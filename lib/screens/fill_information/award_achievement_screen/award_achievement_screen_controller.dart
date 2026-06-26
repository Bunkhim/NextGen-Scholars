part of 'award_achievement_screen_view.dart';

class AwardAchievementScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final hasAttemptedSubmit = false.obs;

  final appData = ApplicationData();

  final selectedAwardAchievement = Rxn<String>();
  final selectedProgramName = Rxn<String>();
  final selectedOrganization = Rxn<String>();
  final selectedLocation = Rxn<String>();
  final selectedDescription = Rxn<String>();

  final awardAchievementError = Rxn<String>();
  final programNameError = Rxn<String>();
  final organizationError = Rxn<String>();
  final locationError = Rxn<String>();
  final descriptionError = Rxn<String>();

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
    selectedAwardAchievement.value = appData.awardAchievement;
    selectedProgramName.value = appData.programName;
    selectedOrganization.value = appData.organization;
    selectedLocation.value = appData.awardLocation;
    selectedDescription.value = appData.awardDescription;
  }

  void _saveData() {
    appData.awardAchievement = selectedAwardAchievement.value;
    appData.programName = selectedProgramName.value;
    appData.organization = selectedOrganization.value;
    appData.awardLocation = selectedLocation.value;
    appData.awardDescription = selectedDescription.value;
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

    if (awardAchievementError.value != null ||
        programNameError.value != null ||
        organizationError.value != null ||
        locationError.value != null ||
        descriptionError.value != null) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();
    Get.toNamed(Routes.scholarshipPreference);
  }
}
