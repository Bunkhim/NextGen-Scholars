// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/scholarship/application_status_controller.dart';
import 'package:scholarship_app/services/application_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class ApplicationStatusScreen extends StatelessWidget {
  final ScholarshipApplication application;

  ApplicationStatusScreen({super.key, required this.application});

  late final ApplicationStatusController controller = Get.put(
    ApplicationStatusController(application),
    tag: application.id,
  );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);
    final ws = WallpaperService();
    final hasTheme = ws.hasTheme;

    return Scaffold(
      backgroundColor: hasTheme
          ? Colors.transparent
          : (isDark ? cs.surface : const Color(0xFFF2F4F8)),
      appBar: AppBar(
        backgroundColor: hasTheme
            ? ws.appBarColor
            : (isDark ? cs.surface : const Color(0xFFF2F4F8)),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: hasTheme ? ws.onThemeColor : cs.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t.translate('trackTitle'),
          style: TextStyle(
            color: hasTheme ? ws.onThemeColor : cs.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        // Single reactive read: controller.application.value updates live
        // whenever Firestore pushes a new snapshot for this application.
        final app = controller.application.value;
        final error = controller.errorMessage.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ],

              // ── Scholarship Info Card ────────────────────────────
              _InfoCard(application: app),
              const SizedBox(height: 24),

              // ── Timeline ─────────────────────────────────────────
              _SectionLabel(t.translate('trackTimeline')),
              const SizedBox(height: 12),
              _TimelineCard(application: app),
              const SizedBox(height: 24),

              // ── Details Card ─────────────────────────────────────
              _SectionLabel(t.translate('trackDetails')),
              const SizedBox(height: 12),
              _DetailsCard(application: app),

              // ── Status-specific Card ─────────────────────────────
              if (app.isAccepted) ...[
                const SizedBox(height: 24),
                _AcceptedCard(),
              ],
              if (app.isRejected) ...[
                const SizedBox(height: 24),
                _RejectedCard(),
              ],
              if (app.isInterview) ...[
                const SizedBox(height: 24),
                _InterviewCard(),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final ScholarshipApplication application;
  const _InfoCard({required this.application});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.school_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.scholarshipTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${application.university}, ${application.country}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_statusIcon(application.status),
                    color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  application.statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'submitted':
        return Icons.send_rounded;
      case 'under_review':
        return Icons.hourglass_top_rounded;
      case 'interview':
        return Icons.event_rounded;
      case 'accepted':
        return Icons.check_circle_rounded;
      case 'rejected':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline;
    }
  }
}

// ── Timeline Card ─────────────────────────────────────────────────────────────

class _TimelineCard extends StatelessWidget {
  final ScholarshipApplication application;
  const _TimelineCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    final steps = [
      _TimelineStep(
        title: t.translate('trackStepSubmitted'),
        subtitle: t.translate('trackStepSubmittedDesc'),
        date: _formatDate(application.appliedAt),
        isDone: application.stepIndex >= 0,
        isActive: application.status == 'submitted',
        icon: Icons.send_rounded,
      ),
      _TimelineStep(
        title: t.translate('trackStepReview'),
        subtitle: t.translate('trackStepReviewDesc'),
        date: application.stepIndex >= 1 ? t.translate('trackInProgress') : '',
        isDone: application.stepIndex >= 1,
        isActive:
            application.status == 'under_review' || application.isInterview,
        icon: Icons.rate_review_rounded,
      ),
      _TimelineStep(
        title: application.isRejected
            ? t.translate('trackStepRejected')
            : application.isAccepted
                ? t.translate('trackStepAccepted')
                : t.translate('trackStepResult'),
        subtitle: application.isRejected
            ? t.translate('trackStepRejectedDesc')
            : application.isAccepted
                ? t.translate('trackStepAcceptedDesc')
                : t.translate('trackStepResultDesc'),
        date: application.stepIndex >= 2 ? t.translate('trackCompleted') : '',
        isDone: application.stepIndex >= 2,
        isActive: application.isAccepted || application.isRejected,
        icon: application.isRejected
            ? Icons.cancel_rounded
            : Icons.check_circle_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
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
        children: List.generate(steps.length, (i) {
          final step = steps[i];
          final isLast = i == steps.length - 1;

          final Color dotColor;
          if (step.isDone) {
            if (application.isRejected && isLast) {
              dotColor = Colors.red;
            } else {
              dotColor = Colors.green;
            }
          } else {
            dotColor = Colors.grey.shade300;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Timeline dot + line ─────────────────────────
              SizedBox(
                width: 36,
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor,
                        boxShadow: step.isDone
                            ? [
                                BoxShadow(
                                  color: dotColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        step.isDone ? step.icon : Icons.circle_outlined,
                        color: step.isDone ? Colors.white : Colors.grey,
                        size: 16,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 56,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: step.isDone
                            ? Colors.green.withOpacity(0.4)
                            : Colors.grey.shade200,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // ── Content ─────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: step.isDone
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (step.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1565C0).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                t.translate('trackCurrent'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      if (step.date.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          step.date,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final String date;
  final bool isDone;
  final bool isActive;
  final IconData icon;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isDone,
    required this.isActive,
    required this.icon,
  });
}

// ── Details Card ──────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final ScholarshipApplication application;
  const _DetailsCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
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
        children: [
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: t.translate('trackAppliedDate'),
            value: _formatDate(application.appliedAt),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.school_rounded,
            label: t.translate('trackScholarship'),
            value: application.scholarshipTitle,
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.location_on_outlined,
            label: t.translate('trackUniversity'),
            value: '${application.university}, ${application.country}',
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.assignment_turned_in_rounded,
            label: t.translate('trackStatus'),
            value: application.statusLabel,
            valueColor: _statusColor(application.status),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.tag_rounded,
            label: t.translate('trackAppId'),
            value: application.id.length > 8
                ? '${application.id.substring(0, 8)}...'
                : application.id,
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
      case 'interview':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: valueColor ?? cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Status-specific Cards ─────────────────────────────────────────────────────

class _AcceptedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.celebration_rounded,
                color: Colors.green, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.translate('trackCongrats'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.translate('trackCongratsDesc'),
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.sentiment_neutral_rounded,
                color: Colors.red, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.translate('trackRejectedTitle'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.translate('trackRejectedDesc'),
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InterviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.teal.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child:
                const Icon(Icons.event_rounded, color: Colors.teal, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.translate('trackInterviewTitle'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.translate('trackInterviewDesc'),
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
