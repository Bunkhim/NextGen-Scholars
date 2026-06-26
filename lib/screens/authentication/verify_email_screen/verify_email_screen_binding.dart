part of 'verify_email_screen_view.dart';

class VerifyEmailScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VerifyEmailScreenViewController());
  }
}
