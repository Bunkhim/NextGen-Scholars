import 'package:get/get.dart';
import 'package:scholarship_app/services/scholarship_service.dart';

class FilterResultController extends GetxController {
  final ScholarshipService _scholarshipService = ScholarshipService();

  final RxList<String> activeFilterKeys = <String>[].obs;
  final RxList<FirestoreScholarship> filteredResults = <FirestoreScholarship>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  String? _filterCountry;
  String? _filterDegree;
  String? _filterFunding;
  String? _searchQuery;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _filterCountry = args['country'] as String?;
      _filterDegree = args['degree'] as String?;
      _filterFunding = args['funding'] as String?;
      _searchQuery = args['search'] as String?;
      if (_filterCountry != null && _filterCountry!.isNotEmpty) {
        activeFilterKeys.add(_filterCountry!);
      }
      if (_filterDegree != null && _filterDegree!.isNotEmpty) {
        activeFilterKeys.add(_filterDegree!);
      }
      if (_filterFunding != null && _filterFunding!.isNotEmpty) {
        activeFilterKeys.add(_filterFunding!);
      }
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        activeFilterKeys.add(_searchQuery!);
      }
    }
    fetchResults();
  }

  Future<void> fetchResults() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await _scholarshipService.fetchActiveScholarships(
        search: _searchQuery,
        country: _filterCountry,
        degree: _filterDegree,
        funding: _filterFunding,
        limit: 100,
      );
      filteredResults.assignAll(results);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void removeFilter(String filterKey) {
    activeFilterKeys.remove(filterKey);
    if (_filterCountry == filterKey) _filterCountry = null;
    if (_filterDegree == filterKey) _filterDegree = null;
    if (_filterFunding == filterKey) _filterFunding = null;
    if (_searchQuery == filterKey) _searchQuery = null;
    fetchResults();
  }
}
