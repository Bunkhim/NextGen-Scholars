import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scholarship_app/core/api/services/auth_api_service.dart';
import 'package:scholarship_app/core/api/services/users_api_service.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/services/application_service.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/saved_scholarship_service.dart';
import 'package:scholarship_app/services/session_security_service.dart';
import 'package:scholarship_app/services/user_data_sync_service.dart';
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
  final _usersApi = UsersApiService();
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
      photoUrl.value = path;
    }
  }

  Future<void> loadProfile() async {
    final jwtEmail = await _jwt.currentUserEmail;
    final jwtName = await _jwt.currentUserDisplayName;
    final jwtUid = await _jwt.currentUid;

    Map<String, dynamic> profile = {};
    try {
      profile = await _usersApi.getProfile();
    } catch (_) {}

    final realSavedCount = await SavedScholarshipService().getSavedCount();
    final realViewedCount = await ViewedScholarshipService().count();

    int realAppliedCount = 0;
    try {
      final apps = await ApplicationService().fetchMyApplications();
      realAppliedCount = apps.length;
    } catch (_) {}

    if (profile.isNotEmpty) {
      userName.value = profile['displayName'] as String? ??
          profile['name'] as String? ??
          jwtName ??
          '';
      userEmail.value = profile['email'] as String? ?? jwtEmail ?? '';
      photoUrl.value = profile['photoUrl'] as String?;
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

      await _usersApi.deleteAccount();
      await FillInfoPersistenceService().onAccountDeleted(uid);
      await UserDataSyncService.deleteAllCloudData(uid);
      await UserDataSyncService.deleteAllLocalData(uid);
      await SessionSecurityService().clearLoginTimestamp();

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
