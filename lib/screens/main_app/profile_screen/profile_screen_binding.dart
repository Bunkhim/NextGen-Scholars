part of 'profile_screen_view.dart';

class ProfileScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileScreenViewController());
  }
}
