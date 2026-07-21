import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/user_data_sync_service.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';

class UserDataSyncController extends GetxController {
  final UserDataSyncService _service = UserDataSyncService();
  final JwtService _jwtService = JwtService();

  final RxBool isLoading = false.obs;

  Future<void> backupAll() async {
    isLoading.value = true;
    try {
      await _service.backupAll();
    } catch (e) {
      debugPrint('Controller error during backupAll: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> restoreAll() async {
    final token = await _jwtService.token;
    if (token == null) return;

    isLoading.value = true;
    try {
      await _service.restoreAll(token);
    } catch (e) {
      debugPrint('Controller error during restoreAll: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncSavedScholarships() async {
    try {
      await _service.syncSavedScholarships();
    } catch (e) {
      debugPrint('Controller error syncing saved scholarships: $e');
    }
  }

  Future<void> syncViewedScholarships() async {
    try {
      await _service.syncViewedScholarships();
    } catch (e) {
      debugPrint('Controller error syncing viewed scholarships: $e');
    }
  }

  Future<void> recordActivity() async {
    try {
      await _service.recordActivity();
    } catch (e) {
      debugPrint('Controller error recording activity: $e');
    }
  }

  Future<void> deleteUserAccountData() async {
    final token = await _jwtService.token;
    if (token == null) return;

    isLoading.value = true;
    try {
      await UserDataSyncService.deleteAllCloudData(token);
      await UserDataSyncService.deleteAllLocalData(token);
    } catch (e) {
      debugPrint('Controller error deleting account data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cleanupStaleData() async {
    final token = await _jwtService.token;
    if (token == null) return;

    try {
      await UserDataSyncService.cleanupStaleCloudData(token);
    } catch (e) {
      debugPrint('Controller error cleaning up stale data: $e');
    }
  }
}
