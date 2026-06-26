part of 'verify_email_screen_view.dart';

class VerifyEmailScreenViewController extends GetxController {
  late final List<TextEditingController> codeControllers =
      List.generate(6, (_) => TextEditingController());
  late final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());
  final phoneOtpService = PhoneOTPService();
  final emailOtpService = EmailOTPService();

  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final remainingSeconds = 60.obs;
  final canResend = false.obs;

  final type = ''.obs;
  final destination = ''.obs;
  final purpose = 'forgotPassword'.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      type.value = args['type'] as String? ?? '';
      destination.value = args['destination'] as String? ?? '';
      purpose.value = args['purpose'] as String? ?? 'forgotPassword';
    }
  }

  void startResendTimer() {
    remainingSeconds.value = 60;
    canResend.value = false;
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      remainingSeconds.value--;
      if (remainingSeconds.value <= 0) {
        canResend.value = true;
      } else {
        _tick();
      }
    });
  }

  @override
  void onClose() {
    for (var c in codeControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
