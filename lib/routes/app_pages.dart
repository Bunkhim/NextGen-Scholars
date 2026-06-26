import 'package:get/get.dart';
import 'package:scholarship_app/screens/authentication/splash_screen/splash_screen_view.dart';
import 'package:scholarship_app/screens/authentication/onboarding_screen/onboarding_screen_view.dart';
import 'package:scholarship_app/screens/authentication/login_screen/login_screen_view.dart';
import 'package:scholarship_app/screens/authentication/register_screen/register_screen_view.dart';
import 'package:scholarship_app/screens/authentication/verify_email_screen/verify_email_screen_view.dart';
import 'package:scholarship_app/screens/authentication/forget_password_screen/forget_password_screen_view.dart';
import 'package:scholarship_app/screens/authentication/reset_password_screen/reset_password_screen_view.dart';

import 'package:scholarship_app/screens/main_app/main_navigation_screen/main_navigation_screen_view.dart';
import 'package:scholarship_app/screens/main_app/discover_screen/discover_screen_view.dart';
import 'package:scholarship_app/screens/main_app/homescreens/homescreens_view.dart';
import 'package:scholarship_app/screens/main_app/profile_screen/profile_screen_view.dart';
import 'package:scholarship_app/screens/main_app/edit_profile/edit_profile_view.dart';
import 'package:scholarship_app/screens/main_app/notification_screen/notification_screen_view.dart';
import 'package:scholarship_app/screens/main_app/setting_screen/setting_screen_view.dart';
import 'package:scholarship_app/screens/main_app/settings_screen/settings_screen_view.dart';
import 'package:scholarship_app/screens/main_app/search_filter_screen/search_filter_screen_view.dart';
import 'package:scholarship_app/screens/main_app/filter_result_screen/filter_result_screen_view.dart';
import 'package:scholarship_app/screens/main_app/search_result_screen/search_result_screen_view.dart';
import 'package:scholarship_app/screens/main_app/display_size_screen/display_size_screen_view.dart';
import 'package:scholarship_app/screens/main_app/font_picker_screen/font_picker_screen_view.dart';
import 'package:scholarship_app/screens/main_app/font_size_screen/font_size_screen_view.dart';
import 'package:scholarship_app/screens/main_app/help_support_screen/help_support_screen_view.dart';
import 'package:scholarship_app/screens/main_app/scholarship_match_screen/scholarship_match_screen_view.dart';
import 'package:scholarship_app/screens/main_app/chat_ai_screen/chat_ai_screen_view.dart';
import 'package:scholarship_app/screens/main_app/wallpaper_screen/wallpaper_screen_view.dart';

import 'package:scholarship_app/screens/fill_information/personal_info_screen/personal_info_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/education_background_screen/education_background_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/work_experience_screen/work_experience_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/research_experience_screen/research_experience_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/award_achievement_screen/award_achievement_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/languages_screen/languages_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/reference_screen/reference_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/scholarship_preference_screen/scholarship_preference_screen_view.dart';

