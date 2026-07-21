import 'package:get/get.dart';
import 'package:scholarship_app/services/application_service.dart';

/// Controller for [MyApplicationsScreen].
class MyApplicationsController extends GetxController {
  final RxList<ScholarshipApplication> applications =
      <ScholarshipApplication>[].obs;

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  Future<void> loadApplications() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final apps = await ApplicationService().fetchMyApplications();
      applications.assignAll(apps);
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = 'Failed to load your applications.';
    }
  }

  bool get isEmpty => applications.isEmpty;

  int get total => applications.length;

  int get pendingCount =>
      applications.where((a) => a.isSubmitted || a.isUnderReview).length;

  int get acceptedCount => applications.where((a) => a.isAccepted).length;

  int get rejectedCount => applications.where((a) => a.isRejected).length;
}
