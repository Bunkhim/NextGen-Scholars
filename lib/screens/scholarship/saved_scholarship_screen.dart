// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/main_navigation_screen.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';
import 'package:scholarship_app/controllers/scholarship/saved_scholarship_controller.dart';

class SavedScholarshipScreen extends StatefulWidget {
  const SavedScholarshipScreen({super.key});

  /// Increment this from anywhere to trigger a live reload of the saved list.
  /// Kept as a static ValueNotifier (not moved into GetX) because other
  /// controllers reference it directly by class name.
  static final ValueNotifier<int> refreshNotifier = ValueNotifier(0);

  @override
  State<SavedScholarshipScreen> createState() => _SavedScholarshipScreenState();
}

class _SavedScholarshipScreenState extends State<SavedScholarshipScreen> {
  final SavedScholarshipController controller =
      Get.put(SavedScholarshipController());

  void _goToExploreScholarships() {
    MainNavigationScreen.tabNotifier.value = 1;
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName == AppRoutes.homeScreen) return;
    Get.offAllNamed(AppRoutes.homeScreen);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Obx(() {
      final visibleScholarships = controller.visibleScholarships;
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
          // No leading back button needed since this is a root navigation tab.
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
              onSelected: controller.sortScholarships,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'deadline',
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 12),
                      Text(t.translate('savedSortByDeadline')),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'name',
                  child: Row(
                    children: [
                      const Icon(Icons.sort_by_alpha, size: 18),
                      const SizedBox(width: 12),
                      Text(t.translate('savedSortByName')),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : controller.loadError.value != null
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
    });
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

  Widget _buildScholarshipCard(SavedScholarshipView item,
      ColorScheme colorScheme, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ScholarshipCard(
        scholarship: item.scholarship,
        onFavoriteToggle: () => controller.removeItem(item.savedId, t),
        onTap: () {
          Get.toNamed(
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
            onPressed: controller.retryLoad,
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