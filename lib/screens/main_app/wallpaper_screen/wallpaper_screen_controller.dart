part of 'wallpaper_screen_view.dart';

class WallpaperScreenViewController extends GetxController {
  final selectedThemeId = Rxn<String>();
  final selectedImagePath = Rxn<String>();
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedThemeId.value = WallpaperService().currentThemeId;
    selectedImagePath.value = WallpaperService().currentWallpaper;
  }

  bool get isDefault =>
      selectedThemeId.value == null && selectedImagePath.value == null;

  void selectTheme(String themeId) {
    selectedThemeId.value = themeId;
    selectedImagePath.value = null;
  }

  bool isLightTheme(String? themeId) {
    const lightIds = {
      'lunar',
      'march_8',
      'khmer_new_year',
      'xmas',
      'cartoon',
    };
    return lightIds.contains(themeId);
  }
}
