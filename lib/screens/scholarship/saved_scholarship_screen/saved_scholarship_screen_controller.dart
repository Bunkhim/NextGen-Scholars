part of 'saved_scholarship_screen_view.dart';

class SavedScholarshipScreenViewController extends GetxController {
  static final RxInt refreshNotifier = 0.obs;

  final SavedScholarshipRepository savedRepo = SavedScholarshipRepository();
  final ScholarshipService scholarshipService = ScholarshipService();
  StreamSubscription<List<FirestoreScholarship>>? firestoreSub;

  final scholarships = <SavedScholarshipView>[].obs;
  final isLoading = true.obs;
  final loadError = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    firestoreSub = scholarshipService
        .streamActiveScholarships()
        .listen(onFirestoreUpdate, onError: (_) {
      // Firestore not available (e.g. permission-denied) — use local data only.
    });
    ever(refreshNotifier, (_) => loadSavedScholarships());
  }

  @override
  void onClose() {
    firestoreSub?.cancel();
    super.onClose();
  }

  void onFirestoreUpdate(List<FirestoreScholarship> latest) {
    if (scholarships.isEmpty) return;
    final map = {for (final s in latest) s.id: s};
    bool changed = false;

    final updated = scholarships.map((view) {
      final fresh = map[view.scholarship.id];
      if (fresh == null) {
        if (view.isVisible) {
          changed = true;
          return view..isVisible = false;
        }
        return view;
      }
      changed = true;
      return SavedScholarshipView(
        savedId: view.savedId,
        scholarship: fresh..isFavorite = true,
      );
    }).toList();

    if (changed) scholarships.assignAll(updated);
  }

  Future<void> loadSavedScholarships() async {
    try {
      final savedWithDetails = await savedRepo.getSavedWithDetails();
      scholarships.assignAll(savedWithDetails.map((row) {
        final deadlineStr = row['deadline'] as String?;
        final openDateStr = row['open_date'] as String?;
        return SavedScholarshipView(
          savedId: row['saved_id'] as int,
          scholarship: FirestoreScholarship(
            id: (row['firestore_id'] as String?)?.isNotEmpty == true
                ? row['firestore_id'] as String
                : 'local_${row['saved_id']}',
            titleEn: (row['title'] as String?) ?? '',
            titleKm: (row['title_km'] as String?) ?? '',
            descriptionEn: (row['description'] as String?) ?? '',
            descriptionKm: (row['description_km'] as String?) ?? '',
            country: (row['country'] as String?) ?? '',
            university: (row['institution'] as String?) ?? '',
            degree: (row['level'] as String?) ?? '',
            fieldOfStudy: (row['field_of_study'] as String?) ?? '',
            fundingType: (row['type'] as String?) ?? '',
            numberOfPlaces: (row['number_of_places'] as int?) ?? 0,
            openDate:
                openDateStr != null ? DateTime.tryParse(openDateStr) : null,
            deadline: deadlineStr != null
                ? DateTime.tryParse(deadlineStr) ?? DateTime.now()
                : DateTime.now(),
            applicationLink: (row['application_url'] as String?) ?? '',
            imageUrl: (row['image_url'] as String?) ?? '',
            logoUrl: (row['logo_url'] as String?) ?? '',
            eligibilityEn: (row['eligibility'] as String?) ?? '',
            eligibilityKm: (row['eligibility_km'] as String?) ?? '',
            benefitsEn: (row['benefits'] as String?) ?? '',
            benefitsKm: (row['benefits_km'] as String?) ?? '',
            requiredDocumentsEn:
                (row['required_documents'] as String?) ?? '',
            requiredDocumentsKm:
                (row['required_documents_km'] as String?) ?? '',
            isActive: (row['is_active'] as int?) == 1,
            createdAt: row['created_at'] != null
                ? DateTime.tryParse(row['created_at'] as String) ??
                    DateTime.now()
                : DateTime.now(),
            isFavorite: true,
          ),
        );
      }).toList());
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      loadError.value = e.toString();
    }
  }

  void removeItem(int savedId) {
    final index = scholarships.indexWhere((s) => s.savedId == savedId);
    if (index == -1) return;
    final scholarship = scholarships[index];
    scholarship.isVisible = false;
    scholarships.refresh();

    savedRepo.hide(savedId);
    ProfileScreenViewController.refreshNotifier.value++;
    DiscoverScreenViewController.refreshNotifier.value++;
  }

  void sortScholarships(String sortType) {
    if (sortType == 'deadline') {
      scholarships.sort(
          (a, b) => a.scholarship.deadline.compareTo(b.scholarship.deadline));
    } else if (sortType == 'name') {
      scholarships.sort(
          (a, b) => a.scholarship.titleEn.compareTo(b.scholarship.titleEn));
    }
    scholarships.refresh();
  }
}
