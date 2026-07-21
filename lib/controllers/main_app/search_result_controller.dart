import 'package:get/get.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/saved_scholarship_service.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';

class SearchResultController extends GetxController {
  final ScholarshipService _scholarshipService = ScholarshipService();
  final SavedScholarshipService _savedScholarshipService = SavedScholarshipService();

  final RxString searchQuery = ''.obs;
  final RxnString filterCountry = RxnString();
  final RxnString filterType = RxnString();

  final RxSet<String> favoriteIds = <String>{}.obs;
  final RxList<FirestoreScholarship> filteredScholarships = <FirestoreScholarship>[].obs;
  
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  SearchResultController({
    String query = '',
    String? country,
    String? type,
  }) {
    searchQuery.value = query;
    filterCountry.value = country;
    filterType.value = type;
  }

  @override
  void onInit() {
    super.onInit();
    _loadSavedIds();
    _loadScholarships();
  }

  Future<void> _loadScholarships() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await _scholarshipService.fetchActiveScholarships(
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        country: filterCountry.value,
        funding: filterType.value,
        limit: 100,
      );
      filteredScholarships.assignAll(results);
      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  Future<void> _loadSavedIds() async {
    final ids = await _savedScholarshipService.getSavedIds();
    favoriteIds
      ..clear()
      ..addAll(ids);
  }

  bool get hasActiveFilter => filterCountry.value != null || filterType.value != null;

  void clearFilters() {
    filterCountry.value = null;
    filterType.value = null;
    _loadScholarships();
  }

  void clearSearch() {
    searchQuery.value = '';
    _loadScholarships();
  }

  void updateFilters({String? query, String? country, String? type}) {
    if (query != null) searchQuery.value = query;
    if (country != null) filterCountry.value = country;
    if (type != null) filterType.value = type;
    _loadScholarships();
  }

  Future<void> toggleFavorite(FirestoreScholarship scholarship) async {
    final isFav = favoriteIds.contains(scholarship.id);
    if (isFav) {
      favoriteIds.remove(scholarship.id);
      await _savedScholarshipService.unsaveScholarship(scholarship.id);
    } else {
      favoriteIds.add(scholarship.id);
      await _savedScholarshipService.saveScholarship(scholarship.id);
    }
    SavedScholarshipScreen.refreshNotifier.value++;
    ProfileScreen.refreshNotifier.value++;
    DiscoverScreen.refreshNotifier.value++;
  }
}
