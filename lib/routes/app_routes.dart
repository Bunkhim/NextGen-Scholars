import 'package:get/get.dart';
import 'package:scholarship_app/screens/authentication/forget_password_screen.dart';
import 'package:scholarship_app/screens/authentication/login_screen.dart';
import 'package:scholarship_app/screens/authentication/onboarding_screen.dart';
import 'package:scholarship_app/screens/authentication/register_screen.dart';
import 'package:scholarship_app/screens/authentication/reset_password_screen.dart';
import 'package:scholarship_app/screens/authentication/splash_screen.dart';
import 'package:scholarship_app/screens/authentication/verify_email_screen.dart';
import 'package:scholarship_app/screens/fill_information/award_achievement_screen.dart';
import 'package:scholarship_app/screens/fill_information/education_background_screen.dart';
import 'package:scholarship_app/screens/fill_information/languages_screen.dart';
import 'package:scholarship_app/screens/fill_information/personal_info_screen.dart'; // ADDED IMPORT
import 'package:scholarship_app/screens/fill_information/reference_screen.dart';
import 'package:scholarship_app/screens/fill_information/research_experience_screen.dart';
import 'package:scholarship_app/screens/fill_information/scholarship_preference_screen.dart';
import 'package:scholarship_app/screens/fill_information/work_experience_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/edit_profile.dart';
import 'package:scholarship_app/screens/main_app/filter_result_screen.dart';
import 'package:scholarship_app/screens/main_app/main_navigation_screen.dart';
import 'package:scholarship_app/screens/main_app/notification_screen.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/main_app/search_filter_screen.dart';
import 'package:scholarship_app/screens/main_app/search_result_screen.dart';
import 'package:scholarship_app/screens/main_app/settings_screen.dart';
import 'package:scholarship_app/screens/scholarship/my_applications_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/screens/scholarship/scholarship_detail_screen.dart';

class AppRoutes {
  // Authentication Routes
  static const String splashScreen = '/splash_screen';
  static const String onboardingScreen = '/onboarding_screen';
  static const String loginScreen = '/login_screen';
  static const String registerScreen = '/register_screen';
  static const String verifyEmailScreen = '/verify_email_screen';
  static const String forgetPasswordScreen = '/forget_password_screen';
  static const String resetPasswordScreen = '/reset_password_screen';

  // Main App Routes
  static const String homeScreen = '/home_screen';
  static const String discoverScreen = '/discover_screen';
  static const String profileScreen = '/profile_screen';
  static const String editProfileScreen = '/edit_profile_screen';
  static const String notificationScreen = '/notification_screen';
  static const String settingScreen = '/setting_screen';

  // ── NEW: Search & Filter Routes ──────────
  static const String searchFilterScreen = '/search_filter_screen';
  static const String filterResultScreen = '/filter_result_screen';
  static const String searchResultScreen = '/search_result_screen';
  static const String settingsScreen = '/settings_screen';

  // Scholarship Routes
  static const String scholarshipDetailScreen = '/scholarship_detail_screen';
  static const String savedScholarshipScreen = '/saved_scholarship_screen';
  static const String myApplicationsScreen = '/my_applications_screen';

  // Fill Information Routes
  static const String personalInfoScreen = '/personal_info_screen';
  static const String educationBackgroundScreen =
      '/education_background_screen';
  static const String workExperienceScreen = '/work_experience_screen';
  static const String researchExperienceScreen = '/research_experience_screen';
  static const String awardAchievementScreen = '/award_achievement_screen';
  static const String languagesScreen = '/languages_screen';
  static const String referenceScreen = '/reference_screen';
  static const String scholarshipPreferenceScreen =
      '/scholarship_preference_screen';

  // Admin Routes
  static const String adminDashboardScreen = '/admin_dashboard_screen';
  static const String manageScholarshipsScreen = '/manage_scholarships_screen';
  static const String manageUsersScreen = '/manage_users_screen';
  static const String statisticAnalyticsScreen = '/statistic_analytics_screen';
  static const String userDetailsScreen = '/user_details_screen';

  static final List<GetPage> getPages = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: onboardingScreen, page: () => OnboardingScreen()),
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: registerScreen, page: () => RegisterScreen()),
    GetPage(
      name: verifyEmailScreen,
      page: () {
        final args = Get.arguments;
        if (args is Map) {
          return VerifyEmailScreen(
            type: args['type'] ?? 'email',
            destination: args['destination'] ?? '',
            purpose: args['purpose'] ?? 'forgotPassword',
          );
        }
        return VerifyEmailScreen(
          type: 'email',
          destination: (args as String?) ?? 'your email',
        );
      },
    ),
    GetPage(name: forgetPasswordScreen, page: () => ForgetPasswordScreen()),
    GetPage(
      name: resetPasswordScreen,
      page: () {
        final args = Get.arguments;
        final map = args is Map<String, dynamic> ? args : <String, dynamic>{};
        return ResetPasswordScreen(email: map['email'] ?? '');
      },
    ),
    GetPage(name: discoverScreen, page: () => DiscoverScreen()),
    GetPage(name: homeScreen, page: () => MainNavigationScreen()),
    GetPage(name: profileScreen, page: () => ProfileScreen()),
    GetPage(name: editProfileScreen, page: () => EditProfileScreen()),
    GetPage(name: notificationScreen, page: () => NotificationsScreen()),
    GetPage(name: settingScreen, page: () => SettingsScreen()),
    GetPage(name: settingsScreen, page: () => SettingsScreen()),
    GetPage(name: searchFilterScreen, page: () => SearchFilterScreen()),
    GetPage(name: filterResultScreen, page: () => FilterResultScreen()),
    GetPage(
      name: searchResultScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        return SearchResultScreen(
          searchQuery: args?['searchQuery'] as String? ?? '',
          filterCountry: args?['filterCountry'] as String?,
          filterType: args?['filterType'] as String?,
        );
      },
    ),
    GetPage(name: scholarshipDetailScreen, page: () => ScholarshipDetailScreen()),
    GetPage(name: savedScholarshipScreen, page: () => SavedScholarshipScreen()),
    GetPage(name: myApplicationsScreen, page: () => MyApplicationsScreen()),
    GetPage(name: personalInfoScreen, page: () => const PersonalInfoScreen()),
    GetPage(name: educationBackgroundScreen, page: () => const EducationBackgroundScreen()),
    GetPage(name: languagesScreen, page: () => const LanguagesScreen()),
    GetPage(name: workExperienceScreen, page: () => const WorkExperienceScreen()),
    GetPage(name: researchExperienceScreen, page: () => const ResearchExperienceScreen()),
    GetPage(name: awardAchievementScreen, page: () => const AwardAchievementScreen()),
    GetPage(name: scholarshipPreferenceScreen, page: () => const ScholarshipPreferenceScreen()),
    GetPage(name: referenceScreen, page: () => const ReferenceScreen()),
  ];
}
