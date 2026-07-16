// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/scholarship/scholarship_detail_controller.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/screens/fill_information/personal_info_screen.dart';
import 'package:scholarship_app/screens/scholarship/my_applications_screen.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:url_launcher/url_launcher.dart';

class ScholarshipDetailScreen extends StatefulWidget {
  const ScholarshipDetailScreen({super.key});

  @override
  State<ScholarshipDetailScreen> createState() => _ScholarshipDetailScreenState();
}

class _ScholarshipDetailScreenState extends State<ScholarshipDetailScreen> {
  ScholarshipDetailController? _controller;
  bool _controllerInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_controllerInitialized) {
      final scholarship =
          ModalRoute.of(context)?.settings.arguments as FirestoreScholarship?;
      if (scholarship != null) {
        _controller = Get.put(
          ScholarshipDetailController(),
          tag: scholarship.id,
        );
        _controller!.init(scholarship);
        _controllerInitialized = true;
      }
    }
  }

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
                  color:
                      isSaved ? Colors.green.shade600 : Colors.orange.shade600,
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
      overlayEntry.remove();
    });
  }

  Future<void> _toggleBookmark(BuildContext context,
      ScholarshipDetailController controller) async {
    final t = AppLocalizations.of(context);
    final added = await controller.toggleBookmark();
    if (!context.mounted) return;
    _showSaveMessage(
      context,
      added ? t.translate('savedAdded') : t.translate('savedRemoved'),
      isSaved: added,
    );
  }

  /// Handle the Apply tap: run the controller's checks, then show the
  /// dialog/snackbar that matches the outcome.
  Future<void> _handleApply(BuildContext context,
      ScholarshipDetailController controller) async {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final result = await controller.handleApply();
    if (!context.mounted) return;

    switch (result.outcome) {
      case ApplyOutcome.profileIncomplete:
        final goFill = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.translate('applyIncompleteTitle')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.translate('applyIncompleteMsg')),
                const SizedBox(height: 12),
                ...result.missingSections.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 18, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s)),
                      ]),
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t.translate('applyCancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(t.translate('applyFillNow')),
              ),
            ],
          ),
        );
        if (goFill == true && context.mounted) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PersonalInfoScreen()));
        }
        break;

      case ApplyOutcome.alreadyApplied:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.translate('applyAlreadyApplied'))),
        );
        break;

      case ApplyOutcome.scholarshipUnavailable:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.translate('applyScholarshipUnavailable')),
            backgroundColor: colorScheme.error,
          ),
        );
        break;

      case ApplyOutcome.success:
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: Text(t.translate('applySuccessTitle')),
            content: Text(t.translate('applySuccessMsg')),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MyApplicationsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: Text(t.translate('applyViewApplications')),
              ),
            ],
          ),
        );
        break;

      case ApplyOutcome.failed:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.translate('applyFailed'))),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final scholarship =
        ModalRoute.of(context)?.settings.arguments as FirestoreScholarship?;

    if (scholarship == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 30, color: colorScheme.onPrimary),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(child: Text(t.translate('detailNotFound'))),
      );
    }

    final controller = _controller!;

    final title = locale == 'km' && scholarship.titleKm.isNotEmpty
        ? scholarship.titleKm
        : scholarship.titleEn;
    final description = locale == 'km' && scholarship.descriptionKm.isNotEmpty
        ? scholarship.descriptionKm
        : scholarship.descriptionEn;
    final eligibility = locale == 'km' && scholarship.eligibilityKm.isNotEmpty
        ? scholarship.eligibilityKm
        : scholarship.eligibilityEn;
    final benefits = locale == 'km' && scholarship.benefitsKm.isNotEmpty
        ? scholarship.benefitsKm
        : scholarship.benefitsEn;
    final requiredDocs =
        locale == 'km' && scholarship.requiredDocumentsKm.isNotEmpty
            ? scholarship.requiredDocumentsKm
            : scholarship.requiredDocumentsEn;

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: WallpaperService().hasTheme
            ? WallpaperService().appBarColor
            : colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 30,
            color: colorScheme.onPrimary,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          t.translate('detailTitle'),
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Image (bookmark icon reactive via its own Obx)
              _buildHeaderImage(context, scholarship, colorScheme, controller),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo + Title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildSmallLogo(scholarship, colorScheme),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            title.isNotEmpty ? title : scholarship.university,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: WallpaperService().hasAny
                                  ? WallpaperService().onThemeColor
                                  : colorScheme.onSurface,
                              height: 1.3,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 4-column info grid
                    _buildInfoGrid(context, scholarship, colorScheme),

                    const SizedBox(height: 14),

                    // Action buttons (Consult, Q&As, Share)
                    _buildActionButtons(context, scholarship, colorScheme),

                    const SizedBox(height: 14),

                    // Divider
                    Divider(
                        color: WallpaperService().hasAny
                            ? WallpaperService().onThemeColor.withOpacity(0.2)
                            : colorScheme.outlineVariant.withOpacity(0.4),
                        height: 1),

                    const SizedBox(height: 14),

                    // About / Description (expandable, reactive)
                    if (description.isNotEmpty) ...[
                      Obx(() => GestureDetector(
                            onTap: controller.toggleDescription,
                            child: Row(
                              children: [
                                Expanded(
                                  child: _buildSectionTitle(
                                      context,
                                      t.translate('detailAboutTitle'),
                                      colorScheme),
                                ),
                                Icon(
                                  controller.descExpanded.value
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: WallpaperService().hasAny
                                      ? WallpaperService()
                                          .onThemeColor
                                          .withOpacity(0.7)
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          )),
                      Obx(() => controller.descExpanded.value
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Divider(
                                      color: WallpaperService().hasAny
                                          ? WallpaperService()
                                              .onThemeColor
                                              .withOpacity(0.2)
                                          : colorScheme.primary
                                              .withOpacity(0.25),
                                      height: 1),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    style: TextStyle(
                                      height: 1.5,
                                      fontSize: 13,
                                      color: WallpaperService().hasAny
                                          ? WallpaperService().onThemeColor
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink()),
                      const SizedBox(height: 16),
                    ],

                    // Benefits
                    if (benefits.isNotEmpty) ...[
                      _buildSectionTitle(context,
                          t.translate('detailBenefitsTitle'), colorScheme),
                      const SizedBox(height: 8),
                      ..._parseBulletPoints(benefits).map(
                        (point) => _buildRequirementBullet(point, colorScheme),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Eligibility
                    if (eligibility.isNotEmpty) ...[
                      _buildSectionTitle(context,
                          t.translate('detailEligibilityTitle'), colorScheme),
                      const SizedBox(height: 8),
                      ..._parseBulletPoints(eligibility).map(
                        (point) => _buildRequirementBullet(point, colorScheme),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Required Documents
                    if (requiredDocs.isNotEmpty) ...[
                      _buildSectionTitle(context,
                          t.translate('detailDocumentsTitle'), colorScheme),
                      const SizedBox(height: 10),
                      ..._parseBulletPoints(requiredDocs).asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildStepItem(
                                number: e.key + 1,
                                text: e.value,
                                colorScheme: colorScheme,
                              ),
                            ),
                          ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: WallpaperService().hasAny
            ? WallpaperService().bottomNavColor
            : null,
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              // Official Link button (outlined)
              Expanded(
                child: OutlinedButton(
                  onPressed: scholarship.applicationLink.isNotEmpty
                      ? () => _launchLink(scholarship.applicationLink)
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: WallpaperService().hasAny
                        ? WallpaperService().onThemeColor
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(
                      color: WallpaperService().hasAny
                          ? WallpaperService().onThemeColor.withOpacity(0.6)
                          : colorScheme.outline,
                    ),
                  ),
                  child: Text(
                    t.translate('detailOfficialLink'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Apply button (filled, reactive on isApplying)
              Expanded(
                child: Obx(() => ElevatedButton(
                      onPressed: controller.isApplying.value
                          ? null
                          : () => _handleApply(context, controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isApplying.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              t.translate('detailApplyButton'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parse multi-line text into bullet points.
  /// Supports newline-separated, "- " prefixed, or "• " prefixed text.
  List<String> _parseBulletPoints(String text) {
    final lines = text
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.replaceFirst(RegExp(r'^[-•*]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return lines.isEmpty ? [text] : lines;
  }

  Widget _buildHeaderImage(
      BuildContext context,
      FirestoreScholarship scholarship,
      ColorScheme colorScheme,
      ScholarshipDetailController controller) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Main scholarship image (campus / building photo)
          if (scholarship.imageUrl.isNotEmpty)
            Image.network(
              scholarship.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _buildHeaderPlaceholder(colorScheme),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: progress.expectedTotalBytes != null
                          ? progress.cumulativeBytesLoaded /
                              progress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              },
            )
          else
            _buildHeaderPlaceholder(colorScheme),

          // Bookmark button (top-right), reactive
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () => _toggleBookmark(context, controller),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Obx(() => controller.isSaving.value
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.amber[700],
                        ),
                      )
                    : Icon(
                        controller.isSaved.value
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: controller.isSaved.value
                            ? WallpaperService().themedPrimary(colorScheme)
                            : colorScheme.onSurfaceVariant.withOpacity(0.5),
                        size: 22,
                      )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPlaceholder(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.25),
            colorScheme.primary.withOpacity(0.08),
          ],
        ),
      ),
      child: Center(
        child: Text(
          'Scholarship',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.primary.withOpacity(0.5),
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  // ── Small Logo (next to title) ─────────────────────────────────────────────

  Widget _buildSmallLogo(
      FirestoreScholarship scholarship, ColorScheme colorScheme) {
    final url = scholarship.logoUrl.isNotEmpty
        ? scholarship.logoUrl
        : scholarship.imageUrl;
    final ws = WallpaperService();
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: ws.hasAny ? ws.cardColor : colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: ws.hasAny
              ? ws.glassBorder
              : colorScheme.outlineVariant.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    _initials(scholarship.university),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary.withOpacity(0.75),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  _initials(scholarship.university),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary.withOpacity(0.75),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
      ),
    );
  }

  // ── 4-Column Info Grid ─────────────────────────────────────────────────────

  Widget _buildInfoGrid(BuildContext context, FirestoreScholarship scholarship,
      ColorScheme colorScheme) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
              color: WallpaperService().hasAny
                  ? WallpaperService().onThemeColor.withOpacity(0.2)
                  : colorScheme.outlineVariant.withOpacity(0.3)),
          bottom: BorderSide(
              color: WallpaperService().hasAny
                  ? WallpaperService().onThemeColor.withOpacity(0.2)
                  : colorScheme.outlineVariant.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          _buildInfoColumn(
            label: '${t.translate('discoverStudyAt')}:',
            value: scholarship.country,
            icon: Icons.location_on,
            color: colorScheme.primary,
            colorScheme: colorScheme,
          ),
          _buildInfoColumn(
            label: '${t.translate('discoverType')}:',
            value: scholarship.fundingType,
            icon: Icons.attach_money,
            color: colorScheme.primary,
            colorScheme: colorScheme,
          ),
          _buildInfoColumn(
            label: '${t.translate('detailDegreeLabel')}:',
            value: scholarship.degree,
            icon: Icons.school_outlined,
            color: colorScheme.primary,
            colorScheme: colorScheme,
          ),
          _buildInfoColumn(
            label: '${t.translate('discoverDeadline')}:',
            value: scholarship.formattedDeadline,
            icon: Icons.calendar_today,
            color: colorScheme.primary,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    final ws = WallpaperService();
    final effectiveAccent = ws.hasAny
        ? (ws.currentThemeData?.accentColor ?? ws.onThemeColor)
        : color;
    final labelColor = ws.hasAny
        ? ws.onThemeColor.withOpacity(0.7)
        : colorScheme.onSurfaceVariant;
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: labelColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Icon(icon, size: 22, color: effectiveAccent),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: effectiveAccent,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Action Buttons (Consult, Q&As, Share) ──────────────────────────────────

  Widget _buildActionButtons(BuildContext context,
      FirestoreScholarship scholarship, ColorScheme colorScheme) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final title = locale == 'km' && scholarship.titleKm.isNotEmpty
        ? scholarship.titleKm
        : scholarship.titleEn;

    return Row(
      children: [
        _buildActionChip(
          icon: Icons.headphones_rounded,
          label: t.translate('detailConsult'),
          colorScheme: colorScheme,
          onTap: () {
            if (scholarship.applicationLink.isNotEmpty) {
              _launchLink(scholarship.applicationLink);
            }
          },
        ),
        const SizedBox(width: 10),
        _buildActionChip(
          icon: Icons.question_answer_outlined,
          label: t.translate('detailQAs'),
          colorScheme: colorScheme,
          onTap: () {},
        ),
        const SizedBox(width: 10),
        _buildActionChip(
          icon: Icons.share_outlined,
          label: t.translate('detailShare'),
          colorScheme: colorScheme,
          onTap: () {
            final text =
                '$title\n${scholarship.university}\n${scholarship.applicationLink}';
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(t.translate('detailLinkCopied')),
                  duration: const Duration(seconds: 2)),
            );
          },
        ),
      ],
    );
  }

  String _initials(String input) {
    final words =
        input.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return 'SC';
    if (words.length == 1) {
      final w = words.first;
      return w.length >= 2 ? w.substring(0, 2).toUpperCase() : w.toUpperCase();
    }
    return '${words.first[0]}${words[1][0]}'.toUpperCase();
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: themed
              ? ws.glassCard(radius: 24)
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: colorScheme.outlineVariant.withOpacity(0.5)),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color:
                      themed ? ws.onThemeColor : colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: themed ? ws.onThemeColor : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── URL launcher ───────────────────────────────────────────────────────────

  Future<void> _launchLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Remaining helpers ──────────────────────────────────────────────────────

  Widget _buildSectionTitle(
      BuildContext context, String title, ColorScheme colorScheme) {
    final ws = WallpaperService();
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ws.hasTheme ? ws.onThemeColor : colorScheme.primary,
      ),
    );
  }

  Widget _buildRequirementBullet(String text, ColorScheme colorScheme) {
    final ws = WallpaperService();
    final dotColor = ws.hasAny
        ? (ws.currentThemeData?.accentColor ?? ws.onThemeColor)
        : colorScheme.primary;
    final textColor = ws.hasAny ? ws.onThemeColor : colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int number,
    required String text,
    required ColorScheme colorScheme,
  }) {
    final ws = WallpaperService();
    final circleColor = ws.hasAny
        ? (ws.currentThemeData?.accentColor ?? ws.onThemeColor)
        : colorScheme.primary;
    final textColor = ws.hasAny ? ws.onThemeColor : colorScheme.onSurface;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: textColor),
          ),
        ),
      ],
    );
  }
}