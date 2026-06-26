// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/discover_screen/discover_screen_view.dart';
import 'package:scholarship_app/screens/main_app/profile_screen/profile_screen_view.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen/saved_scholarship_screen_view.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

part 'search_result_screen_controller.dart';
part 'search_result_screen_binding.dart';

class SearchResultScreenView extends GetView<SearchResultScreenViewController> {
  const SearchResultScreenView({super.key});

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
            onPressed: () => Get.back(),
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
        stream: controller.scholarshipsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colorScheme.primary));
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

          final scholarships = controller.applyFilters(allScholarships);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(context, colorScheme, t),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                if (scholarships.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: colorScheme.outline),
                          const SizedBox(height: 16),
                          Text(
                            t.translate('discoverNoResults'),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => controller.openSearchFilter(context),
                            icon: const Icon(Icons.search, size: 18),
                            label: Text(t.translate('searchNewSearch')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colorScheme.primary,
                              side: BorderSide(color: colorScheme.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      scholarship.isFavorite = controller.favoriteIds.contains(scholarship.id);
                      return ScholarshipCard(
                        scholarship: scholarship,
                        onFavoriteToggle: () => controller.toggleFavorite(scholarship, context),
                        onTap: () {
                          Get.toNamed(
                            Routes.scholarshipDetail,
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

  Widget _buildSearchBar(BuildContext context, ColorScheme colorScheme, AppLocalizations t) {
    final hasQuery = controller.searchQuery.isNotEmpty;
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
                  onTap: () => controller.openSearchFilter(context),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasQuery ? colorScheme.primary : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search,
                            color: hasQuery ? colorScheme.primary : colorScheme.onSurfaceVariant,
                            size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            hasQuery ? controller.searchQuery.value : t.translate('homeSearchHint'),
                            style: TextStyle(
                              color: hasQuery ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                              fontSize: 14,
                              fontWeight: hasQuery ? FontWeight.w500 : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasQuery)
                          GestureDetector(
                            onTap: controller.clearSearch,
                            child: Icon(Icons.close, size: 18, color: colorScheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => controller.openSearchFilter(context),
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8, offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(Icons.tune_rounded, color: colorScheme.onPrimary, size: 22),
                      ),
                      if (controller.hasActiveFilter)
                        Positioned(
                          top: 8, right: 8,
                          child: Container(
                            width: 8, height: 8,
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
                      label: Text(controller.filterCountry.value!, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => controller.filterCountry.value = null,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                if (controller.filterType.value != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(controller.filterType.value!, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => controller.filterType.value = null,
                      visualDensity: VisualDensity.compact,
                      backgroundColor: colorScheme.primaryContainer,
                      labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                TextButton(
                  onPressed: controller.clearFilters,
                  style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
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
