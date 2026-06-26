import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/discover_screen/discover_screen_view.dart';
import 'package:scholarship_app/screens/main_app/profile_screen/profile_screen_view.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen/saved_scholarship_screen_view.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

part 'scholarship_match_screen_controller.dart';
part 'scholarship_match_screen_binding.dart';

class ScholarshipMatchScreenView
    extends GetView<ScholarshipMatchScreenViewController> {
  const ScholarshipMatchScreenView({super.key});

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
          onPressed: () => Get.back(),
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
      body: Obx(() {
        if (!controller.prefsLoaded.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!controller.hasPreferences) {
          return _buildNoPreferences(colorScheme, t);
        }
        return StreamBuilder<List<FirestoreScholarship>>(
          stream: controller.scholarshipService.streamActiveScholarships(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final all = snapshot.data ?? [];
            final matched = controller.filterAndSort(all);

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
                          controller.favoriteIds.contains(scholarship.id);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ScholarshipCard(
                          scholarship: scholarship,
                          onFavoriteToggle: () async {
                            final isFav = controller.favoriteIds
                                .contains(scholarship.id);
                            if (isFav) {
                              await controller.savedRepo
                                  .unsaveByFirestoreId(scholarship.id);
                              controller.favoriteIds.remove(scholarship.id);
                            } else {
                              final sqliteId = await controller
                                  .scholarshipRepo
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
                              await controller.savedRepo.save(
                                  SavedScholarshipModel(
                                      scholarshipId: sqliteId));
                              controller.favoriteIds.add(scholarship.id);
                            }
                            scholarship.isFavorite = !isFav;
                            SavedScholarshipScreenViewController.refreshNotifier.value++;
                            ProfileScreenViewController.refreshNotifier.value++;
                            DiscoverScreenViewController.refreshNotifier.value++;
                            if (context.mounted) {
                              _showSaveMessage(
                                  context,
                                  isFav
                                      ? t.translate('savedRemoved')
                                      : t.translate('savedAdded'),
                                  isSaved: !isFav,
                                );
                            }
                          },
                          onTap: () {
                            Get.toNamed(Routes.scholarshipDetail,
                                    arguments: scholarship)
                                ?.then((_) => controller.loadAll());
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  void _showSaveMessage(BuildContext context, String message, {bool isSaved = true}) {
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
                Get.toNamed(Routes.scholarshipPreference)
                    ?.then((_) => controller.reloadPrefs());
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
