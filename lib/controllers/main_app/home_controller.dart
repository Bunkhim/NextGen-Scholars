// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/core/services/jwt_service.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/main_app/scholarship_match_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/user_firestore_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  static const _cambodiaUtcOffset = Duration(hours: 7);

  final scholarshipService = ScholarshipService();
  final savedRepo = SavedScholarshipRepository();
  final appData = ApplicationData();

  late final Stream<List<FirestoreScholarship>> scholarshipsStream;

  final RxSet<String> favoriteIds = <String>{}.obs;
  final RxnString photoUrl = RxnString();
  final RxList<String> actionOrder =
      <String>['discover', 'match', 'applications', 'fillInfo'].obs;
  final RxString userName = ''.obs;
  final RxBool isMatchReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    scholarshipsStream = scholarshipService.streamActiveScholarships();
    loadFavorites();
    loadPhoto();
    loadActionOrder();
    loadUserName();
    loadMatchState();
    ProfileScreen.photoRefreshNotifier.addListener(_onPhotoChanged);
    ProfileScreen.refreshNotifier.addListener(_onProfileRefresh);
    SavedScholarshipScreen.refreshNotifier.addListener(loadFavorites);
  }

  @override
  void onClose() {
    ProfileScreen.photoRefreshNotifier.removeListener(_onPhotoChanged);
    ProfileScreen.refreshNotifier.removeListener(_onProfileRefresh);
    SavedScholarshipScreen.refreshNotifier.removeListener(loadFavorites);
    super.onClose();
  }

  void _onProfileRefresh() {
    loadUserName();
  }

  void _onPhotoChanged() {
    final path = ProfileScreen.activePhotoPath;
    if (path != null && !path.startsWith('http') && File(path).existsSync()) {
      FileImage(File(path)).evict();
    }
    photoUrl.value = path;
  }

  Future<void> loadUserName() async {
    final profile = await UserFirestoreService().getProfile();
    final name = profile?['name'] as String? ??
        JwtService().displayNameSync ??
        'User';
    userName.value = name;
  }

  Future<void> loadFavorites() async {
    final ids = await savedRepo.getSavedFirestoreIds();
    favoriteIds.value = ids.toSet();
  }

  /// Returns the appropriate greeting translation key based on Cambodia time (UTC+7).
  String greetingKey() {
    final cambodiaTime = DateTime.now().toUtc().add(_cambodiaUtcOffset);
    final hour = cambodiaTime.hour;
    if (hour >= 5 && hour < 12) return 'homeGoodMorning';
    if (hour >= 12 && hour < 17) return 'homeGoodAfternoon';
    if (hour >= 17 && hour < 21) return 'homeGoodEvening';
    return 'homeGoodNight';
  }

  Future<void> loadPhoto() async {
    if (ProfileScreen.activePhotoPath != null) {
      photoUrl.value = ProfileScreen.activePhotoPath;
      return;
    }
    final profile = await UserFirestoreService().getProfile();
    final url = profile?['photoUrl'] as String?;
    ProfileScreen.activePhotoPath = url;
    photoUrl.value = url;
  }

  Future<void> loadActionOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('quickActionsOrder');
    actionOrder.value =
        saved ?? ['discover', 'match', 'applications', 'fillInfo'];
  }

  void reorderActions(int oldIndex, int newIndex) {
    final item = actionOrder.removeAt(oldIndex);
    actionOrder.insert(newIndex, item);
    _saveActionOrder();
  }

  Future<void> _saveActionOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quickActionsOrder', actionOrder);
  }

  bool _hasRequiredMatchPreferences() {
    final country = (appData.destinationCountry ?? '').trim();
    final degree = (appData.preferredDegree ?? '').trim();
    final major = (appData.preferredMajor ?? '').trim();
    return country.isNotEmpty && degree.isNotEmpty && major.isNotEmpty;
  }

  Future<void> loadMatchState() async {
    await appData.loadFromPrefs();
    isMatchReady.value = _hasRequiredMatchPreferences();
  }

  /// Handles tapping the "Match" quick action.
  /// Returns true if navigation to ScholarshipMatchScreen happened directly,
  /// false if the user was routed to fill preferences first.
  Future<void> handleMatchTap(AppLocalizations t) async {
    await loadMatchState();

    if (!isMatchReady.value) {
      Get.snackbar('', t.translate('matchNoPreferences'));
      await Get.toNamed(AppRoutes.scholarshipPreferenceScreen);
      await loadMatchState();
      return;
    }

    await Get.to(() => const ScholarshipMatchScreen());
    await loadMatchState();
  }

  Future<void> toggleFavorite(FirestoreScholarship scholarship) async {
    final isFav = favoriteIds.contains(scholarship.id);
    if (isFav) {
      favoriteIds.remove(scholarship.id);
    } else {
      favoriteIds.add(scholarship.id);
    }

    if (isFav) {
      await savedRepo.unsaveByFirestoreId(scholarship.id);
    } else {
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
      await savedRepo.save(SavedScholarshipModel(scholarshipId: sqliteId));
    }
    SavedScholarshipScreen.refreshNotifier.value++;
    ProfileScreen.refreshNotifier.value++;
    DiscoverScreen.refreshNotifier.value++;
  }

  Future<void> openScholarshipDetail(FirestoreScholarship scholarship) async {
    await Get.toNamed(
      AppRoutes.scholarshipDetailScreen,
      arguments: scholarship,
    );
    await loadFavorites();
  }

  Future<void> openSearchFilter() async {
    final result = await Get.toNamed(AppRoutes.searchFilterScreen);

    if (result is String && result.isNotEmpty) {
      Get.toNamed(
        AppRoutes.searchResultScreen,
        arguments: {'searchQuery': result},
      );
    } else if (result is Map) {
      Get.toNamed(
        AppRoutes.searchResultScreen,
        arguments: {
          'filterCountry': result['country'] as String?,
          'filterType': result['type'] as String?,
        },
      );
    }
  }
}
