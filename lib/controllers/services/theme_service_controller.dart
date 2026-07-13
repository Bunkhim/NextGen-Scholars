import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/theme_service.dart';

/// GetX wrapper around the existing [ThemeService] singleton.
///
/// [ThemeService] already holds the actual dark/light state and the
/// light/dark [ThemeData] definitions — this controller doesn't duplicate
/// that. It just exposes the current mode as an `Rx<ThemeMode>` so widgets
/// that aren't already wired to `ThemeService.themeNotifier` (e.g. your
/// root `MaterialApp`/`GetMaterialApp`) can react via `Obx` / `Get.changeTheme`
/// instead of a `ValueListenableBuilder`.
class ThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = (ThemeService().isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light)
      .obs;

  @override
  void onInit() {
    super.onInit();
    // Stay in sync if ThemeService is changed from somewhere that only
    // knows about themeNotifier (e.g. legacy ValueListenableBuilder code).
    ThemeService.themeNotifier.addListener(_onServiceChanged);
  }

  @override
  void onClose() {
    ThemeService.themeNotifier.removeListener(_onServiceChanged);
    super.onClose();
  }

  void _onServiceChanged() {
    themeMode.value =
        ThemeService.themeNotifier.value ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  ThemeData get currentTheme =>
      isDarkMode ? ThemeService.darkTheme : ThemeService.lightTheme;

  void toggleTheme() {
    ThemeService().toggleTheme();
    themeMode.value = ThemeService().isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void setDarkMode(bool isDark) {
    ThemeService().setTheme(isDark);
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}