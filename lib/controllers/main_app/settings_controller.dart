import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scholarship_app/services/language_service.dart';
import 'package:scholarship_app/services/theme_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  // SharedPreferences keys
  static const _kPush = 'settings_push_notifications';
  static const _kEmail = 'settings_email_notifications';
  static const _kDeadline = 'settings_deadline_reminders';
  static const _kNewScholarships = 'settings_new_scholarships';
  static const _kSound = 'settings_notification_sound';

  // Notification toggles
  final RxBool pushNotifications = true.obs;
  final RxBool emailNotifications = true.obs;
  final RxBool deadlineReminders = true.obs;
  final RxBool newScholarships = false.obs;

  // App settings
  final RxString selectedLanguage = 'English'.obs;
  final RxString notificationSound = 'Default'.obs;
  final RxBool darkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    darkMode.value = ThemeService().isDarkMode;
    // Sync language display with current locale
    final currentLocale = LanguageService.localeNotifier.value;
    selectedLanguage.value =
        currentLocale.languageCode == 'km' ? 'ខ្មែរ' : 'English';
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

  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    
    // Update local reactive variables
    switch (key) {
      case _kPush: pushNotifications.value = value; break;
      case _kEmail: emailNotifications.value = value; break;
      case _kDeadline: deadlineReminders.value = value; break;
      case _kNewScholarships: newScholarships.value = value; break;
    }
  }

  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    if (key == _kSound) {
      notificationSound.value = value;
    }
  }

  void setLanguage(String val) {
    selectedLanguage.value = val;
    final langCode = val == 'ខ្មែរ' ? 'km' : 'en';
    LanguageService().setLanguage(langCode);
  }

  void toggleTheme(bool isDark) {
    darkMode.value = isDark;
    ThemeService().setTheme(isDark);
  }

  Future<bool> openLink(String page) async {
    final urls = <String, String>{
      'Privacy Policy': 'https://nextgenscholars.app/privacy-policy',
      'Terms of Service': 'https://nextgenscholars.app/terms-of-service',
      'Help & Support': 'mailto:support@nextgenscholars.app?subject=Help%20%26%20Support',
    };

    final url = urls[page];
    if (url == null || url.isEmpty) return false;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
