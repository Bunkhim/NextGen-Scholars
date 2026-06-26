part of 'homescreens_view.dart';

class HomeScreenViewController extends GetxController {
  static const _cambodiaUtcOffset = Duration(hours: 7);
  final _scholarshipService = ScholarshipService();
  final _savedRepo = SavedScholarshipRepository();
  final _appData = ApplicationData();
  late final Stream<List<FirestoreScholarship>> scholarshipsStream;

  final favoriteIds = <String>{}.obs;
  final photoUrl = Rx<String?>(null);
  final actionOrder = <String>[
    'discover',
    'match',
    'applications',
    'fillInfo',
  ].obs;
  final userName = ''.obs;
  final isMatchReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    scholarshipsStream = _scholarshipService.streamActiveScholarships();
    loadFavorites();
    loadPhoto();
    loadActionOrder();
    loadUserName();
    loadMatchState();
    ever(ProfileScreenViewController.photoRefreshNotifier, (_) => onPhotoChanged());
    ever(ProfileScreenViewController.refreshNotifier, (_) => onProfileRefresh());
    ever(SavedScholarshipScreenViewController.refreshNotifier, (_) => loadFavorites());
  }

  void onProfileRefresh() {
    loadUserName();
  }

  void onPhotoChanged() {
    final path = ProfileScreenViewController.activePhotoPath;
    if (path != null && !path.startsWith('http') && File(path).existsSync()) {
      FileImage(File(path)).evict();
    }
    photoUrl.value = path;
  }

  Future<void> loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    final profile = await UserFirestoreService().getProfile();
    final name = profile?['name'] as String? ?? user?.displayName ?? 'User';
    userName.value = name;
  }

  Future<void> loadFavorites() async {
    final ids = await _savedRepo.getSavedFirestoreIds();
    favoriteIds.clear();
    favoriteIds.addAll(ids);
  }

  String greetingKey() {
    final cambodiaTime = DateTime.now().toUtc().add(_cambodiaUtcOffset);
    final hour = cambodiaTime.hour;
    if (hour >= 5 && hour < 12) return 'homeGoodMorning';
    if (hour >= 12 && hour < 17) return 'homeGoodAfternoon';
    if (hour >= 17 && hour < 21) return 'homeGoodEvening';
    return 'homeGoodNight';
  }

  Future<void> loadPhoto() async {
    if (ProfileScreenViewController.activePhotoPath != null) {
      photoUrl.value = ProfileScreenViewController.activePhotoPath;
      return;
    }
    final profile = await UserFirestoreService().getProfile();
    final user = FirebaseAuth.instance.currentUser;
    final url = profile?['photoUrl'] as String? ?? user?.photoURL;
    ProfileScreenViewController.activePhotoPath = url;
    photoUrl.value = url;
  }

  Future<void> loadActionOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('quickActionsOrder');
    if (saved != null) {
      actionOrder.value = saved;
    }
  }

  bool _hasRequiredMatchPreferences() {
    final country = (_appData.destinationCountry ?? '').trim();
    final degree = (_appData.preferredDegree ?? '').trim();
    final major = (_appData.preferredMajor ?? '').trim();
    return country.isNotEmpty && degree.isNotEmpty && major.isNotEmpty;
  }

  Future<void> loadMatchState() async {
    await _appData.loadFromPrefs();
    isMatchReady.value = _hasRequiredMatchPreferences();
  }

  Future<void> handleMatchTap() async {
    await loadMatchState();

    if (!isMatchReady.value) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        SnackBar(
            content: Text(
                AppLocalizations.of(Get.context!).translate('matchNoPreferences'))),
      );
      await Get.to(() => const ScholarshipPreferenceScreenView());
      await loadMatchState();
      return;
    }

    await Get.to(() => const ScholarshipMatchScreenView());
    await loadMatchState();
  }

  Future<void> saveActionOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quickActionsOrder', actionOrder.toList());
  }

  Future<void> openSearchFilter() async {
    final result = await Get.toNamed(Routes.searchFilter);
    if (result is String && result.isNotEmpty) {
      Get.toNamed(
        Routes.searchResult,
        arguments: {'searchQuery': result},
      );
    } else if (result is Map) {
      Get.toNamed(
        Routes.searchResult,
        arguments: {
          'filterCountry': result['country'] as String?,
          'filterType': result['type'] as String?,
        },
      );
    }
  }

  Future<void> toggleFavorite(FirestoreScholarship scholarship) async {
    final isFav = favoriteIds.contains(scholarship.id);
    if (isFav) {
      favoriteIds.remove(scholarship.id);
      await _savedRepo.unsaveByFirestoreId(scholarship.id);
    } else {
      favoriteIds.add(scholarship.id);
      final sqliteId = await ScholarshipRepository().upsertByFirestoreId(
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

  @override
  void onClose() {
    super.onClose();
  }
}
