import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/core/api/services/users_api_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class SearchFilterController extends GetxController {
  static const int maxSearchLength = 100;

  final UsersApiService _usersApi = UsersApiService();

  final searchController = TextEditingController();
  final focusNode = FocusNode();
  final RxnString searchError = RxnString();

  final RxList<String> recentSearches = <String>[].obs;
  final RxList<String> popularSearches = <String>[].obs;
  final RxBool isLoadingHistory = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSearchHistory();
  }

  @override
  void onClose() {
    searchController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  Future<void> _loadSearchHistory() async {
    isLoadingHistory.value = true;
    try {
      final recentRes = await _usersApi.getRecentSearches(limit: 5);
      recentSearches.assignAll(
        recentRes.map((item) {
          if (item is Map<String, dynamic>) return item['query'] ?? '';
          return item.toString();
        }).where((s) => s.isNotEmpty).cast<String>(),
      );

      final popularRes = await _usersApi.getPopularSearches(limit: 5);
      popularSearches.assignAll(
        popularRes.map((item) {
          if (item is Map<String, dynamic>) return item['query'] ?? '';
          return item.toString();
        }).where((s) => s.isNotEmpty).cast<String>(),
      );
    } catch (_) {
      // Silently fail — history is non-critical
    } finally {
      isLoadingHistory.value = false;
    }
  }

  List<String> getRecentSearches(AppLocalizations t) {
    if (recentSearches.isNotEmpty) return recentSearches.toList();
    return [
      t.translate('searchRecentCS'),
      t.translate('searchRecentEngineering'),
      t.translate('searchRecentBusiness'),
    ];
  }

  List<String> getPopularSearches(AppLocalizations t) {
    if (popularSearches.isNotEmpty) return popularSearches.toList();
    return [
      t.translate('searchPopularSTEM'),
      t.translate('searchPopularMedical'),
      t.translate('searchPopularFullScholarship'),
      t.translate('searchPopularUSA'),
    ];
  }

  String sanitizeInput(String input) {
    var sanitized = input.trim();
    sanitized = sanitized.replaceAll(RegExp('[<>"\'\\\\;/]'), '');
    if (sanitized.length > maxSearchLength) {
      sanitized = sanitized.substring(0, maxSearchLength);
    }
    return sanitized;
  }

  void onSearchChanged(String value) {
    final sanitized = sanitizeInput(value);
    if (sanitized != value) {
      searchController.text = sanitized;
      searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: sanitized.length),
      );
    }
    searchError.value = null;
  }

  void onRecentTap(String query) {
    searchController.text = query;
    _recordSearch(query);
    Get.back(result: query);
  }

  void onPopularTap(String query) {
    searchController.text = query;
    _recordSearch(query);
    Get.back(result: query);
  }

  void onSearchSubmitted(String val, AppLocalizations t) {
    final sanitized = sanitizeInput(val);
    if (sanitized.isEmpty) {
      searchError.value = t.translate('validationSearchEmpty');
      return;
    }
    _recordSearch(sanitized);
    Get.back(result: sanitized);
  }

  Future<void> _recordSearch(String query) async {
    try {
      await _usersApi.addSearchHistory(query: query);
    } catch (_) {
      // Silently fail — recording is non-critical
    }
  }

  /// Propagates a filter result (from the bottom sheet) back to whoever
  /// opened this screen (e.g. HomeController.openSearchFilter()).
  void applyFilterResult(Map<String, String?> result) {
    Get.back(result: result);
  }
}
