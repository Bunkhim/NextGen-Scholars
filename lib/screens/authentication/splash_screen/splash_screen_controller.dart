part of 'splash_screen_view.dart';

class SplashScreenViewController extends GetxController {
  Future<void> navigateToNext() async {
    final user = FirebaseAuth.instance.currentUser;
    var pref = await SharedPreferences.getInstance();
    var hasSeenOnboarding = pref.getBool("isLogin") ?? false;

    if (user != null) {
      final sessionValid = await SessionSecurityService().isSessionValid();
      if (!sessionValid) {
        await SessionSecurityService().forceLogout();
        Get.offAllNamed(Routes.login);
        return;
      }
      Get.offAllNamed(Routes.home);
    } else if (hasSeenOnboarding) {
      Get.offAllNamed(Routes.login);
    } else {
      Get.offAllNamed(Routes.onboarding);
    }
  }
}
