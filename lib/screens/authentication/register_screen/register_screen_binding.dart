part of 'register_screen_view.dart';

class RegisterScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RegisterScreenViewController());
  }
}
