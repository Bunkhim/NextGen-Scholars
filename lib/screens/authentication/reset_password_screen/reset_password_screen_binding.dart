part of 'reset_password_screen_view.dart';

class ResetPasswordScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ResetPasswordScreenViewController());
  }
}
