// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/main_app/profile_controller.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/screens/main_app/edit_profile.dart';
import 'package:scholarship_app/screens/main_app/help_support_screen.dart';
import 'package:scholarship_app/screens/main_app/notification_screen.dart';
import 'package:scholarship_app/screens/main_app/settings_screen.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class ProfileScreen extends StatefulWidget {
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  /// Increment this from anywhere to trigger a live reload of profile stats.
  static final ValueNotifier<int> refreshNotifier = ValueNotifier(0);

  /// Holds the current photo URL/path — updated instantly without Firestore round-trip.
  static String? activePhotoPath;

  /// Notifies screens that photo has changed (use with activePhotoPath).
  static final ValueNotifier<int> photoRefreshNotifier = ValueNotifier(0);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: WallpaperService().hasAny
          ? Colors.transparent
          : (isDark ? cs.surface : const Color(0xFFF2F4F8)),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Hero Header ─────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              stretch: true,
              backgroundColor: WallpaperService().hasTheme
                  ? WallpaperService().appBarColor!
                  : cs.primary,
              elevation: 0,
              automaticallyImplyLeading: !widget.embedded,
              leading: widget.embedded
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 21),
                      onPressed: () => Navigator.pop(context),
                    ),
              actions: [
                IconButton(
                  icon: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_outlined,
                        color: Colors.white, size: 18),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  ).then((_) {
                    // Photo already updated via photoRefreshNotifier
                    // Just reload stats (name, counts)
                    controller.loadProfile();
                  }),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: Obx(() => _HeroHeader(
                  userName: controller.userName.value,
                  userEmail: controller.userEmail.value,
                  photoUrl: controller.photoUrl.value,
                  subtitle: t.translate('profileManageSubtitle'),
                )),
              ),
            ),

            // ── Body ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Stats Row ──────────────────────────────────────
                    Obx(() => _StatsRow(
                      savedCount: controller.savedCount.value,
                      appliedCount: controller.appliedCount.value,
                      viewedCount: controller.viewedCount.value,
                      savedLabel: t.translate('profileSavedLabel'),
                      appliedLabel: t.translate('profileAppliedLabel'),
                      viewedLabel: t.translate('profileViewedLabel'),
                    )),
                    const SizedBox(height: 20),

                    // ── Edit Profile Button ────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: WallpaperService().hasTheme
                              ? LinearGradient(
                                  colors: [
                                    WallpaperService().themedPrimary(cs),
                                    WallpaperService()
                                        .themedPrimary(cs)
                                        .withOpacity(0.7),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                )
                              : LinearGradient(
                                  colors: [
                                    cs.primary,
                                    cs.primary.withOpacity(0.7)
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: (WallpaperService().hasTheme
                                      ? WallpaperService().themedPrimary(cs)
                                      : cs.primary)
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          ).then((_) {
                            controller.loadProfile();
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.edit_rounded,
                              color: Colors.white, size: 18),
                          label: Text(
                            t.translate('profileEditButton'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Account Section ────────────────────────────────
                    _SectionLabel(t.translate('profileAccountSettings')),
                    const SizedBox(height: 10),
                    _MenuCard(items: [
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        color: cs.primary,
                        label: t.translate('profileNotifications'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.send_outlined,
                        color: cs.primary,
                        label: t.translate('profileMyApplications'),
                        onTap: () => Navigator.pushNamed(
                            context, '/my_applications_screen'),
                      ),
                    ]),
                    const SizedBox(height: 20),

                    // ── General Section ────────────────────────────────
                    _SectionLabel(t.translate('profileGeneralSection')),
                    const SizedBox(height: 10),
                    _MenuCard(items: [
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        color: cs.primary,
                        label: t.translate('profileSettings'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen())),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        color: cs.primary,
                        label: t.translate('profileHelpSupport'),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HelpSupportScreen())),
                      ),
                    ]),
                    const SizedBox(height: 28),

                    // ── Logout ─────────────────────────────────────────
                    Obx(() => _LogoutButton(
                      label: t.translate('profileLogout'),
                      confirmMessage: t.translate('profileLogoutConfirm'),
                      cancelLabel: t.translate('profileLogoutCancel'),
                      loadingLabel: t.translate('profileLoggingOut'),
                      isLoading: controller.isLoggingOut.value,
                      onConfirm: controller.handleLogout,
                    )),
                    const SizedBox(height: 12),

                    // ── Delete Account ─────────────────────────────────
                    Obx(() => _DeleteAccountButton(
                      label: t.translate('profileDeleteAccount'),
                      confirmMessage:
                          t.translate('profileDeleteAccountConfirm'),
                      cancelLabel: t.translate('profileDeleteAccountCancel'),
                      loadingLabel: t.translate('profileDeletingAccount'),
                      isLoading: controller.isDeletingAccount.value,
                      onConfirm: controller.handleDeleteAccount,
                    )),
                    const SizedBox(height: 16),

                    // ── Version ────────────────────────────────────────
                    Center(
                      child: Text(
                        t.translate('profileVersion'),
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.outline.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Header ────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.userName,
    required this.userEmail,
    required this.subtitle,
    this.photoUrl,
  });
  final String userName;
  final String userEmail;
  final String? photoUrl;
  final String subtitle;

  bool get _hasPhoto {
    if (photoUrl == null || photoUrl!.isEmpty) return false;
    if (photoUrl!.startsWith('http')) return true;
    return false;
  }

  ImageProvider? get _photoImageProvider {
    if (photoUrl == null || photoUrl!.isEmpty) return null;
    if (photoUrl!.startsWith('http')) return NetworkImage(photoUrl!);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ws = WallpaperService();
    return Container(
      decoration: BoxDecoration(
        gradient: ws.hasTheme
            ? ws.heroGradient(
                fallbackColors: const [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5),
                ],
              ),
      ),
      child: Stack(
        children: [
          // Decorative background shapes
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Content
          SizedBox.expand(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 52),
                  // Avatar ring
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.8), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: !_hasPhoto
                            ? LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.10),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        image: _hasPhoto
                            ? DecorationImage(
                                image: _photoImageProvider!,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _hasPhoto
                          ? null
                          : const Icon(
                              Icons.person_rounded,
                              size: 46,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ──────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.savedCount,
    required this.appliedCount,
    required this.viewedCount,
    required this.savedLabel,
    required this.appliedLabel,
    required this.viewedLabel,
  });

  final int savedCount;
  final int appliedCount;
  final int viewedCount;
  final String savedLabel;
  final String appliedLabel;
  final String viewedLabel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ws = WallpaperService();
    final themed = ws.hasTheme;

    return Container(
      decoration: themed
          ? ws.glassCard(radius: 18)
          : BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          _StatItem(
            value: savedCount.toString(),
            label: savedLabel,
            icon: Icons.bookmark_rounded,
            color: cs.primary,
          ),
          _VertDivider(),
          _StatItem(
            value: appliedCount.toString(),
            label: appliedLabel,
            icon: Icons.send_rounded,
            color: cs.primary,
          ),
          _VertDivider(),
          _StatItem(
            value: viewedCount.toString(),
            label: viewedLabel,
            icon: Icons.visibility_outlined,
            color: cs.primary,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 1,
      height: 50,
      color: cs.outlineVariant.withOpacity(0.5),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color:
              themed ? ws.onThemeColor.withOpacity(0.7) : cs.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ── Menu Card ──────────────────────────────────────────────────────────────────

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ws = WallpaperService();
    final themed = ws.hasTheme;

    return Container(
      decoration: themed
          ? ws.glassCard(radius: 18)
          : BoxDecoration(
              color: isDark ? cs.surfaceContainerHighest : Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(18) : Radius.zero,
                    bottom: isLast ? const Radius.circular(18) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    child: Row(
                      children: [
                        // Icon badge
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: cs.outline, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 70),
                  child: Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withOpacity(0.5)),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Logout Button ──────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.label,
    required this.confirmMessage,
    required this.cancelLabel,
    required this.loadingLabel,
    required this.onConfirm,
    this.isLoading = false,
  });
  final String label;
  final String confirmMessage;
  final String cancelLabel;
  final String loadingLabel;
  final VoidCallback onConfirm;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE53935);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;

    return Material(
      color: themed
          ? ws.cardColor
          : (isDark ? cs.surfaceContainerHighest : Colors.white),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isLoading
            ? null
            : () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        const Icon(Icons.logout_rounded, color: red, size: 22),
                        const SizedBox(width: 10),
                        Text(label),
                      ],
                    ),
                    content: Text(confirmMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(cancelLabel),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        child: Text(label),
                      ),
                    ],
                  ),
                ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: red.withOpacity(0.25), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2.5, color: red),
                )
              else
                const Icon(Icons.logout_rounded, color: red, size: 20),
              const SizedBox(width: 10),
              Text(
                isLoading ? loadingLabel : label,
                style: const TextStyle(
                  color: red,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Delete Account Button ──────────────────────────────────────────────────────

class _DeleteAccountButton extends StatelessWidget {
  const _DeleteAccountButton({
    required this.label,
    required this.confirmMessage,
    required this.cancelLabel,
    required this.loadingLabel,
    required this.onConfirm,
    this.isLoading = false,
  });
  final String label;
  final String confirmMessage;
  final String cancelLabel;
  final String loadingLabel;
  final VoidCallback onConfirm;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFE53935);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;

    return Material(
      color: themed
          ? ws.cardColor
          : (isDark ? cs.surfaceContainerHighest : Colors.white),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isLoading
            ? null
            : () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        const Icon(Icons.delete_forever_rounded,
                            color: red, size: 22),
                        const SizedBox(width: 10),
                        Text(label),
                      ],
                    ),
                    content: Text(confirmMessage),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(cancelLabel),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        child: Text(label),
                      ),
                    ],
                  ),
                ),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: red.withOpacity(0.25), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2.5, color: red),
                )
              else
                const Icon(Icons.delete_forever_rounded, color: red, size: 20),
              const SizedBox(width: 10),
              Text(
                isLoading ? loadingLabel : label,
                style: const TextStyle(
                  color: red,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
