import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class ScholarshipPreferenceController extends GetxController {
  final _appData = ApplicationData();

  final Rxn<String> selectedDestinationCountry = Rxn<String>();
  final Rxn<String> selectedPreferredUniversity = Rxn<String>();
  final Rxn<String> selectedPreferredDegree = Rxn<String>();
  final Rxn<String> selectedPreferredMajor = Rxn<String>();

  final RxnString destinationCountryError = RxnString();
  final RxnString preferredUniversityError = RxnString();
  final RxnString preferredDegreeError = RxnString();
  final RxnString preferredMajorError = RxnString();

  final RxBool hasAttemptedSubmit = false.obs;

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
    selectedDestinationCountry.value = _appData.destinationCountry;
    selectedPreferredUniversity.value = _appData.preferredUniversity;
    selectedPreferredDegree.value = _appData.preferredDegree;
    selectedPreferredMajor.value = _appData.preferredMajor;
  }

  void _saveData() {
    _appData.destinationCountry = selectedDestinationCountry.value;
    _appData.preferredUniversity = selectedPreferredUniversity.value;
    _appData.preferredDegree = selectedPreferredDegree.value;
    _appData.preferredMajor = selectedPreferredMajor.value;
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

  void selectDestinationCountry(String? value) {
    selectedDestinationCountry.value = value;
    destinationCountryError.value = null;
  }

  void selectPreferredUniversity(String? value) {
    selectedPreferredUniversity.value = value;
    preferredUniversityError.value = null;
  }

  void selectPreferredDegree(String? value) {
    selectedPreferredDegree.value = value;
    preferredDegreeError.value = null;
  }

  void selectPreferredMajor(String? value) {
    selectedPreferredMajor.value = value;
    preferredMajorError.value = null;
  }

  /// Returns true if the whole form is valid.
  bool submitForm(AppLocalizations t) {
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

    final isValid = destinationCountryError.value == null &&
        preferredUniversityError.value == null &&
        preferredDegreeError.value == null &&
        preferredMajorError.value == null;

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