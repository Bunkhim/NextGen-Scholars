import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:scholarship_app/core/api/api_config.dart';

class UploadApiService {
  final ApiConfig _apiConfig = ApiConfig();

  Future<Map<String, dynamic>> uploadImage(File file, {bool deleteAfterUpload = false}) async {
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
        ),
      );

      if (deleteAfterUpload) {
        await _cleanupTempFile(file);
      }

      if (response.data is Map<String, dynamic>) return response.data;
      return {'url': '', 'filename': ''};
    } on DioException catch (e) {
      debugPrint('UploadApiService uploadImage error: $e');
      if (deleteAfterUpload) {
        await _cleanupTempFile(file);
      }
      return {'url': '', 'filename': '', 'error': e.message};
    }
  }

  Future<void> _cleanupTempFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
