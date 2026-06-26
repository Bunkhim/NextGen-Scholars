// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/profile_screen/profile_screen_view.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen/saved_scholarship_screen_view.dart';
import 'package:scholarship_app/services/notification_service.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';

part 'discover_screen_binding.dart';
part 'discover_screen_controller.dart';

class DiscoverScreenView extends GetView<DiscoverScreenViewController> {
  const DiscoverScreenView({super.key});

  void _showSaveMessage(BuildContext context, String message,
      {bool isSaved = true}) {
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
                  color: isSaved ? Colors.green.shade600 : Colors.orange.shade600,
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
      if (overlayEntry.mounted) overlayEntry.remove();
    });
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
                  onPressed: () => Get.back(),
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
              onTap: () => Get.toNamed(Routes.notification),
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
        stream: controller.scholarshipsStream,
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
          controller.syncToSQLite(allScholarships);

          final scholarships = controller.filterScholarships(allScholarships);

          return Obx(
            () => SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchBar(context, colorScheme, t),
                  _buildCategories(context, colorScheme, t),
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
                              color: WallpaperService()
                                  .themedOnSurface(colorScheme),
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
                            await controller
                                .toggleFavorite(scholarship);
                            final t = AppLocalizations.of(context);
                            final isFav = controller.favoriteIds
                                .contains(scholarship.id);
                            _showSaveMessage(
                              context,
                              isFav
                                  ? t.translate('savedRemoved')
                                  : t.translate('savedAdded'),
                              isSaved: !isFav,
                            );
                          },
                          onTap: () {
                            Get.toNamed(Routes.scholarshipDetail,
                                    arguments: scholarship)
                                ?.then((_) => controller.loadSavedIds());
                          },
                        );
                      },
                    ),
                ],
              ),
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
                            color: controller.searchError.value != null
                                ? Colors.red.shade400
                                : colorScheme.outlineVariant,
                            width: 1,
                          ),
                        ),
                  child: TextField(
                    controller: controller.searchController,
                    maxLength: DiscoverScreenViewController._maxSearchLength,
                    style: TextStyle(
                        color: themed
                            ? ws.onThemeColor
                            : colorScheme.onSurface),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (value) {
                      final sanitized = controller.sanitizeInput(value);
                      controller.searchQuery.value = sanitized;
                    },
                    onChanged: (value) {
                      final sanitized = controller.sanitizeInput(value);
                      if (sanitized != value) {
                        controller.searchController.text = sanitized;
                        controller.searchController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: sanitized.length),
                        );
                      }
                      controller.searchQuery.value = sanitized;
                      controller.searchError.value = null;
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
                                  size: 18,
                                  color: colorScheme.outline),
                              onPressed: () {
                                controller.searchController.clear();
                                controller.searchQuery.value = '';
                                controller.searchError.value = null;
                              },
                            )
                          : null,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14),
                      counterText: '',
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
                      color:
                          ws.themedPrimary(colorScheme).withOpacity(0.3),
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
                      onPressed: controller.openSearchFilter,
                    ),
                    if (controller.hasActiveFilter)
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
          if (controller.hasActiveFilter) ...[
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
                      onRemove: () =>
                          controller.filterCountry.value = null,
                    ),
                  if (controller.filterType.value != null) ...[
                    if (controller.filterCountry.value != null)
                      const SizedBox(width: 8),
                    _buildFilterChip(
                      label: controller.filterType.value!,
                      icon: Icons.card_giftcard_outlined,
                      colorScheme: colorScheme,
                      onRemove: () =>
                          controller.filterType.value = null,
                    ),
                  ],
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: controller.clearFilters,
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
                  onTap: () => Get.toNamed(Routes.searchFilter),
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
              children: controller.getCategories(t).map((category) {
                final catIndex =
                    controller.getCategories(t).indexOf(category);
                final isSelected =
                    catIndex == controller.selectedCategoryIndex.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () {
                      controller.selectedCategoryIndex.value = catIndex;
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
                                  ws.themedPrimary(colorScheme).withOpacity(0.8),
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
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
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
