part of 'discover_screen_view.dart';

class DiscoverScreenViewController extends GetxController {
  static final RxInt refreshNotifier = 0.obs;

  static const int _maxSearchLength = 100;

  final ScholarshipService _scholarshipService = ScholarshipService();
  final ScholarshipRepository _scholarshipRepo = ScholarshipRepository();
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();

  late final Stream<List<FirestoreScholarship>> scholarshipsStream;
  final _streamCtrl = StreamController<List<FirestoreScholarship>>();
  StreamSubscription<List<FirestoreScholarship>>? _firestoreSub;

  final selectedCategoryIndex = 0.obs;
  final searchQuery = ''.obs;
  final searchError = Rx<String?>(null);
  final filterCountry = Rx<String?>(null);
  final filterType = Rx<String?>(null);
  final searchController = TextEditingController();
  final favoriteIds = <String>{}.obs;

  String? _lastSyncHash;

  @override
  void onInit() {
    super.onInit();
    _streamCtrl.add([]);
    _firestoreSub = _scholarshipService
        .streamActiveScholarships()
        .listen(_streamCtrl.add, onError: (_) => _streamCtrl.add([]));
    scholarshipsStream = _streamCtrl.stream;
    loadSavedIds();
    ever(refreshNotifier, (_) => loadSavedIds());
  }

  @override
  void onClose() {
    _firestoreSub?.cancel();
    _streamCtrl.close();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadSavedIds() async {
    final ids = await _savedRepo.getSavedFirestoreIds();
    favoriteIds.clear();
    favoriteIds.addAll(ids);
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

  Future<void> syncToSQLite(List<FirestoreScholarship> active) async {
    final hash = _computeSyncHash(active);
    if (_lastSyncHash == hash) return;
    _lastSyncHash = hash;

    for (final s in active) {
      await _scholarshipRepo.upsertByFirestoreId(
        firestoreId: s.id,
        scholarship: Scholarship(
          title: s.titleEn,
          titleKm: s.titleKm,
          institution: s.university,
          country: s.country,
          type: s.fundingType,
          deadline: s.deadline,
          openDate: s.openDate,
          numberOfPlaces: s.numberOfPlaces,
          description: s.descriptionEn,
          descriptionKm: s.descriptionKm,
          applicationUrl: s.applicationLink,
          imageUrl: s.imageUrl,
          logoUrl: s.logoUrl,
          level: s.degree,
          fieldOfStudy: s.fieldOfStudy,
          eligibility: s.eligibilityEn,
          eligibilityKm: s.eligibilityKm,
          benefits: s.benefitsEn,
          benefitsKm: s.benefitsKm,
          requiredDocuments: s.requiredDocumentsEn,
          requiredDocumentsKm: s.requiredDocumentsKm,
          isActive: true,
        ),
      );
    }

    final ids = active.map((s) => s.id).toList();
    await _scholarshipRepo.syncActiveStatus(ids);

    SavedScholarshipScreenViewController.refreshNotifier.value++;
  }

  bool get hasActiveFilter =>
      filterCountry.value != null || filterType.value != null;

  void clearFilters() {
    filterCountry.value = null;
    filterType.value = null;
  }

  Future<void> openSearchFilter() async {
    final result = await Get.toNamed(Routes.searchFilter);
    if (result is String && result.isNotEmpty) {
      searchQuery.value = result;
      searchController.text = result;
      searchError.value = null;
    } else if (result is Map) {
      filterCountry.value = result['country'] as String?;
      filterType.value = result['type'] as String?;
    }
  }

  List<String> getCategories(AppLocalizations t) => [
        t.translate('discoverCategoryAll'),
        t.translate('discoverCategoryTechnology'),
        t.translate('discoverCategoryScience'),
        t.translate('discoverCategoryBusiness'),
        t.translate('discoverCategoryArt'),
      ];

  String sanitizeInput(String input) {
    var sanitized = input.trim();
    sanitized = sanitized.replaceAll(RegExp('[<>"\'\\\\;/]'), '');
    if (sanitized.length > _maxSearchLength) {
      sanitized = sanitized.substring(0, _maxSearchLength);
    }
    return sanitized;
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
    SavedScholarshipScreenViewController.refreshNotifier.value++;
    ProfileScreenViewController.refreshNotifier.value++;
  }

  List<FirestoreScholarship> filterScholarships(
      List<FirestoreScholarship> all) {
    const categoryKeywords = <String?>[
      null,
      'technology',
      'science',
      'business',
      'art',
    ];
    final catKeyword = (selectedCategoryIndex.value > 0 &&
            selectedCategoryIndex.value < categoryKeywords.length)
        ? categoryKeywords[selectedCategoryIndex.value]
        : null;

    final q = searchQuery.value.toLowerCase();
    return all.where((s) {
      final matchesSearch = searchQuery.value.isEmpty ||
          s.titleEn.toLowerCase().contains(q) ||
          s.titleKm.contains(searchQuery.value) ||
          s.university.toLowerCase().contains(q) ||
          s.country.toLowerCase().contains(q) ||
          s.fieldOfStudy.toLowerCase().contains(q) ||
          s.fundingType.toLowerCase().contains(q) ||
          s.degree.toLowerCase().contains(q);
      final matchesCountry = filterCountry.value == null ||
          s.country
              .toLowerCase()
              .contains(filterCountry.value!.toLowerCase());
      final matchesType = filterType.value == null ||
          s.fundingType
              .toLowerCase()
              .contains(filterType.value!.toLowerCase());
      final matchesCategory = catKeyword == null ||
          s.fieldOfStudy.toLowerCase().contains(catKeyword);
      return matchesSearch &&
          matchesCountry &&
          matchesType &&
          matchesCategory;
    }).toList();
  }

}
