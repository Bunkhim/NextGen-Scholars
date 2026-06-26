part of 'work_experience_screen_view.dart';

class WorkExperienceScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WorkExperienceScreenViewController());
  }
}
