part of 'discover_screen_view.dart';

class DiscoverScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DiscoverScreenViewController());
  }
}
