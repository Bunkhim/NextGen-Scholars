// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/data/models/saved_scholarship_model.dart';
import 'package:scholarship_app/data/models/scholarship_model.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/controllers/main_app/discover_controller.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/services/notification_service.dart';
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
  late final DiscoverController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DiscoverController());
    controller.refreshSavedIds();
    DiscoverScreen.refreshNotifier.addListener(_onRefreshNotifier);
  }

  void _onRefreshNotifier() {
    controller.refreshSavedIds();
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

  bool get _hasActiveFilter => controller.hasActiveFilter;

  void _clearFilters() => controller.clearFilters();

  Future<void> _openSearchFilter() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.searchFilterScreen,
    );
    if (!mounted) return;
    if (result is String && result.isNotEmpty) {
      controller.updateSearchQuery(result);
    } else if (result is Map) {
      controller.setFilterCountry(result['country'] as String?);
      controller.setFilterType(result['type'] as String?);
    }
  }

  List<String> _getCategories(AppLocalizations t) => controller.getCategories(t);

  @override
  void dispose() {
    DiscoverScreen.refreshNotifier.removeListener(_onRefreshNotifier);
    if (Get.isRegistered<DiscoverController>()) {
      Get.delete<DiscoverController>();
    }
    super.dispose();
  }

  String _sanitizeInput(String input) => controller.sanitizeInput(input);

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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
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

        final allScholarships = controller.scholarshipsList;

        // Sync API list → SQLite so the saved screen shows fresh data.
        controller.syncToSQLite(allScholarships);

        // Map category index → fieldOfStudy keyword (null = All)
        const categoryKeywords = <String?>[
          null, // 0: All
          'technology', // 1: Technology
          'science', // 2: Science
          'business', // 3: Business
          'art', // 4: Art
        ];
        
        final catKeyword = (controller.selectedCategoryIndex.value > 0 &&
                controller.selectedCategoryIndex.value <
                    categoryKeywords.length)
            ? categoryKeywords[controller.selectedCategoryIndex.value]
            : null;

        // Apply search + filter
        final scholarships = allScholarships.where((s) {
          final q = controller.searchQuery.value.toLowerCase();
          final matchesSearch = controller.searchQuery.value.isEmpty ||
              s.titleEn.toLowerCase().contains(q) ||
              s.titleKm.contains(controller.searchQuery.value) ||
              s.university.toLowerCase().contains(q) ||
              s.country.toLowerCase().contains(q) ||
              s.fieldOfStudy.toLowerCase().contains(q) ||
              s.fundingType.toLowerCase().contains(q) ||
              s.degree.toLowerCase().contains(q);
          final matchesCountry = controller.filterCountry.value == null ||
              s.country.toLowerCase().contains(
                  controller.filterCountry.value!.toLowerCase());
          final matchesType = controller.filterType.value == null ||
              s.fundingType
                  .toLowerCase()
                  .contains(controller.filterType.value!.toLowerCase());
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
                        controller.favoriteIds.contains(scholarship.id);
                    return ScholarshipCard(
                      scholarship: scholarship,
                      onFavoriteToggle: () async {
                        final isFav =
                            controller.favoriteIds.contains(scholarship.id);
                        if (isFav) {
                          controller.favoriteIds.remove(scholarship.id);
                        } else {
                          controller.favoriteIds.add(scholarship.id);
                        }
                        if (isFav) {
                          await controller.savedRepository
                              .unsaveByFirestoreId(scholarship.id);
                        } else {
                          final sqliteId =
                              await controller.scholarshipRepository
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
                          await controller.savedRepository.save(
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
                        ).then((_) => controller.refreshSavedIds());
                      },
                    );
                  },
                ),
            ],
          ),
        );
      }),
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
                            color: controller.searchError.value != null
                                ? Colors.red.shade400
                                : colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                  child: TextField(
                    controller: controller.searchController,
                    maxLength: DiscoverController.maxSearchLength,
                    style: TextStyle(
                        color:
                            themed ? ws.onThemeColor : colorScheme.onSurface),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      final sanitized = _sanitizeInput(value);
                      controller.updateSearchQuery(sanitized);
                    },
                    onChanged: (value) {
                      final sanitized = _sanitizeInput(value);
                      if (sanitized != value) {
                        controller.searchController.text = sanitized;
                        controller.searchController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: sanitized.length),
                        );
                      }
                      controller.updateSearchQuery(sanitized);
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
                        color: controller.searchError.value != null
                            ? Colors.red
                            : ws.themedPrimary(colorScheme),
                        size: 22,
                      ),
                      suffixIcon: controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  size: 18, color: colorScheme.outline),
                              onPressed: () {
                                controller.clearSearch();
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
          if (controller.searchError.value != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                controller.searchError.value!,
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
                  if (controller.filterCountry.value != null)
                    _buildFilterChip(
                      label: controller.filterCountry.value!,
                      icon: Icons.location_on_outlined,
                      colorScheme: colorScheme,
                      onRemove: () => controller.setFilterCountry(null),
                    ),
                  if (controller.filterType.value != null) ...[
                    if (controller.filterCountry.value != null)
                      const SizedBox(width: 8),
                    _buildFilterChip(
                      label: controller.filterType.value!,
                      icon: Icons.card_giftcard_outlined,
                      colorScheme: colorScheme,
                      onRemove: () => controller.setFilterType(null),
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
                final isSelected = catIndex == controller.selectedCategoryIndex.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => controller.selectCategory(catIndex, t),
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
