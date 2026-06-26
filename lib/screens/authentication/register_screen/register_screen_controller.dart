part of 'register_screen_view.dart';

class RegisterScreenViewController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final useEmail = true.obs;
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;
  final isFacebookLoading = false.obs;
  final selectedCountryCode = '+1'.obs;

  final nameError = Rx<String?>('');
  final emailError = Rx<String?>('');
  final phoneError = Rx<String?>('');
  final passwordError = Rx<String?>('');
  final confirmPasswordError = Rx<String?>('');

  final Map<String, String> countryCodes = {
    '+1': '🇺🇸 +1',
    '+44': '🇬🇧 +44',
    '+91': '🇮🇳 +91',
    '+86': '🇨🇳 +86',
    '+81': '🇯🇵 +81',
    '+33': '🇫🇷 +33',
    '+49': '🇩🇪 +49',
    '+39': '🇮🇹 +39',
    '+34': '🇪🇸 +34',
    '+61': '🇦🇺 +61',
    '+55': '🇧🇷 +55',
    '+54': '🇦🇷 +54',
    '+52': '🇲🇽 +52',
    '+27': '🇿🇦 +27',
    '+234': '🇳🇬 +234',
    '+20': '🇪🇬 +20',
    '+60': '🇲🇾 +60',
    '+65': '🇸🇬 +65',
    '+82': '🇰🇷 +82',
    '+84': '🇻🇳 +84',
    '+62': '🇮🇩 +62',
    '+63': '🇵🇭 +63',
    '+855': '🇰🇭 +855',
    '+90': '🇹🇷 +90',
    '+966': '🇸🇦 +966',
    '+971': '🇦🇪 +971',
  };

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
