import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  // ── Observable State ──────────────────────────────────────────────────────
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxnString photoUrl = RxnString();
  final RxInt savedCount = 0.obs;
  final RxInt appliedCount = 0.obs;
  final RxInt viewedCount = 0.obs;
  final RxBool isLoggingOut = false.obs;
  final RxBool isDeletingAccount = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    // Listen for refresh triggers from other screens
    ProfileScreen.refreshNotifier.addListener(loadProfile);
    // Listen for instant photo update (no Firestore delay)
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
      // Evict cached file so the new image is loaded from disk
      if (!path.startsWith('http') && File(path).existsSync()) {
        FileImage(File(path)).evict();
      }
      photoUrl.value = path;
    }
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final profile = await UserFirestoreService().getProfile();

    // Get real counts from actual data sources
    final realSavedCount = await SavedScholarshipRepository().count();
    final realViewedCount = await ViewedScholarshipService().count();

    // Count applications from Firestore collection
    int realAppliedCount = 0;
    try {
      final apps = await ApplicationService().streamMyApplications().first;
      realAppliedCount = apps.length;
    } catch (_) {
      realAppliedCount = (profile?['applications'] as int?) ?? 0;
    }

    if (profile != null) {
      userName.value = profile['name'] ?? user?.displayName ?? '';
      userEmail.value = profile['email'] ?? user?.email ?? '';
      photoUrl.value = profile['photoUrl'] ?? user?.photoURL;
      ProfileScreen.activePhotoPath = photoUrl.value;
      ProfileScreen.photoRefreshNotifier.value++;
    } else if (user != null) {
      userName.value = user.displayName ?? '';
      userEmail.value = user.email ?? '';
      photoUrl.value = user.photoURL;
    }
    savedCount.value = realSavedCount;
    appliedCount.value = realAppliedCount;
    viewedCount.value = realViewedCount;
  }

  Future<void> handleLogout() async {
    isLoggingOut.value = true;
    try {
      // Backup ALL user data to Firestore before signing out
      await UserDataSyncService().backupAll();
      // Preserve Fill Info data but detach from current user
      await FillInfoPersistenceService().onUserLoggedOut();
      // Clear session timestamp so next login resets the 7-day timer
      await SessionSecurityService().clearLoginTimestamp();

      // Sign out Google if used
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      // Sign out Firebase
      await FirebaseAuth.instance.signOut();

      // Clear entire navigation stack and go to login
      Get.offAllNamed(AppRoutes.loginScreen);
    } catch (e) {
      isLoggingOut.value = false;
      Get.snackbar('Error', 'Logout failed. Please try again.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> handleDeleteAccount() async {
    isDeletingAccount.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;

      // 1. Delete Fill Info local data permanently (local + Firestore)
      await FillInfoPersistenceService().onAccountDeleted(uid);

      // 2. Delete ALL other cloud-synced data
      await UserDataSyncService.deleteAllCloudData(uid);
      await UserDataSyncService.deleteAllLocalData(uid);

      // 3. Clear session security timestamp
      await SessionSecurityService().clearLoginTimestamp();

      // 4. Delete Firestore user document
      await UserFirestoreService().deleteUserDocument(uid);

      // 5. Sign out Google if used
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // 6. Delete Firebase Auth account
      await user.delete();

      Get.snackbar('', 'Account deleted successfully.',
          backgroundColor: Colors.green, colorText: Colors.white);

      // Navigate to login and clear stack
      Get.offAllNamed(AppRoutes.loginScreen);
    } on FirebaseAuthException catch (e) {
      isDeletingAccount.value = false;
      String errorMsg = 'Failed to delete account.';
      if (e.code == 'requires-recent-login') {
        errorMsg = 'Please re-authenticate and try again.';
      }
      Get.snackbar('Error', errorMsg,
          backgroundColor: Colors.red, colorText: Colors.white);
    } catch (e) {
      isDeletingAccount.value = false;
      Get.snackbar('Error', 'Failed to delete account.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
