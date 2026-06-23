import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static final LanguageService _instance = LanguageService._internal();
  static final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale('en'));

  factory LanguageService() => _instance;
  LanguageService._internal();

  static const String _prefKey = 'app_language';

  static final List<Locale> supportedLocales = [
    const Locale('en'),
    const Locale('km'),
  ];

  static final Map<String, String> languageNames = {
    'en': 'English',
    'km': 'ខ្មែរ',
  };

  String get currentLanguageCode => localeNotifier.value.languageCode;
  String get currentLanguageName =>
      languageNames[currentLanguageCode] ?? 'English';

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey) ?? 'en';
    localeNotifier.value = Locale(code);
  }

  Future<void> setLanguage(String languageCode) async {
    localeNotifier.value = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, languageCode);
  }
}
