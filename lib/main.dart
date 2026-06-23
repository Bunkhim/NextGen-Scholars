// ignore_for_file: deprecated_member_use

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scholarship_app/database/database_helper.dart';
import 'package:scholarship_app/database/seeds/database_seeder.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/authentication/forget_password_screen.dart';
import 'package:scholarship_app/screens/authentication/login_screen.dart';
import 'package:scholarship_app/screens/authentication/onboarding_screen.dart';
import 'package:scholarship_app/screens/authentication/register_screen.dart';
import 'package:scholarship_app/screens/authentication/reset_password_screen.dart';
import 'package:scholarship_app/screens/authentication/splash_screen.dart';
import 'package:scholarship_app/screens/authentication/verify_email_screen.dart';
import 'package:scholarship_app/screens/main_app/discover_screen.dart';
import 'package:scholarship_app/screens/main_app/editProfile.dart';
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
import 'package:scholarship_app/services/display_settings_service.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/language_service.dart';
import 'package:scholarship_app/services/theme_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/theme_background_overlay.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize SQLite database and seed default data.
  await DatabaseHelper().database;
  await DatabaseSeeder().seedIfEmpty();
  await LanguageService().loadSavedLanguage();
  await DisplaySettingsService().loadSettings();
  await WallpaperService().loadSettings();
  // Initialize per-user Fill Info: cleanup stale data (>30 days),
  // then restore Fill Info for the currently signed-in user (if any).
  await FillInfoPersistenceService().initialize();
  runApp(const ScholarshipApp());
}

class ScholarshipApp extends StatefulWidget {
  const ScholarshipApp({super.key});

  @override
  State<ScholarshipApp> createState() => _ScholarshipAppState();
}

