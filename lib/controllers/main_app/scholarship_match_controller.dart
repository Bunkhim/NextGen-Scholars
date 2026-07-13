import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';

class ScholarshipMatchController extends GetxController {
  final ScholarshipService _scholarshipService = ScholarshipService();
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();
  final ScholarshipRepository _scholarshipRepo = ScholarshipRepository();
  final ApplicationData appData = ApplicationData();

  final RxSet<String> favoriteIds = <String>{}.obs;
  final RxBool prefsLoaded = false.obs;
  final RxList<FirestoreScholarship> _allScholarships = <FirestoreScholarship>[].obs;
  StreamSubscription? _subscription;

  @override
  void onInit() {
    super.onInit();
    loadAll();
    _subscription = _scholarshipService.streamActiveScholarships().listen((data) {
      _allScholarships.value = data;
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }

  Future<void> loadAll() async {
    await appData.loadFromPrefs();
    final ids = await _savedRepo.getSavedFirestoreIds();
    favoriteIds.clear();
    favoriteIds.addAll(ids);
    prefsLoaded.value = true;
  }

  bool get hasPreferences =>
      (appData.destinationCountry ?? '').trim().isNotEmpty &&
      (appData.preferredDegree ?? '').trim().isNotEmpty &&
      (appData.preferredMajor ?? '').trim().isNotEmpty;

  int _matchScore(FirestoreScholarship s) {
    int score = 0;
    final country = appData.destinationCountry?.toLowerCase() ?? '';
    final degree = appData.preferredDegree?.toLowerCase() ?? '';
    final major = appData.preferredMajor?.toLowerCase() ?? '';
    final uni = appData.preferredUniversity?.toLowerCase() ?? '';

    if (country.isNotEmpty && s.country.toLowerCase().contains(country)) score += 3;
    if (degree.isNotEmpty && s.degree.toLowerCase().contains(degree)) score += 3;
    if (major.isNotEmpty && s.fieldOfStudy.toLowerCase().contains(major)) score += 2;
    if (uni.isNotEmpty && s.university.toLowerCase().contains(uni)) score += 2;

    return score;
  }

  List<FirestoreScholarship> get matchedScholarships {
    final scored = <MapEntry<FirestoreScholarship, int>>[];
    for (final s in _allScholarships) {
      final score = _matchScore(s);
      if (score > 0) scored.add(MapEntry(s, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  Future<void> toggleFavorite(FirestoreScholarship scholarship, BuildContext context, String savedAddedMsg, String savedRemovedMsg) async {
    final isFav = favoriteIds.contains(scholarship.id);
    if (isFav) {
      await _savedRepo.unsaveByFirestoreId(scholarship.id);
      favoriteIds.remove(scholarship.id);
    } else {
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
      favoriteIds.add(scholarship.id);
    }
    
    // UI Refresh Notifications
    SavedScholarshipScreen.refreshNotifier.value++;
    ProfileScreen.refreshNotifier.value++;
    DiscoverScreen.refreshNotifier.value++;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isFav ? Icons.bookmark_remove : Icons.bookmark_added,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(isFav ? savedRemovedMsg : savedAddedMsg)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isFav ? Colors.grey[700] : const Color(0xFF4ECDC4),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
