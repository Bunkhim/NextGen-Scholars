// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Theme definition ─────────────────────────────────────────────────────────

class AppThemeData {
  final String id;
  final String nameKey;
  final List<Color> gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final List<double>? gradientStops;

  /// Theme-specific accent colour used for glass card borders.
  final Color? accentColor;

  const AppThemeData({
    required this.id,
    required this.nameKey,
    required this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.gradientStops,
    this.accentColor,
  });
}

// ── Built-in themes ──────────────────────────────────────────────────────────

const List<AppThemeData> builtInThemes = [
  AppThemeData(
    id: 'smart_glass',
    nameKey: 'themeSmartGlass',
    gradientColors: [Color(0xFF1A4A47), Color(0xFF0D3330), Color(0xFF071E1C)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFF4DB6AC),
  ),
  AppThemeData(
    id: 'dynamic',
    nameKey: 'themeDynamic',
    gradientColors: [Color(0xFF020B18), Color(0xFF051428), Color(0xFF071B38)],
    gradientBegin: Alignment.topLeft,
    gradientEnd: Alignment.bottomRight,
    accentColor: Color(0xFF00B0FF),
  ),
  AppThemeData(
    id: 'valentine',
    nameKey: 'themeValentine',
    gradientColors: [Color(0xFF3D0018), Color(0xFF6B0F35), Color(0xFF3D0018)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFFFF4081),
  ),
  AppThemeData(
    id: 'lunar',
    nameKey: 'themeLunar',
    gradientColors: [Color(0xFFFFF9F0), Color(0xFFFFEDD5), Color(0xFFFFDEB8)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFFFFAA00),
  ),
  AppThemeData(
    id: 'modern',
    nameKey: 'themeModern',
    gradientColors: [Color(0xFF0D1117), Color(0xFF161B22), Color(0xFF0D1117)],
    gradientBegin: Alignment.topLeft,
    gradientEnd: Alignment.bottomRight,
    accentColor: Color(0xFF58A6FF),
  ),
  AppThemeData(
    id: 'visak_bochea',
    nameKey: 'themeVisakBochea',
    gradientColors: [Color(0xFF0D0A00), Color(0xFF1A1400), Color(0xFF0D0A00)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFFFFD700),
  ),
  AppThemeData(
    id: 'islamic',
    nameKey: 'themeIslamic',
    gradientColors: [Color(0xFF052533), Color(0xFF073D52), Color(0xFF052533)],
    gradientBegin: Alignment.topLeft,
    gradientEnd: Alignment.bottomRight,
    accentColor: Color(0xFF29B6F6),
  ),
  AppThemeData(
    id: 'march_8',
    nameKey: 'themeMarch8',
    gradientColors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9), Color(0xFFF48FB1)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFFE91E8C),
  ),
  AppThemeData(
    id: 'khmer_new_year',
    nameKey: 'themeKhmerNewYear',
    gradientColors: [Color(0xFFF5E6B8), Color(0xFF9DBF6E), Color(0xFF7AA74E)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    gradientStops: [0.0, 0.6, 1.0],
    accentColor: Color(0xFF43A047),
  ),
  AppThemeData(
    id: 'linear',
    nameKey: 'themeLinear',
    gradientColors: [Color(0xFF030C1A), Color(0xFF071428), Color(0xFF030C1A)],
    gradientBegin: Alignment.topRight,
    gradientEnd: Alignment.bottomLeft,
    accentColor: Color(0xFF40C4FF),
  ),
  AppThemeData(
    id: 'temple',
    nameKey: 'themeTemple',
    gradientColors: [Color(0xFF2A1A05), Color(0xFF3D2810), Color(0xFF2A1A05)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFFC8A96E),
  ),
  AppThemeData(
    id: 'xmas',
    nameKey: 'themeXmas',
    gradientColors: [Color(0xFFE8F4FD), Color(0xFFBBDEF9), Color(0xFF90CAF9)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFF1976D2),
  ),
  AppThemeData(
    id: 'water_festival',
    nameKey: 'themeWaterFestival',
    gradientColors: [Color(0xFF0277BD), Color(0xFF0288D1), Color(0xFF039BE5)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFF80D8FF),
  ),
  AppThemeData(
    id: 'pchum_ben',
    nameKey: 'themePchumBen',
    gradientColors: [Color(0xFF1A0D00), Color(0xFF2E1A00), Color(0xFF1A0D00)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFFFF8F00),
  ),
  AppThemeData(
    id: 'cartoon',
    nameKey: 'themeCartoon',
    gradientColors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9), Color(0xFFFCE4EC)],
    gradientBegin: Alignment.topCenter,
    gradientEnd: Alignment.bottomCenter,
    accentColor: Color(0xFFFF4081),
  ),
];

