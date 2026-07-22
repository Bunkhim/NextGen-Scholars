// ignore_for_file: deprecated_member_use

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:scholarship_app/constants/app_colors.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/wallpaper_screen.dart';
import 'package:scholarship_app/services/notification_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/scholarship_card.dart';
import 'package:scholarship_app/controllers/main_app/home_controller.dart';

/// NOTE: This used to wrap HomeScreen in its own nested MaterialApp, which
/// duplicated the app's GetMaterialApp from main.dart. Removed — this class
/// now just returns HomeScreen directly. Consider pointing your route
/// (AppRoutes.homeScreen) straight at HomeScreen instead of this wrapper.
class Homescreens extends StatelessWidget {
  const Homescreens({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: WallpaperService().hasAny
          ? Colors.transparent
          : colorScheme.surfaceContainerHighest,
      body: Column(
        children: [
          _buildHeroSection(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 5,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  const _BannerSection(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  _buildScholarshipCards(),
                  const SizedBox(height: 24),
                  _buildFeatureShowcaseSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);
    final ws = WallpaperService();

    return Container(
      decoration: BoxDecoration(
        gradient: ws.hasTheme
            ? ws.heroGradient(
                fallbackColors: [AppColors.primary, AppColors.primaryDark],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                    : [AppColors.primary, AppColors.primaryDark],
              ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -35,
            right: -25,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -15,
            right: 55,
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: -20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.28),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/icons/nextgen_logo.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.translate('homeScholarshipBrand'),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                              letterSpacing: -0.4,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            t.translate('homeFindYourFuture'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.65),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Get.toNamed(AppRoutes.notificationScreen),
                      child: FutureBuilder<int>(
                        future: NotificationService().fetchUnreadCount(),
                        builder: (context, snap) {
                          final unread = snap.data ?? 0;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                              if (unread > 0)
                                Positioned(
                                  top: -3,
                                  right: -3,
                                  child: Container(
                                    width: 11,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: AppColors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.primaryDark,
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
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.22),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.profileScreen),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Obx(
                        () => Stack(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.2),
                                  image: (controller.photoUrl.value != null &&
                                          controller.photoUrl.value!.isNotEmpty &&
                                          controller.photoUrl.value!.startsWith('http'))
                                      ? DecorationImage(
                                          image: NetworkImage(
                                              controller.photoUrl.value!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: (controller.photoUrl.value == null ||
                                        controller.photoUrl.value!.isEmpty ||
                                        !controller.photoUrl.value!.startsWith('http'))
                                    ? const Icon(Icons.person_rounded,
                                        color: Colors.white, size: 30)
                                    : null,
                              ),
                            ),
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF69F0AE),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.primaryDark,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.translate(controller.greetingKey()),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 0.1,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Obx(
                              () => Text(
                                controller.userName.value,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white,
                                  letterSpacing: -0.5,
                                  height: 1.15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.16),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.22),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF69F0AE),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    t.translate('homeStudentBadge'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.9),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: ws.hasTheme
                              ? Colors.white.withOpacity(0.16)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: ws.hasTheme
                              ? Border.all(
                                  color: Colors.white.withOpacity(0.24),
                                  width: 1,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.14),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.translate('homeProfileButton'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: ws.hasTheme
                                    ? ws.onThemeColor
                                    : AppColors.primary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: ws.hasTheme
                                  ? ws.onThemeColor
                                  : AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: controller.openSearchFilter,
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: themed
                    ? ws.glassSection(radius: 14)
                    : BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colorScheme.outline),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: colorScheme.onSurfaceVariant, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t.translate('homeSearchHint'),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              final wsPrimary = ws.themedPrimary(colorScheme);
              return Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: ws.hasTheme
                      ? LinearGradient(
                          colors: [
                            wsPrimary.withOpacity(0.95),
                            wsPrimary.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF3A3A3A),
                                  const Color(0xFF2C2C2C)
                                ]
                              : [AppColors.primary, AppColors.primaryDark],
                        ),
                  borderRadius: BorderRadius.circular(14),
                  border: ws.hasTheme
                      ? Border.all(color: ws.glassBorder, width: 0.8)
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: ws.hasTheme
                          ? wsPrimary.withOpacity(0.35)
                          : (isDark
                              ? Colors.black.withOpacity(0.3)
                              : AppColors.primary.withOpacity(0.3)),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: controller.openSearchFilter,
                  icon: Icon(Icons.tune_rounded,
                      color: ws.hasTheme
                          ? ws.onThemeColor
                          : (isDark ? colorScheme.onSurface : AppColors.white),
                      size: 22),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    final actionMap = {
      'discover': (
        icon: Icons.explore_outlined,
        label: t.translate('homeActionDiscover'),
        onTap: () => Get.toNamed(AppRoutes.discoverScreen),
      ),
      'match': (
        icon: Icons.military_tech_outlined,
        label: t.translate('homeActionMatch'),
        onTap: () => controller.handleMatchTap(t),
      ),
      'applications': (
        icon: Icons.assignment_outlined,
        label: t.translate('profileMyApplications'),
        onTap: () => Get.toNamed(AppRoutes.myApplicationsScreen),
      ),
      'fillInfo': (
        icon: Icons.edit_document,
        label: t.translate('homeActionFillInfo'),
        onTap: () => Get.toNamed(AppRoutes.personalInfoScreen),
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.translate('homeQuickActionsTitle'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: WallpaperService().themedOnSurface(colorScheme),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Obx(
            () => ReorderableGridView.count(
              key: const ValueKey('quick_actions_grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              onReorder: controller.reorderActions,
              children: [
                for (int i = 0; i < controller.actionOrder.length; i++)
                  _ActionCard(
                    key: ValueKey(controller.actionOrder[i]),
                    icon: actionMap[controller.actionOrder[i]]!.icon,
                    label: actionMap[controller.actionOrder[i]]!.label,
                    onTap: actionMap[controller.actionOrder[i]]!.onTap,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              t.translate('homeLatestScholarships'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: WallpaperService().themedOnSurface(colorScheme),
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.discoverScreen),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Row(
              children: [
                Text(t.translate('homeSeeAll'),
                    style: TextStyle(
                        color: WallpaperService().themedPrimary(colorScheme),
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios,
                    size: 12,
                    color: WallpaperService().themedPrimary(colorScheme)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScholarshipCards() {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    return FutureBuilder<List<FirestoreScholarship>>(
      future: controller.scholarshipService.fetchActiveScholarships(limit: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            ),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Text(t.translate('discoverError'),
                style: TextStyle(color: colorScheme.error)),
          );
        }
        final all = snapshot.data ?? [];

        if (all.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.school_rounded,
                      size: 48, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    t.translate('discoverNoResults'),
                    style: TextStyle(
                        fontSize: 14, color: colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final items = all.take(10).toList();
        return SizedBox(
          height: 310,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final scholarship = items[index];
              return Obx(() {
                scholarship.isFavorite =
                    controller.favoriteIds.contains(scholarship.id);
                return SizedBox(
                  width: 300,
                  child: ScholarshipCard(
                    scholarship: scholarship,
                    onFavoriteToggle: () => controller.toggleFavorite(scholarship),
                    onTap: () => controller.openScholarshipDetail(scholarship),
                  ),
                );
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildFeatureShowcaseSection() {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            t.translate('homeFeatureSectionTitle'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: WallpaperService().themedOnSurface(colorScheme),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _FeatureShowcaseSection(),
      ],
    );
  }
}

// ── Action Card ───────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    final accent = ws.currentThemeData?.accentColor;
    final isDark = ws.isThemeDark;

    BoxDecoration cardDecoration;
    if (themed && accent != null) {
      final baseColor = isDark
          ? Color.lerp(accent, Colors.white, 0.80)!.withOpacity(0.92)
          : Color.lerp(accent, Colors.white, 0.85)!.withOpacity(0.95);
      final tintColor = isDark
          ? Color.lerp(accent, Colors.white, 0.65)!.withOpacity(0.60)
          : Color.lerp(accent, Colors.white, 0.75)!.withOpacity(0.70);
      cardDecoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, tintColor],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: accent.withOpacity(isDark ? 0.50 : 0.35),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else if (themed) {
      cardDecoration = ws.glassCard(radius: 14);
    } else {
      cardDecoration = BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      );
    }

    final iconBg = (themed && accent != null)
        ? Color.lerp(accent, Colors.white, isDark ? 0.30 : 0.45)!
            .withOpacity(isDark ? 0.40 : 0.50)
        : ws.themedPrimary(colorScheme).withOpacity(0.15);
    final iconColor = (themed && accent != null)
        ? (isDark
            ? Color.lerp(accent, Colors.white, 0.15)!
            : Color.lerp(accent, Colors.black, 0.20)!)
        : ws.themedPrimary(colorScheme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: cardDecoration,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ws.themedOnSurface(colorScheme))),
          ],
        ),
      ),
    );
  }
}

// ── Banner Section ────────────────────────────────────────────────────────────
// (UI-only presentational state — no business logic to migrate)

class _BannerSection extends StatefulWidget {
  const _BannerSection();

  @override
  State<_BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<_BannerSection> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final List<Map<String, String>> slides = [
      {
        'image':
            'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?w=1200&q=90',
        'title': t.translate('homeBannerTitle1'),
        'subtitle': t.translate('homeBannerSubtitle1')
      },
      {
        'image':
            'https://images.unsplash.com/photo-1541339907198-e08756dedf3f?w=1200&q=90',
        'title': t.translate('homeBannerTitle2'),
        'subtitle': t.translate('homeBannerSubtitle2')
      },
      {
        'image':
            'https://images.unsplash.com/photo-1488190211105-8b0e65b80b4e?w=1200&q=90',
        'title': t.translate('homeBannerTitle3'),
        'subtitle': t.translate('homeBannerSubtitle3')
      },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 140,
                  viewportFraction: 1.0,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayCurve: Curves.easeInOutCubic,
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  enlargeCenterPage: false,
                  onPageChanged: (index, reason) =>
                      setState(() => _currentIndex = index),
                ),
                items: slides.map((slide) {
                  return Builder(
                    builder: (context) {
                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primary.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              slide['image']!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white.withOpacity(0.7),
                                    strokeWidth: 2.5,
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => Container(
                                color: AppColors.primary.withOpacity(0.2),
                                child: const Center(
                                  child: Icon(
                                    Icons.school_rounded,
                                    color: Colors.white54,
                                    size: 60,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.1),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slide['title']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black38,
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    slide['subtitle']!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.95),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.2,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(slides.length, (index) {
              final isActive = index == _currentIndex;
              final colorScheme = Theme.of(context).colorScheme;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isActive ? 24 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? colorScheme.primary
                      : colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Feature Showcase Section ──────────────────────────────────────────────────
// (UI-only presentational state — no business logic to migrate)

class _FeatureShowcaseSection extends StatefulWidget {
  const _FeatureShowcaseSection();

  @override
  State<_FeatureShowcaseSection> createState() =>
      _FeatureShowcaseSectionState();
}

class _FeatureShowcaseSectionState extends State<_FeatureShowcaseSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final features = [
      _FeatureTile(
        imageUrl:
            'https://images.unsplash.com/photo-1557682250-33bd709cbe85?w=400&q=80',
        color: const Color(0xFF6C63FF),
        title: t.translate('homeFeatureTitle0'),
        desc: t.translate('homeFeatureDesc0'),
        buttonLabel: t.translate('homeFeatureButton0'),
        onTap: () => Get.to(() => WallpaperScreen()),
      ),
      _FeatureTile(
        imageUrl:
            'https://images.unsplash.com/photo-1498243691581-b145c3f54a5a?w=400&q=80',
        color: const Color(0xFF2196F3),
        title: t.translate('homeFeatureTitle1'),
        desc: t.translate('homeFeatureDesc1'),
        buttonLabel: t.translate('homeFeatureButton1'),
        onTap: () => Get.toNamed(AppRoutes.discoverScreen),
      ),
      _FeatureTile(
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcToXWzUvXzBa5lJ1aINeIYUO6RcvM6woGHFSQ&s',
        color: const Color(0xFF9C27B0),
        title: t.translate('homeFeatureTitle2'),
        desc: t.translate('homeFeatureDesc2'),
        buttonLabel: t.translate('homeFeatureButton2'),
        onTap: () => Get.toNamed(AppRoutes.chatAIScreen),
      ),
      _FeatureTile(
        imageUrl:
            'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&q=80',
        color: const Color(0xFF4CAF50),
        title: t.translate('homeFeatureTitle3'),
        desc: t.translate('homeFeatureDesc3'),
        buttonLabel: t.translate('homeFeatureButton3'),
        onTap: () => Get.toNamed(AppRoutes.personalInfoScreen),
      ),
      _FeatureTile(
        imageUrl:
            'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&q=80',
        color: const Color(0xFFFF9800),
        title: t.translate('homeFeatureTitle4'),
        desc: t.translate('homeFeatureDesc4'),
        buttonLabel: t.translate('homeFeatureButton4'),
        onTap: () => Get.toNamed(AppRoutes.myApplicationsScreen),
      ),
      _FeatureTile(
        imageUrl:
            'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400&q=80',
        color: const Color(0xFFF44336),
        title: t.translate('homeFeatureTitle5'),
        desc: t.translate('homeFeatureDesc5'),
        buttonLabel: t.translate('homeFeatureButton5'),
        onTap: () => Get.toNamed(AppRoutes.savedScholarshipScreen),
      ),
      _FeatureTile(
        imageUrl:
            'https://images.unsplash.com/photo-1487014679447-9f8336841d58?w=400&q=80',
        color: const Color(0xFF00BCD4),
        title: t.translate('homeFeatureTitle6'),
        desc: t.translate('homeFeatureDesc6'),
        buttonLabel: t.translate('homeFeatureButton6'),
        onTap: () => Get.toNamed(AppRoutes.settingsScreen),
      ),
    ];

    final pages = <List<_FeatureTile>>[];
    for (var i = 0; i < features.length; i += 2) {
      pages.add(features.sublist(i, (i + 2).clamp(0, features.length)));
    }

    return Column(
      children: [
        SizedBox(
          height: 185,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, pageIndex) {
              final pair = pages[pageIndex];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _buildCard(pair[0], isDark, colorScheme)),
                    const SizedBox(width: 12),
                    if (pair.length > 1)
                      Expanded(child: _buildCard(pair[1], isDark, colorScheme))
                    else
                      const Expanded(child: SizedBox()),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pages.length, (i) {
            final isActive = i == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.18),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCard(_FeatureTile f, bool isDark, ColorScheme colorScheme) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return GestureDetector(
      onTap: () => _showFeaturePreview(f, colorScheme),
      child: Container(
        decoration: themed
            ? ws.glassCard(radius: 16)
            : BoxDecoration(
                color: isDark ? colorScheme.surface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.12 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                f.imageUrl,
                width: double.infinity,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  height: 90,
                  color: f.color.withOpacity(0.12),
                ),
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 90,
                    color: f.color.withOpacity(0.08),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: f.color,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      f.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.3,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      f.desc,
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeaturePreview(_FeatureTile f, ColorScheme colorScheme) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.4,
          maxChildSize: 0.85,
          builder: (_, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            child: Image.network(
                              f.imageUrl,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: double.infinity,
                                height: 180,
                                color: f.color.withOpacity(0.15),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: f.color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        f.title,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  f.desc,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      f.onTap();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: f.color,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      f.buttonLabel,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FeatureTile {
  final String imageUrl;
  final Color color;
  final String title;
  final String desc;
  final String buttonLabel;
  final VoidCallback onTap;
  const _FeatureTile({
    required this.imageUrl,
    required this.color,
    required this.title,
    required this.desc,
    required this.buttonLabel,
    required this.onTap,
  });
}