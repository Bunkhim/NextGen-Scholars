part of 'education_background_screen_view.dart';

class EducationBackgroundScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EducationBackgroundScreenViewController());
  }
}
