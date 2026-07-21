import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/saved_scholarship_service.dart';

class DiscoverController extends GetxController {
  static const int maxSearchLength = 100;

  final ScholarshipService scholarshipService = ScholarshipService();
  final SavedScholarshipService savedScholarshipService = SavedScholarshipService();

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
  final RxSet<String> savingIds = <String>{}.obs;

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
      final ids = await savedScholarshipService.getSavedIds();
      favoriteIds
        ..clear()
        ..addAll(ids);
    } catch (_) {
      favoriteIds.clear();
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

  void openNotifications() {
    Get.toNamed(AppRoutes.notificationScreen);
  }

  void openSearchFilter() {
    Get.toNamed(AppRoutes.searchFilterScreen);
  }

  bool isFavorite(String firestoreId) => favoriteIds.contains(firestoreId);
}
