import 'package:scholarship_app/core/api/services/auth_api_service.dart';

class EmailOTPService {
  final AuthApiService _authApi = AuthApiService();

  Future<String?> sendOTP({required String email}) async {
    try {
      final res = await _authApi.sendEmailOtp(email: email.trim().toLowerCase());
      if (res.containsKey('success')) return null;
      return res['detail'] as String? ?? 'Failed to send OTP.';
    } catch (e) {
      return 'Failed to send OTP. Please check your connection.';
    }
  }

  Future<String?> verifyOTP({
    required String email,
    required String code,
  }) async {
    try {
      final res = await _authApi.verifyEmailOtp(
        email: email.trim().toLowerCase(),
        code: code.trim(),
      );
      if (res.containsKey('success')) return null;
      return res['detail'] as String? ?? 'Invalid or expired OTP code.';
    } catch (e) {
      return 'Verification failed. Please check your connection.';
    }
  }
}
