// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scholarship_app/database/database_helper.dart';
import 'package:scholarship_app/database/seeds/database_seeder.dart';
import 'package:scholarship_app/firebase_options.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/display_settings_service.dart';
import 'package:scholarship_app/services/fcm_service.dart';
import 'package:scholarship_app/services/fill_info_persistence_service.dart';
import 'package:scholarship_app/services/language_service.dart';
import 'package:scholarship_app/services/theme_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/theme_background_overlay.dart';
import 'package:scholarship_app/controllers/main_app/notification_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  FlutterError.onError = (details) {
    stderr.writeln('FlutterError: ${details.exception}');
    stderr.writeln('Stack: ${details.stack}');
  };

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e, s) {
    stderr.writeln('Firebase init failed: $e\n$s');
  }

  try {
    await FcmService().initialize();
  } catch (e, s) {
    stderr.writeln('FCM init failed: $e\n$s');
  }

  try {
    await DatabaseHelper().database;
    await DatabaseSeeder().seedIfEmpty();
  } catch (e, s) {
    stderr.writeln('Database init failed: $e\n$s');
  }

  try {
    await ThemeService().loadSettings();
    await LanguageService().loadSavedLanguage();
    await DisplaySettingsService().loadSettings();
    await WallpaperService().loadSettings();
    await FillInfoPersistenceService().initialize();
  } catch (e, s) {
    stderr.writeln('Settings init failed: $e\n$s');
  }

  try {
    Get.put(NotificationController(), permanent: true);
  } catch (e, s) {
    stderr.writeln('NotificationController init failed: $e\n$s');
  }

  runApp(const ScholarshipApp());
}

class ScholarshipApp extends StatefulWidget {
  const ScholarshipApp({super.key});

  @override
  State<ScholarshipApp> createState() => _ScholarshipAppState();
}

class _ScholarshipAppState extends State<ScholarshipApp> {
  final _notifiers = <Listenable>[
    ThemeService.themeNotifier,
    LanguageService.localeNotifier,
    DisplaySettingsService.textScaleNotifier,
    DisplaySettingsService.displayScaleNotifier,
    DisplaySettingsService.fontFamilyNotifier,
    WallpaperService.themeIdNotifier,
    WallpaperService.wallpaperNotifier,
  ];

  @override
  void initState() {
    super.initState();
    for (final n in _notifiers) {
      n.addListener(_onSettingChanged);
    }
  }

  void _onSettingChanged() => setState(() {});

  @override
  void dispose() {
    for (final n in _notifiers) {
      n.removeListener(_onSettingChanged);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read current values directly from notifiers
    final isDarkMode = ThemeService.themeNotifier.value;
    final locale = LanguageService.localeNotifier.value;
    final textScale = DisplaySettingsService.textScaleNotifier.value;
    final displayScale = DisplaySettingsService.displayScaleNotifier.value;
    final fontFamily = DisplaySettingsService.fontFamilyNotifier.value;
    final themeId = WallpaperService.themeIdNotifier.value;

    Get.updateLocale(locale);

    final ws = WallpaperService();
    final decoration = ws.currentDecoration;
    final hasWp = decoration != null;

    // Build light/dark themes
    ThemeData lt =
        _applyFontFamily(ThemeService.lightTheme, fontFamily);
    ThemeData dt =
        _applyFontFamily(ThemeService.darkTheme, fontFamily);

    // When a wallpaper/theme is active override
    // AppBar + scaffold colours so every screen
    // picks them up automatically.
    if (hasWp) {
      ThemeData themed(ThemeData base) {
        final cs = base.colorScheme;
        final isTheme = ws.hasTheme;
        final accent = isTheme ? ws.themedPrimary(cs) : null;

        return base.copyWith(
          scaffoldBackgroundColor: Colors.transparent,
          // ── Inject theme accent into the
          //    colour-scheme so every widget
          //    that reads cs.primary picks it up.
          colorScheme: isTheme
              ? cs.copyWith(
                  primary: accent,
                  onPrimary: Colors.white,
                  primaryContainer: accent!.withOpacity(0.18),
                  onPrimaryContainer: ws.onThemeColor,
                )
              : null,
          appBarTheme: base.appBarTheme.copyWith(
            backgroundColor:
                isTheme ? ws.appBarColor : Colors.transparent,
            foregroundColor: isTheme ? ws.onThemeColor : null,
            surfaceTintColor: Colors.transparent,
            iconTheme: isTheme
                ? IconThemeData(color: ws.onThemeColor)
                : null,
            elevation: 0,
          ),
          // ── BottomNav picks up theme colours
          bottomNavigationBarTheme: isTheme
              ? BottomNavigationBarThemeData(
                  backgroundColor: ws.bottomNavColor,
                  selectedItemColor: accent,
                  unselectedItemColor:
                      ws.onThemeColor.withOpacity(0.55),
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
      initialRoute: AppRoutes.splashScreen,
      theme: lt,
      darkTheme: dt,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
            textScaler:
                TextScaler.linear(textScale * displayScale),
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
          onTap: () =>
              FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: content,
        );
      },
      getPages: AppRoutes.getPages,
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
