part of 'splash_screen_view.dart';

class SplashScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashScreenViewController());
  }
}
