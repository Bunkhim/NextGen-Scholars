part of 'application_status_screen_view.dart';

class ApplicationStatusScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ApplicationStatusScreenViewController());
  }
}
