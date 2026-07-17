// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

import 'package:get/get.dart';
import 'package:scholarship_app/controllers/main_app/search_result_controller.dart';

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
  late final SearchResultController controller;

  Future<void> _openSearchFilter() async {
    final result = await Get.toNamed(AppRoutes.searchFilterScreen);
    if (result is String && result.isNotEmpty) {
      controller.updateFilters(query: result);
    } else if (result is Map) {
      controller.updateFilters(
        country: result['country'] as String?,
        type: result['type'] as String?,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final tag = '${widget.searchQuery}_${widget.filterCountry}_${widget.filterType}';
    controller = Get.put(
      SearchResultController(
        query: widget.searchQuery,
        country: widget.filterCountry,
        type: widget.filterType,
      ),
      tag: tag,
    );
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
              : Colors.blue,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: WallpaperService().hasTheme
                    ? WallpaperService().onThemeColor
                    : Colors.white,
                size: 20),
            onPressed: () => Get.back(),
          ),
          titleSpacing: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: WallpaperService().hasTheme
                  ? WallpaperService().appBarColor
                  : Colors.blue,
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
              color: WallpaperService().hasTheme
                  ? WallpaperService().onThemeColor
                  : Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: colorScheme.primary));
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

        // Apply search + filter
        final scholarships = controller.filteredScholarships;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Search Bar Section ──────────────────────────────────
                _buildSearchBar(colorScheme, t, controller),

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
                            onPressed: () => _openSearchFilter(),
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
                      return Obx(() {
                        scholarship.isFavorite =
                            controller.favoriteIds.contains(scholarship.id);
                        return ScholarshipCard(
                          scholarship: scholarship,
                          onFavoriteToggle: () async {
                            await controller.toggleFavorite(scholarship);
                          },
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.scholarshipDetailScreen,
                              arguments: scholarship,
                            );
                          },
                        );
                      });
                    },
                  ),
              ],
            ),
          );
      }),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme, AppLocalizations t, SearchResultController controller) {
    final hasQuery = controller.searchQuery.value.isNotEmpty;
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
                  onTap: () => _openSearchFilter(),
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
                                ? controller.searchQuery.value
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
                            onTap: controller.clearSearch,
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
                onTap: () => _openSearchFilter(),
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
                      if (controller.hasActiveFilter)
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
          if (controller.hasActiveFilter) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (controller.filterCountry.value != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(controller.filterCountry.value!,
                          style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => controller.filterCountry.value = null,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle:
                          TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                if (controller.filterType.value != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(controller.filterType.value!,
                          style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => controller.filterType.value = null,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle:
                          TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                TextButton(
                  onPressed: controller.clearFilters,
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
