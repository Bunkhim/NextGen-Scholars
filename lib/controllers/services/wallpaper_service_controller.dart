import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class WallpaperController extends GetxController {
  final WallpaperService _service = WallpaperService();
  final RxBool isLoading = true.obs;

  BoxDecoration? get currentDecoration => _service.currentDecoration;
  AppThemeData? get currentThemeData => _service.currentThemeData;
  String get displayLabelKey => _service.displayLabelKey;
  bool get isThemeDark => _service.isThemeDark;

  Color? get appBarColor => _service.appBarColor;
  Color? get bottomNavColor => _service.bottomNavColor;
  Color get onThemeColor => _service.onThemeColor;

  Color themedOnSurface(ColorScheme cs) => _service.themedOnSurface(cs);
  Color themedOnSurfaceVariant(ColorScheme cs) =>
      _service.themedOnSurfaceVariant(cs);
  Color themedPrimary(ColorScheme cs) => _service.themedPrimary(cs);

  BoxDecoration glassCard({double radius = 16}) =>
      _service.glassCard(radius: radius);
  BoxDecoration glassSection({double radius = 0}) =>
      _service.glassSection(radius: radius);
  BoxDecoration glassInput({double radius = 12}) =>
      _service.glassInput(radius: radius);

  LinearGradient heroGradient({
    required List<Color> fallbackColors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) => _service.heroGradient(
        fallbackColors: fallbackColors,
        begin: begin,
        end: end,
      );

  WallpaperController() {
    WallpaperService.themeIdNotifier.addListener(_handleServiceUpdate);
    WallpaperService.wallpaperNotifier.addListener(_handleServiceUpdate);
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    isLoading.value = true;

    try {
      await _service.loadSettings();
    } catch (e) {
      debugPrint('Error loading wallpaper settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleServiceUpdate() {
    update();
  }

  Future<void> updateTheme(String? themeId) async {
    try {
      await _service.setTheme(themeId);
    } catch (e) {
      debugPrint('Error setting theme: $e');
    }
  }

  Future<void> updateWallpaper(String? imagePath) async {
    try {
      await _service.setWallpaper(imagePath);
    } catch (e) {
      debugPrint('Error setting wallpaper: $e');
    }
  }

  Future<void> clearBackground() async {
    try {
      await _service.removeAll();
    } catch (e) {
      debugPrint('Error clearing background settings: $e');
    }
  }

  @override
  void onClose() {
    WallpaperService.themeIdNotifier.removeListener(_handleServiceUpdate);
    WallpaperService.wallpaperNotifier.removeListener(_handleServiceUpdate);
    super.onClose();
  }
}
