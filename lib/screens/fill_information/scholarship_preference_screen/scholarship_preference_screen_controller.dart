part of 'scholarship_preference_screen_view.dart';

class ScholarshipPreferenceScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final hasAttemptedSubmit = false.obs;

  final appData = ApplicationData();

  final selectedDestinationCountry = Rxn<String>();
  final selectedPreferredUniversity = Rxn<String>();
  final selectedPreferredDegree = Rxn<String>();
  final selectedPreferredMajor = Rxn<String>();

  final destinationCountryError = Rxn<String>();
  final preferredUniversityError = Rxn<String>();
  final preferredDegreeError = Rxn<String>();
  final preferredMajorError = Rxn<String>();

  List<String> getDestinationCountries(AppLocalizations t) => [
        t.translate('prefCountryCambodia'),
        t.translate('prefCountryUS'),
        t.translate('prefCountryUK'),
        t.translate('prefCountryCanada'),
        t.translate('prefCountryAustralia'),
        t.translate('prefCountryGermany'),
        t.translate('prefCountryFrance'),
        t.translate('prefCountryJapan'),
        t.translate('prefCountrySouthKorea'),
        t.translate('prefCountrySingapore'),
        t.translate('prefCountryMalaysia'),
        t.translate('prefCountryChina'),
        t.translate('prefCountryNetherlands'),
        t.translate('prefCountrySweden'),
        t.translate('prefCountryNewZealand'),
        t.translate('prefCountryOther'),
      ];

  List<String> getPreferredUniversities(AppLocalizations t) => [
        t.translate('prefUniRUPP'),
        t.translate('prefUniITC'),
        t.translate('prefUniRUA'),
        t.translate('prefUniRUFA'),
        t.translate('prefUniRULE'),
        t.translate('prefUniNUM'),
        t.translate('prefUniUC'),
        t.translate('prefUniPuthisastra'),
        t.translate('prefUniPannasastra'),
        t.translate('prefUniAsiaEuro'),
        t.translate('prefUniUHS'),
        t.translate('prefUniIU'),
        t.translate('prefUniWestern'),
        t.translate('prefUniAUPP'),
        t.translate('prefUniBuildBright'),
        t.translate('prefUniCMU'),
        t.translate('prefUniCamEd'),
        t.translate('prefUniPPIU'),
        t.translate('prefUniIIC'),
        t.translate('prefUniNPIC'),
        t.translate('prefUniLimkokwing'),
        t.translate('prefUniHarvard'),
        t.translate('prefUniStanford'),
        t.translate('prefUniMIT'),
        t.translate('prefUniOxford'),
        t.translate('prefUniCambridge'),
        t.translate('prefUniImperial'),
        t.translate('prefUniETH'),
        t.translate('prefUniToronto'),
        t.translate('prefUniMelbourne'),
        t.translate('prefUniNUS'),
        t.translate('prefUniUCL'),
        t.translate('prefUniCaltech'),
        t.translate('prefUniPrinceton'),
        t.translate('prefUniYale'),
        t.translate('prefUniOther'),
      ];

  List<String> getPreferredDegrees(AppLocalizations t) => [
        t.translate('prefDegreeBachelor'),
        t.translate('prefDegreeMaster'),
        t.translate('prefDegreePhd'),
        t.translate('prefDegreeAssociate'),
        t.translate('prefDegreeProfCert'),
        t.translate('prefDegreeDiploma'),
      ];

  List<String> getPreferredMajors(AppLocalizations t) => [
        t.translate('prefMajorCS'),
        t.translate('prefMajorIT'),
        t.translate('prefMajorSE'),
        t.translate('prefMajorDataScience'),
        t.translate('prefMajorAI'),
        t.translate('prefMajorBusiness'),
        t.translate('prefMajorAccounting'),
        t.translate('prefMajorMarketing'),
        t.translate('prefMajorFinance'),
        t.translate('prefMajorEconomics'),
        t.translate('prefMajorMechEng'),
        t.translate('prefMajorElecEng'),
        t.translate('prefMajorCivilEng'),
        t.translate('prefMajorArchitecture'),
        t.translate('prefMajorMedicine'),
        t.translate('prefMajorNursing'),
        t.translate('prefMajorLaw'),
        t.translate('prefMajorPsychology'),
        t.translate('prefMajorEducation'),
        t.translate('prefMajorGraphicDesign'),
        t.translate('prefMajorOther'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
  }

  void _loadSavedData() {
    selectedDestinationCountry.value = appData.destinationCountry;
    selectedPreferredUniversity.value = appData.preferredUniversity;
    selectedPreferredDegree.value = appData.preferredDegree;
    selectedPreferredMajor.value = appData.preferredMajor;
  }

  void _saveData() {
    appData.destinationCountry = selectedDestinationCountry.value;
    appData.preferredUniversity = selectedPreferredUniversity.value;
    appData.preferredDegree = selectedPreferredDegree.value;
    appData.preferredMajor = selectedPreferredMajor.value;
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

    destinationCountryError.value = selectedDestinationCountry.value == null
        ? t.translate('prefSelectCountry')
        : null;
    preferredUniversityError.value = selectedPreferredUniversity.value == null
        ? t.translate('prefSelectUniversity')
        : null;
    preferredDegreeError.value = selectedPreferredDegree.value == null
        ? t.translate('prefSelectDegree')
        : null;
    preferredMajorError.value = selectedPreferredMajor.value == null
        ? t.translate('prefSelectMajor')
        : null;

    if (destinationCountryError.value != null ||
        preferredUniversityError.value != null ||
        preferredDegreeError.value != null ||
        preferredMajorError.value != null) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();
    Get.toNamed(Routes.reference);
  }
}
