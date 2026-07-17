import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/core/api/services/users_api_service.dart';

class SearchResultController extends GetxController {
  final ScholarshipService _scholarshipService = ScholarshipService();
  final ScholarshipRepository _scholarshipRepo = ScholarshipRepository();
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();
  final _usersApi = UsersApiService();

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
    final ids = await _savedRepo.getSavedFirestoreIds();
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
      await _savedRepo.unsaveByFirestoreId(scholarship.id);
      await _usersApi.unsaveScholarship(scholarship.id);
    } else {
      favoriteIds.add(scholarship.id);
      final sqliteId = await _scholarshipRepo.upsertByFirestoreId(
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
      await _savedRepo.save(SavedScholarshipModel(scholarshipId: sqliteId));
      await _usersApi.saveScholarship(scholarship.id);
    }
    SavedScholarshipScreen.refreshNotifier.value++;
    ProfileScreen.refreshNotifier.value++;
    DiscoverScreen.refreshNotifier.value++;
  }
}
