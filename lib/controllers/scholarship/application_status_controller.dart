import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/application_service.dart';

/// Controller for [ApplicationStatusScreen].
///
/// Loads the application from the backend API and polls for updates.
class ApplicationStatusController extends GetxController {
  ApplicationStatusController(ScholarshipApplication initial)
      : application = initial.obs;

  /// The current application, kept in sync via polling.
  final Rx<ScholarshipApplication> application;

  final RxString errorMessage = ''.obs;

  Timer? _pollTimer;

  String get id => application.value.id;
  String get status => application.value.status;
  int get stepIndex => application.value.stepIndex;
  bool get isAccepted => application.value.isAccepted;
  bool get isRejected => application.value.isRejected;
  bool get isInterview => application.value.isInterview;

  @override
  void onInit() {
    super.onInit();
    _refreshApplication();
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refreshApplication());
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  Future<void> _refreshApplication() async {
    try {
      final fresh = await ApplicationService().getApplication(id);
      if (fresh != null) {
        application.value = fresh;
      }
    } catch (_) {
      errorMessage.value = 'Failed to load application updates.';
    }
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
