abstract class Routes {
  Routes._();

  // Authentication Routes
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify_email';
  static const String forgetPassword = '/forget_password';
  static const String resetPassword = '/reset_password';

  // Main App Routes
  static const String home = '/home';
  static const String discover = '/discover';
  static const String profile = '/profile';
  static const String editProfile = '/edit_profile';
  static const String notification = '/notification';
  static const String setting = '/setting';
  static const String settings = '/settings';

  // Search & Filter Routes
  static const String searchFilter = '/search_filter';
  static const String filterResult = '/filter_result';
  static const String searchResult = '/search_result';

  // Scholarship Routes
  static const String scholarshipDetail = '/scholarship_detail';
  static const String savedScholarship = '/saved_scholarship';
  static const String myApplications = '/my_applications';

  // Fill Information Routes
  static const String personalInfo = '/personal_info';
  static const String educationBackground = '/education_background';
  static const String workExperience = '/work_experience';
  static const String researchExperience = '/research_experience';
  static const String awardAchievement = '/award_achievement';
  static const String languages = '/languages';
  static const String reference = '/reference';
  static const String scholarshipPreference = '/scholarship_preference';

  // Additional Screens
  static const String displaySize = '/display_size';
  static const String fontPicker = '/font_picker';
  static const String fontSize = '/font_size';
  static const String helpSupport = '/help_support';
  static const String scholarshipMatch = '/scholarship_match';
  static const String chatAi = '/chat_ai';
  static const String wallpaper = '/wallpaper';
  static const String applicationStatus = '/application_status';

  // Admin Routes
  static const String adminDashboard = '/admin_dashboard';
  static const String manageScholarships = '/manage_scholarships';
  static const String manageUsers = '/manage_users';
  static const String statisticAnalytics = '/statistic_analytics';
  static const String userDetails = '/user_details';
}
