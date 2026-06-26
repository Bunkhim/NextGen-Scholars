import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarship_app/constants/app_colors.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/widgets/theme_background_overlay.dart';

part 'wallpaper_screen_binding.dart';
part 'wallpaper_screen_controller.dart';

class WallpaperScreenView extends GetView<WallpaperScreenViewController> {
  const WallpaperScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: WallpaperService().hasTheme
                            ? WallpaperService().onThemeColor
                            : colorScheme.onSurface,
                        size: 20),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      t.translate('settingsWallpaper'),
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
                  Obx(() => TextButton(
                        onPressed: controller.isSaving.value ? null : _apply,
                        style: TextButton.styleFrom(
                          foregroundColor: WallpaperService().hasTheme
                              ? WallpaperService().onThemeColor
                              : colorScheme.primary,
                          backgroundColor: WallpaperService().hasTheme
                              ? Colors.white.withOpacity(0.16)
                              : colorScheme.primary.withOpacity(0.08),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isSaving.value
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    WallpaperService().hasTheme
                                        ? WallpaperService().onThemeColor
                                        : colorScheme.primary,
                                  ),
                                ),
                              )
                            : Text(
                                t.translate('settingsWallpaperApply'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      )),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() =>
                        _buildPreviewCard(context, colorScheme, t, isDark)),
                    const SizedBox(height: 24),
                    _buildSectionLabel(
                        t.translate('settingsWallpaperThemes'), colorScheme),
                    const SizedBox(height: 12),
                    Obx(() => _buildThemeGrid(context, colorScheme, t)),
                    const SizedBox(height: 24),
                    _buildSectionLabel(
                        t.translate('settingsWallpaperCustomSection'),
                        colorScheme),
                    const SizedBox(height: 12),
                    Obx(() => _buildCustomRow(context, colorScheme, t, isDark)),
                    const SizedBox(height: 28),
                    Obx(() => _buildApplyButton(context, colorScheme, t)),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (picked != null) {
      controller.selectedThemeId.value = null;
      controller.selectedImagePath.value = picked.path;
    }
  }

  Future<void> _apply() async {
    controller.isSaving.value = true;
    if (controller.selectedThemeId.value != null) {
      await WallpaperService().setTheme(controller.selectedThemeId.value!);
    } else if (controller.selectedImagePath.value != null) {
      await WallpaperService()
          .setWallpaper(controller.selectedImagePath.value!);
    } else {
      await WallpaperService().removeAll();
    }
    controller.isSaving.value = false;
    Get.back();
  }

  Widget _buildPreviewCard(BuildContext context, ColorScheme colorScheme,
      AppLocalizations t, bool isDark) {
    BoxDecoration? previewDeco;
    if (controller.selectedThemeId.value != null) {
      final theme = builtInThemes.cast<AppThemeData?>().firstWhere(
            (th) => th!.id == controller.selectedThemeId.value,
            orElse: () => null,
          );
      if (theme != null) {
        previewDeco = BoxDecoration(
          gradient: LinearGradient(
            colors: theme.gradientColors,
            begin: theme.gradientBegin,
            end: theme.gradientEnd,
            stops: theme.gradientStops,
          ),
          borderRadius: BorderRadius.circular(24),
        );
      }
    } else if (controller.selectedImagePath.value != null &&
        File(controller.selectedImagePath.value!).existsSync()) {
      previewDeco = BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(controller.selectedImagePath.value!)),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(24),
      );
    }

    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: previewDeco != null
          ? Container(
              decoration: previewDeco.copyWith(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  if (controller.selectedThemeId.value != null)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: ThemeBackgroundOverlay(
                          themeId: controller.selectedThemeId.value,
                          themeData: builtInThemes
                              .cast<AppThemeData?>()
                              .firstWhere(
                                (th) =>
                                    th!.id == controller.selectedThemeId.value,
                                orElse: () => null,
                              ),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: _PhoneMockOverlay(
                      colorScheme: colorScheme,
                      isDark: controller
                              .isLightTheme(controller.selectedThemeId.value)
                          ? false
                          : true,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        t.translate('settingsWallpaperPreview'),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Container(
              color: isDark
                  ? const Color(0xFF1E1E2E)
                  : colorScheme.surfaceContainerHighest,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.wallpaper_rounded,
                        size: 56, color: colorScheme.outline.withOpacity(0.35)),
                    const SizedBox(height: 10),
                    Text(
                      t.translate('settingsWallpaperDefault'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.translate('settingsWallpaperChooseHint'),
                      style:
                          TextStyle(fontSize: 13, color: colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildThemeGrid(
      BuildContext context, ColorScheme colorScheme, AppLocalizations t) {
    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: builtInThemes.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ThemeCard(
              label: t.translate('settingsWallpaperDefaultLabel'),
              isSelected: controller.isDefault,
              onTap: () {
                controller.selectedThemeId.value = null;
                controller.selectedImagePath.value = null;
              },
              colorScheme: colorScheme,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(Icons.phone_android_rounded,
                      size: 36, color: colorScheme.outline.withOpacity(0.5)),
                ),
              ),
            );
          }
          final theme = builtInThemes[index - 1];
          final isSelected = controller.selectedThemeId.value == theme.id;
          return _ThemeCard(
            label: t.translate(theme.nameKey),
            isSelected: isSelected,
            onTap: () => controller.selectTheme(theme.id),
            colorScheme: colorScheme,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: theme.gradientColors,
                  begin: theme.gradientBegin,
                  end: theme.gradientEnd,
                  stops: theme.gradientStops,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  ThemeBackgroundOverlay(themeId: theme.id, themeData: theme),
                  _ThemeDecoOverlay(
                    themeId: theme.id,
                    isDark: !controller.isLightTheme(theme.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCustomRow(BuildContext context, ColorScheme colorScheme,
      AppLocalizations t, bool isDark) {
    return Row(
      children: [
        GestureDetector(
          onTap: _pickFromGallery,
          child: Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_rounded,
                    size: 32, color: colorScheme.primary),
                const SizedBox(height: 6),
                Text(
                  t.translate('settingsWallpaperChooseGallery'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (controller.selectedImagePath.value != null &&
            File(controller.selectedImagePath.value!).existsSync()) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary,
                  width: 2.5,
                ),
                image: DecorationImage(
                  image: FileImage(File(controller.selectedImagePath.value!)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildApplyButton(
      BuildContext context, ColorScheme colorScheme, AppLocalizations t) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: controller.isSaving.value ? null : _apply,
            child: Center(
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          t.translate('settingsWallpaperApply'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final Widget child;

  const _ThemeCard({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 105,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 105,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.15),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(child: child),
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneMockOverlay extends StatelessWidget {
  final ColorScheme colorScheme;
  final bool isDark;

  const _PhoneMockOverlay({required this.colorScheme, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final barC = (isDark ? Colors.white : Colors.black).withOpacity(0.12);
    final cardC = (isDark ? Colors.white : Colors.black).withOpacity(0.08);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 50,
                  height: 6,
                  decoration: BoxDecoration(
                      color: barC, borderRadius: BorderRadius.circular(3))),
              Row(
                children: List.generate(
                  3,
                  (_) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 4),
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: barC),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 28,
            decoration: BoxDecoration(
                color: cardC, borderRadius: BorderRadius.circular(14)),
          ),
          const SizedBox(height: 12),
          Container(
            height: 50,
            decoration: BoxDecoration(
                color: cardC, borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Container(
                  height: 34,
                  margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                      color: cardC, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Container(
                  height: 34,
                  margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                      color: cardC, borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeDecoOverlay extends StatelessWidget {
  final String themeId;
  final bool isDark;
  final bool isLarge;

  const _ThemeDecoOverlay({
    required this.themeId,
    required this.isDark,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = (isDark ? Colors.white : Colors.black).withOpacity(0.13);
    final accent =
        isDark ? Colors.white.withOpacity(0.25) : Colors.black.withOpacity(0.1);
    final s = isLarge ? 2.0 : 1.0;

    switch (themeId) {
      case 'smart_glass':
        return _buildSmartGlass(c, accent, s);
      case 'dynamic':
        return _buildDynamic(c, accent, s);
      case 'valentine':
        return _buildValentine(c, accent, s);
      case 'lunar':
        return _buildLunar(c, accent, s);
      case 'modern':
        return _buildModern(c, accent, s);
      case 'visak_bochea':
        return _buildVisakBochea(c, accent, s);
      case 'islamic':
        return _buildIslamic(c, accent, s);
      case 'march_8':
        return _buildMarch8(c, accent, s);
      case 'khmer_new_year':
        return _buildKhmerNewYear(c, accent, s);
      case 'linear':
        return _buildLinear(c, accent, s);
      case 'temple':
        return _buildTemple(c, accent, s);
      case 'xmas':
        return _buildXmas(c, accent, s);
      case 'water_festival':
        return _buildWaterFestival(c, accent, s);
      case 'pchum_ben':
        return _buildPchumBen(c, accent, s);
      case 'cartoon':
        return _buildCartoon(c, accent, s);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSmartGlass(Color c, Color accent, double s) {
    return Stack(
      children: [
        Positioned(top: 6 * s, right: 6 * s, child: _hexagon(18 * s, accent)),
        Positioned(
            bottom: 20 * s, left: 8 * s, child: _hexagon(12 * s, accent)),
        Positioned(top: 35 * s, left: 20 * s, child: _circle(6 * s, c)),
        Positioned(
            bottom: 10 * s, right: 15 * s, child: _dashedLine(30 * s, c, true)),
        Positioned(
            top: 18 * s, right: 25 * s, child: _dashedLine(20 * s, c, false)),
        Positioned(
            bottom: 40 * s,
            left: 30 * s,
            child: Icon(Icons.settings_outlined, size: 14 * s, color: accent)),
      ],
    );
  }

  Widget _buildDynamic(Color c, Color accent, double s) {
    return Stack(
      children: [
        Positioned(
            top: 10 * s,
            right: 8 * s,
            child: Icon(Icons.bolt_rounded, size: 22 * s, color: accent)),
        Positioned(
            bottom: 15 * s,
            left: 10 * s,
            child: Icon(Icons.electric_bolt_rounded, size: 16 * s, color: c)),
        Positioned(top: 40 * s, left: 15 * s, child: _circle(8 * s, accent)),
        Positioned(bottom: 35 * s, right: 20 * s, child: _circle(5 * s, c)),
        Positioned(
            top: 20 * s,
            left: 35 * s,
            child: Transform.rotate(
                angle: 0.4,
                child: Icon(Icons.auto_awesome, size: 10 * s, color: accent))),
      ],
    );
  }

  Widget _buildValentine(Color c, Color accent, double s) {
    return Stack(
      children: [
        Positioned(
            top: 8 * s,
            right: 10 * s,
            child: Icon(Icons.favorite_rounded,
                size: 20 * s, color: Colors.pinkAccent.withOpacity(0.35))),
        Positioned(
            bottom: 18 * s,
            left: 12 * s,
            child: Icon(Icons.favorite_rounded,
                size: 14 * s, color: Colors.pinkAccent.withOpacity(0.25))),
        Positioned(
            top: 35 * s,
            left: 8 * s,
            child: Icon(Icons.favorite_border, size: 10 * s, color: accent)),
        Positioned(
            bottom: 40 * s,
            right: 8 * s,
            child: _sparkle(8 * s, Colors.pinkAccent.withOpacity(0.3))),
        Positioned(top: 18 * s, left: 30 * s, child: _sparkle(6 * s, accent)),
      ],
    );
  }

  Widget _buildLunar(Color c, Color accent, double s) {
    final starC = Colors.amber.withOpacity(0.4);
    return Stack(
      children: [
        Positioned(
            top: 6 * s,
            right: 8 * s,
            child: Icon(Icons.nightlight_round,
                size: 22 * s, color: Colors.orange.withOpacity(0.35))),
        Positioned(
            bottom: 25 * s, left: 10 * s, child: _sparkle(10 * s, starC)),
        Positioned(top: 30 * s, left: 25 * s, child: _sparkle(6 * s, starC)),
        Positioned(
            bottom: 12 * s,
            right: 15 * s,
            child: Icon(Icons.star_rounded, size: 12 * s, color: starC)),
        Positioned(top: 18 * s, left: 8 * s, child: _circle(4 * s, starC)),
      ],
    );
  }

  Widget _buildModern(Color c, Color accent, double s) {
    return Stack(
      children: [
        Positioned(
            top: 8 * s, right: 8 * s, child: _rotatedSquare(16 * s, accent)),
        Positioned(
            bottom: 20 * s, left: 10 * s, child: _rotatedSquare(10 * s, c)),
        Positioned(
            top: 35 * s,
            left: 25 * s,
            child: _dashedLine(25 * s, accent, true)),
        Positioned(
            bottom: 40 * s,
            right: 15 * s,
            child: _dashedLine(18 * s, accent, false)),
        Positioned(bottom: 10 * s, right: 8 * s, child: _circle(6 * s, c)),
      ],
    );
  }

  Widget _buildVisakBochea(Color c, Color accent, double s) {
    final glow = Colors.amber.withOpacity(0.3);
    return Stack(
      children: [
        Positioned(
            top: 8 * s,
            right: 10 * s,
            child: Icon(Icons.local_fire_department_rounded,
                size: 18 * s, color: glow)),
        Positioned(
            bottom: 20 * s,
            left: 12 * s,
            child: Icon(Icons.spa_rounded, size: 16 * s, color: accent)),
        Positioned(top: 35 * s, left: 20 * s, child: _sparkle(7 * s, glow)),
        Positioned(bottom: 12 * s, right: 20 * s, child: _circle(5 * s, glow)),
        Positioned(
            bottom: 38 * s,
            right: 8 * s,
            child: Icon(Icons.auto_awesome, size: 10 * s, color: accent)),
      ],
    );
  }

  Widget _buildIslamic(Color c, Color accent, double s) {
    return Stack(
      children: [
        Positioned(
            top: 6 * s,
            right: 8 * s,
            child: Icon(Icons.nightlight_round, size: 20 * s, color: accent)),
        Positioned(
            top: 12 * s,
            right: 18 * s,
            child: Icon(Icons.star_rounded, size: 10 * s, color: accent)),
        Positioned(bottom: 18 * s, left: 10 * s, child: _hexagon(12 * s, c)),
        Positioned(bottom: 38 * s, right: 12 * s, child: _hexagon(8 * s, c)),
        Positioned(top: 38 * s, left: 18 * s, child: _circle(5 * s, accent)),
      ],
    );
  }

  Widget _buildMarch8(Color c, Color accent, double s) {
    final pink = Colors.pink.withOpacity(0.3);
    return Stack(
      children: [
        Positioned(
            top: 6 * s,
            right: 8 * s,
            child:
                Icon(Icons.local_florist_rounded, size: 20 * s, color: pink)),
        Positioned(
            bottom: 20 * s,
            left: 10 * s,
            child:
                Icon(Icons.local_florist_rounded, size: 14 * s, color: accent)),
        Positioned(top: 32 * s, left: 20 * s, child: _sparkle(6 * s, pink)),
        Positioned(
            bottom: 12 * s,
            right: 15 * s,
            child: Icon(Icons.favorite_rounded, size: 10 * s, color: pink)),
        Positioned(bottom: 40 * s, left: 30 * s, child: _circle(4 * s, accent)),
      ],
    );
  }

  Widget _buildKhmerNewYear(Color c, Color accent, double s) {
    final leaf = Colors.green.withOpacity(0.3);
    return Stack(
      children: [
        Positioned(
            top: 6 * s,
            right: 8 * s,
            child: Icon(Icons.wb_sunny_rounded,
                size: 18 * s, color: Colors.orange.withOpacity(0.3))),
        Positioned(
            bottom: 18 * s,
            left: 8 * s,
            child: Icon(Icons.eco_rounded, size: 16 * s, color: leaf)),
        Positioned(top: 32 * s, left: 22 * s, child: _sparkle(7 * s, leaf)),
        Positioned(
            bottom: 10 * s,
            right: 12 * s,
            child: Icon(Icons.grass_rounded, size: 12 * s, color: leaf)),
        Positioned(
            bottom: 38 * s, right: 25 * s, child: _circle(4 * s, accent)),
      ],
    );
  }

  Widget _buildLinear(Color c, Color accent, double s) {
    return Stack(
      children: [
        Positioned(
            top: 8 * s, left: 8 * s, child: _dashedLine(35 * s, accent, true)),
        Positioned(
            top: 18 * s, left: 8 * s, child: _dashedLine(28 * s, c, true)),
        Positioned(
            bottom: 25 * s,
            right: 8 * s,
            child: _dashedLine(30 * s, accent, true)),
        Positioned(top: 30 * s, right: 10 * s, child: _circle(6 * s, accent)),
        Positioned(bottom: 12 * s, left: 15 * s, child: _circle(8 * s, c)),
        Positioned(
            bottom: 40 * s, left: 30 * s, child: _rotatedSquare(8 * s, accent)),
      ],
    );
  }

  Widget _buildTemple(Color c, Color accent, double s) {
    final golden = Colors.brown.withOpacity(0.25);
    return Stack(
      children: [
        Positioned(
            top: 8 * s,
            right: 10 * s,
            child: Icon(Icons.account_balance_rounded,
                size: 20 * s, color: golden)),
        Positioned(
            bottom: 18 * s,
            left: 10 * s,
            child: Icon(Icons.temple_buddhist_rounded,
                size: 16 * s, color: accent)),
        Positioned(top: 35 * s, left: 25 * s, child: _sparkle(6 * s, golden)),
        Positioned(
            bottom: 10 * s, right: 18 * s, child: _circle(5 * s, golden)),
        Positioned(
            bottom: 38 * s,
            right: 8 * s,
            child: _dashedLine(18 * s, accent, false)),
      ],
    );
  }

  Widget _buildXmas(Color c, Color accent, double s) {
    final snow = Colors.blue.withOpacity(0.25);
    return Stack(
      children: [
        Positioned(
            top: 6 * s,
            right: 8 * s,
            child: Icon(Icons.ac_unit_rounded, size: 18 * s, color: snow)),
        Positioned(
            bottom: 20 * s,
            left: 10 * s,
            child: Icon(Icons.park_rounded,
                size: 16 * s, color: Colors.green.withOpacity(0.3))),
        Positioned(
            top: 32 * s,
            left: 15 * s,
            child: Icon(Icons.ac_unit_rounded, size: 10 * s, color: snow)),
        Positioned(
            bottom: 12 * s,
            right: 12 * s,
            child: Icon(Icons.star_rounded,
                size: 12 * s, color: Colors.amber.withOpacity(0.3))),
        Positioned(bottom: 38 * s, right: 25 * s, child: _sparkle(5 * s, snow)),
      ],
    );
  }

  Widget _buildWaterFestival(Color c, Color accent, double s) {
    final water = Colors.blue.withOpacity(0.28);
    return Stack(
      children: [
        Positioned(
            top: 6 * s,
            right: 8 * s,
            child: Icon(Icons.water_drop_rounded, size: 20 * s, color: water)),
        Positioned(
            bottom: 22 * s,
            left: 12 * s,
            child: Icon(Icons.water_drop_rounded, size: 14 * s, color: water)),
        Positioned(
            top: 30 * s,
            left: 20 * s,
            child: Icon(Icons.waves_rounded, size: 12 * s, color: accent)),
        Positioned(bottom: 10 * s, right: 15 * s, child: _circle(6 * s, water)),
        Positioned(
            bottom: 40 * s, right: 10 * s, child: _sparkle(6 * s, water)),
      ],
    );
  }

  Widget _buildPchumBen(Color c, Color accent, double s) {
    final warm = Colors.orange.withOpacity(0.3);
    return Stack(
      children: [
        Positioned(
            top: 8 * s,
            right: 10 * s,
            child: Icon(Icons.local_fire_department_rounded,
                size: 18 * s, color: warm)),
        Positioned(
            bottom: 18 * s,
            left: 10 * s,
            child: Icon(Icons.spa_rounded, size: 16 * s, color: accent)),
        Positioned(top: 35 * s, left: 22 * s, child: _sparkle(7 * s, warm)),
        Positioned(bottom: 38 * s, right: 12 * s, child: _circle(5 * s, warm)),
        Positioned(
            bottom: 10 * s,
            right: 20 * s,
            child: Icon(Icons.auto_awesome, size: 10 * s, color: accent)),
      ],
    );
  }

  Widget _buildCartoon(Color c, Color accent, double s) {
    final fun = Colors.purple.withOpacity(0.2);
    return Stack(
      children: [
        Positioned(
            top: 6 * s,
            right: 8 * s,
            child: Icon(Icons.auto_awesome, size: 18 * s, color: fun)),
        Positioned(
            bottom: 20 * s,
            left: 10 * s,
            child: Icon(Icons.star_rounded,
                size: 16 * s, color: Colors.pink.withOpacity(0.2))),
        Positioned(
            top: 30 * s,
            left: 20 * s,
            child: Icon(Icons.circle,
                size: 8 * s, color: Colors.blue.withOpacity(0.15))),
        Positioned(
            bottom: 12 * s, right: 15 * s, child: _rotatedSquare(10 * s, fun)),
        Positioned(
            bottom: 40 * s,
            left: 30 * s,
            child: Icon(Icons.cloud_rounded, size: 12 * s, color: accent)),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _hexagon(double size, Color color) {
    return Transform.rotate(
      angle: pi / 6,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size * 0.25),
        ),
      ),
    );
  }

  Widget _rotatedSquare(double size, Color color) {
    return Transform.rotate(
      angle: pi / 4,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _sparkle(double size, Color color) {
    return Icon(Icons.auto_awesome, size: size, color: color);
  }

  Widget _dashedLine(double width, Color color, bool horizontal) {
    return SizedBox(
      width: horizontal ? width : 2,
      height: horizontal ? 2 : width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
