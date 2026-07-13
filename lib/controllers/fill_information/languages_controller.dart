import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';

class LanguagesController extends GetxController {
  final _appData = ApplicationData();

  final Rxn<String> selectedSpokenLanguage = Rxn<String>();
  final Rxn<String> selectedEnglishLevel = Rxn<String>();
  final Rxn<String> selectedIELTSCertificate = Rxn<String>();

  final RxnString spokenLanguageError = RxnString();
  final RxnString englishLevelError = RxnString();
  final RxnString ieltsCertificateError = RxnString();

  final RxBool hasAttemptedSubmit = false.obs;

  List<String> getSpokenLanguages(AppLocalizations t) => [
        t.translate('languagesKhmer'),
        t.translate('languagesEnglish'),
        t.translate('languagesMandarinChinese'),
        t.translate('languagesCantoneseChinese'),
        t.translate('languagesThai'),
        t.translate('languagesVietnamese'),
        t.translate('languagesFrench'),
        t.translate('languagesSpanish'),
        t.translate('languagesJapanese'),
        t.translate('languagesKorean'),
        t.translate('languagesGerman'),
        t.translate('languagesArabic'),
        t.translate('languagesOther'),
      ];

  List<String> getEnglishLevels(AppLocalizations t) => [
        t.translate('languagesLevelBeginner'),
        t.translate('languagesLevelElementary'),
        t.translate('languagesLevelIntermediate'),
        t.translate('languagesLevelUpperIntermediate'),
        t.translate('languagesLevelAdvanced'),
        t.translate('languagesLevelProficient'),
        t.translate('languagesLevelNative'),
      ];

  List<String> getIeltsCertificates(AppLocalizations t) => [
        t.translate('languagesIeltsNone'),
        t.translate('languagesIeltsBand4'),
        t.translate('languagesIeltsBand4_5'),
        t.translate('languagesIeltsBand5'),
        t.translate('languagesIeltsBand5_5'),
        t.translate('languagesIeltsBand6'),
        t.translate('languagesIeltsBand6_5'),
        t.translate('languagesIeltsBand7'),
        t.translate('languagesIeltsBand7_5'),
        t.translate('languagesIeltsBand8'),
        t.translate('languagesIeltsBand8_5'),
        t.translate('languagesIeltsBand9'),
      ];

  @override
  void onInit() {
    super.onInit();
    _loadSavedData();
  }

  void _loadSavedData() {
    selectedSpokenLanguage.value = _appData.spokenLanguage;
    selectedEnglishLevel.value = _appData.englishLevel;
    selectedIELTSCertificate.value = _appData.ieltsCertificate;
  }

  void _saveData() {
    _appData.spokenLanguage = selectedSpokenLanguage.value;
    _appData.englishLevel = selectedEnglishLevel.value;
    _appData.ieltsCertificate = selectedIELTSCertificate.value;
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

  void selectSpokenLanguage(String? value) {
    selectedSpokenLanguage.value = value;
    spokenLanguageError.value = null;
  }

  void selectEnglishLevel(String? value) {
    selectedEnglishLevel.value = value;
    englishLevelError.value = null;
  }

  void selectIeltsCertificate(String? value) {
    selectedIELTSCertificate.value = value;
    ieltsCertificateError.value = null;
  }

  /// Returns true if the whole form is valid.
  bool submitForm(AppLocalizations t) {
    hasAttemptedSubmit.value = true;

    spokenLanguageError.value = selectedSpokenLanguage.value == null
        ? t.translate('languagesSelectSpoken')
        : null;
    englishLevelError.value = selectedEnglishLevel.value == null
        ? t.translate('languagesSelectLevel')
        : null;
    ieltsCertificateError.value = selectedIELTSCertificate.value == null
        ? t.translate('languagesSelectIelts')
        : null;

    final isValid = spokenLanguageError.value == null &&
        englishLevelError.value == null &&
        ieltsCertificateError.value == null;

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