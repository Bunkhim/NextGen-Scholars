import 'base_api_service.dart';

class AuthApiService {
  final BaseApiService _base = BaseApiService();

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/register',
      data: {'email': email, 'password': password, 'name': name},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/login',
      data: {'email': email, 'password': password},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> socialAuth({
    required String provider,
    required String token,
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/social',
      data: {'provider': provider, 'token': token},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> verifyToken({required String token}) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/verify-token',
      data: {'token': token},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> refreshToken() async {
    final res = await _base.post(endpoint: '/api/v1/auth/refresh');
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> logout() async {
    final res = await _base.post(endpoint: '/api/v1/auth/logout');
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> sendEmailOtp({required String email}) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/send-email-otp',
      data: {'email': email},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/verify-email-otp',
      data: {'email': email, 'code': code},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> sendSmsOtp({required String phone}) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/send-sms-otp',
      data: {'phone': phone},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> verifySmsOtp({
    required String phone,
    required String code,
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/verify-sms-otp',
      data: {'phone': phone, 'code': code},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/reset-password',
      data: {'email': email, 'newPassword': newPassword},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }

  Future<Map<String, dynamic>> lookupUser({required String email}) async {
    final res = await _base.post(
      endpoint: '/api/v1/auth/lookup',
      data: {'email': email},
    );
    if (res is Map<String, dynamic>) return res;
    return {'result': false, 'message': 'Invalid response'};
  }
}
