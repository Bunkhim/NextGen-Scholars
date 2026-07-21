import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scholarship_app/core/api/api_config.dart';

class UploadApiService {
  final ApiConfig _apiConfig = ApiConfig();

  Future<Map<String, dynamic>> uploadImage(File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _apiConfig.dio.post(
        '/api/v1/upload/image',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'Authorization': 'Bearer ${await ApiConfig.token}',
          },
        ),
      );

      if (response.data is Map<String, dynamic>) return response.data;
      return {'url': '', 'filename': ''};
    } on DioException catch (e) {
      debugPrint('UploadApiService uploadImage error: $e');
      return {'url': '', 'filename': '', 'error': e.message};
    }
  }
}