import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen/saved_scholarship_screen_view.dart';
import 'package:scholarship_app/screens/scholarship/scholarship_detail_screen/scholarship_detail_screen_view.dart';
import 'package:scholarship_app/screens/scholarship/my_applications_screen/my_applications_screen_view.dart';
import 'package:scholarship_app/screens/scholarship/application_status_screen/application_status_screen_view.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreenView(),
      binding: SplashScreenViewBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingScreenView(),
      binding: OnboardingScreenViewBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreenView(),
      binding: LoginScreenViewBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreenView(),
      binding: RegisterScreenViewBinding(),
    ),
    GetPage(
      name: Routes.verifyEmail,
      page: () => const VerifyEmailScreenView(),
      binding: VerifyEmailScreenViewBinding(),
    ),
    GetPage(
      name: Routes.forgetPassword,
      page: () => const ForgetPasswordScreenView(),
      binding: ForgetPasswordScreenViewBinding(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordScreenView(),
      binding: ResetPasswordScreenViewBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const MainNavigationScreenView(),
      binding: MainNavigationScreenViewBinding(),
    ),
    GetPage(
      name: Routes.discover,
      page: () => const DiscoverScreenView(),
      binding: DiscoverScreenViewBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreenView(),
      binding: ProfileScreenViewBinding(),
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileView(),
      binding: EditProfileViewBinding(),
    ),
    GetPage(
      name: Routes.notification,
      page: () => const NotificationScreenView(),
      binding: NotificationScreenViewBinding(),
    ),
    GetPage(
      name: Routes.setting,
      page: () => const SettingScreenView(),
      binding: SettingScreenViewBinding(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreenView(),
      binding: SettingsScreenViewBinding(),
    ),
    GetPage(
      name: Routes.searchFilter,
      page: () => const SearchFilterScreenView(),
      binding: SearchFilterScreenViewBinding(),
    ),
    GetPage(
      name: Routes.filterResult,
      page: () => const FilterResultScreenView(),
      binding: FilterResultScreenViewBinding(),
    ),
    GetPage(
      name: Routes.searchResult,
      page: () => const SearchResultScreenView(),
      binding: SearchResultScreenViewBinding(),
    ),
    GetPage(
      name: Routes.scholarshipDetail,
      page: () => const ScholarshipDetailScreenView(),
      binding: ScholarshipDetailScreenViewBinding(),
    ),
    GetPage(
      name: Routes.savedScholarship,
      page: () => const SavedScholarshipScreenView(),
      binding: SavedScholarshipScreenViewBinding(),
    ),
    GetPage(
      name: Routes.myApplications,
      page: () => const MyApplicationsScreenView(),
      binding: MyApplicationsScreenViewBinding(),
    ),
    GetPage(
      name: Routes.personalInfo,
      page: () => const PersonalInfoScreenView(),
      binding: PersonalInfoScreenViewBinding(),
    ),
    GetPage(
      name: Routes.educationBackground,
      page: () => const EducationBackgroundScreenView(),
      binding: EducationBackgroundScreenViewBinding(),
    ),
    GetPage(
      name: Routes.workExperience,
      page: () => const WorkExperienceScreenView(),
      binding: WorkExperienceScreenViewBinding(),
    ),
    GetPage(
      name: Routes.researchExperience,
      page: () => const ResearchExperienceScreenView(),
      binding: ResearchExperienceScreenViewBinding(),
    ),
    GetPage(
      name: Routes.awardAchievement,
      page: () => const AwardAchievementScreenView(),
      binding: AwardAchievementScreenViewBinding(),
    ),
    GetPage(
      name: Routes.languages,
      page: () => const LanguagesScreenView(),
      binding: LanguagesScreenViewBinding(),
    ),
    GetPage(
      name: Routes.reference,
      page: () => const ReferenceScreenView(),
      binding: ReferenceScreenViewBinding(),
    ),
    GetPage(
      name: Routes.scholarshipPreference,
      page: () => const ScholarshipPreferenceScreenView(),
      binding: ScholarshipPreferenceScreenViewBinding(),
    ),
    GetPage(
      name: Routes.displaySize,
      page: () => const DisplaySizeScreenView(),
      binding: DisplaySizeScreenViewBinding(),
    ),
    GetPage(
      name: Routes.fontPicker,
      page: () => const FontPickerScreenView(),
      binding: FontPickerScreenViewBinding(),
    ),
    GetPage(
      name: Routes.fontSize,
      page: () => const FontSizeScreenView(),
      binding: FontSizeScreenViewBinding(),
    ),
    GetPage(
      name: Routes.helpSupport,
      page: () => const HelpSupportScreenView(),
      binding: HelpSupportScreenViewBinding(),
    ),
    GetPage(
      name: Routes.scholarshipMatch,
      page: () => const ScholarshipMatchScreenView(),
      binding: ScholarshipMatchScreenViewBinding(),
    ),
    GetPage(
      name: Routes.chatAi,
      page: () => const ChatAiScreenView(),
      binding: ChatAiScreenViewBinding(),
    ),
    GetPage(
      name: Routes.wallpaper,
      page: () => const WallpaperScreenView(),
      binding: WallpaperScreenViewBinding(),
    ),
    GetPage(
      name: Routes.applicationStatus,
      page: () => const ApplicationStatusScreenView(),
      binding: ApplicationStatusScreenViewBinding(),
    ),
  ];
}
