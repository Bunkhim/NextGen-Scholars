// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/fill_information/scholarship_preference_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

class ScholarshipMatchScreen extends StatefulWidget {
  const ScholarshipMatchScreen({super.key});

  @override
  State<ScholarshipMatchScreen> createState() => _ScholarshipMatchScreenState();
}

class _ScholarshipMatchScreenState extends State<ScholarshipMatchScreen> {
  final ScholarshipService _scholarshipService = ScholarshipService();
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();
  final ScholarshipRepository _scholarshipRepo = ScholarshipRepository();
  final _appData = ApplicationData();

  final Set<String> _favoriteIds = {};
  bool _prefsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await _appData.loadFromPrefs();
    final ids = await _savedRepo.getSavedFirestoreIds();
    if (mounted) {
      setState(() {
        _favoriteIds.addAll(ids);
        _prefsLoaded = true;
      });
    }
  }

  Future<void> _reloadPrefs() async {
    await _appData.loadFromPrefs();
    if (mounted) setState(() {});
  }

  bool get _hasPreferences =>
      (_appData.destinationCountry ?? '').trim().isNotEmpty &&
      (_appData.preferredDegree ?? '').trim().isNotEmpty &&
      (_appData.preferredMajor ?? '').trim().isNotEmpty;

  /// Score a scholarship based on how well it matches user preferences.
  int _matchScore(FirestoreScholarship s) {
    int score = 0;
    final country = _appData.destinationCountry?.toLowerCase() ?? '';
    final degree = _appData.preferredDegree?.toLowerCase() ?? '';
    final major = _appData.preferredMajor?.toLowerCase() ?? '';
    final uni = _appData.preferredUniversity?.toLowerCase() ?? '';

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

  List<FirestoreScholarship> _filterAndSort(List<FirestoreScholarship> all) {
    final scored = <MapEntry<FirestoreScholarship, int>>[];
    for (final s in all) {
      final score = _matchScore(s);
      if (score > 0) scored.add(MapEntry(s, score));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  void _showSaveMessage(String message, {bool isSaved = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSaved ? Icons.bookmark_added : Icons.bookmark_remove,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: isSaved ? const Color(0xFF4ECDC4) : Colors.grey[700],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final ws = WallpaperService();

    return Scaffold(
      backgroundColor: ws.hasAny ? Colors.transparent : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: ws.hasTheme ? ws.appBarColor : colorScheme.surface,
        elevation: 0,
        surfaceTintColor:
            ws.hasTheme ? Colors.transparent : colorScheme.surface,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: ws.hasTheme ? ws.onThemeColor : colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t.translate('matchScreenTitle'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ws.hasTheme ? ws.onThemeColor : colorScheme.onSurface,
          ),
        ),
      ),
      body: !_prefsLoaded
          ? const Center(child: CircularProgressIndicator())
          : !_hasPreferences
          ? _buildNoPreferences(colorScheme, t)
          : StreamBuilder<List<FirestoreScholarship>>(
              stream: _scholarshipService.streamActiveScholarships(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snapshot.data ?? [];
                final matched = _filterAndSort(all);

                if (matched.isEmpty) {
                  return _buildNoResults(colorScheme, t);
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        t
                            .translate('matchFoundCount')
                            .replaceAll('\$count', '${matched.length}'),
                        style: TextStyle(
                          fontSize: 14,
                          color: ws.themedOnSurfaceVariant(colorScheme),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: matched.length,
                        itemBuilder: (context, index) {
                          final scholarship = matched[index];
                          scholarship.isFavorite =
                              _favoriteIds.contains(scholarship.id);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ScholarshipCard(
                              scholarship: scholarship,
                              onFavoriteToggle: () async {
                                final isFav =
                                    _favoriteIds.contains(scholarship.id);
                                if (isFav) {
                                  await _savedRepo
                                      .unsaveByFirestoreId(scholarship.id);
                                  _favoriteIds.remove(scholarship.id);
                                } else {
                                  final sqliteId = await _scholarshipRepo
                                      .upsertByFirestoreId(
                                    firestoreId: scholarship.id,
                                    scholarship: Scholarship(
                                      title: scholarship.titleEn,
                                      titleKm: scholarship.titleKm,
                                      institution: scholarship.university,
                                      country: scholarship.country,
                                      type: scholarship.fundingType,
                                      deadline: scholarship.deadline,
                                      openDate: scholarship.openDate,
                                      numberOfPlaces:
                                          scholarship.numberOfPlaces,
                                      description: scholarship.descriptionEn,
                                      descriptionKm: scholarship.descriptionKm,
                                      applicationUrl:
                                          scholarship.applicationLink,
                                      imageUrl: scholarship.imageUrl,
                                      level: scholarship.degree,
                                      fieldOfStudy: scholarship.fieldOfStudy,
                                      eligibility: scholarship.eligibilityEn,
                                      eligibilityKm: scholarship.eligibilityKm,
                                      benefits: scholarship.benefitsEn,
                                      benefitsKm: scholarship.benefitsKm,
                                      requiredDocuments:
                                          scholarship.requiredDocumentsEn,
                                      requiredDocumentsKm:
                                          scholarship.requiredDocumentsKm,
                                      isActive: true,
                                    ),
                                  );
                                  await _savedRepo.save(SavedScholarshipModel(
                                      scholarshipId: sqliteId));
                                  _favoriteIds.add(scholarship.id);
                                }
                                setState(() {
                                  scholarship.isFavorite = !isFav;
                                });
                                SavedScholarshipScreen.refreshNotifier.value++;
                                ProfileScreen.refreshNotifier.value++;
                                DiscoverScreen.refreshNotifier.value++;
                                if (mounted) {
                                  _showSaveMessage(
                                    isFav
                                        ? t.translate('savedRemoved')
                                        : t.translate('savedAdded'),
                                    isSaved: !isFav,
                                  );
                                }
                              },
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.scholarshipDetailScreen,
                                  arguments: scholarship,
                                ).then((_) => _loadAll());
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildNoPreferences(ColorScheme colorScheme, AppLocalizations t) {
    final ws = WallpaperService();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: ws.hasTheme
                    ? Colors.white.withOpacity(0.12)
                    : colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.military_tech_outlined,
                size: 50,
                color: ws.hasTheme
                    ? ws.onThemeColor.withOpacity(0.6)
                    : colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              t.translate('matchNoPreferences'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ws.themedOnSurfaceVariant(colorScheme),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ScholarshipPreferenceScreen(),
                  ),
                ).then((_) => _reloadPrefs());
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: Text(t.translate('matchFillPreferences')),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults(ColorScheme colorScheme, AppLocalizations t) {
    final ws = WallpaperService();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 60,
              color: ws.hasTheme
                  ? ws.onThemeColor.withOpacity(0.5)
                  : colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              t.translate('matchNoResults'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ws.themedOnSurfaceVariant(colorScheme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
