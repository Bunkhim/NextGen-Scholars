import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for sending and verifying email-based OTP codes
/// via Render.com Express server.
class EmailOTPService {
  static const String _baseUrl = 'https://scholarship-email-otp.onrender.com';
  static final http.Client _client = http.Client();

  /// Send a 6-digit OTP code to [email].
  ///
  /// Returns null on success, or an error message string on failure.
  Future<String?> sendOTP({required String email}) async {
    try {
      debugPrint('📧 Sending email OTP to: $email');
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/send-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email.trim().toLowerCase()}),
          )
          .timeout(const Duration(seconds: 120));

      debugPrint('📧 Response status: ${response.statusCode}');
      debugPrint('📧 Response body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        debugPrint('✅ Email OTP sent successfully');
        return null; // success
      }

      final errorMsg = data['error'] ?? 'Failed to send OTP.';
      debugPrint('❌ Server error: $errorMsg');

      if (response.statusCode == 429) {
        return 'Too many requests. Please try again later.';
      }
      return errorMsg;
    } catch (e) {
      debugPrint('❌ Exception sending email OTP: $e');
      return 'Failed to send OTP. Please check your connection.';
    }
  }

  /// Verify the 6-digit [code] for [email].
  ///
  /// Returns null on success, or an error message string on failure.
  Future<String?> verifyOTP({
    required String email,
    required String code,
  }) async {
    try {
      debugPrint('🔍 Verifying email OTP for: $email');
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'code': code.trim(),
            }),
          )
          .timeout(const Duration(seconds: 120));

      debugPrint('🔍 Verify response: ${response.statusCode} ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        debugPrint('✅ Email OTP verified successfully');
        return null; // success
      }

      final errorMsg = data['error'] ?? 'Verification failed.';
      debugPrint('❌ Verify error: $errorMsg');

      if (response.statusCode == 404) {
        return 'Invalid or expired OTP code.';
      }
      return errorMsg;
    } catch (e) {
      debugPrint('❌ Exception verifying email OTP: $e');
      return 'Verification failed. Please check your connection.';
    }
  }
}
