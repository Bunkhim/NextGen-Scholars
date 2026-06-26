part of 'research_experience_screen_view.dart';

class ResearchExperienceScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ResearchExperienceScreenViewController());
  }
}
