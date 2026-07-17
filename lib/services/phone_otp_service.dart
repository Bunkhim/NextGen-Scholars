import 'package:scholarship_app/core/api/services/auth_api_service.dart';

class PhoneOTPService {
  final AuthApiService _authApi = AuthApiService();

  Future<String?> sendOTP({required String phoneNumber}) async {
    try {
      final res = await _authApi.sendSmsOtp(phone: phoneNumber.trim());
      if (res.containsKey('success')) return null;
      return res['detail'] as String? ?? 'Failed to send OTP.';
    } catch (e) {
      return 'Network error. Please check your connection.';
    }
  }

  Future<String?> verifyOTP({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      final res = await _authApi.verifySmsOtp(
        phone: phoneNumber.trim(),
        code: code.trim(),
      );
      if (res.containsKey('success')) return null;
      return res['detail'] as String? ?? 'Invalid or expired OTP code.';
    } catch (e) {
      return 'Network error. Please check your connection.';
    }
  }
}
