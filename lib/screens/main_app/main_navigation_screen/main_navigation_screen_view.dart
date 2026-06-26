import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/screens/main_app/chat_ai_screen/chat_ai_screen_view.dart';
import 'package:scholarship_app/screens/main_app/discover_screen/discover_screen_view.dart';
import 'package:scholarship_app/screens/main_app/homescreens/homescreens_view.dart';
import 'package:scholarship_app/screens/main_app/profile_screen/profile_screen_view.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen/saved_scholarship_screen_view.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/bottom_nav_bar.dart';
import 'package:scholarship_app/screens/fill_information/personal_info_screen/personal_info_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/education_background_screen/education_background_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/work_experience_screen/work_experience_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/research_experience_screen/research_experience_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/award_achievement_screen/award_achievement_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/languages_screen/languages_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/reference_screen/reference_screen_view.dart';
import 'package:scholarship_app/screens/fill_information/scholarship_preference_screen/scholarship_preference_screen_view.dart';
import 'package:scholarship_app/screens/main_app/settings_screen/settings_screen_view.dart';
import 'package:scholarship_app/screens/main_app/notification_screen/notification_screen_view.dart';
import 'package:scholarship_app/screens/main_app/help_support_screen/help_support_screen_view.dart';
import 'package:scholarship_app/screens/main_app/scholarship_match_screen/scholarship_match_screen_view.dart';
import 'package:scholarship_app/screens/main_app/edit_profile/edit_profile_view.dart';
import 'package:scholarship_app/screens/main_app/font_picker_screen/font_picker_screen_view.dart';
import 'package:scholarship_app/screens/main_app/font_size_screen/font_size_screen_view.dart';
import 'package:scholarship_app/screens/main_app/display_size_screen/display_size_screen_view.dart';
import 'package:scholarship_app/screens/main_app/wallpaper_screen/wallpaper_screen_view.dart';

part 'main_navigation_screen_binding.dart';
part 'main_navigation_screen_controller.dart';

class MainNavigationScreenView extends StatefulWidget {
  const MainNavigationScreenView({super.key});

  @override
  State<MainNavigationScreenView> createState() =>
      _MainNavigationScreenViewState();
}

class _MainNavigationScreenViewState extends State<MainNavigationScreenView> {
  late final ctrl = Get.find<MainNavigationScreenViewController>();

  final List<Widget> _pages = const [
    HomeScreenView(),
    DiscoverScreenView(),
    ChatAiScreenView(),
    SavedScholarshipScreenView(),
    ProfileScreenView(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(
        () => IndexedStack(
          key: ValueKey(WallpaperService().hasAny),
          index: ctrl.currentIndex.value,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => ModernBottomNavBar(
          currentIndex: ctrl.currentIndex.value,
          onTap: (index) =>
              MainNavigationScreenViewController.tabNotifier.value = index,
          items: [
            NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: t.translate('navHome'),
            ),
            NavItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore_rounded,
              label: t.translate('navDiscover'),
            ),
            NavItem(
              icon: Icons.auto_awesome_outlined,
              activeIcon: Icons.auto_awesome,
              label: t.translate('navChatAI'),
            ),
            NavItem(
              icon: Icons.bookmark_border_rounded,
              activeIcon: Icons.bookmark_rounded,
              label: t.translate('navSaved'),
            ),
            NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: t.translate('navProfile'),
            ),
          ],
          centerIndex: 2,
        ),
      ),
      extendBody: true,
    );
  }
}
