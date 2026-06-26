part of 'main_navigation_screen_view.dart';

class MainNavigationScreenViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainNavigationScreenViewController());
    Get.lazyPut(() => HomeScreenViewController());
    Get.lazyPut(() => DiscoverScreenViewController());
    Get.lazyPut(() => ProfileScreenViewController());
    Get.lazyPut(() => SavedScholarshipScreenViewController());
    Get.lazyPut(() => ChatAiScreenViewController());

    // Fill info screens
    Get.lazyPut(() => PersonalInfoScreenViewController());
    Get.lazyPut(() => EducationBackgroundScreenViewController());
    Get.lazyPut(() => WorkExperienceScreenViewController());
    Get.lazyPut(() => ResearchExperienceScreenViewController());
    Get.lazyPut(() => AwardAchievementScreenViewController());
    Get.lazyPut(() => LanguagesScreenViewController());
    Get.lazyPut(() => ReferenceScreenViewController());
    Get.lazyPut(() => ScholarshipPreferenceScreenViewController());

    // Settings & display screens
    Get.lazyPut(() => SettingsScreenViewController());
    Get.lazyPut(() => NotificationScreenViewController());
    Get.lazyPut(() => HelpSupportScreenViewController());
    Get.lazyPut(() => ScholarshipMatchScreenViewController());
    Get.lazyPut(() => EditProfileViewController());
    Get.lazyPut(() => FontPickerScreenViewController());
    Get.lazyPut(() => FontSizeScreenViewController());
    Get.lazyPut(() => DisplaySizeScreenViewController());
    Get.lazyPut(() => WallpaperScreenViewController());
  }
}
