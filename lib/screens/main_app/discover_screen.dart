// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/services/notification_service.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  /// Increment this from anywhere to trigger a reload of the favorites list.
  static final ValueNotifier<int> refreshNotifier = ValueNotifier(0);

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  static const int _maxSearchLength = 100;

  final ScholarshipService _scholarshipService = ScholarshipService();
  final ScholarshipRepository _scholarshipRepo = ScholarshipRepository();
  final SavedScholarshipRepository _savedRepo = SavedScholarshipRepository();

  late final Stream<List<FirestoreScholarship>> _scholarshipsStream;

  String selectedCategory = 'All';
  int _selectedCategoryIndex = 0; // 0 = All
  String _searchQuery = '';
  String? _searchError;
  String? _filterCountry;
  String? _filterType;
  final TextEditingController _searchController = TextEditingController();

  // Track favorites locally (loaded from SQLite on init)
  final Set<String> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    // Cache the stream so reassignment of setState never restarts the subscription.
    _scholarshipsStream = _scholarshipService.streamActiveScholarships();
    _loadSavedIds();
    // Reload favorites when other screens save/unsave a scholarship.
    DiscoverScreen.refreshNotifier.addListener(_loadSavedIds);
  }

  Future<void> _loadSavedIds() async {
    final ids = await _savedRepo.getSavedFirestoreIds();
    if (mounted) {
      setState(() {
        _favoriteIds.clear();
        _favoriteIds.addAll(ids);
      });
    }
  }

  void _showSaveMessage(String message, {bool isSaved = true}) {
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSaved ? Colors.green.shade600 : Colors.orange.shade600,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) overlayEntry.remove();
    });
  }

  /// Sync Firestore data → SQLite (full upsert) so the saved screen always
  /// shows fresh, complete data including image, degree, openDate, etc.
  String? _lastSyncHash;

  String _computeSyncHash(List<FirestoreScholarship> active) {
    if (active.isEmpty) return '';
    // Include every field that an admin can edit so any change triggers a sync.
    return active
        .map((s) => [
              s.id,
              s.deadline.millisecondsSinceEpoch,
              s.titleEn,
              s.titleKm,
              s.imageUrl,
              s.logoUrl,
              s.university,
              s.country,
              s.fundingType,
              s.degree,
              s.fieldOfStudy,
              s.numberOfPlaces,
              s.openDate?.millisecondsSinceEpoch ?? 0,
              s.descriptionEn,
              s.eligibilityEn,
              s.benefitsEn,
              s.requiredDocumentsEn,
              s.applicationLink,
              s.isActive,
            ].join(':'))
        .join('|');
  }

  Future<void> _syncToSQLite(List<FirestoreScholarship> active) async {
    final hash = _computeSyncHash(active);
    if (_lastSyncHash == hash) return;
    _lastSyncHash = hash;

    // Upsert all active scholarships with complete data.
    for (final s in active) {
      await _scholarshipRepo.upsertByFirestoreId(
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
    }

    // Mark any locally-cached scholarships not in the active list as inactive.
    final ids = active.map((s) => s.id).toList();
    await _scholarshipRepo.syncActiveStatus(ids);

    // Notify saved screen to reload with fresh data.
    SavedScholarshipScreen.refreshNotifier.value++;
  }

  bool get _hasActiveFilter => _filterCountry != null || _filterType != null;

  void _clearFilters() {
    setState(() {
      _filterCountry = null;
      _filterType = null;
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
        _searchController.text = result;
        _searchError = null;
      });
    } else if (result is Map) {
      setState(() {
        _filterCountry = result['country'] as String?;
        _filterType = result['type'] as String?;
      });
    }
  }

  List<String> _getCategories(AppLocalizations t) => [
        t.translate('discoverCategoryAll'),
        t.translate('discoverCategoryTechnology'),
        t.translate('discoverCategoryScience'),
        t.translate('discoverCategoryBusiness'),
        t.translate('discoverCategoryArt'),
      ];

  @override
  void dispose() {
    DiscoverScreen.refreshNotifier.removeListener(_loadSavedIds);
    _searchController.dispose();
    super.dispose();
  }

  String _sanitizeInput(String input) {
    var sanitized = input.trim();
    // Remove XSS dangerous characters: < > " ' / \ ;
    sanitized = sanitized.replaceAll(RegExp('[<>"\'\\\\;/]'), '');
    // Limit to max length
    if (sanitized.length > _maxSearchLength) {
      sanitized = sanitized.substring(0, _maxSearchLength);
    }
    return sanitized;
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
          automaticallyImplyLeading: false,
          leading: Navigator.canPop(context)
              ? IconButton(
                  icon: Icon(Icons.arrow_back_ios,
                      color: WallpaperService().hasTheme
                          ? WallpaperService().onThemeColor
                          : colorScheme.onSurface,
                      size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          titleSpacing: Navigator.canPop(context) ? 0 : 20,
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
          title: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      WallpaperService().themedPrimary(colorScheme),
                      WallpaperService()
                          .themedPrimary(colorScheme)
                          .withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: WallpaperService()
                          .themedPrimary(colorScheme)
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/nextgen_logo.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.translate('discoverTitle'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: WallpaperService().hasTheme
                            ? WallpaperService().onThemeColor
                            : colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      t.translate('discoverSubtitle'),
                      style: TextStyle(
                        fontSize: 12,
                        color: WallpaperService().hasTheme
                            ? WallpaperService().onThemeColor.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.notificationScreen),
              child: StreamBuilder<int>(
                stream: NotificationService().streamUnreadCount(),
                builder: (context, snap) {
                  final notificationCount = snap.data ?? 0;
                  final ws = WallpaperService();
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: ws.hasTheme
                              ? Colors.white.withOpacity(0.15)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: ws.hasTheme
                                ? Colors.white.withOpacity(0.2)
                                : colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: ws.hasTheme
                              ? ws.onThemeColor
                              : colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                      if (notificationCount > 0)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
      body: StreamBuilder<List<FirestoreScholarship>>(
        stream: _scholarshipsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                      t.translate('discoverLoadFailedTitle'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.translate('discoverLoadFailedSubtitle'),
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final allScholarships = snapshot.data ?? [];

          // Sync Firestore active list → SQLite so the saved screen hides
          // scholarships that the admin has deactivated and shows fresh data.
          _syncToSQLite(allScholarships);

          // Map category index → fieldOfStudy keyword (null = All)
          const categoryKeywords = <String?>[
            null, // 0: All
            'technology', // 1: Technology
            'science', // 2: Science
            'business', // 3: Business
            'art', // 4: Art
          ];
          final catKeyword = (_selectedCategoryIndex > 0 &&
                  _selectedCategoryIndex < categoryKeywords.length)
              ? categoryKeywords[_selectedCategoryIndex]
              : null;

          // Apply search + filter
          final scholarships = allScholarships.where((s) {
            final q = _searchQuery.toLowerCase();
            final matchesSearch = _searchQuery.isEmpty ||
                s.titleEn.toLowerCase().contains(q) ||
                s.titleKm.contains(_searchQuery) ||
                s.university.toLowerCase().contains(q) ||
                s.country.toLowerCase().contains(q) ||
                s.fieldOfStudy.toLowerCase().contains(q) ||
                s.fundingType.toLowerCase().contains(q) ||
                s.degree.toLowerCase().contains(q);
            final matchesCountry = _filterCountry == null ||
                s.country.toLowerCase().contains(_filterCountry!.toLowerCase());
            final matchesType = _filterType == null ||
                s.fundingType
                    .toLowerCase()
                    .contains(_filterType!.toLowerCase());
            final matchesCategory = catKeyword == null ||
                s.fieldOfStudy.toLowerCase().contains(catKeyword);
            return matchesSearch &&
                matchesCountry &&
                matchesType &&
                matchesCategory;
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Search Bar
                _buildSearchBar(context, colorScheme, t),

                // Categories
                _buildCategories(context, colorScheme, t),

                // Scholarships List Header
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
                            color:
                                WallpaperService().themedOnSurface(colorScheme),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: WallpaperService()
                              .themedPrimary(colorScheme)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${scholarships.length} ${t.translate('discoverFoundCount')}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                WallpaperService().themedPrimary(colorScheme),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scholarships List or Empty State
                if (scholarships.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(
                          t.translate('discoverNoScholarshipsFound'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
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
                          // Notify saved screen to reload immediately.
                          SavedScholarshipScreen.refreshNotifier.value++;
                          ProfileScreen.refreshNotifier.value++;
                          // Show feedback message
                          if (mounted) {
                            final t = AppLocalizations.of(context);
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
                          ).then((_) => _loadSavedIds());
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

  Widget _buildSearchBar(
      BuildContext context, ColorScheme colorScheme, AppLocalizations t) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Container(
      decoration: themed
          ? ws.glassSection()
          : BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.onSurface.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: themed
                      ? ws.glassInput(radius: 12)
                      : BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _searchError != null
                                ? Colors.red.shade400
                                : colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                  child: TextField(
                    controller: _searchController,
                    maxLength: _maxSearchLength,
                    style: TextStyle(
                        color:
                            themed ? ws.onThemeColor : colorScheme.onSurface),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      final sanitized = _sanitizeInput(value);
                      setState(() {
                        _searchQuery = sanitized;
                      });
                    },
                    onChanged: (value) {
                      final sanitized = _sanitizeInput(value);
                      if (sanitized != value) {
                        _searchController.text = sanitized;
                        _searchController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: sanitized.length),
                        );
                      }
                      setState(() {
                        _searchQuery = sanitized;
                        _searchError = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: t.translate('discoverSearchHint'),
                      hintStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: _searchError != null
                            ? Colors.red
                            : ws.themedPrimary(colorScheme),
                        size: 22,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  size: 18, color: colorScheme.outline),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _searchError = null;
                                });
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      counterText: '', // Hide character counter
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ws.themedPrimary(colorScheme),
                      ws.themedPrimary(colorScheme).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: ws.themedPrimary(colorScheme).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.tune,
                          color: colorScheme.onPrimary, size: 22),
                      onPressed: _openSearchFilter,
                    ),
                    if (_hasActiveFilter)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5722),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_searchError != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _searchError!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          if (_hasActiveFilter) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_filterCountry != null)
                    _buildFilterChip(
                      label: _filterCountry!,
                      icon: Icons.location_on_outlined,
                      colorScheme: colorScheme,
                      onRemove: () => setState(() => _filterCountry = null),
                    ),
                  if (_filterType != null) ...[
                    if (_filterCountry != null) const SizedBox(width: 8),
                    _buildFilterChip(
                      label: _filterType!,
                      icon: Icons.card_giftcard_outlined,
                      colorScheme: colorScheme,
                      onRemove: () => setState(() => _filterType = null),
                    ),
                  ],
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _clearFilters,
                    child: Text(
                      t.translate('discoverClearFilters'),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required VoidCallback onRemove,
  }) {
    final ws = WallpaperService();
    final chipColor = ws.themedPrimary(colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipColor.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 13, color: chipColor),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(
      BuildContext context, ColorScheme colorScheme, AppLocalizations t) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Container(
      color: themed ? null : colorScheme.surface,
      decoration: themed ? ws.glassSection() : null,
      padding: const EdgeInsets.only(top: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    t.translate('discoverCategoriesTitle'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ws.themedOnSurface(colorScheme),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.searchFilterScreen),
                  child: Row(
                    children: [
                      Text(
                        t.translate('discoverCategoriesSeeAll'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ws.themedPrimary(colorScheme),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: ws.themedPrimary(colorScheme),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _getCategories(t).map((category) {
                final catIndex = _getCategories(t).indexOf(category);
                final isSelected = catIndex == _selectedCategoryIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category;
                        _selectedCategoryIndex = catIndex;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  ws.themedPrimary(colorScheme),
                                  ws
                                      .themedPrimary(colorScheme)
                                      .withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected
                            ? null
                            : themed
                                ? (ws.currentThemeData?.accentColor != null
                                    ? Color.lerp(
                                        ws.currentThemeData!.accentColor!,
                                        Colors.white,
                                        ws.isThemeDark ? 0.78 : 0.85,
                                      )!
                                        .withOpacity(
                                            ws.isThemeDark ? 0.35 : 0.60)
                                    : (ws.isThemeDark
                                        ? Colors.white.withOpacity(0.10)
                                        : Colors.white.withOpacity(0.45)))
                                : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected
                              ? ws.themedPrimary(colorScheme)
                              : themed
                                  ? ws.glassBorder
                                  : colorScheme.outlineVariant,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: ws
                                      .themedPrimary(colorScheme)
                                      .withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : ws.themedOnSurface(colorScheme),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
