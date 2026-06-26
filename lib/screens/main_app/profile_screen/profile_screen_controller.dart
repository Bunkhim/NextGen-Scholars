part of 'profile_screen_view.dart';

class ProfileScreenViewController extends GetxController {
  static final RxInt refreshNotifier = 0.obs;
  static String? activePhotoPath;
  static final RxInt photoRefreshNotifier = 0.obs;

  final userName = ''.obs;
  final userEmail = ''.obs;
  final photoUrl = Rx<String?>(null);
  final savedCount = 0.obs;
  final appliedCount = 0.obs;
  final viewedCount = 0.obs;
  final isLoggingOut = false.obs;
  final isDeletingAccount = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfile();
    ever(refreshNotifier, (_) => loadProfile());
    ever(photoRefreshNotifier, (_) => onPhotoRefresh());
  }

  void onPhotoRefresh() {
    if (ProfileScreenViewController.activePhotoPath != null) {
      final path = ProfileScreenViewController.activePhotoPath!;
      if (!path.startsWith('http') && File(path).existsSync()) {
        FileImage(File(path)).evict();
      }
      photoUrl.value = path;
    }
  }

  Future<void> loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final profile = await UserFirestoreService().getProfile();

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
      userName.value = profile['name'] ?? user?.displayName ?? '';
      userEmail.value = profile['email'] ?? user?.email ?? '';
      photoUrl.value = profile['photoUrl'] ?? user?.photoURL;
      ProfileScreenViewController.activePhotoPath = photoUrl.value;
      ProfileScreenViewController.photoRefreshNotifier.value++;
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
      await UserDataSyncService().backupAll();
      await FillInfoPersistenceService().onUserLoggedOut();
      await SessionSecurityService().clearLoginTimestamp();

      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();

      Get.offAllNamed(Routes.login);
    } catch (e) {
      isLoggingOut.value = false;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(Get.context!).translate('profileLogoutFailed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> handleDeleteAccount() async {
    isDeletingAccount.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final uid = user.uid;

      await FillInfoPersistenceService().onAccountDeleted(uid);
      await UserDataSyncService.deleteAllCloudData(uid);
      await UserDataSyncService.deleteAllLocalData(uid);
      await SessionSecurityService().clearLoginTimestamp();
      await UserFirestoreService().deleteUserDocument(uid);

      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await user.delete();

      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(Get.context!)
              .translate('profileDeleteAccountSuccess')),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Get.offAllNamed(Routes.login);
    } on FirebaseAuthException catch (e) {
      isDeletingAccount.value = false;

      String errorMsg =
          AppLocalizations.of(Get.context!).translate('profileDeleteAccountFailed');
      if (e.code == 'requires-recent-login') {
        errorMsg =
            AppLocalizations.of(Get.context!).translate('profileDeleteAccountReauth');
      }
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      isDeletingAccount.value = false;
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(Get.context!)
              .translate('profileDeleteAccountFailed')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
