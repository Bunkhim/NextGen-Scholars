import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  static final ValueNotifier<bool> themeNotifier = ValueNotifier(false);
  static const _kDarkMode = 'settings_dark_mode';

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  static bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_kDarkMode) ?? false;
    themeNotifier.value = _isDarkMode;
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    themeNotifier.value = _isDarkMode;
    _save();
  }

  void setTheme(bool isDark) {
    _isDarkMode = isDark;
    themeNotifier.value = isDark;
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, _isDarkMode);
  }

  static const PageTransitionsTheme _smoothPageTransitions =
      PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
    },
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xff2196F3),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    colorScheme: const ColorScheme.light(
      primary: Color(0xff2196F3),
      primaryContainer: Color(0xff1976D2),
      secondary: Color(0xff90CAF9),
      surface: Color(0xFFFFFFFF),
      // card / tile background
      surfaceContainerHighest: Color(0xFFF5F5F5),
      // section header bg
      onPrimary: Colors.white,
      onSurface: Color(0xFF212121),
      // main text
      onSurfaceVariant: Color(0xFF757575),
      // secondary text
      outline: Color(0xFFBDBDBD),
      // dividers / hints
      outlineVariant: Color(0xFFF0F0F0),
      // subtle dividers
      error: Color(0xFFF44336),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xff212121)),
      titleTextStyle: TextStyle(
        color: Color(0xff212121),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardColor: Colors.white,
    dividerColor: const Color(0xFFF0F0F0),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xff2196F3);
        }
        return Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xff90CAF9);
        }
        return const Color(0xffE0E0E0);
      }),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xff212121)),
      bodyMedium: TextStyle(color: Color(0xff757575)),
      titleLarge: TextStyle(color: Color(0xff212121)),
    ),
    pageTransitionsTheme: _smoothPageTransitions,
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xff2196F3),
    scaffoldBackgroundColor: const Color(0xff121212),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xff64B5F6),
      primaryContainer: Color(0xff1565C0),
      secondary: Color(0xff90CAF9),
      surface: Color(0xff1E1E1E),
      // card / tile background
      surfaceContainerHighest: Color(0xff2C2C2C),
      // section header bg
      onPrimary: Colors.black,
      onSurface: Color(0xFFE0E0E0),
      // main text
      onSurfaceVariant: Color(0xFF9E9E9E),
      // secondary text
      outline: Color(0xFF424242),
      // dividers / hints
      outlineVariant: Color(0xFF333333),
      // subtle dividers
      error: Color(0xFFEF5350),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xff1E1E1E),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardColor: const Color(0xff1E1E1E),
    dividerColor: const Color(0xFF333333),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xff64B5F6);
        }
        return const Color(0xff9E9E9E);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const Color(0xff1565C0);
        }
        return const Color(0xff424242);
      }),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
      bodyMedium: TextStyle(color: Color(0xFFBDBDBD)),
      titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
    ),
    pageTransitionsTheme: _smoothPageTransitions,
  );
}
