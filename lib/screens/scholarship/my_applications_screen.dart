// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/scholarship/my_applications_controller.dart';
import 'package:scholarship_app/screens/scholarship/application_status_screen.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  late final MyApplicationsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(MyApplicationsController());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: WallpaperService().hasTheme
            ? WallpaperService().appBarColor
            : colorScheme.surface,
        surfaceTintColor: WallpaperService().hasTheme
            ? Colors.transparent
            : Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    color: WallpaperService().hasTheme
                        ? WallpaperService().onThemeColor
                        : colorScheme.onSurface,
                    size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        titleSpacing: Navigator.canPop(context) ? 0 : 20,
        title: Text(
          t.translate('myApplicationsTitle'),
          style: TextStyle(
            color: WallpaperService().hasTheme
                ? WallpaperService().onThemeColor
                : colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  t.translate('myApplicationsError'),
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.send_outlined,
                    size: 64, color: colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  t.translate('myApplicationsEmpty'),
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        final apps = controller.applications;

        return Column(
          children: [
            // ── Summary bar ──────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SummaryItem(
                      count: controller.total,
                      label: t.translate('myAppTotal'),
                      color: WallpaperService().themedPrimary(colorScheme)),
                  _SummaryItem(
                      count: controller.pendingCount,
                      label: t.translate('myAppPending'),
                      color: Colors.orange),
                  _SummaryItem(
                      count: controller.acceptedCount,
                      label: t.translate('myAppAccepted'),
                      color: Colors.green),
                  _SummaryItem(
                      count: controller.rejectedCount,
                      label: t.translate('myAppReject'),
                      color: Colors.red),
                ],
              ),
            ),
            const Divider(height: 1),

            // ── Application list ─────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: apps.length,
                itemBuilder: (context, i) =>
                    _ApplicationCard(application: apps[i]),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Summary Item ──────────────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Application Card ──────────────────────────────────────────────────────────

class _ApplicationCard extends StatelessWidget {
  final ScholarshipApplication application;

  const _ApplicationCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final ws = WallpaperService();
    final themed = ws.hasTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: themed
          ? ws.glassCard(radius: 14)
          : BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title + status badge ───────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  application.scholarshipTitle,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: application.status),
            ],
          ),
          const SizedBox(height: 6),

          // ── University + Date ──────────────────────────────────
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 14, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${application.university}, ${application.country}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${t.translate('myAppApplied')}: ${_formatDate(application.appliedAt)}',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.translate('myAppProcess'),
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 12),

          // ── Progress bar ───────────────────────────────────────
          _ProgressBar(
              step: application.stepIndex, isRejected: application.isRejected),
          const SizedBox(height: 8),

          // ── Step labels ────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.translate('myAppStepSubmitted'),
                  style: TextStyle(
                      fontSize: 11, color: colorScheme.onSurfaceVariant)),
              Text(t.translate('myAppStepReview'),
                  style: TextStyle(
                      fontSize: 11, color: colorScheme.onSurfaceVariant)),
              Text(t.translate('myAppStepResult'),
                  style: TextStyle(
                      fontSize: 11, color: colorScheme.onSurfaceVariant)),
            ],
          ),

          const SizedBox(height: 12),

          // ── Action button ──────────────────────────────────────
          _ActionButton(application: application),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

// ── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'submitted':
        bg = Colors.orange.withOpacity(0.12);
        fg = Colors.orange;
        label = 'Pending';
        break;
      case 'under_review':
        bg = Colors.blue.withOpacity(0.12);
        fg = Colors.blue;
        label = 'Under Review';
        break;
      case 'interview':
        bg = Colors.teal.withOpacity(0.12);
        fg = Colors.teal;
        label = 'Interview Schedule';
        break;
      case 'accepted':
        bg = Colors.green.withOpacity(0.12);
        fg = Colors.green;
        label = 'Accepted';
        break;
      case 'rejected':
        bg = Colors.red.withOpacity(0.12);
        fg = Colors.red;
        label = 'Rejected';
        break;
      default:
        bg = Colors.grey.withOpacity(0.12);
        fg = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ── Progress Bar with 3 steps ─────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int step; // 0 = submitted, 1 = review, 2 = result
  final bool isRejected;

  const _ProgressBar({required this.step, this.isRejected = false});

  @override
  Widget build(BuildContext context) {
    final activeColor = isRejected ? Colors.red : Colors.green;

    return Row(
      children: [
        _StepCircle(done: step >= 0, color: activeColor),
        Expanded(child: _StepLine(done: step >= 1, color: activeColor)),
        _StepCircle(done: step >= 1, color: activeColor),
        Expanded(child: _StepLine(done: step >= 2, color: activeColor)),
        _StepCircle(
          done: step >= 2,
          color: activeColor,
          showClock: step < 2,
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final bool done;
  final Color color;
  final bool showClock;

  const _StepCircle({
    required this.done,
    required this.color,
    this.showClock = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showClock) {
      return Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
      );
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? color : Colors.grey.shade200,
      ),
      child:
          done ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
    );
  }
}

class _StepLine extends StatelessWidget {
  final bool done;
  final Color color;

  const _StepLine({required this.done, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: done ? color : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final ScholarshipApplication application;

  const _ActionButton({required this.application});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    String label;
    Color bg;
    Color fg;
    bool filled;

    switch (application.status) {
      case 'accepted':
        label = t.translate('myAppViewLetter');
        bg = Colors.green;
        fg = Colors.white;
        filled = true;
        break;
      case 'interview':
        label = t.translate('myAppViewInterview');
        bg = Colors.white;
        fg = WallpaperService().themedPrimary(colorScheme);
        filled = false;
        break;
      case 'rejected':
        label = t.translate('myAppViewDetails');
        bg = Colors.white;
        fg = Colors.red;
        filled = false;
        break;
      default:
        label = t.translate('myAppTrack');
        bg = Colors.white;
        fg = WallpaperService().themedPrimary(colorScheme);
        filled = false;
    }

    void navigate() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ApplicationStatusScreen(application: application),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: filled
          ? ElevatedButton(
              onPressed: navigate,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            )
          : OutlinedButton(
              onPressed: navigate,
              style: OutlinedButton.styleFrom(
                foregroundColor: fg,
                side: BorderSide(color: fg),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
    );
  }
}