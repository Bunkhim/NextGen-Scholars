// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';

import 'package:get/get.dart';
import 'package:scholarship_app/controllers/main_app/filter_result_controller.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/controllers/main_app/discover_controller.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/core/api/services/users_api_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class FilterResultScreen extends StatelessWidget {
  const FilterResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FilterResultController());
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      body: SafeArea(
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App Bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: WallpaperService().hasTheme
                          ? WallpaperService().onThemeColor
                          : colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      t.translate('filterResultTitle'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: WallpaperService().hasTheme
                            ? WallpaperService().onThemeColor
                            : colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ── Active Filter Chips ───────────────────────────────────────
            if (controller.activeFilterKeys.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.activeFilterKeys.map((filterKey) {
                    return _FilterChip(
                      label: filterKey,
                      onRemove: () => controller.removeFilter(filterKey),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 16),

            // ── Divider + Count ───────────────────────────────────────────
            Divider(height: 1, color: colorScheme.outline),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                '${t.translate('filterResultFoundCount')} ${controller.filteredResults.length} ${t.translate('filterResultScholarships')}',
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Divider(height: 1, color: colorScheme.outline),

            // ── Results ───────────────────────────────────────────────────
            Expanded(
              child: controller.isLoading.value
                  ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
                  : controller.hasError.value
                      ? _ErrorState(onRetry: () => controller.fetchResults())
                      : controller.filteredResults.isEmpty
                          ? _EmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: controller.filteredResults.length,
                              itemBuilder: (_, i) {
                                final scholarship = controller.filteredResults[i];
                                final discoverCtrl = Get.find<DiscoverController>();
                                scholarship.isFavorite = discoverCtrl.favoriteIds.contains(scholarship.id);
                                return ScholarshipCard(
                                  scholarship: scholarship,
                                  onFavoriteToggle: () async {
                                    final savedRepo = SavedScholarshipRepository();
                                    final scholarshipRepo = ScholarshipRepository();
                                    final usersApi = UsersApiService();
                                    final isFav = discoverCtrl.favoriteIds.contains(scholarship.id);
                                    if (isFav) {
                                      discoverCtrl.favoriteIds.remove(scholarship.id);
                                      await savedRepo.unsaveByFirestoreId(scholarship.id);
                                      await usersApi.unsaveScholarship(scholarship.id);
                                    } else {
                                      discoverCtrl.favoriteIds.add(scholarship.id);
                                      final sqliteId = await scholarshipRepo.upsertByFirestoreId(
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
                                      await usersApi.saveScholarship(scholarship.id);
                                    }
                                    SavedScholarshipScreen.refreshNotifier.value++;
                                    ProfileScreen.refreshNotifier.value++;
                                    DiscoverScreen.refreshNotifier.value++;
                                  },
                                  onTap: () {
                                    Get.toNamed(
                                      AppRoutes.scholarshipDetailScreen,
                                      arguments: scholarship,
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        )),
      ),
    );
  }
}

// ── Filter Chip Widget ────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary,
          width: 1.5,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 72, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            t.translate('filterResultNoResults'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.translate('filterResultTryAdjusting'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.primary),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: Text(
              t.translate('filterResultNewSearch'),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error State ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

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
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(t.translate('savedRetry')),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(color: colorScheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