class _ScholarshipAppState extends State<ScholarshipApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, isDarkMode, child) {
        return ValueListenableBuilder<Locale>(
          valueListenable: LanguageService.localeNotifier,
          builder: (context, locale, child) {
            return ValueListenableBuilder<double>(
              valueListenable: DisplaySettingsService.textScaleNotifier,
              builder: (context, textScale, child) {
                return ValueListenableBuilder<double>(
                  valueListenable: DisplaySettingsService.displayScaleNotifier,
                  builder: (context, displayScale, child) {
                    return ValueListenableBuilder<String?>(
                      valueListenable:
                          DisplaySettingsService.fontFamilyNotifier,
                      builder: (context, fontFamily, child) {
                        // ── Wallpaper / Theme reactivity ──
                        return ValueListenableBuilder<String?>(
                          valueListenable: WallpaperService.themeIdNotifier,
                          builder: (context, themeId, _) {
                            return ValueListenableBuilder<String?>(
                              valueListenable:
                                  WallpaperService.wallpaperNotifier,
                              builder: (context, wallpaperPath, _) {
                                final ws = WallpaperService();
                                final decoration = ws.currentDecoration;
                                final hasWp = decoration != null;

                                // Build light/dark themes
                                ThemeData lt = _applyFontFamily(
                                    ThemeService.lightTheme, fontFamily);
                                ThemeData dt = _applyFontFamily(
                                    ThemeService.darkTheme, fontFamily);

                                // When a wallpaper/theme is active override
                                // AppBar + scaffold colours so every screen
                                // picks them up automatically.
                                if (hasWp) {
                                  ThemeData themed(ThemeData base) {
                                    final cs = base.colorScheme;
                                    final isTheme = ws.hasTheme;
                                    final accent =
                                        isTheme ? ws.themedPrimary(cs) : null;

                                    return base.copyWith(
                                      scaffoldBackgroundColor:
                                          Colors.transparent,
                                      // ── Inject theme accent into the
                                      //    colour-scheme so every widget
                                      //    that reads cs.primary picks it up.
                                      colorScheme: isTheme
                                          ? cs.copyWith(
                                              primary: accent,
                                              onPrimary: Colors.white,
                                              primaryContainer:
                                                  accent!.withOpacity(0.18),
                                              onPrimaryContainer:
                                                  ws.onThemeColor,
                                            )
                                          : null,
                                      appBarTheme: base.appBarTheme.copyWith(
                                        backgroundColor: isTheme
                                            ? ws.appBarColor
                                            : Colors.transparent,
                                        foregroundColor:
                                            isTheme ? ws.onThemeColor : null,
                                        surfaceTintColor: Colors.transparent,
                                        iconTheme: isTheme
                                            ? IconThemeData(
                                                color: ws.onThemeColor)
                                            : null,
                                        elevation: 0,
                                      ),
                                      // ── BottomNav picks up theme colours
                                      bottomNavigationBarTheme: isTheme
                                          ? BottomNavigationBarThemeData(
                                              backgroundColor:
                                                  ws.bottomNavColor,
                                              selectedItemColor: accent,
                                              unselectedItemColor: ws
                                                  .onThemeColor
                                                  .withOpacity(0.55),
                                            )
                                          : null,
                                    );
                                  }

                                  lt = themed(lt);
                                  dt = themed(dt);
                                }

                                return MaterialApp(
                                  title: 'NextGen Scholars',
                                  debugShowCheckedModeBanner: false,
                                  themeAnimationDuration:
                                      const Duration(milliseconds: 360),
                                  themeAnimationCurve: Curves.easeInOutCubic,
                                  initialRoute: AppRoutes.splashScreen,
                                  theme: lt,
                                  darkTheme: dt,
                                  themeMode: isDarkMode
                                      ? ThemeMode.dark
                                      : ThemeMode.light,
                                  localizationsDelegates: const [
                                    AppLocalizations.delegate,
                                    GlobalMaterialLocalizations.delegate,
                                    GlobalWidgetsLocalizations.delegate,
                                    GlobalCupertinoLocalizations.delegate,
                                  ],
                                  supportedLocales: const [
                                    Locale('en'),
                                    Locale('km'),
                                  ],
                                  locale: locale,
                                  builder: (context, child) {
                                    Widget content = MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                        boldText: false,
                                        textScaler: TextScaler.linear(
                                            textScale * displayScale),
                                      ),
                                      child: child!,
                                    );

                                    // Wrap with wallpaper/gradient
                                    if (hasWp) {
                                      content = Container(
                                        decoration: decoration,
                                        child: Stack(
                                          children: [
                                            // Per-theme illustrated background pattern
                                            if (ws.hasTheme)
                                              ThemeBackgroundOverlay(
                                                themeId: themeId,
                                                themeData: ws.currentThemeData,
                                              ),
                                            content,
                                          ],
                                        ),
                                      );
                                    }
                                    return content;
                                  },
                                  routes: {
                                    AppRoutes.discoverScreen: (context) =>
                                        DiscoverScreen(),
                                    AppRoutes.splashScreen: (context) =>
                                        SplashScreen(),
                                    AppRoutes.onboardingScreen: (context) =>
                                        OnboardingScreen(),
                                    AppRoutes.registerScreen: (context) =>
                                        RegisterScreen(),
                                    AppRoutes.loginScreen: (context) =>
                                        LoginScreen(),
                                    AppRoutes.verifyEmailScreen: (context) {
                                      final args = ModalRoute.of(context)
                                          ?.settings
                                          .arguments;
                                      if (args is Map<String, dynamic>) {
                                        return VerifyEmailScreen(
                                          type: args['type'] ?? 'email',
                                          destination:
                                              args['destination'] ?? '',
                                          purpose: args['purpose'] ??
                                              'forgotPassword',
                                        );
                                      }
                                      // Fallback for legacy String args
                                      return VerifyEmailScreen(
                                        type: 'email',
                                        destination:
                                            (args as String?) ?? 'your email',
                                      );
                                    },
                                    AppRoutes.forgetPasswordScreen: (context) =>
                                        ForgetPasswordScreen(),
                                    AppRoutes.resetPasswordScreen: (context) {
                                      final args = ModalRoute.of(context)
                                          ?.settings
                                          .arguments;
                                      final map = args is Map<String, dynamic>
                                          ? args
                                          : <String, dynamic>{};
                                      return ResetPasswordScreen(
                                        email: map['email'] ?? '',
                                      );
                                    },
                                    AppRoutes.scholarshipDetailScreen:
                                        (context) => ScholarshipDetailScreen(),
                                    AppRoutes.savedScholarshipScreen:
                                        (context) => SavedScholarshipScreen(),
                                    AppRoutes.myApplicationsScreen: (context) =>
                                        const MyApplicationsScreen(),
                                    AppRoutes.homeScreen: (context) =>
                                        MainNavigationScreen(),
                                    AppRoutes.profileScreen: (context) =>
                                        ProfileScreen(),
                                    AppRoutes.notificationScreen: (context) =>
                                        NotificationsScreen(),
                                    AppRoutes.searchFilterScreen: (context) =>
                                        SearchFilterScreen(),
                                    AppRoutes.filterResultScreen: (context) =>
                                        FilterResultScreen(),
                                    AppRoutes.searchResultScreen: (context) {
                                      final args = ModalRoute.of(context)
                                          ?.settings
                                          .arguments as Map<String, dynamic>?;
                                      return SearchResultScreen(
                                        searchQuery:
                                            args?['searchQuery'] as String? ??
                                                '',
                                        filterCountry:
                                            args?['filterCountry'] as String?,
                                        filterType:
                                            args?['filterType'] as String?,
                                      );
                                    },
                                    AppRoutes.settingsScreen: (context) =>
                                        SettingsScreen(),
                                    AppRoutes.settingScreen: (context) =>
                                        SettingsScreen(),
                                    AppRoutes.editProfileScreen: (context) =>
                                        EditProfileScreen(),
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  ThemeData _applyFontFamily(ThemeData theme, String? fontFamily) {
    if (fontFamily == null || fontFamily.isEmpty) return theme;
    return theme.copyWith(
      textTheme: GoogleFonts.getTextTheme(fontFamily, theme.textTheme),
      primaryTextTheme:
          GoogleFonts.getTextTheme(fontFamily, theme.primaryTextTheme),
    );
  }
}






//-------------------------------------------------------------------






