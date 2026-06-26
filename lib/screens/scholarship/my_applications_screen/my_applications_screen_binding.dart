part of 'my_applications_screen_view.dart';

class MyApplicationsScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyApplicationsScreenViewController());
  }
}
