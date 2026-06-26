part of 'wallpaper_screen_view.dart';

class WallpaperScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WallpaperScreenViewController());
  }
}
