import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:scholarship_app/controllers/main_app/discover_controller.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/main_navigation_screen.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/saved_scholarship_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class SavedScholarshipView {
  final int savedId;
  final FirestoreScholarship scholarship;
  bool isVisible;

  SavedScholarshipView({
    required this.savedId,
    required this.scholarship,
    this.isVisible = true,
  });
}

class SavedScholarshipController extends GetxController {
  final SavedScholarshipService savedScholarshipService = SavedScholarshipService();
  final ScholarshipService scholarshipService = ScholarshipService();

  final RxList<SavedScholarshipView> scholarships =
      <SavedScholarshipView>[].obs;
  final RxBool isLoading = true.obs;
  final RxnString loadError = RxnString();

  List<SavedScholarshipView> get visibleScholarships =>
      scholarships.where((s) => s.isVisible).toList();

  @override
  void onInit() {
    super.onInit();
    loadSavedScholarships();
    SavedScholarshipScreen.refreshNotifier.addListener(loadSavedScholarships);
  }

  @override
  void onClose() {
    SavedScholarshipScreen.refreshNotifier
        .removeListener(loadSavedScholarships);
    super.onClose();
  }

  Future<void> loadSavedScholarships() async {
    try {
      final items = await savedScholarshipService.getSavedScholarships();
      final views = <SavedScholarshipView>[];
      for (int i = 0; i < items.length; i++) {
        views.add(SavedScholarshipView(
          savedId: i,
          scholarship: items[i],
        ));
      }
      scholarships.value = views;

      try {
        final discoverCtrl = Get.find<DiscoverController>();
        final ids = views.map((v) => v.scholarship.id).toSet();
        discoverCtrl.favoriteIds
          ..clear()
          ..addAll(ids);
      } catch (_) {}

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      loadError.value = e.toString();
    }
  }

  void retryLoad() {
    isLoading.value = true;
    loadError.value = null;
    loadSavedScholarships();
  }

  void removeItem(int savedId, AppLocalizations t) {
    final index = scholarships.indexWhere((s) => s.savedId == savedId);
    if (index == -1) return;
    final removed = scholarships[index];
    scholarships[index].isVisible = false;
    scholarships.refresh();

    savedScholarshipService.unsaveScholarship(removed.scholarship.id);
    ProfileScreen.refreshNotifier.value++;
    DiscoverScreen.refreshNotifier.value++;

    Get.snackbar(
      '',
      t.translate('savedRemoved'),
      mainButton: TextButton(
        onPressed: () {
          scholarships[index].isVisible = true;
          scholarships.refresh();
          savedScholarshipService.saveScholarship(removed.scholarship.id);
          ProfileScreen.refreshNotifier.value++;
          DiscoverScreen.refreshNotifier.value++;
          Get.closeCurrentSnackbar();
        },
        child: Text(t.translate('savedUndo')),
      ),
      duration: const Duration(seconds: 3),
    );
  }

  void sortScholarships(String sortType) {
    final list = List<SavedScholarshipView>.from(scholarships);
    if (sortType == 'deadline') {
      list.sort(
          (a, b) => a.scholarship.deadline.compareTo(b.scholarship.deadline));
    } else if (sortType == 'name') {
      list.sort(
          (a, b) => a.scholarship.titleEn.compareTo(b.scholarship.titleEn));
    }
    scholarships.value = list;
  }

  void goToHomeTab() {
    if (Get.previousRoute.isNotEmpty) {
      Get.back();
    } else {
      MainNavigationScreen.tabNotifier.value = 0;
    }
  }
}
