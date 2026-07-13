import 'package:get/get.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;

  void setPage(int index) {
    currentPage.value = index;
  }

  /// Marks onboarding as complete and navigates to login.
  /// Used by both the "Skip" button and the final "Get Started" button.
  Future<void> completeOnboarding() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('isLogin', true);
    Get.offAllNamed(AppRoutes.loginScreen);
  }
}