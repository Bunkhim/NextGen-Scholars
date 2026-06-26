import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/database/database.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/main_app/discover_screen/discover_screen_view.dart';
import 'package:scholarship_app/screens/main_app/profile_screen/profile_screen_view.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen/saved_scholarship_screen_view.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/services/application_service.dart';
import 'package:scholarship_app/services/scholarship_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

part 'scholarship_detail_screen_binding.dart';
part 'scholarship_detail_screen_controller.dart';

class ScholarshipDetailScreenView
    extends GetView<ScholarshipDetailScreenViewController> {
  const ScholarshipDetailScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final scholarship = controller.scholarship.value;

    if (scholarship == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 30, color: colorScheme.onPrimary),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(child: Text(t.translate('detailNotFound'))),
      );
    }

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
          onPressed: () => Get.back(),
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
              _buildHeaderImage(scholarship, colorScheme),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    _buildInfoGrid(context, scholarship, colorScheme),
                    const SizedBox(height: 14),
                    _buildActionButtons(context, scholarship, colorScheme),
                    const SizedBox(height: 14),
                    Divider(
                        color: WallpaperService().hasAny
                            ? WallpaperService().onThemeColor.withOpacity(0.2)
                            : colorScheme.outlineVariant.withOpacity(0.4),
                        height: 1),
                    const SizedBox(height: 14),
                    Obx(() {
                      if (description.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => controller.toggleDesc(),
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
                          ),
                          if (controller.descExpanded.value) ...[
                            const SizedBox(height: 4),
                            Divider(
                                color: WallpaperService().hasAny
                                    ? WallpaperService()
                                        .onThemeColor
                                        .withOpacity(0.2)
                                    : colorScheme.primary.withOpacity(0.25),
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
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                    if (benefits.isNotEmpty) ...[
                      _buildSectionTitle(context,
                          t.translate('detailBenefitsTitle'), colorScheme),
                      const SizedBox(height: 8),
                      ..._parseBulletPoints(benefits).map(
                        (point) => _buildRequirementBullet(point, colorScheme),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (eligibility.isNotEmpty) ...[
                      _buildSectionTitle(context,
                          t.translate('detailEligibilityTitle'), colorScheme),
                      const SizedBox(height: 8),
                      ..._parseBulletPoints(eligibility).map(
                        (point) => _buildRequirementBullet(point, colorScheme),
                      ),
                      const SizedBox(height: 16),
                    ],
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
              Expanded(
                child: Obx(() => ElevatedButton(
                      onPressed: controller.applying.value
                          ? null
                          : () => _handleApply(context, scholarship),
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
                      child: controller.applying.value
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

  Future<void> _handleApply(
      BuildContext context, FirestoreScholarship scholarship) async {
    final t = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final appData = ApplicationData();
    if (!appData.isProfileComplete) {
      final missing = appData.incompleteSections;
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
              ...missing.map((s) => Padding(
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
              onPressed: () => Get.back(),
              child: Text(t.translate('applyCancel')),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Text(t.translate('applyFillNow')),
            ),
          ],
        ),
      );
      if (goFill == true) {
        Get.toNamed(Routes.personalInfo);
      }
      return;
    }

    final alreadyApplied =
        await ApplicationService().hasApplied(scholarship.id);
    if (alreadyApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('applyAlreadyApplied'))),
      );
      return;
    }

    final freshScholarship =
        await ScholarshipService().getScholarshipById(scholarship.id);
    if (freshScholarship == null || !freshScholarship.isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('applyScholarshipUnavailable')),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    controller.applying.value = true;
    final result = await ApplicationService().apply(scholarship);
    controller.applying.value = false;

    if (result != null) {
      ProfileScreenViewController.refreshNotifier.value++;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: Text(t.translate('applySuccessTitle')),
          content: Text(t.translate('applySuccessMsg')),
          actions: [
            ElevatedButton(
              onPressed: () {
                Get.back();
                Get.toNamed(Routes.myApplications);
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('applyFailed'))),
      );
    }
  }

  List<String> _parseBulletPoints(String text) {
    final lines = text
        .split(RegExp(r'[\n\r]+'))
        .map((line) => line.replaceFirst(RegExp(r'^[-•*]\s*'), '').trim())
        .where((line) => line.isNotEmpty)
        .toList();
    return lines.isEmpty ? [text] : lines;
  }

  Widget _buildHeaderImage(
      FirestoreScholarship scholarship, ColorScheme colorScheme) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
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
          Positioned(
            top: 12,
            right: 12,
            child: Obx(() => GestureDetector(
                  onTap: () => controller.toggleBookmark(scholarship),
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
                    child: controller.isSaving.value
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
                          ),
                  ),
                )),
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

  Future<void> _launchLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
