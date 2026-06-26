part of 'application_status_screen_view.dart';

class ApplicationStatusScreenViewController extends GetxController {
  late final ScholarshipApplication application;

  @override
  void onInit() {
    super.onInit();
    application = Get.arguments as ScholarshipApplication;
  }
}
