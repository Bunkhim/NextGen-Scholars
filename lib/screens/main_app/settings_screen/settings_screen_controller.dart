part of 'settings_screen_view.dart';

class SettingsScreenViewController extends GetxController {
  static const _kPush = 'settings_push_notifications';
  static const _kEmail = 'settings_email_notifications';
  static const _kDeadline = 'settings_deadline_reminders';
  static const _kNewScholarships = 'settings_new_scholarships';
  static const _kSound = 'settings_notification_sound';

  final pushNotifications = true.obs;
  final emailNotifications = true.obs;
  final deadlineReminders = true.obs;
  final newScholarships = false.obs;
  final selectedLanguage = 'English'.obs;
  final notificationSound = 'Default'.obs;
  final darkMode = false.obs;

  final List<String> _languages = ['English', 'ខ្មែរ'];

  List<String> _getSounds(AppLocalizations t) => [
    t.translate('settingsSoundDefault'),
    t.translate('settingsSoundSilent'),
    t.translate('settingsSoundVibrateOnly'),
    t.translate('settingsSoundChime'),
  ];

  @override
  void onInit() {
    super.onInit();
    darkMode.value = ThemeService().isDarkMode;
    final currentLocale = LanguageService.localeNotifier.value;
    selectedLanguage.value = currentLocale.languageCode == 'km' ? 'ខ្មែរ' : 'English';
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    pushNotifications.value = prefs.getBool(_kPush) ?? true;
    emailNotifications.value = prefs.getBool(_kEmail) ?? true;
    deadlineReminders.value = prefs.getBool(_kDeadline) ?? true;
    newScholarships.value = prefs.getBool(_kNewScholarships) ?? false;
    notificationSound.value = prefs.getString(_kSound) ?? 'Default';
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  void setPushNotifications(bool v) {
    pushNotifications.value = v;
    _saveBool(_kPush, v);
  }

  void setEmailNotifications(bool v) {
    emailNotifications.value = v;
    _saveBool(_kEmail, v);
  }

  void setDeadlineReminders(bool v) {
    deadlineReminders.value = v;
    _saveBool(_kDeadline, v);
  }

  void setNewScholarships(bool v) {
    newScholarships.value = v;
    _saveBool(_kNewScholarships, v);
  }

  void setDarkMode(bool v) {
    darkMode.value = v;
    ThemeService().setTheme(v);
  }

  void showLanguagePicker(BuildContext context) {
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: AppLocalizations.of(context).translate('settingsLanguage'),
        items: _languages,
        selected: selectedLanguage.value,
        onSelect: (val) {
          selectedLanguage.value = val;
          final langCode = val == 'ខ្មែរ' ? 'km' : 'en';
          LanguageService().setLanguage(langCode);
        },
      ),
    );
  }

  void showSoundPicker(BuildContext context) {
    if (!context.mounted) return;
    final t = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        title: t.translate('settingsNotificationSound'),
        items: _getSounds(t),
        selected: notificationSound.value,
        onSelect: (val) {
          notificationSound.value = val;
          _saveString(_kSound, val);
        },
      ),
    );
  }

  Future<void> openLink(String page) async {
    if (page == 'Rate App') {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(AppLocalizations.of(Get.context!).translate('settingsRateApp')),
          content: Text(AppLocalizations.of(Get.context!).translate('settingsRateAppThanks')),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(AppLocalizations.of(Get.context!).translate('ok')),
            ),
          ],
        ),
      );
      return;
    }

    final urls = <String, String>{
      'Privacy Policy': 'https://nextgenscholars.app/privacy-policy',
      'Terms of Service': 'https://nextgenscholars.app/terms-of-service',
      'Help & Support': 'mailto:support@nextgenscholars.app?subject=Help%20%26%20Support',
    };

    final url = urls[page];
    if (url == null || url.isEmpty) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      final t = AppLocalizations.of(Get.context!);
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(t.translate('settingsOpeningPage').replaceAll('\$page', page)),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: const Color(0xff2196F3),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
