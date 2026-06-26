import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scholarship_app/database/database_helper.dart';
import 'package:scholarship_app/database/seeds/database_seeder.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/display_settings_service.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/language_service.dart';
import 'package:scholarship_app/services/theme_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/theme_background_overlay.dart';

import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await DatabaseHelper().database;
  await DatabaseSeeder().seedIfEmpty();
  await LanguageService().loadSavedLanguage();
  await DisplaySettingsService().loadSettings();
  await WallpaperService().loadSettings();
  await FillInfoPersistenceService().initialize();
  runApp(const ScholarshipApp());
}

class ScholarshipApp extends StatelessWidget {
  const ScholarshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDarkMode = ThemeService.themeNotifier.value;
      final locale = LanguageService.localeNotifier.value;
      final textScale = DisplaySettingsService.textScaleNotifier.value;
      final displayScale = DisplaySettingsService.displayScaleNotifier.value;
      final fontFamily = DisplaySettingsService.fontFamilyNotifier.value;
      final themeIdValue = WallpaperService.themeIdNotifier.value;
      final wallpaperPathValue = WallpaperService.wallpaperNotifier.value;

      final ws = WallpaperService();
      final decoration = ws.currentDecoration;
      final hasWp = decoration != null;

      ThemeData lt = _applyFontFamily(ThemeService.lightTheme, fontFamily);
      ThemeData dt = _applyFontFamily(ThemeService.darkTheme, fontFamily);

      if (hasWp) {
        ThemeData themed(ThemeData base) {
          final cs = base.colorScheme;
          final isTheme = ws.hasTheme;
          final accent = isTheme ? ws.themedPrimary(cs) : null;

          return base.copyWith(
            scaffoldBackgroundColor: Colors.transparent,
            colorScheme: isTheme
                ? cs.copyWith(
                    primary: accent,
                    onPrimary: Colors.white,
                    primaryContainer: accent!.withOpacity(0.18),
                    onPrimaryContainer: ws.onThemeColor,
                  )
                : null,
            appBarTheme: base.appBarTheme.copyWith(
              backgroundColor: isTheme ? ws.appBarColor : Colors.transparent,
              foregroundColor: isTheme ? ws.onThemeColor : null,
              surfaceTintColor: Colors.transparent,
              iconTheme: isTheme
                  ? IconThemeData(color: ws.onThemeColor)
                  : null,
              elevation: 0,
            ),
            bottomNavigationBarTheme: isTheme
                ? BottomNavigationBarThemeData(
                    backgroundColor: ws.bottomNavColor,
                    selectedItemColor: accent,
                    unselectedItemColor: ws.onThemeColor.withOpacity(0.55),
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
        initialRoute: Routes.splash,
        getPages: AppPages.routes,
        theme: lt,
        darkTheme: dt,
        themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
        locale: locale,
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
        builder: (context, child) {
          Widget content = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              boldText: false,
              textScaler: TextScaler.linear(textScale * displayScale),
            ),
            child: child!,
          );

          if (hasWp) {
            content = Container(
              decoration: decoration,
              child: Stack(
                children: [
                  if (ws.hasTheme)
                    ThemeBackgroundOverlay(
                      themeId: themeIdValue,
                      themeData: ws.currentThemeData,
                    ),
                  content,
                ],
              ),
            );
          }

          return content;
        },
      );
    });
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
