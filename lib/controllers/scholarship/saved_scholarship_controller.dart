import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/main_navigation_screen.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/core/api/services/users_api_service.dart';
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
  final UsersApiService _usersApi = UsersApiService();

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
    SavedScholarshipScreen.refreshNotifier.addListener(loadSavedScholarships);
  }

  @override
  void onClose() {
    SavedScholarshipScreen.refreshNotifier
        .removeListener(loadSavedScholarships);
    super.onClose();
  }

  Future<void> loadSavedScholarships() async {
    try {
      // Try backend API first
      final savedItems = await _usersApi.getSavedScholarships();
      if (savedItems.isNotEmpty && savedItems.first is Map<String, dynamic>) {
        final views = <SavedScholarshipView>[];
        for (int i = 0; i < savedItems.length; i++) {
          final item = savedItems[i] as Map<String, dynamic>;
          final scholarship = FirestoreScholarship.fromJson(item);
          scholarship.isFavorite = true;
          views.add(SavedScholarshipView(
            savedId: i,
            scholarship: scholarship,
          ));
        }
        scholarships.value = views;
        isLoading.value = false;
        return;
      }

      // Fallback to SQLite
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
    _usersApi.unsaveScholarship(scholarships[index].scholarship.id);
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
          _usersApi.saveScholarship(scholarships[index].scholarship.id);
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