// ── Service ──────────────────────────────────────────────────────────────────

class WallpaperService {
  static final WallpaperService _instance = WallpaperService._internal();
  factory WallpaperService() => _instance;
  WallpaperService._internal();

  // ── Notifiers ─────────────────────────────────────────────────────────────

  static final ValueNotifier<String?> themeIdNotifier = ValueNotifier(null);
  static final ValueNotifier<String?> wallpaperNotifier = ValueNotifier(null);

  // ── Pref Keys ─────────────────────────────────────────────────────────────

  static const String _themeIdKey = 'app_theme_id';
  static const String _wallpaperKey = 'app_wallpaper_path';

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    themeIdNotifier.value = prefs.getString(_themeIdKey);
    final savedPath = prefs.getString(_wallpaperKey);
    if (savedPath != null &&
        savedPath.isNotEmpty &&
        File(savedPath).existsSync()) {
      wallpaperNotifier.value = savedPath;
    } else {
      wallpaperNotifier.value = null;
    }
  }

  // ── Apply built-in theme ───────────────────────────────────────────────────

  Future<void> setTheme(String? themeId) async {
    themeIdNotifier.value = themeId;
    wallpaperNotifier.value = null;
    final prefs = await SharedPreferences.getInstance();
    if (themeId == null) {
      await prefs.remove(_themeIdKey);
    } else {
      await prefs.setString(_themeIdKey, themeId);
    }
    await prefs.remove(_wallpaperKey);
  }

  // ── Apply custom wallpaper ─────────────────────────────────────────────────

  Future<void> setWallpaper(String? path) async {
    wallpaperNotifier.value = path;
    themeIdNotifier.value = null;
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_wallpaperKey);
    } else {
      await prefs.setString(_wallpaperKey, path);
    }
    await prefs.remove(_themeIdKey);
  }

  // ── Remove ─────────────────────────────────────────────────────────────────

  Future<void> removeAll() async {
    themeIdNotifier.value = null;
    wallpaperNotifier.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeIdKey);
    await prefs.remove(_wallpaperKey);
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  String? get currentThemeId => themeIdNotifier.value;
  String? get currentWallpaper => wallpaperNotifier.value;
  bool get hasTheme => themeIdNotifier.value != null;
  bool get hasWallpaper =>
      wallpaperNotifier.value != null && wallpaperNotifier.value!.isNotEmpty;
  bool get hasAny => hasTheme || hasWallpaper;

  AppThemeData? get currentThemeData {
    final id = themeIdNotifier.value;
    if (id == null) return null;
    return builtInThemes.cast<AppThemeData?>().firstWhere(
          (t) => t!.id == id,
          orElse: () => null,
        );
  }

  BoxDecoration? get currentDecoration {
    final theme = currentThemeData;
    if (theme != null) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: theme.gradientColors,
          begin: theme.gradientBegin,
          end: theme.gradientEnd,
          stops: theme.gradientStops,
        ),
      );
    }
    final path = wallpaperNotifier.value;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(path)),
          fit: BoxFit.cover,
        ),
      );
    }
    return null;
  }

  String get displayLabelKey {
    if (hasTheme) return currentThemeData?.nameKey ?? 'settingsWallpaperNone';
    if (hasWallpaper) return 'settingsWallpaperCustom';
    return 'settingsWallpaperNone';
  }

  // ── Theme-derived colors ───────────────────────────────────────────────────

  /// First gradient colour (top of gradient).
  Color? get primaryColor => currentThemeData?.gradientColors.first;

  /// Last gradient colour (bottom of gradient).
  Color? get secondaryColor => currentThemeData?.gradientColors.last;

  /// `true` when the active theme gradient is visually dark.
  bool get isThemeDark {
    final c = primaryColor;
    if (c == null) return false;
    return c.computeLuminance() < 0.4;
  }

  /// Foreground colour that contrasts with the theme gradient.
  Color get onThemeColor =>
      isThemeDark ? const Color(0xFFFFFFFF) : const Color(0xDD000000);

  /// AppBar background – the theme primary colour.
  Color? get appBarColor => primaryColor;

  /// BottomNav surface – slightly transparent version of the secondary colour.
  Color? get bottomNavColor {
    final c = secondaryColor;
    if (c == null) return null;
    return Color.fromRGBO(c.red, c.green, c.blue, 0.92);
  }

  // ── Glassmorphism helpers ────────────────────────────────────────────────

  /// Semi-transparent card surface tinted with the active theme accent.
  Color get cardColor {
    final accent = currentThemeData?.accentColor;
    if (accent != null) {
      return isThemeDark
          ? Color.lerp(accent, Colors.white, 0.82)!.withOpacity(0.88)
          : Color.lerp(accent, Colors.white, 0.88)!.withOpacity(0.92);
    }
    return isThemeDark ? const Color(0xCCFFFFFF) : const Color(0xD9FFFFFF);
  }

  /// Lighter tint for section headers / secondary surfaces.
  Color get surfaceTint {
    final accent = currentThemeData?.accentColor;
    if (accent != null) {
      return isThemeDark
          ? Color.lerp(accent, Colors.white, 0.75)!.withOpacity(0.65)
          : Color.lerp(accent, Colors.white, 0.85)!.withOpacity(0.75);
    }
    return isThemeDark ? const Color(0x99FFFFFF) : const Color(0xB3FFFFFF);
  }

  /// Subtle border for frosted-glass effect — uses the theme accent colour when
  /// available, otherwise defaults to a semi-transparent white.
  Color get glassBorder {
    final accent = currentThemeData?.accentColor;
    if (accent != null) {
      return accent.withOpacity(isThemeDark ? 0.55 : 0.40);
    }
    return isThemeDark ? const Color(0x55FFFFFF) : const Color(0x44FFFFFF);
  }

  /// Full glass-card decoration: white fill + border + shadow.
  BoxDecoration glassCard({double radius = 16}) => BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: glassBorder, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      );

  /// Lighter glass decoration for section backgrounds / search bars.
  BoxDecoration glassSection({double radius = 0}) => BoxDecoration(
        color: surfaceTint,
        borderRadius: radius > 0 ? BorderRadius.circular(radius) : null,
        border: Border.all(color: glassBorder, width: 0.5),
      );

  // ── Theme-adaptive color helpers ─────────────────────────────────────────

  /// Text color for content rendered directly on the gradient surface.
  /// Use for section headers, labels, etc. NOT inside glass cards.
  Color themedOnSurface(ColorScheme cs) =>
      hasTheme ? onThemeColor : cs.onSurface;

  /// Secondary text color for content on the gradient surface.
  Color themedOnSurfaceVariant(ColorScheme cs) =>
      hasTheme ? onThemeColor.withOpacity(0.7) : cs.onSurfaceVariant;

  /// Theme accent colour, falls back to system primary.
  Color themedPrimary(ColorScheme cs) =>
      currentThemeData?.accentColor ?? cs.primary;

  /// Hero-section gradient that harmonises with the active theme.
  /// Falls back to [fallbackColors] when no theme is active.
  LinearGradient heroGradient({
    required List<Color> fallbackColors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    final data = currentThemeData;
    if (data != null) {
      final accent = data.accentColor ?? data.gradientColors.first;
      return LinearGradient(
        begin: begin,
        end: end,
        colors: [
          Color.lerp(accent, Colors.black, 0.35)!,
          Color.lerp(data.gradientColors.first, Colors.black, 0.15)!,
          Color.lerp(data.gradientColors.last, Colors.black, 0.25)!,
        ],
      );
    }
    return LinearGradient(begin: begin, end: end, colors: fallbackColors);
  }

  /// Glass-style decoration for input fields on themed backgrounds.
  BoxDecoration glassInput({double radius = 12}) {
    final accent = currentThemeData?.accentColor;
    final Color fill;
    if (accent != null) {
      fill = isThemeDark
          ? Color.lerp(accent, Colors.white, 0.78)!.withOpacity(0.18)
          : Color.lerp(accent, Colors.white, 0.88)!.withOpacity(0.55);
    } else {
      fill = isThemeDark
          ? Colors.white.withOpacity(0.12)
          : Colors.white.withOpacity(0.50);
    }
    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: glassBorder, width: 0.6),
    );
  }
}
