// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

/// Reusable scholarship card used in both Discover and Saved screens.
/// Displays each university/school logo prominently via Network Image.
class ScholarshipCard extends StatelessWidget {
  final FirestoreScholarship scholarship;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const ScholarshipCard({
    super.key,
    required this.scholarship,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  /// Resolve the best URL for the school logo.
  /// Priority: logoUrl → imageUrl → empty (shows placeholder).
  String get _resolvedLogoUrl {
    if (scholarship.logoUrl.isNotEmpty) return scholarship.logoUrl;
    if (scholarship.imageUrl.isNotEmpty) return scholarship.imageUrl;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    final accent = ws.currentThemeData?.accentColor;

    // Build theme-aware card decoration
    BoxDecoration cardDeco;
    if (themed && accent != null) {
      final baseColor = ws.isThemeDark
          ? Color.lerp(accent, Colors.white, 0.80)!.withOpacity(0.90)
          : Color.lerp(accent, Colors.white, 0.86)!.withOpacity(0.94);
      final tintColor = ws.isThemeDark
          ? Color.lerp(accent, Colors.white, 0.70)!.withOpacity(0.75)
          : Color.lerp(accent, Colors.white, 0.80)!.withOpacity(0.85);
      cardDeco = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, tintColor],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withOpacity(ws.isThemeDark ? 0.45 : 0.30),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else if (themed) {
      cardDeco = ws.glassCard(radius: 16);
    } else {
      cardDeco = BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(isDark ? 0.18 : 0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: cardDeco,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Logo + University Header ──
            _buildLogoHeader(context, colorScheme, isDark),
            // ── Info Rows ──
            _buildInfoContent(context, colorScheme),
          ],
        ),
      ),
    );
  }

  // ── Logo Header ────────────────────────────────────────────────────────────

  Widget _buildLogoHeader(
      BuildContext context, ColorScheme colorScheme, bool isDark) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
      decoration: BoxDecoration(
        color: themed
            ? Colors.transparent
            : (isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.primary.withOpacity(0.04)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Circular School Logo ──
          _buildLogo(colorScheme),
          const SizedBox(width: 12),

          // ── University Name + Country ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scholarship.university,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: colorScheme.primary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        scholarship.country,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Bookmark ──
          GestureDetector(
            onTap: onFavoriteToggle,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: scholarship.isFavorite
                    ? colorScheme.primary.withOpacity(0.10)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                scholarship.isFavorite
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: scholarship.isFavorite
                    ? colorScheme.primary
                    : colorScheme.outline,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    final url = _resolvedLogoUrl;
    final ws = WallpaperService();
    final accent = ws.currentThemeData?.accentColor;
    final themed = ws.hasTheme;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: (themed && accent != null)
            ? Color.lerp(accent, Colors.white, 0.90)!
            : colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: (themed && accent != null)
              ? accent.withOpacity(0.30)
              : colorScheme.outlineVariant.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (themed && accent != null)
                ? accent.withOpacity(0.12)
                : colorScheme.onSurface.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) =>
                    _buildLogoPlaceholder(colorScheme),
              )
            : _buildLogoPlaceholder(colorScheme),
      ),
    );
  }

  Widget _buildLogoPlaceholder(ColorScheme colorScheme) {
    final initials = _schoolInitials(scholarship.university);
    return Container(
      color: colorScheme.primary.withOpacity(0.08),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary.withOpacity(0.75),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  String _schoolInitials(String input) {
    final words =
        input.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'SC';
    if (words.length == 1) {
      final w = words.first;
      return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
    }
    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  // ── Info Content ───────────────────────────────────────────────────────────

  Widget _buildInfoContent(BuildContext context, ColorScheme colorScheme) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Education Level
          _buildInfoRow(
            context,
            icon: Icons.school_outlined,
            label: t.translate('discoverEducationLevel'),
            value: t.translate(scholarship.degreeLabelKey),
          ),
          const SizedBox(height: 8),

          // Type / Funding
          _buildInfoRow(
            context,
            icon: Icons.info_outline,
            label: t.translate('discoverType'),
            value: scholarship.fundingType,
          ),
          const SizedBox(height: 8),

          // Number of Places
          if (scholarship.numberOfPlaces > 0) ...[
            _buildInfoRow(
              context,
              icon: Icons.check_circle_outline,
              label: t.translate('discoverNumberOfPlaces'),
              value: scholarship.numberOfPlaces.toString(),
            ),
            const SizedBox(height: 8),
          ],

          // Study At (Country)
          _buildInfoRow(
            context,
            icon: Icons.location_on_outlined,
            label: t.translate('discoverStudyAt'),
            value: scholarship.country,
          ),
          const SizedBox(height: 8),

          // Open Date
          if (scholarship.formattedOpenDate.isNotEmpty) ...[
            _buildInfoRow(
              context,
              icon: Icons.calendar_today_outlined,
              label: t.translate('discoverReceiptDate'),
              value: scholarship.formattedOpenDate,
            ),
            const SizedBox(height: 8),
          ],

          // Deadline
          _buildInfoRow(
            context,
            icon: Icons.access_time_outlined,
            label: t.translate('discoverDeadline'),
            value: scholarship.formattedDeadline,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final accent = ws.currentThemeData?.accentColor;
    final themed = ws.hasTheme;
    final iconColor = (themed && accent != null)
        ? (ws.isThemeDark
            ? Color.lerp(accent, Colors.white, 0.20)!
            : Color.lerp(accent, Colors.black, 0.15)!)
        : colorScheme.primary;
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
