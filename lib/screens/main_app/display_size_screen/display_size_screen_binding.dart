part of 'display_size_screen_view.dart';

class DisplaySizeScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DisplaySizeScreenViewController());
  }
}
