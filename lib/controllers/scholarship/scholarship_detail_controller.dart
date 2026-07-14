import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/services/application_service.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/viewed_scholarship_service.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';

/// Outcome of an apply attempt. The screen maps each case to the
/// appropriate dialog/snackbar; the controller only decides *what*
/// happened, not how it's shown.
enum ApplyOutcome {
  profileIncomplete,
  alreadyApplied,
  scholarshipUnavailable,
  success,
  failed,
}

class ApplyResult {
  final ApplyOutcome outcome;
  final List<String> missingSections;

  const ApplyResult(this.outcome, {this.missingSections = const []});
}

/// Controller for [ScholarshipDetailScreen].
///
/// The scholarship still arrives via route arguments (unchanged navigation
/// pattern), so the screen calls [init] once it has resolved the argument.
/// [init] is idempotent — safe to call on every build.
class ScholarshipDetailController extends GetxController {
  final _savedRepo = SavedScholarshipRepository();
  final _scholarshipRepo = ScholarshipRepository();
  final _scholarshipService = ScholarshipService();

  bool _initialized = false;

  final Rx<FirestoreScholarship?> scholarship = Rx<FirestoreScholarship?>(null);
  final RxBool isSaved = false.obs;
  final RxBool isSaving = false.obs;
  final RxBool isApplying = false.obs;
  final RxBool descExpanded = true.obs;

  /// Call once the screen has resolved the scholarship from route
  /// arguments. Tracks the view and loads bookmark state the first time;
  /// subsequent calls with the same scholarship are no-ops.
  void init(FirestoreScholarship s) {
    if (_initialized) return;
    _initialized = true;
    scholarship.value = s;

    if (s.id.isNotEmpty) {
      ViewedScholarshipService().markViewed(s.id);
      ProfileScreen.refreshNotifier.value++;
    }

    _loadSavedState(s.id);
  }

  Future<void> _loadSavedState(String scholarshipId) async {
    final ids = await _savedRepo.getSavedFirestoreIds();
    isSaved.value = ids.contains(scholarshipId);
  }

  void toggleDescription() => descExpanded.value = !descExpanded.value;

  /// Toggles the bookmark. Returns true if the scholarship is now saved,
  /// false if it was just removed. The screen uses this to pick the
  /// right toast message.
  Future<bool> toggleBookmark() async {
    final current = scholarship.value;
    if (current == null || isSaving.value) return isSaved.value;

    final wasSaved = isSaved.value;
    isSaved.value = !wasSaved;
    isSaving.value = true;

    try {
      if (wasSaved) {
        await _savedRepo.unsaveByFirestoreId(current.id);
      } else {
        final sqliteId = await _scholarshipRepo.upsertByFirestoreId(
          firestoreId: current.id,
          scholarship: Scholarship(
            title: current.titleEn,
            titleKm: current.titleKm,
            institution: current.university,
            country: current.country,
            type: current.fundingType,
            deadline: current.deadline,
            openDate: current.openDate,
            numberOfPlaces: current.numberOfPlaces,
            description: current.descriptionEn,
            descriptionKm: current.descriptionKm,
            applicationUrl: current.applicationLink,
            imageUrl: current.imageUrl,
            logoUrl: current.logoUrl,
            level: current.degree,
            fieldOfStudy: current.fieldOfStudy,
            eligibility: current.eligibilityEn,
            eligibilityKm: current.eligibilityKm,
            benefits: current.benefitsEn,
            benefitsKm: current.benefitsKm,
            requiredDocuments: current.requiredDocumentsEn,
            requiredDocumentsKm: current.requiredDocumentsKm,
            isActive: true,
          ),
        );
        await _savedRepo.save(SavedScholarshipModel(scholarshipId: sqliteId));
      }

      SavedScholarshipScreen.refreshNotifier.value++;
      ProfileScreen.refreshNotifier.value++;
      DiscoverScreen.refreshNotifier.value++;

      return !wasSaved;
    } finally {
      isSaving.value = false;
    }
  }

  /// Runs the full apply flow: profile-completeness check → duplicate
  /// check → scholarship-still-active check → submit. Stops at the first
  /// failing check and reports why via [ApplyResult.outcome].
  Future<ApplyResult> handleApply() async {
    final current = scholarship.value;
    if (current == null) return const ApplyResult(ApplyOutcome.failed);

    // 1. Profile completeness
    final appData = ApplicationData();
    if (!appData.isProfileComplete) {
      return ApplyResult(
        ApplyOutcome.profileIncomplete,
        missingSections: appData.incompleteSections,
      );
    }

    // 2. Duplicate check
    final alreadyApplied = await ApplicationService().hasApplied(current.id);
    if (alreadyApplied) return const ApplyResult(ApplyOutcome.alreadyApplied);

    // 3. Scholarship still active
    final fresh = await _scholarshipService.getScholarshipById(current.id);
    if (fresh == null || !fresh.isActive) {
      return const ApplyResult(ApplyOutcome.scholarshipUnavailable);
    }

    // 4. Submit
    isApplying.value = true;
    try {
      final result = await ApplicationService().apply(current);
      if (result != null) {
        ProfileScreen.refreshNotifier.value++;
        return const ApplyResult(ApplyOutcome.success);
      }
      return const ApplyResult(ApplyOutcome.failed);
    } finally {
      isApplying.value = false;
    }
  }
}
