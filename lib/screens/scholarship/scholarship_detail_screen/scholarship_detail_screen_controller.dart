part of 'scholarship_detail_screen_view.dart';

class ScholarshipDetailScreenViewController extends GetxController {
  final scholarship = Rx<FirestoreScholarship?>(null);
  final applying = false.obs;
  final descExpanded = true.obs;
  final isSaved = false.obs;
  final isSaving = false.obs;

  final savedRepo = SavedScholarshipRepository();
  final scholarshipRepo = ScholarshipRepository();

  @override
  void onInit() {
    super.onInit();
    scholarship.value = Get.arguments as FirestoreScholarship?;
    WidgetsBinding.instance.addPostFrameCallback((_) => loadSavedState());
  }

  Future<void> loadSavedState() async {
    final s = scholarship.value;
    if (s == null) return;
    final ids = await savedRepo.getSavedFirestoreIds();
    isSaved.value = ids.contains(s.id);
  }

  void toggleDesc() {
    descExpanded.value = !descExpanded.value;
  }

  Future<void> toggleBookmark(FirestoreScholarship s) async {
    if (isSaving.value) return;
    final wasSaved = isSaved.value;
    isSaved.value = !wasSaved;
    isSaving.value = true;

    if (wasSaved) {
      await savedRepo.unsaveByFirestoreId(s.id);
    } else {
      final sqliteId = await scholarshipRepo.upsertByFirestoreId(
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
      await savedRepo.save(SavedScholarshipModel(scholarshipId: sqliteId));
    }

    SavedScholarshipScreenViewController.refreshNotifier.value++;
    ProfileScreenViewController.refreshNotifier.value++;
    DiscoverScreenViewController.refreshNotifier.value++;

    isSaving.value = false;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
