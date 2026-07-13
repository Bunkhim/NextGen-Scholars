import 'dart:async';

import 'package:get/get.dart';
import 'package:scholarship_app/services/application_service.dart';

/// Controller for [MyApplicationsScreen].
///
/// Subscribes to `ApplicationService().streamMyApplications()` and exposes
/// the list plus derived summary counts as reactive state, so the screen
/// can drop its `StreamBuilder`/`StatefulWidget` in favor of `Obx`.
class MyApplicationsController extends GetxController {
  final RxList<ScholarshipApplication> applications =
      <ScholarshipApplication>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<ScholarshipApplication>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = ApplicationService().streamMyApplications().listen(
      (apps) {
        applications.assignAll(apps);
        isLoading.value = false;
        errorMessage.value = '';
      },
      onError: (_) {
        isLoading.value = false;
        errorMessage.value = 'Failed to load your applications.';
      },
    );
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  bool get isEmpty => applications.isEmpty;

  int get total => applications.length;

  int get pendingCount =>
      applications.where((a) => a.isSubmitted || a.isUnderReview).length;

  int get acceptedCount => applications.where((a) => a.isAccepted).length;

  int get rejectedCount => applications.where((a) => a.isRejected).length;
}