part of 'search_filter_screen_view.dart';

class SearchFilterScreenViewController extends GetxController {
  final searchController = TextEditingController();
  final focusNode = FocusNode();
  final searchError = Rx<String?>(null);

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

  void onRecentTap(String query) {
    searchController.text = query;
    Get.back(result: query);
  }

  void onPopularTap(String query) {
    searchController.text = query;
    Get.back(result: query);
  }

  Future<void> openFilter(BuildContext context) async {
    if (!context.mounted) return;
    final result = await showModalBottomSheet<Map<String, String?>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(),
    );
    if (result != null) {
      Get.back(result: result);
    }
  }

  String sanitizeInput(String input) {
    var sanitized = input.trim();
    sanitized = sanitized.replaceAll(RegExp('[<>"\'\\\\;/]'), '');
    if (sanitized.length > 100) {
      sanitized = sanitized.substring(0, 100);
    }
    return sanitized;
  }

  @override
  void onClose() {
    searchController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}
