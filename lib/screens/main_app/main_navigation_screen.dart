import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/screens/main_app/chat_ai_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/homescreens.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/widgets/bottom_nav_bar.dart';
import 'package:scholarship_app/controllers/main_app/main_navigation_controller.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  /// Use this from any embedded tab to switch to a different tab.
  /// Kept as a static ValueNotifier (not moved into GetX) since other
  /// screens reference it directly by class name to switch tabs remotely.
  static final ValueNotifier<int> tabNotifier = ValueNotifier(0);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final MainNavigationController controller =
      Get.put(MainNavigationController());

  final List<Widget> _pages = const [
    HomeScreen(),
    DiscoverScreen(),
    ChatAIScreen(),
    SavedScholarshipScreen(),
    ProfileScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Obx(
      () => Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: _pages,
        ),
        bottomNavigationBar: ModernBottomNavBar(
                  currentIndex: controller.currentIndex.value,
                  onTap: controller.changeTab,
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
        extendBody: true,
      ),
    );
  }
}
