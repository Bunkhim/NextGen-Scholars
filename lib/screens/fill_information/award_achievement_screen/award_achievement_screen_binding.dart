part of 'award_achievement_screen_view.dart';

class AwardAchievementScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AwardAchievementScreenViewController());
  }
}
