import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/core/api/services/users_api_service.dart';
import 'package:scholarship_app/services/scholarship_service.dart';

class DiscoverController extends GetxController {
  static const int maxSearchLength = 100;

  final ScholarshipService scholarshipService = ScholarshipService();
  final ScholarshipRepository scholarshipRepository = ScholarshipRepository();
  final SavedScholarshipRepository savedRepository = SavedScholarshipRepository();

  final RxList<FirestoreScholarship> scholarshipsList = <FirestoreScholarship>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  final TextEditingController searchController = TextEditingController();

  final RxString selectedCategory = 'All'.obs;
  final RxInt selectedCategoryIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final RxnString searchError = RxnString();
  final RxnString filterCountry = RxnString();
  final RxnString filterType = RxnString();
  final RxSet<String> favoriteIds = <String>{}.obs;

  String? _lastSyncHash;

  @override
  void onInit() {
    super.onInit();
    _loadSavedIds();
    _loadScholarships();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadScholarships() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final data = await scholarshipService.fetchActiveScholarships();
      scholarshipsList.assignAll(data);
      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  Future<void> refreshScholarships() => _loadScholarships();

  Future<void> _loadSavedIds() async {
    try {
      final savedItems = await UsersApiService().getSavedScholarships();
      final ids = savedItems
          .whereType<Map<String, dynamic>>()
          .map((item) => item['id'] as String)
          .where((id) => id.isNotEmpty)
          .toSet();
      favoriteIds
        ..clear()
        ..addAll(ids);
    } catch (_) {
      final ids = await savedRepository.getSavedFirestoreIds();
      favoriteIds
        ..clear()
        ..addAll(ids);
    }
  }

  List<String> getCategories(AppLocalizations t) => [
        t.translate('discoverCategoryAll'),
        t.translate('discoverCategoryTechnology'),
        t.translate('discoverCategoryScience'),
        t.translate('discoverCategoryBusiness'),
        t.translate('discoverCategoryArt'),
      ];

  void selectCategory(int index, AppLocalizations t) {
    selectedCategoryIndex.value = index;
    final categories = getCategories(t);
    if (index >= 0 && index < categories.length) {
      selectedCategory.value = categories[index];
    }
  }

  void updateSearchQuery(String value) {
    final sanitized = sanitizeInput(value);
    searchQuery.value = sanitized;
    searchController.text = sanitized;
    searchError.value = null;
  }

  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
    searchError.value = null;
  }

  void setFilterCountry(String? value) {
    filterCountry.value = value;
  }

  void setFilterType(String? value) {
    filterType.value = value;
  }

  bool get hasActiveFilter => filterCountry.value != null || filterType.value != null;

  void clearFilters() {
    filterCountry.value = null;
    filterType.value = null;
  }

  String sanitizeInput(String input) {
    var sanitized = input.trim();
    sanitized = sanitized.replaceAll(RegExp('[<>"\'\\;/]'), '');
    if (sanitized.length > maxSearchLength) {
      sanitized = sanitized.substring(0, maxSearchLength);
    }
    return sanitized;
  }

  Future<void> refreshSavedIds() => _loadSavedIds();

  Future<void> syncToSQLite(List<FirestoreScholarship> active) async {
    final hash = _computeSyncHash(active);
    if (_lastSyncHash == hash) return;
    _lastSyncHash = hash;

    for (final scholarship in active) {
      await scholarshipRepository.upsertByFirestoreId(
        firestoreId: scholarship.id,
        scholarship: Scholarship(
          title: scholarship.titleEn,
          titleKm: scholarship.titleKm,
          institution: scholarship.university,
          country: scholarship.country,
          type: scholarship.fundingType,
          deadline: scholarship.deadline,
          openDate: scholarship.openDate,
          numberOfPlaces: scholarship.numberOfPlaces,
          description: scholarship.descriptionEn,
          descriptionKm: scholarship.descriptionKm,
          applicationUrl: scholarship.applicationLink,
          imageUrl: scholarship.imageUrl,
          logoUrl: scholarship.logoUrl,
          level: scholarship.degree,
          fieldOfStudy: scholarship.fieldOfStudy,
          eligibility: scholarship.eligibilityEn,
          eligibilityKm: scholarship.eligibilityKm,
          benefits: scholarship.benefitsEn,
          benefitsKm: scholarship.benefitsKm,
          requiredDocuments: scholarship.requiredDocumentsEn,
          requiredDocumentsKm: scholarship.requiredDocumentsKm,
          isActive: true,
        ),
      );
    }

    await scholarshipRepository.syncActiveStatus(active.map((s) => s.id).toList());
    SavedScholarshipScreen.refreshNotifier.value++;
  }

  String _computeSyncHash(List<FirestoreScholarship> active) {
    if (active.isEmpty) return '';
    return active
        .map((s) => [
              s.id,
              s.deadline.millisecondsSinceEpoch,
              s.titleEn,
              s.titleKm,
              s.imageUrl,
              s.logoUrl,
              s.university,
              s.country,
              s.fundingType,
              s.degree,
              s.fieldOfStudy,
              s.numberOfPlaces,
              s.openDate?.millisecondsSinceEpoch ?? 0,
              s.descriptionEn,
              s.eligibilityEn,
              s.benefitsEn,
              s.requiredDocumentsEn,
              s.applicationLink,
              s.isActive,
            ].join(':'))
        .join('|');
  }

  void openNotifications() {
    Get.toNamed(AppRoutes.notificationScreen);
  }

  void openSearchFilter() {
    Get.toNamed(AppRoutes.searchFilterScreen);
  }

  bool isFavorite(String firestoreId) => favoriteIds.contains(firestoreId);
}
