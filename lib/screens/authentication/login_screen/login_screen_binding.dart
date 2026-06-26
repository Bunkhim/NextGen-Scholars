part of 'login_screen_view.dart';

class LoginScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginScreenViewController());
  }
}
