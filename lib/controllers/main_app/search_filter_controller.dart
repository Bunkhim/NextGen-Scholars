import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class SearchFilterController extends GetxController {
  static const int maxSearchLength = 100;

  final searchController = TextEditingController();
  final focusNode = FocusNode();
  final RxnString searchError = RxnString();

  @override
  void onClose() {
    searchController.dispose();
    focusNode.dispose();
    super.onClose();
  }

  List<String> getRecentSearches(AppLocalizations t) => [
        t.translate('searchRecentCS'),
        t.translate('searchRecentEngineering'),
        t.translate('searchRecentBusiness'),
      ];

  List<String> getPopularSearches(AppLocalizations t) => [
        t.translate('searchPopularSTEM'),
        t.translate('searchPopularMedical'),
        t.translate('searchPopularFullScholarship'),
        t.translate('searchPopularUSA'),
      ];

  String sanitizeInput(String input) {
    var sanitized = input.trim();
    // Remove XSS dangerous characters: < > " ' / \ ;
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
    Get.back(result: query);
  }

  void onPopularTap(String query) {
    searchController.text = query;
    Get.back(result: query);
  }

  void onSearchSubmitted(String val, AppLocalizations t) {
    final sanitized = sanitizeInput(val);
    if (sanitized.isEmpty) {
      searchError.value = t.translate('validationSearchEmpty');
      return;
    }
    Get.back(result: sanitized);
  }

  /// Propagates a filter result (from the bottom sheet) back to whoever
  /// opened this screen (e.g. HomeController.openSearchFilter()).
  void applyFilterResult(Map<String, String?> result) {
    Get.back(result: result);
  }
}