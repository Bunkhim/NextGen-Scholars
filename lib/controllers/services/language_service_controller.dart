import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/language_service.dart';

/// GetX wrapper around the existing [LanguageService] singleton.
///
/// [LanguageService] already owns persistence (SharedPreferences) and the
/// supported-locale/language-name tables — this controller doesn't
/// duplicate any of that. It just exposes the current locale as an
/// `Rx<Locale>` so widgets can react via `Obx` instead of
/// `ValueListenableBuilder`.
class LanguageController extends GetxController {
  final Rx<Locale> locale = LanguageService.localeNotifier.value.obs;

  @override
  void onInit() {
    super.onInit();
    LanguageService.localeNotifier.addListener(_onServiceChanged);
    // Load the persisted language preference on startup.
    LanguageService().loadSavedLanguage();
  }

  @override
  void onClose() {
    LanguageService.localeNotifier.removeListener(_onServiceChanged);
    super.onClose();
  }

  void _onServiceChanged() {
    locale.value = LanguageService.localeNotifier.value;
  }

  String get currentLanguageCode => locale.value.languageCode;

  String get currentLanguageName =>
      LanguageService.languageNames[currentLanguageCode] ?? 'English';

  List<Locale> get supportedLocales => LanguageService.supportedLocales;

  Map<String, String> get languageNames => LanguageService.languageNames;

  Future<void> setLanguage(String languageCode) async {
    await LanguageService().setLanguage(languageCode);
    // _onServiceChanged() also fires via the listener, but setting it here
    // directly avoids a one-frame lag waiting on the notifier callback.
    locale.value = Locale(languageCode);
  }
}