import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/saved_scholarship_service.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';

class ScholarshipMatchController extends GetxController {
  final ScholarshipService _scholarshipService = ScholarshipService();
  final SavedScholarshipService _savedScholarshipService = SavedScholarshipService();
  final ApplicationData appData = ApplicationData();

  final RxSet<String> favoriteIds = <String>{}.obs;
  final RxBool prefsLoaded = false.obs;
  final RxList<FirestoreScholarship> matchedScholarships = <FirestoreScholarship>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    await appData.loadFromPrefs();
    final ids = await _savedScholarshipService.getSavedIds();
    favoriteIds.clear();
    favoriteIds.addAll(ids);
    prefsLoaded.value = true;
    await _matchScholarships();
  }

  Future<void> _matchScholarships() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final results = await _scholarshipService.matchScholarships(
        destinationCountry: appData.destinationCountry ?? '',
        preferredDegree: appData.preferredDegree ?? '',
        preferredMajor: appData.preferredMajor ?? '',
        preferredUniversity: appData.preferredUniversity ?? '',
      );
      matchedScholarships.assignAll(results);
      isLoading.value = false;
    } catch (e) {
      hasError.value = true;
      isLoading.value = false;
    }
  }

  bool get hasPreferences =>
      (appData.destinationCountry ?? '').trim().isNotEmpty &&
      (appData.preferredDegree ?? '').trim().isNotEmpty &&
      (appData.preferredMajor ?? '').trim().isNotEmpty;

  Future<void> toggleFavorite(FirestoreScholarship scholarship, BuildContext context, String savedAddedMsg, String savedRemovedMsg) async {
    final isFav = favoriteIds.contains(scholarship.id);
    if (isFav) {
      await _savedScholarshipService.unsaveScholarship(scholarship.id);
      favoriteIds.remove(scholarship.id);
    } else {
      await _savedScholarshipService.saveScholarship(scholarship.id);
      favoriteIds.add(scholarship.id);
    }

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
