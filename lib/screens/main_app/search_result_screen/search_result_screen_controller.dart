part of 'search_result_screen_view.dart';

class SearchResultScreenViewController extends GetxController {
  final ScholarshipService _scholarshipService = ScholarshipService();
  final ScholarshipRepository _scholarshipRepo = ScholarshipRepository();
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();

  late final Stream<List<FirestoreScholarship>> scholarshipsStream;
  final searchQuery = ''.obs;
  final filterCountry = Rx<String?>(null);
  final filterType = Rx<String?>(null);

  final Set<String> favoriteIds = {};

  bool get hasActiveFilter => filterCountry.value != null || filterType.value != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    searchQuery.value = (args?['searchQuery'] as String?) ?? '';
    filterCountry.value = args?['filterCountry'] as String?;
    filterType.value = args?['filterType'] as String?;
    scholarshipsStream = _scholarshipService.streamActiveScholarships();
    loadSavedIds();
  }

  Future<void> loadSavedIds() async {
    final ids = await _savedRepo.getSavedFirestoreIds();
    favoriteIds.addAll(ids);
  }

  List<FirestoreScholarship> applyFilters(List<FirestoreScholarship> all) {
    return all.where((s) {
      final q = searchQuery.value.toLowerCase();
      final matchesSearch = searchQuery.value.isEmpty ||
          s.titleEn.toLowerCase().contains(q) ||
          s.titleKm.contains(searchQuery.value) ||
          s.university.toLowerCase().contains(q) ||
          s.country.toLowerCase().contains(q) ||
          s.fieldOfStudy.toLowerCase().contains(q);
      final matchesCountry = filterCountry.value == null ||
          s.country.toLowerCase().contains(filterCountry.value!.toLowerCase());
      final matchesType = filterType.value == null ||
          s.fundingType.toLowerCase().contains(filterType.value!.toLowerCase());
      return matchesSearch && matchesCountry && matchesType;
    }).toList();
  }

  void clearFilters() {
    filterCountry.value = null;
    filterType.value = null;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<void> openSearchFilter(BuildContext context) async {
    final result = await Get.toNamed(Routes.searchFilter);
    if (result is String && result.isNotEmpty) {
      searchQuery.value = result;
    } else if (result is Map) {
      filterCountry.value = result['country'] as String?;
      filterType.value = result['type'] as String?;
    }
  }

  Future<void> toggleFavorite(FirestoreScholarship scholarship, BuildContext context) async {
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
    SavedScholarshipScreenViewController.refreshNotifier.value++;
    ProfileScreenViewController.refreshNotifier.value++;
    DiscoverScreenViewController.refreshNotifier.value++;
  }
}
