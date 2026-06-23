// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/display_settings_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class FontPickerScreen extends StatefulWidget {
  const FontPickerScreen({super.key});

  @override
  State<FontPickerScreen> createState() => _FontPickerScreenState();
}

class _FontPickerScreenState extends State<FontPickerScreen>
    with SingleTickerProviderStateMixin {
  late String? _selectedFont;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _service = DisplaySettingsService();

  @override
  void initState() {
    super.initState();
    _selectedFont = _service.currentFontFamily;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectFont(String? family) {
    setState(() => _selectedFont = family);
    _service.setFontFamily(family);
  }

  TextStyle _getFontStyle(String family, {double fontSize = 16}) {
    if (family.isEmpty) {
      return TextStyle(fontSize: fontSize);
    }
    try {
      return GoogleFonts.getFont(family, fontSize: fontSize);
    } catch (_) {
      return TextStyle(fontSize: fontSize, fontFamily: family);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final fonts = DisplaySettingsService.availableFonts;

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : cs.surface,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: WallpaperService().hasTheme
                  ? WallpaperService().heroGradient(
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
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        t.translate('settingsFont'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Font List ───────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Builder(builder: (context) {
                final ws = WallpaperService();
                final themed = ws.hasTheme;
                final primary = ws.themedPrimary(cs);
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  itemCount: fonts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final font = fonts[index];
                    final family = font['family']!;
                    final name = font['name']!;
                    final isSelected = family.isEmpty
                        ? (_selectedFont == null || _selectedFont!.isEmpty)
                        : _selectedFont == family;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            _selectFont(family.isEmpty ? null : family),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primary.withOpacity(0.08)
                                : themed
                                    ? Colors.white.withOpacity(
                                        ws.isThemeDark ? 0.10 : 0.40)
                                    : cs.surfaceContainerHighest
                                        .withOpacity(0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? primary
                                  : themed
                                      ? ws.glassBorder
                                      : cs.outlineVariant,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? primary
                                            : themed
                                                ? ws.onThemeColor
                                                    .withOpacity(0.7)
                                                : cs.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'AaBbCcDd 123',
                                      style: _getFontStyle(family, fontSize: 20)
                                          .copyWith(
                                        color: themed
                                            ? ws.onThemeColor
                                            : cs.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      t.translate('settingsFontPreview'),
                                      style: _getFontStyle(family, fontSize: 13)
                                          .copyWith(
                                        color: themed
                                            ? ws.onThemeColor.withOpacity(0.7)
                                            : cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
