part of 'scholarship_match_screen_view.dart';

class ScholarshipMatchScreenViewController extends GetxController {
  final ScholarshipService scholarshipService = ScholarshipService();
  final SavedScholarshipRepository savedRepo = SavedScholarshipRepository();
  final ScholarshipRepository scholarshipRepo = ScholarshipRepository();
  final appData = ApplicationData();

  final favoriteIds = <String>{}.obs;
  final prefsLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    await appData.loadFromPrefs();
    final ids = await savedRepo.getSavedFirestoreIds();
    favoriteIds.addAll(ids);
    prefsLoaded.value = true;
  }

  Future<void> reloadPrefs() async {
    await appData.loadFromPrefs();
  }

  bool get hasPreferences =>
      (appData.destinationCountry ?? '').trim().isNotEmpty &&
      (appData.preferredDegree ?? '').trim().isNotEmpty &&
      (appData.preferredMajor ?? '').trim().isNotEmpty;

  int matchScore(FirestoreScholarship s) {
    int score = 0;
    final country = appData.destinationCountry?.toLowerCase() ?? '';
    final degree = appData.preferredDegree?.toLowerCase() ?? '';
    final major = appData.preferredMajor?.toLowerCase() ?? '';
    final uni = appData.preferredUniversity?.toLowerCase() ?? '';

    if (country.isNotEmpty && s.country.toLowerCase().contains(country)) {
      score += 3;
    }
    if (degree.isNotEmpty && s.degree.toLowerCase().contains(degree)) {
      score += 3;
    }
    if (major.isNotEmpty && s.fieldOfStudy.toLowerCase().contains(major)) {
      score += 2;
    }
    if (uni.isNotEmpty && s.university.toLowerCase().contains(uni)) {
      score += 2;
    }
    return score;
  }

  List<FirestoreScholarship> filterAndSort(List<FirestoreScholarship> all) {
    final scored = <MapEntry<FirestoreScholarship, int>>[];
    for (final s in all) {
      final score = matchScore(s);
      if (score > 0) scored.add(MapEntry(s, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }
}
