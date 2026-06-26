import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplaySettingsService {
  static final DisplaySettingsService _instance =
      DisplaySettingsService._internal();

  factory DisplaySettingsService() => _instance;
  DisplaySettingsService._internal();

  // ── Notifiers ─────────────────────────────────────────────────────────────

  /// Font family name (null = system default)
  static final Rx<String?> fontFamilyNotifier = Rx<String?>(null);

  /// Text scale factor (0.85 = Small, 1.0 = Default, 1.15 = Medium, 1.3 = Large, 1.45 = Very large)
  static final RxDouble textScaleNotifier = 1.0.obs;

  /// Display scale factor (0.9 = Small, 1.0 = Standard, 1.1 = Large)
  static final RxDouble displayScaleNotifier = 1.0.obs;

  // ── Pref Keys ─────────────────────────────────────────────────────────────

  static const String _fontFamilyKey = 'display_font_family';
  static const String _textScaleKey = 'display_text_scale';
  static const String _displayScaleKey = 'display_display_scale';

  // ── Available Fonts ───────────────────────────────────────────────────────

  static const List<Map<String, String>> availableFonts = [
    {'name': 'Default', 'family': ''},
    {'name': 'Roboto', 'family': 'Roboto'},
    {'name': 'Open Sans', 'family': 'Open Sans'},
    {'name': 'Lato', 'family': 'Lato'},
    {'name': 'Montserrat', 'family': 'Montserrat'},
    {'name': 'Poppins', 'family': 'Poppins'},
    {'name': 'Nunito', 'family': 'Nunito'},
    {'name': 'Raleway', 'family': 'Raleway'},
    {'name': 'Inter', 'family': 'Inter'},
    {'name': 'Battambang', 'family': 'Battambang'},
    {'name': 'Koulen', 'family': 'Koulen'},
    {'name': 'Moul', 'family': 'Moul'},
  ];

  // ── Text Scale Options ────────────────────────────────────────────────────

  static const List<Map<String, dynamic>> textScaleOptions = [
    {'labelKey': 'settingsFontSizeSmall', 'scale': 0.85},
    {'labelKey': 'settingsFontSizeDefault', 'scale': 1.0},
    {'labelKey': 'settingsFontSizeMedium', 'scale': 1.15},
    {'labelKey': 'settingsFontSizeLarge', 'scale': 1.3},
    {'labelKey': 'settingsFontSizeVeryLarge', 'scale': 1.45},
  ];

  // ── Display Scale Options ─────────────────────────────────────────────────

  static const List<Map<String, dynamic>> displayScaleOptions = [
    {'labelKey': 'settingsDisplaySizeSmall', 'scale': 0.9},
    {'labelKey': 'settingsDisplaySizeStandard', 'scale': 1.0},
    {'labelKey': 'settingsDisplaySizeLarge', 'scale': 1.1},
  ];

  // ── Load saved settings ───────────────────────────────────────────────────

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedFont = prefs.getString(_fontFamilyKey);
    fontFamilyNotifier.value =
        (savedFont == null || savedFont.isEmpty) ? null : savedFont;

    textScaleNotifier.value = prefs.getDouble(_textScaleKey) ?? 1.0;
    displayScaleNotifier.value = prefs.getDouble(_displayScaleKey) ?? 1.0;
  }

  // ── Setters ───────────────────────────────────────────────────────────────

  Future<void> setFontFamily(String? family) async {
    fontFamilyNotifier.value = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, family ?? '');
  }

  Future<void> setTextScale(double scale) async {
    textScaleNotifier.value = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_textScaleKey, scale);
  }

  Future<void> setDisplayScale(double scale) async {
    displayScaleNotifier.value = scale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_displayScaleKey, scale);
  }

  // ── Getters ───────────────────────────────────────────────────────────────

  String? get currentFontFamily => fontFamilyNotifier.value;
  double get currentTextScale => textScaleNotifier.value;
  double get currentDisplayScale => displayScaleNotifier.value;

  String get currentFontDisplayName {
    final family = fontFamilyNotifier.value;
    if (family == null || family.isEmpty) return 'Default';
    return family;
  }

  String currentTextScaleLabelKey() {
    final scale = textScaleNotifier.value;
    for (final option in textScaleOptions) {
      if (((option['scale'] as double) - scale).abs() < 0.01) {
        return option['labelKey'] as String;
      }
    }
    return 'settingsFontSizeDefault';
  }

  String currentDisplayScaleLabelKey() {
    final scale = displayScaleNotifier.value;
    for (final option in displayScaleOptions) {
      if (((option['scale'] as double) - scale).abs() < 0.01) {
        return option['labelKey'] as String;
      }
    }
    return 'settingsDisplaySizeStandard';
  }
}
