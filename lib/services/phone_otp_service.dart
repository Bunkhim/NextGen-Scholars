import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for sending and verifying phone-based OTP codes
/// via Render.com Express server + Brevo SMS API.
class PhoneOTPService {
  static const String _baseUrl = 'https://scholarship-email-otp.onrender.com';
  static final http.Client _client = http.Client();

  /// Send a 6-digit OTP code via SMS to [phoneNumber].
  ///
  /// Returns null on success, or an error message string on failure.
  Future<String?> sendOTP({required String phoneNumber}) async {
    try {
      debugPrint('📱 Sending phone OTP to: $phoneNumber');
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/send-sms-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phoneNumber.trim()}),
          )
          .timeout(const Duration(seconds: 120));

      debugPrint('📱 Response status: ${response.statusCode}');
      debugPrint('📱 Response body: ${response.body}');

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return 'Server error (status ${response.statusCode})';
      }

      if (response.statusCode == 200 && data['success'] == true) {
        return null; // success
      }
      return (data['error'] as String?) ?? 'Failed to send OTP.';
    } catch (e) {
      debugPrint('📱 sendOTP error: $e');
      return 'Network error. Please check your connection.';
    }
  }

  /// Verify the 6-digit OTP [code] for [phoneNumber].
  ///
  /// Returns null on success, or an error message string on failure.
  Future<String?> verifyOTP({
    required String phoneNumber,
    required String code,
  }) async {
    try {
      debugPrint('📱 Verifying phone OTP for: $phoneNumber');
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/api/verify-sms-otp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'phone': phoneNumber.trim(),
              'code': code.trim(),
            }),
          )
          .timeout(const Duration(seconds: 30));

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return 'Server error (status ${response.statusCode})';
      }

      if (response.statusCode == 200 && data['success'] == true) {
        return null; // success
      }
      return (data['error'] as String?) ?? 'Invalid or expired OTP code.';
    } catch (e) {
      debugPrint('📱 verifyOTP error: $e');
      return 'Network error. Please check your connection.';
    }
  }
}
