// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/fill_information/scholarship_preference_screen.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/main_app/scholarship_match_controller.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

class ScholarshipMatchScreen extends StatefulWidget {
  const ScholarshipMatchScreen({super.key});

  @override
  State<ScholarshipMatchScreen> createState() => _ScholarshipMatchScreenState();
}

class _ScholarshipMatchScreenState extends State<ScholarshipMatchScreen> {
  late final ScholarshipMatchController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ScholarshipMatchController());
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
          return _buildNoPreferences(context, colorScheme, t, controller);
        }

        final matched = controller.matchedScholarships;
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
                        await controller.toggleFavorite(
                          scholarship, 
                          context, 
                          t.translate('savedAdded'), 
                          t.translate('savedRemoved')
                        );
                      },
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.scholarshipDetailScreen,
                          arguments: scholarship,
                        )?.then((_) => controller.loadAll());
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildNoPreferences(BuildContext context, ColorScheme colorScheme, AppLocalizations t, ScholarshipMatchController controller) {
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
                Get.to(() => const ScholarshipPreferenceScreen())
                    ?.then((_) => controller.loadAll());
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
