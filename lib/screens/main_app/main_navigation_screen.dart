import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/screens/main_app/chat_ai_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/homescreens.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/screens/scholarship/saved_scholarship_screen.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/bottom_nav_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  /// Use this from any embedded tab to switch to a different tab.
  static final ValueNotifier<int> tabNotifier = ValueNotifier(0);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    MainNavigationScreen.tabNotifier.addListener(() {
      if (mounted) {
        setState(() => _currentIndex = MainNavigationScreen.tabNotifier.value);
      }
    });
  }

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

    // Listen to wallpaper changes so the IndexedStack rebuilds its key
    // (forces tab screens to re-read WallpaperService).
    return ValueListenableBuilder<String?>(
      valueListenable: WallpaperService.themeIdNotifier,
      builder: (context, themeId, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: WallpaperService.wallpaperNotifier,
          builder: (context, wallpaperPath, _) {
            final hasBackground = WallpaperService().hasAny;

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: IndexedStack(
                key: ValueKey(hasBackground),
                index: _currentIndex,
                children: _pages,
              ),
              bottomNavigationBar: ModernBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) =>
                    MainNavigationScreen.tabNotifier.value = index,
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
            );
          },
        );
      },
    );
  }
}
