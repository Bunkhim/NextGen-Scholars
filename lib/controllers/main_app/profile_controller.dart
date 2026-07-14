import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scholarship_app/core/api/services/auth_api_service.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/data/repositories/saved_scholarship_repository.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/services/application_service.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/session_security_service.dart';
import 'package:scholarship_app/services/user_data_sync_service.dart';
import 'package:scholarship_app/services/user_firestore_service.dart';
import 'package:scholarship_app/services/viewed_scholarship_service.dart';

class ProfileController extends GetxController {
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxnString photoUrl = RxnString();
  final RxInt savedCount = 0.obs;
  final RxInt appliedCount = 0.obs;
  final RxInt viewedCount = 0.obs;
  final RxBool isLoggingOut = false.obs;
  final RxBool isDeletingAccount = false.obs;

  final _authApi = AuthApiService();
  final _jwt = JwtService();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    ProfileScreen.refreshNotifier.addListener(loadProfile);
    ProfileScreen.photoRefreshNotifier.addListener(_onPhotoRefresh);
  }

  @override
  void onClose() {
    ProfileScreen.refreshNotifier.removeListener(loadProfile);
    ProfileScreen.photoRefreshNotifier.removeListener(_onPhotoRefresh);
    super.onClose();
  }

  void _onPhotoRefresh() {
    if (ProfileScreen.activePhotoPath != null) {
      final path = ProfileScreen.activePhotoPath!;
      if (!path.startsWith('http') && File(path).existsSync()) {
        FileImage(File(path)).evict();
      }
      photoUrl.value = path;
    }
  }

  Future<void> loadProfile() async {
    final profile = await UserFirestoreService().getProfile();
    final jwtEmail = await _jwt.currentUserEmail;
    final jwtName = await _jwt.currentUserDisplayName;
    final jwtUid = await _jwt.currentUid;

    final realSavedCount = await SavedScholarshipRepository().count();
    final realViewedCount = await ViewedScholarshipService().count();

    int realAppliedCount = 0;
    try {
      final apps = await ApplicationService().streamMyApplications().first;
      realAppliedCount = apps.length;
    } catch (_) {
      realAppliedCount = (profile?['applications'] as int?) ?? 0;
    }

    if (profile != null) {
      userName.value = profile['name'] ?? jwtName ?? '';
      userEmail.value = profile['email'] ?? jwtEmail ?? '';
      photoUrl.value = profile['photoUrl'];
      ProfileScreen.activePhotoPath = photoUrl.value;
      ProfileScreen.photoRefreshNotifier.value++;
    } else if (jwtUid != null) {
      userName.value = jwtName ?? '';
      userEmail.value = jwtEmail ?? '';
    }
    savedCount.value = realSavedCount;
    appliedCount.value = realAppliedCount;
    viewedCount.value = realViewedCount;
  }

  Future<void> handleLogout() async {
    isLoggingOut.value = true;
    try {
      await _authApi.logout();
    } catch (_) {}

    try {
      await UserDataSyncService().backupAll();
    } catch (_) {}

    await FillInfoPersistenceService().onUserLoggedOut();
    await SessionSecurityService().clearLoginTimestamp();

    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}

    await _jwt.clearUserSession();

    Get.offAllNamed(AppRoutes.loginScreen);
  }

  Future<void> handleDeleteAccount() async {
    isDeletingAccount.value = true;
    try {
      final uid = await _jwt.currentUid;
      if (uid == null) return;

      await FillInfoPersistenceService().onAccountDeleted(uid);
      await UserDataSyncService.deleteAllCloudData(uid);
      await UserDataSyncService.deleteAllLocalData(uid);
      await SessionSecurityService().clearLoginTimestamp();
      await UserFirestoreService().deleteUserDocument(uid);

      try {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (_) {}

      await _jwt.clearUserSession();

      Get.snackbar('', 'Account deleted successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);
      Get.offAllNamed(AppRoutes.loginScreen);
    } catch (e) {
      isDeletingAccount.value = false;
      Get.snackbar('Error', 'Failed to delete account.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
