part of 'forget_password_screen_view.dart';

class ForgetPasswordScreenViewController extends GetxController {
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final phoneOtpService = PhoneOTPService();
  final emailOtpService = EmailOTPService();

  final isLoading = false.obs;
  final error = Rx<String?>(null);
  final selectedCountryCode = '+855'.obs;
  final selectedTab = 0.obs;

  final Map<String, Map<String, String>> countryCodes = {
    '+855': {'flag': '🇰🇭', 'nameKey': 'countryNameCambodia', 'code': '+855'},
    '+1': {'flag': '🇺🇸', 'nameKey': 'countryNameUSA', 'code': '+1'},
    '+44': {'flag': '🇬🇧', 'nameKey': 'countryNameUK', 'code': '+44'},
    '+91': {'flag': '🇮🇳', 'nameKey': 'countryNameIndia', 'code': '+91'},
    '+86': {'flag': '🇨🇳', 'nameKey': 'countryNameChina', 'code': '+86'},
    '+81': {'flag': '🇯🇵', 'nameKey': 'countryNameJapan', 'code': '+81'},
    '+82': {'flag': '🇰🇷', 'nameKey': 'countryNameSouthKorea', 'code': '+82'},
    '+84': {'flag': '🇻🇳', 'nameKey': 'countryNameVietnam', 'code': '+84'},
    '+65': {'flag': '🇸🇬', 'nameKey': 'countryNameSingapore', 'code': '+65'},
    '+60': {'flag': '🇲🇾', 'nameKey': 'countryNameMalaysia', 'code': '+60'},
    '+62': {'flag': '🇮🇩', 'nameKey': 'countryNameIndonesia', 'code': '+62'},
    '+63': {'flag': '🇵🇭', 'nameKey': 'countryNamePhilippines', 'code': '+63'},
    '+61': {'flag': '🇦🇺', 'nameKey': 'countryNameAustralia', 'code': '+61'},
    '+33': {'flag': '🇫🇷', 'nameKey': 'countryNameFrance', 'code': '+33'},
    '+49': {'flag': '🇩🇪', 'nameKey': 'countryNameGermany', 'code': '+49'},
  };

  @override
  void onClose() {
    phoneController.dispose();
    emailController.dispose();
    phoneFocusNode.dispose();
    emailFocusNode.dispose();
    super.onClose();
  }
}
