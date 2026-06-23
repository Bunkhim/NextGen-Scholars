// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/main_navigation_screen.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

class SavedScholarshipScreen extends StatefulWidget {
  const SavedScholarshipScreen({super.key});

  /// Increment this from anywhere to trigger a live reload of the saved list.
  static final ValueNotifier<int> refreshNotifier = ValueNotifier(0);

  @override
  State<SavedScholarshipScreen> createState() => _SavedScholarshipScreenState();
}

class _SavedScholarshipScreenState extends State<SavedScholarshipScreen> {
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();
  final ScholarshipService _scholarshipService = ScholarshipService();
  StreamSubscription<List<FirestoreScholarship>>? _firestoreSub;
  List<_SavedScholarshipView> _scholarships = [];
  bool _isLoading = true;
  String? _loadError;

  void _goToExploreScholarships() {
    MainNavigationScreen.tabNotifier.value = 1;
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == AppRoutes.homeScreen) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.homeScreen,
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSavedScholarships();
    // Reload whenever discover screen saves or unsaves a scholarship.
    SavedScholarshipScreen.refreshNotifier.addListener(_loadSavedScholarships);
    // Subscribe to Firestore so any admin edit is reflected immediately.
    _firestoreSub = _scholarshipService
        .streamActiveScholarships()
        .listen(_onFirestoreUpdate);
  }

  @override
  void dispose() {
    SavedScholarshipScreen.refreshNotifier
        .removeListener(_loadSavedScholarships);
    _firestoreSub?.cancel();
    super.dispose();
  }

  /// Called whenever Firestore emits a new scholarship list.
  /// Updates only the items that are already saved without reloading from SQLite.
  void _onFirestoreUpdate(List<FirestoreScholarship> latest) {
    if (!mounted || _scholarships.isEmpty) return;
    final map = {for (final s in latest) s.id: s};
    bool changed = false;

    final updated = _scholarships.map((view) {
      final fresh = map[view.scholarship.id];
      if (fresh == null) {
        // Admin deactivated / deleted — hide it.
        if (view.isVisible) {
          changed = true;
          return view..isVisible = false;
        }
        return view;
      }
      // Replace with fresh Firestore data while keeping savedId.
      changed = true;
      return _SavedScholarshipView(
        savedId: view.savedId,
        scholarship: fresh..isFavorite = true,
      );
    }).toList();

    if (changed && mounted) setState(() => _scholarships = updated);
  }

  Future<void> _loadSavedScholarships() async {
    try {
      final savedWithDetails = await _savedRepo.getSavedWithDetails();
      if (mounted) {
        setState(() {
          _scholarships = savedWithDetails.map((row) {
            final deadlineStr = row['deadline'] as String?;
            final openDateStr = row['open_date'] as String?;
            return _SavedScholarshipView(
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
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  void _removeItem(int savedId) {
    final index = _scholarships.indexWhere((s) => s.savedId == savedId);
    if (index == -1) return;
    final scholarship = _scholarships[index];
    setState(() {
      scholarship.isVisible = false;
    });

    // Soft-hide in DB.
    _savedRepo.hide(savedId);
    ProfileScreen.refreshNotifier.value++;
    DiscoverScreen.refreshNotifier.value++;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('savedRemoved')),
        action: SnackBarAction(
          label: AppLocalizations.of(context).translate('savedUndo'),
          onPressed: () {
            setState(() {
              scholarship.isVisible = true;
            });
            // Restore in DB.
            _savedRepo.restore(savedId);
            ProfileScreen.refreshNotifier.value++;
            DiscoverScreen.refreshNotifier.value++;
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _sortScholarships(String sortType) {
    setState(() {
      if (sortType == 'deadline') {
        _scholarships.sort(
            (a, b) => a.scholarship.deadline.compareTo(b.scholarship.deadline));
      } else if (sortType == 'name') {
        _scholarships.sort(
            (a, b) => a.scholarship.titleEn.compareTo(b.scholarship.titleEn));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final visibleScholarships =
        _scholarships.where((s) => s.isVisible).toList();
    final savedCount = visibleScholarships.length;

    return Scaffold(
      backgroundColor: WallpaperService().hasAny
          ? Colors.transparent
          : colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WallpaperService().hasTheme
            ? WallpaperService().appBarColor
            : colorScheme.surface,
        surfaceTintColor: WallpaperService().hasTheme
            ? Colors.transparent
            : colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: WallpaperService().hasTheme
                  ? WallpaperService().onThemeColor
                  : colorScheme.onSurface,
              size: 20),
          onPressed: () {
            // Switch back to Home tab (index 0) in BottomNavigationBar
            MainNavigationScreen.tabNotifier.value = 0;
          },
        ),
        title: Text(
          t.translate('savedTitle'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: WallpaperService().hasTheme
                ? WallpaperService().onThemeColor
                : colorScheme.onSurface,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort,
                color: WallpaperService().hasTheme
                    ? WallpaperService().onThemeColor
                    : colorScheme.onSurface),
            onSelected: _sortScholarships,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'deadline',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18),
                    SizedBox(width: 12),
                    Text(t.translate('savedSortByDeadline')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha, size: 18),
                    SizedBox(width: 12),
                    Text(t.translate('savedSortByName')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildErrorState(colorScheme, t)
              : savedCount == 0
                  ? _buildEmptyState(colorScheme)
                  : Column(
                      children: [
                        _buildHeader(savedCount, colorScheme),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.only(
                              top: 8,
                              bottom:
                                  MediaQuery.of(context).padding.bottom + 85,
                            ),
                            itemCount: visibleScholarships.length,
                            itemBuilder: (context, index) {
                              return _buildScholarshipCard(
                                  visibleScholarships[index], colorScheme, t);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildHeader(int count, ColorScheme colorScheme) {
    final ws = WallpaperService();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: ws.hasTheme ? Colors.transparent : colorScheme.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ws.themedPrimary(colorScheme).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.bookmark,
                  size: 16,
                  color: ws.themedPrimary(colorScheme),
                ),
                const SizedBox(width: 6),
                Text(
                  "$count ${AppLocalizations.of(context).translate('savedCount')}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ws.themedPrimary(colorScheme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipCard(
      _SavedScholarshipView item, ColorScheme colorScheme, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ScholarshipCard(
        scholarship: item.scholarship,
        onFavoriteToggle: () => _removeItem(item.savedId),
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.scholarshipDetailScreen,
            arguments: item.scholarship,
          );
        },
      ),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme, AppLocalizations t) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            t.translate('savedLoadError'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _loadError = null;
              });
              _loadSavedScholarships();
            },
            icon: const Icon(Icons.refresh),
            label: Text(t.translate('savedRetry')),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: WallpaperService().hasTheme
                  ? Colors.white.withOpacity(0.12)
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_border,
              size: 60,
              color: WallpaperService().hasTheme
                  ? WallpaperService().onThemeColor.withOpacity(0.6)
                  : colorScheme.outline,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).translate('savedEmpty'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: WallpaperService().themedOnSurface(colorScheme),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              AppLocalizations.of(context).translate('savedEmptyMessage'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: WallpaperService().themedOnSurfaceVariant(colorScheme),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _goToExploreScholarships,
            icon: const Icon(Icons.explore),
            label: Text(
                AppLocalizations.of(context).translate('savedExploreButton')),
            style: ElevatedButton.styleFrom(
              backgroundColor: WallpaperService().themedPrimary(colorScheme),
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedScholarshipView {
  final int savedId;
  final FirestoreScholarship scholarship;
  bool isVisible = true;

  _SavedScholarshipView({
    required this.savedId,
    required this.scholarship,
  });
}
