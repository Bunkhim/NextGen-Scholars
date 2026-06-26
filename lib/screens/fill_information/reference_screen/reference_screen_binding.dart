part of 'reference_screen_view.dart';

class ReferenceScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ReferenceScreenViewController());
  }
}
