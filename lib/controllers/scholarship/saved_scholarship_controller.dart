import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/main_navigation_screen.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class SavedScholarshipView {
  final int savedId;
  final FirestoreScholarship scholarship;
  bool isVisible;

  SavedScholarshipView({
    required this.savedId,
    required this.scholarship,
    this.isVisible = true,
  });
}

class SavedScholarshipController extends GetxController {
  final SavedScholarshipRepository savedRepo = SavedScholarshipRepository();
  final ScholarshipService scholarshipService = ScholarshipService();
  StreamSubscription<List<FirestoreScholarship>>? _firestoreSub;

  final RxList<SavedScholarshipView> scholarships =
      <SavedScholarshipView>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();

  List<SavedScholarshipView> get visibleScholarships =>
      scholarships.where((s) => s.isVisible).toList();

  @override
  void onInit() {
    super.onInit();
    loadSavedScholarships();
    // Reload whenever discover screen saves or unsaves a scholarship.
    // Kept as a static ValueNotifier (not moved into GetX) since other
    // screens reference it directly by class name (e.g. HomeController).
    SavedScholarshipScreen.refreshNotifier.addListener(loadSavedScholarships);
    // Subscribe to Firestore so any admin edit is reflected immediately.
    _firestoreSub = scholarshipService
        .streamActiveScholarships()
        .listen(_onFirestoreUpdate);
  }

  @override
  void onClose() {
    SavedScholarshipScreen.refreshNotifier
        .removeListener(loadSavedScholarships);
    _firestoreSub?.cancel();
    super.onClose();
  }

  /// Called whenever Firestore emits a new scholarship list.
  /// Updates only the items that are already saved without reloading from SQLite.
  void _onFirestoreUpdate(List<FirestoreScholarship> latest) {
    if (scholarships.isEmpty) return;
    final map = {for (final s in latest) s.id: s};
    bool changed = false;

    final updated = scholarships.map((view) {
      final fresh = map[view.scholarship.id];
      if (fresh == null) {
        // Admin deactivated / deleted — hide it.
        if (view.isVisible) {
          changed = true;
          view.isVisible = false;
        }
        return view;
      }
      changed = true;
      return SavedScholarshipView(
        savedId: view.savedId,
        scholarship: fresh..isFavorite = true,
      );
    }).toList();

    if (changed) scholarships.value = updated;
  }

  Future<void> loadSavedScholarships() async {
    try {
      final savedWithDetails = await savedRepo.getSavedWithDetails();
      scholarships.value = savedWithDetails.map((row) {
        final deadlineStr = row['deadline'] as String?;
        final openDateStr = row['open_date'] as String?;
        return SavedScholarshipView(
          savedId: row['saved_id'] as int,
          scholarship: FirestoreScholarship(
            id: (row['firestore_id'] as String?)?.isNotEmpty == true
                ? row['firestore_id'] as String
                : 'local_${row['saved_id']}',
            titleEn: (row['title'] as String?) ?? '',
            titleKm: (row['title_km'] as String?) ?? '',
            descriptionEn: (row['description'] as String?) ?? '',
            descriptionKm: (row['description_km'] as String?) ?? '',
            country: (row['country'] as String?) ?? '',
            university: (row['institution'] as String?) ?? '',
            degree: (row['level'] as String?) ?? '',
            fieldOfStudy: (row['field_of_study'] as String?) ?? '',
            fundingType: (row['type'] as String?) ?? '',
            numberOfPlaces: (row['number_of_places'] as int?) ?? 0,
            openDate:
                openDateStr != null ? DateTime.tryParse(openDateStr) : null,
            deadline: deadlineStr != null
                ? DateTime.tryParse(deadlineStr) ?? DateTime.now()
                : DateTime.now(),
            applicationLink: (row['application_url'] as String?) ?? '',
            imageUrl: (row['image_url'] as String?) ?? '',
            logoUrl: (row['logo_url'] as String?) ?? '',
            eligibilityEn: (row['eligibility'] as String?) ?? '',
            eligibilityKm: (row['eligibility_km'] as String?) ?? '',
            benefitsEn: (row['benefits'] as String?) ?? '',
            benefitsKm: (row['benefits_km'] as String?) ?? '',
            requiredDocumentsEn: (row['required_documents'] as String?) ?? '',
            requiredDocumentsKm:
                (row['required_documents_km'] as String?) ?? '',
            isActive: (row['is_active'] as int?) == 1,
            createdAt: row['created_at'] != null
                ? DateTime.tryParse(row['created_at'] as String) ??
                    DateTime.now()
                : DateTime.now(),
            isFavorite: true,
          ),
        );
      }).toList();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      loadError.value = e.toString();
    }
  }

  void retryLoad() {
    isLoading.value = true;
    loadError.value = null;
    loadSavedScholarships();
  }

  void removeItem(int savedId, AppLocalizations t) {
    final index = scholarships.indexWhere((s) => s.savedId == savedId);
    if (index == -1) return;
    scholarships[index].isVisible = false;
    scholarships.refresh();

    savedRepo.hide(savedId);
    ProfileScreen.refreshNotifier.value++;
    DiscoverScreen.refreshNotifier.value++;

    Get.snackbar(
      '',
      t.translate('savedRemoved'),
      mainButton: TextButton(
        onPressed: () {
          scholarships[index].isVisible = true;
          scholarships.refresh();
          savedRepo.restore(savedId);
          ProfileScreen.refreshNotifier.value++;
          DiscoverScreen.refreshNotifier.value++;
          Get.closeCurrentSnackbar();
        },
        child: Text(t.translate('savedUndo')),
      ),
      duration: const Duration(seconds: 3),
    );
  }

  void sortScholarships(String sortType) {
    final list = List<SavedScholarshipView>.from(scholarships);
    if (sortType == 'deadline') {
      list.sort(
          (a, b) => a.scholarship.deadline.compareTo(b.scholarship.deadline));
    } else if (sortType == 'name') {
      list.sort(
          (a, b) => a.scholarship.titleEn.compareTo(b.scholarship.titleEn));
    }
    scholarships.value = list;
  }

  void goToHomeTab() {
    MainNavigationScreen.tabNotifier.value = 0;
  }
}