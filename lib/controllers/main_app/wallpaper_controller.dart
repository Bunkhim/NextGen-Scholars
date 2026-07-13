import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class WallpaperController extends GetxController {
  final RxnString selectedThemeId = RxnString();
  final RxnString selectedImagePath = RxnString();
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    selectedThemeId.value = WallpaperService().currentThemeId;
    selectedImagePath.value = WallpaperService().currentWallpaper;
  }

  bool get isDefault => selectedThemeId.value == null && selectedImagePath.value == null;

  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      selectedThemeId.value = null;
      selectedImagePath.value = picked.path;
    }
  }

  void selectTheme(String themeId) {
    selectedThemeId.value = themeId;
    selectedImagePath.value = null;
  }

  void selectDefault() {
    selectedThemeId.value = null;
    selectedImagePath.value = null;
  }

  Future<void> apply() async {
    isSaving.value = true;
    if (selectedThemeId.value != null) {
      await WallpaperService().setTheme(selectedThemeId.value!);
    } else if (selectedImagePath.value != null) {
      await WallpaperService().setWallpaper(selectedImagePath.value!);
    } else {
      await WallpaperService().removeAll();
    }
    isSaving.value = false;
    Get.back();
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
