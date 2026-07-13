import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/application_service.dart';

/// Controller for [ApplicationStatusScreen].
///
/// Owns the reactive application state and the pure status-derived logic
/// (icon/color/date formatting) so the widget tree can stay declarative.
/// Text that depends on `AppLocalizations` still lives in the widget, since
/// that needs a `BuildContext`.
///
/// Auto-refresh: `ApplicationService` has no single-document getter, so
/// instead of polling, this controller subscribes to
/// `streamMyApplications()` (a live Firestore snapshot listener) and picks
/// out the matching application by id. Any status change made elsewhere
/// (e.g. by an admin) is reflected here automatically, no manual refresh
/// needed.
class ApplicationStatusController extends GetxController {
  ApplicationStatusController(ScholarshipApplication initial)
      : application = initial.obs;

  /// The current application, kept in sync with Firestore.
  final Rx<ScholarshipApplication> application;

  final RxString errorMessage = ''.obs;

  StreamSubscription<List<ScholarshipApplication>>? _sub;

  String get id => application.value.id;
  String get status => application.value.status;
  int get stepIndex => application.value.stepIndex;
  bool get isAccepted => application.value.isAccepted;
  bool get isRejected => application.value.isRejected;
  bool get isInterview => application.value.isInterview;

  @override
  void onInit() {
    super.onInit();
    _sub = ApplicationService().streamMyApplications().listen(
      (apps) {
        final match = apps.where((a) => a.id == id);
        if (match.isNotEmpty) {
          application.value = match.first;
        }
      },
      onError: (_) {
        errorMessage.value = 'Failed to load application updates.';
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  // ── Pure status-derived helpers (no context/translation needed) ─────────

  IconData get statusIcon {
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

  Color get statusColor {
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

  String get formattedAppliedDate => _formatDate(application.value.appliedAt);

  String get truncatedId => id.length > 8 ? '${id.substring(0, 8)}...' : id;

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}