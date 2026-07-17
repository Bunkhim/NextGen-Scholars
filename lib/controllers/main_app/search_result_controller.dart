import 'dart:async';
import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';

class SearchResultController extends GetxController {
  final ScholarshipService _scholarshipService = ScholarshipService();
  final ScholarshipRepository _scholarshipRepo = ScholarshipRepository();
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();

  final RxString searchQuery = ''.obs;
  final RxnString filterCountry = RxnString();
  final RxnString filterType = RxnString();

  final RxSet<String> favoriteIds = <String>{}.obs;
  final RxList<FirestoreScholarship> _allScholarships = <FirestoreScholarship>[].obs;
  
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  StreamSubscription? _subscription;

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
    DiscoverScreen.refreshNotifier.addListener(_refreshFavorites);
    _subscription = _scholarshipService.streamActiveScholarships().listen(
      (data) {
        _allScholarships.value = data;
        isLoading.value = false;
        hasError.value = false;
      },
      onError: (e) {
        hasError.value = true;
        isLoading.value = false;
      },
    );
  }

  void _refreshFavorites() {
    _loadSavedIds();
  }

  @override
  void onClose() {
    DiscoverScreen.refreshNotifier.removeListener(_refreshFavorites);
    _subscription?.cancel();
    super.onClose();
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
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  void updateFilters({String? query, String? country, String? type}) {
    if (query != null) searchQuery.value = query;
    if (country != null) filterCountry.value = country;
    if (type != null) filterType.value = type;
  }

  List<FirestoreScholarship> get filteredScholarships {
    return _allScholarships.where((s) {
      final q = searchQuery.value.toLowerCase();
      final matchesSearch = q.isEmpty ||
          s.titleEn.toLowerCase().contains(q) ||
          s.titleKm.contains(searchQuery.value) ||
          s.university.toLowerCase().contains(q) ||
          s.country.toLowerCase().contains(q) ||
          s.fieldOfStudy.toLowerCase().contains(q);
      
      final fCountry = filterCountry.value?.toLowerCase();
      final matchesCountry = fCountry == null || s.country.toLowerCase().contains(fCountry);
      
      final fType = filterType.value?.toLowerCase();
      final matchesType = fType == null || s.fundingType.toLowerCase().contains(fType);
      
      return matchesSearch && matchesCountry && matchesType;
    }).toList();
  }

  Future<void> toggleFavorite(FirestoreScholarship scholarship) async {
    final isFav = favoriteIds.contains(scholarship.id);
    if (isFav) {
      favoriteIds.remove(scholarship.id);
      await _savedRepo.unsaveByFirestoreId(scholarship.id);
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
    }
    SavedScholarshipScreen.refreshNotifier.value++;
    ProfileScreen.refreshNotifier.value++;
    DiscoverScreen.refreshNotifier.value++;
  }
}
