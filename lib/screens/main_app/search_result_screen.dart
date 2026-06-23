// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

/// A dedicated screen that shows search / filter results exactly like
/// DiscoverScreen — with real Firestore data, favorite toggling, etc.
class SearchResultScreen extends StatefulWidget {
  final String searchQuery;
  final String? filterCountry;
  final String? filterType;

  const SearchResultScreen({
    super.key,
    this.searchQuery = '',
    this.filterCountry,
    this.filterType,
  });

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final ScholarshipService _scholarshipService = ScholarshipService();
  final ScholarshipRepository _scholarshipRepo = ScholarshipRepository();
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();

  late final Stream<List<FirestoreScholarship>> _scholarshipsStream;
  late String _searchQuery;
  String? _filterCountry;
  String? _filterType;

  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.searchQuery;
    _filterCountry = widget.filterCountry;
    _filterType = widget.filterType;
    _scholarshipsStream = _scholarshipService.streamActiveScholarships();
    _loadSavedIds();
  }

  Future<void> _loadSavedIds() async {
    final ids = await _savedRepo.getSavedFirestoreIds();
    if (mounted) setState(() => _favoriteIds.addAll(ids));
  }

  bool get _hasActiveFilter => _filterCountry != null || _filterType != null;

  void _clearFilters() {
    setState(() {
      _filterCountry = null;
      _filterType = null;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
    });
  }

  Future<void> _openSearchFilter() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.searchFilterScreen,
    );
    if (!mounted) return;
    if (result is String && result.isNotEmpty) {
      setState(() {
        _searchQuery = result;
      });
    } else if (result is Map) {
      setState(() {
        _filterCountry = result['country'] as String?;
        _filterType = result['type'] as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: WallpaperService().hasAny
          ? Colors.transparent
          : colorScheme.surfaceContainerHighest,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: WallpaperService().hasTheme
              ? WallpaperService().appBarColor
              : colorScheme.surface,
          surfaceTintColor: WallpaperService().hasTheme
              ? Colors.transparent
              : colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: WallpaperService().hasTheme
                    ? WallpaperService().onThemeColor
                    : colorScheme.onSurface,
                size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: WallpaperService().hasTheme
                  ? WallpaperService().appBarColor
                  : colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          title: Text(
            t.translate('searchResultTitle'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<FirestoreScholarship>>(
        stream: _scholarshipsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: colorScheme.primary));
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: colorScheme.outline),
                    const SizedBox(height: 16),
                    Text(
                      t.translate('discoverError'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final allScholarships = snapshot.data ?? [];

          // Apply search + filter
          final scholarships = allScholarships.where((s) {
            final q = _searchQuery.toLowerCase();
            final matchesSearch = _searchQuery.isEmpty ||
                s.titleEn.toLowerCase().contains(q) ||
                s.titleKm.contains(_searchQuery) ||
                s.university.toLowerCase().contains(q) ||
                s.country.toLowerCase().contains(q) ||
                s.fieldOfStudy.toLowerCase().contains(q);
            final matchesCountry = _filterCountry == null ||
                s.country.toLowerCase().contains(_filterCountry!.toLowerCase());
            final matchesType = _filterType == null ||
                s.fundingType
                    .toLowerCase()
                    .contains(_filterType!.toLowerCase());
            return matchesSearch && matchesCountry && matchesType;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar Section ──────────────────────────────────
                _buildSearchBar(colorScheme, t),

                // ── Results Header ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          t.translate('discoverAvailableTitle'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${scholarships.length} ${t.translate('discoverFoundCount')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Scholarship List or Empty State ─────────────────────
                if (scholarships.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            t.translate('discoverNoResults'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _openSearchFilter,
                            icon: const Icon(Icons.search, size: 18),
                            label: Text(t.translate('searchNewSearch')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: scholarships.length,
                    itemBuilder: (context, index) {
                      final scholarship = scholarships[index];
                      scholarship.isFavorite =
                          _favoriteIds.contains(scholarship.id);
                      return ScholarshipCard(
                        scholarship: scholarship,
                        onFavoriteToggle: () async {
                          final isFav = _favoriteIds.contains(scholarship.id);
                          setState(() {
                            if (isFav) {
                              _favoriteIds.remove(scholarship.id);
                            } else {
                              _favoriteIds.add(scholarship.id);
                            }
                          });
                          if (isFav) {
                            await _savedRepo
                                .unsaveByFirestoreId(scholarship.id);
                          } else {
                            final sqliteId =
                                await _scholarshipRepo.upsertByFirestoreId(
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
                                requiredDocuments:
                                    scholarship.requiredDocumentsEn,
                                requiredDocumentsKm:
                                    scholarship.requiredDocumentsKm,
                                isActive: true,
                              ),
                            );
                            await _savedRepo.save(
                                SavedScholarshipModel(scholarshipId: sqliteId));
                          }
                          SavedScholarshipScreen.refreshNotifier.value++;
                          ProfileScreen.refreshNotifier.value++;
                          DiscoverScreen.refreshNotifier.value++;
                        },
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.scholarshipDetailScreen,
                            arguments: scholarship,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, AppLocalizations t) {
    final hasQuery = _searchQuery.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _openSearchFilter,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasQuery
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: hasQuery
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasQuery
                                ? _searchQuery
                                : t.translate('homeSearchHint'),
                            style: TextStyle(
                              color: hasQuery
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                              fontSize: 14,
                              fontWeight:
                                  hasQuery ? FontWeight.w500 : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasQuery)
                          GestureDetector(
                            onTap: _clearSearch,
                            child: Icon(Icons.close,
                                size: 18, color: colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _openSearchFilter,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(Icons.tune_rounded,
                            color: colorScheme.onPrimary, size: 22),
                      ),
                      if (_hasActiveFilter)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF5252),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_hasActiveFilter) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (_filterCountry != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(_filterCountry!,
                          style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _filterCountry = null),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle:
                          TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                if (_filterType != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(_filterType!,
                          style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _filterType = null),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle:
                          TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                TextButton(
                  onPressed: _clearFilters,
                  style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8)),
                  child: Text(t.translate('discoverClearFilters'),
                      style: TextStyle(fontSize: 12, color: colorScheme.error)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
