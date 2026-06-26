part of 'onboarding_screen_view.dart';

class OnboardingScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OnboardingScreenViewController());
  }
}
