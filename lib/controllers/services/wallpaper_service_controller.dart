// ignore_for_file: non_constant_identifier_names, strict_top_level_inference

import 'package:flutter/material.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

// import 'package:your_app/services/wallpaper_service.dart';

class WallpaperController extends ChangeNotifier {
  final WallpaperService _service = WallpaperService();
  bool _isLoading = true;

  // Getter for the initialization state
  bool get isLoading => _isLoading;

  /// Exposing Service Getters directly for concise UI bindings
  BoxDecoration? get currentDecoration => _service.currentDecoration;
  AppThemeData? get currentThemeData => _service.currentThemeData;
  String get displayLabelKey => _service.displayLabelKey;
  bool get isThemeDark => _service.isThemeDark;
  
  // Theme layout surfaces
  Color? get appBarColor => _service.appBarColor;
  Color? get bottomNavColor => _service.bottomNavColor;
  Color get onThemeColor => _service.onThemeColor;

  // Theme-adaptive helper wrappers
  Color themedOnSurface(ColorScheme cs) => _service.themedOnSurface(cs);
  Color themedOnSurfaceVariant(ColorScheme cs) => _service.themedOnSurfaceVariant(cs);
  Color themedPrimary(ColorScheme cs) => _service.themedPrimary(cs);

  // Frosted Glass dynamic decoration bridges
  BoxDecoration glassCard({double radius = 16}) => _service.glassCard(radius: radius);
  BoxDecoration glassSection({double radius = 0}) => _service.glassSection(radius: radius);
  BoxDecoration glassInput({double radius = 12}) => _service.glassInput(radius: radius);
  
  LinearGradient heroGradient({
    required List<Color> fallbackColors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) => _service.heroGradient(fallbackColors: fallbackColors, begin: begin, end: end);

  NotificationController() {
    // Synchronize this controller with internal service updates
    WallpaperService.themeIdNotifier.addListener(_handleServiceUpdate);
    WallpaperService.wallpaperNotifier.addListener(_handleServiceUpdate);
    
    // Automatically trigger settings load upon creation
    _initializeSettings();
  }

  /// Initial settings retrieval from SharedPreferences
  Future<void> _initializeSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.loadSettings();
    } catch (e) {
      debugPrint('Error loading wallpaper settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Internal listener to catch any outside modifications to the ValueNotifiers
  void _handleServiceUpdate() {
    notifyListeners();
  }

  /// Changes the app background to a built-in gradient theme
  Future<void> updateTheme(String? themeId) async {
    try {
      await _service.setTheme(themeId);
    } catch (e) {
      debugPrint('Error setting theme: $e');
    }
  }

  /// Changes the app background to a custom user-selected local file image
  Future<void> updateWallpaper(String? imagePath) async {
    try {
      await _service.setWallpaper(imagePath);
    } catch (e) {
      debugPrint('Error setting wallpaper: $e');
    }
  }

  /// Resets the background back to default (none)
  Future<void> clearBackground() async {
    try {
      await _service.removeAll();
    } catch (e) {
      debugPrint('Error clearing background settings: $e');
    }
  }

  @override
  void dispose() {
    // Avoid memory leaks by cleaning up listeners tied to static elements
    WallpaperService.themeIdNotifier.removeListener(_handleServiceUpdate);
    WallpaperService.wallpaperNotifier.removeListener(_handleServiceUpdate);
    super.dispose();
  }
}