// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scholarship_app/services/display_settings_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/translations/app_localizations.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String? lastUpdated;
  final List<LegalSection> sections;

  const LegalScreen({
    super.key,
    required this.title,
    required this.sections,
    this.lastUpdated,
  });

  TextStyle _titleStyle() {
    const base = TextStyle(fontSize: 20, fontWeight: FontWeight.w700);
    final family = DisplaySettingsService().currentFontFamily;
    if (family == null || family.isEmpty) return base;
    try {
      return GoogleFonts.getFont(family, fontSize: 20, fontWeight: FontWeight.w700);
    } catch (_) {
      return base.copyWith(fontFamily: family);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ws = WallpaperService();

    return Scaffold(
      backgroundColor: ws.hasAny ? Colors.transparent : (isDark ? cs.surface : const Color(0xFFF2F4F8)),
      body: Column(
        children: [
          // ── Header (matches font-picker screen) ─────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: ws.hasTheme
                  ? ws.heroGradient(
                      fallbackColors: const [
                        Color(0xFF1565C0),
                        Color(0xFF1976D2),
                        Color(0xFF2196F3),
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1565C0),
                        Color(0xFF1976D2),
                        Color(0xFF2196F3),
                      ],
                    ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () => Get.back(),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: _titleStyle().copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                for (final section in sections) ...[
                  Text(
                    section.heading,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final paragraph in section.paragraphs) ...[
                    Text(
                      paragraph,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 14),
                ],
                if (lastUpdated != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      lastUpdated!,
                      style: TextStyle(
                        color: cs.outline,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LegalSection {
  final String heading;
  final List<String> paragraphs;

  const LegalSection(this.heading, this.paragraphs);
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return LegalScreen(
      title: t.translate('settingsPrivacyPolicy'),
      lastUpdated: t.translate('legalLastUpdated'),
      sections: [
        LegalSection(t.translate('legalPrivacyS1Title'), [
          t.translate('legalPrivacyS1P1'),
        ]),
        LegalSection(t.translate('legalPrivacyS2Title'), [
          t.translate('legalPrivacyS2P1'),
          t.translate('legalPrivacyS2P2'),
          t.translate('legalPrivacyS2P3'),
          t.translate('legalPrivacyS2P4'),
          t.translate('legalPrivacyS2P5'),
        ]),
        LegalSection(t.translate('legalPrivacyS3Title'), [
          t.translate('legalPrivacyS3P1'),
          t.translate('legalPrivacyS3P2'),
          t.translate('legalPrivacyS3P3'),
          t.translate('legalPrivacyS3P4'),
        ]),
        LegalSection(t.translate('legalPrivacyS4Title'), [
          t.translate('legalPrivacyS4P1'),
          t.translate('legalPrivacyS4P2'),
          t.translate('legalPrivacyS4P3'),
        ]),
        LegalSection(t.translate('legalPrivacyS5Title'), [
          t.translate('legalPrivacyS5P1'),
        ]),
        LegalSection(t.translate('legalPrivacyS6Title'), [
          t.translate('legalPrivacyS6P1'),
        ]),
        LegalSection(t.translate('legalPrivacyS7Title'), [
          t.translate('legalPrivacyS7P1'),
        ]),
        LegalSection(t.translate('legalPrivacyS8Title'), [
          t.translate('legalPrivacyS8P1'),
        ]),
        LegalSection(t.translate('legalPrivacyS9Title'), [
          t.translate('legalPrivacyS9P1'),
        ]),
        LegalSection(t.translate('legalPrivacyS10Title'), [
          t.translate('legalPrivacyS10P1'),
        ]),
      ],
    );
  }
}

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return LegalScreen(
      title: t.translate('settingsTermsOfService'),
      lastUpdated: t.translate('legalLastUpdated'),
      sections: [
        LegalSection(t.translate('legalTermsS1Title'), [
          t.translate('legalTermsS1P1'),
        ]),
        LegalSection(t.translate('legalTermsS2Title'), [
          t.translate('legalTermsS2P1'),
        ]),
        LegalSection(t.translate('legalTermsS3Title'), [
          t.translate('legalTermsS3P1'),
        ]),
        LegalSection(t.translate('legalTermsS4Title'), [
          t.translate('legalTermsS4P1'),
        ]),
        LegalSection(t.translate('legalTermsS5Title'), [
          t.translate('legalTermsS5P1'),
        ]),
        LegalSection(t.translate('legalTermsS6Title'), [
          t.translate('legalTermsS6P1'),
        ]),
        LegalSection(t.translate('legalTermsS7Title'), [
          t.translate('legalTermsS7P1'),
        ]),
        LegalSection(t.translate('legalTermsS8Title'), [
          t.translate('legalTermsS8P1'),
        ]),
        LegalSection(t.translate('legalTermsS9Title'), [
          t.translate('legalTermsS9P1'),
        ]),
        LegalSection(t.translate('legalTermsS10Title'), [
          t.translate('legalTermsS10P1'),
        ]),
        LegalSection(t.translate('legalTermsS11Title'), [
          t.translate('legalTermsS11P1'),
        ]),
        LegalSection(t.translate('legalTermsS12Title'), [
          t.translate('legalTermsS12P1'),
        ]),
        LegalSection(t.translate('legalTermsS13Title'), [
          t.translate('legalTermsS13P1'),
        ]),
      ],
    );
  }
}
