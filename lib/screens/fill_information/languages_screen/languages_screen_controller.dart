part of 'languages_screen_view.dart';

class LanguagesScreenViewController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final hasAttemptedSubmit = false.obs;

  final appData = ApplicationData();

  final selectedSpokenLanguage = Rxn<String>();
  final selectedEnglishLevel = Rxn<String>();
  final selectedIELTSCertificate = Rxn<String>();

  final spokenLanguageError = Rxn<String>();
  final englishLevelError = Rxn<String>();
  final ieltsCertificateError = Rxn<String>();

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
    selectedSpokenLanguage.value = appData.spokenLanguage;
    selectedEnglishLevel.value = appData.englishLevel;
    selectedIELTSCertificate.value = appData.ieltsCertificate;
  }

  void _saveData() {
    appData.spokenLanguage = selectedSpokenLanguage.value;
    appData.englishLevel = selectedEnglishLevel.value;
    appData.ieltsCertificate = selectedIELTSCertificate.value;
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
    spokenLanguageError.value = selectedSpokenLanguage.value == null
        ? t.translate('languagesSelectSpoken')
        : null;
    englishLevelError.value = selectedEnglishLevel.value == null
        ? t.translate('languagesSelectLevel')
        : null;
    ieltsCertificateError.value = selectedIELTSCertificate.value == null
        ? t.translate('languagesSelectIelts')
        : null;

    if (spokenLanguageError.value != null ||
        englishLevelError.value != null ||
        ieltsCertificateError.value != null) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();
    Get.toNamed(Routes.workExperience);
  }
}
