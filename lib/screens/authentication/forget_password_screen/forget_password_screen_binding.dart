part of 'forget_password_screen_view.dart';

class ForgetPasswordScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgetPasswordScreenViewController());
  }
}
