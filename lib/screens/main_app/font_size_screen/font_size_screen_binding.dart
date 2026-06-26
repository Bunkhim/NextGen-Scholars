part of 'font_size_screen_view.dart';

class FontSizeScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FontSizeScreenViewController());
  }
}
