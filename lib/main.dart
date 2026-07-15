import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scholarship_app/database/database_helper.dart';
import 'package:scholarship_app/database/seeds/database_seeder.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/display_settings_service.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/language_service.dart';
import 'package:scholarship_app/services/theme_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/theme_background_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  // Initialize SQLite database and seed default data.
  await DatabaseHelper().database;
  await DatabaseSeeder().seedIfEmpty();
  await ThemeService().loadSettings();
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
            Get.updateLocale(locale);
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

                                return GetMaterialApp(
                                  title: 'NextGen Scholars',
                                  debugShowCheckedModeBanner: false,
                                  // themeAnimationDuration:
                                      // const Duration(milliseconds: 360),
                                  // themeAnimationCurve: Curves.easeInOutCubic,
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

                                    // Global keyboard dismiss on tap outside
                                    return GestureDetector(
                                      onTap: () => FocusManager.instance
                                          .primaryFocus
                                          ?.unfocus(),
                                      behavior: HitTestBehavior.translucent,
                                      child: content,
                                    );
                                  },
                                  getPages: AppRoutes.getPages,
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
