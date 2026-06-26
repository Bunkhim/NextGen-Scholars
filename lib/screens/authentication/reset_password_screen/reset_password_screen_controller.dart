part of 'reset_password_screen_view.dart';

class ResetPasswordScreenViewController extends GetxController {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final obscurePassword = true.obs;
  final obscureConfirm = true.obs;
  final isLoading = false.obs;
  final passwordError = Rx<String?>(null);
  final confirmError = Rx<String?>(null);
  final errorMessage = Rx<String?>(null);

  final email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      email.value = args['email'] as String? ?? '';
    } else if (args is String) {
      email.value = args;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
