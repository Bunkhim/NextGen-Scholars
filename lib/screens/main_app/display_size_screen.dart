// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/display_settings_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class DisplaySizeScreen extends StatefulWidget {
  const DisplaySizeScreen({super.key});

  @override
  State<DisplaySizeScreen> createState() => _DisplaySizeScreenState();
}

class _DisplaySizeScreenState extends State<DisplaySizeScreen>
    with SingleTickerProviderStateMixin {
  late double _currentScale;
  final _service = DisplaySettingsService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentScale = _service.currentDisplayScale;
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

  int _scaleToIndex(double scale) {
    final options = DisplaySettingsService.displayScaleOptions;
    for (int i = 0; i < options.length; i++) {
      if (((options[i]['scale'] as double) - scale).abs() < 0.01) return i;
    }
    return 1; // Standard
  }

  void _onScaleChanged(double value) {
    final index = value.round();
    final scale =
        DisplaySettingsService.displayScaleOptions[index]['scale'] as double;
    setState(() => _currentScale = scale);
    _service.setDisplayScale(scale);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final options = DisplaySettingsService.displayScaleOptions;
    final currentIndex = _scaleToIndex(_currentScale);

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
                        t.translate('settingsDisplaySize'),
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

          // ── Content ─────────────────────────────────────────────────
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Builder(builder: (context) {
                  final ws = WallpaperService();
                  final themed = ws.hasTheme;
                  final primary = ws.themedPrimary(cs);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),

                      // ── Chat Preview ──────────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: themed
                            ? ws.glassCard(radius: 20)
                            : BoxDecoration(
                                color:
                                    cs.surfaceContainerHighest.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                        child: Column(
                          children: [
                            // Incoming message
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  t.translate('settingsDisplaySizePreviewMsg1'),
                                  style: TextStyle(
                                    fontSize: 14 * _currentScale,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Reply message
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.65,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: themed
                                      ? Colors.white.withOpacity(
                                          ws.isThemeDark ? 0.12 : 0.50)
                                      : cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  t.translate('settingsDisplaySizePreviewMsg2'),
                                  style: TextStyle(
                                    fontSize: 14 * _currentScale,
                                    color:
                                        themed ? ws.onThemeColor : cs.onSurface,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Outgoing message
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  t.translate('settingsDisplaySizePreviewMsg3'),
                                  style: TextStyle(
                                    fontSize: 14 * _currentScale,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Reply message 2
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: themed
                                      ? Colors.white.withOpacity(
                                          ws.isThemeDark ? 0.12 : 0.50)
                                      : cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  t.translate('settingsDisplaySizePreviewMsg4'),
                                  style: TextStyle(
                                    fontSize: 14 * _currentScale,
                                    color:
                                        themed ? ws.onThemeColor : cs.onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Page dots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: themed
                                        ? ws.glassBorder
                                        : cs.outlineVariant,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Slider Section ────────────────────────────────
                      Divider(
                          color: themed ? ws.glassBorder : cs.outlineVariant),
                      const SizedBox(height: 16),

                      // Labels row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: options.map((option) {
                          final label =
                              t.translate(option['labelKey'] as String);
                          final idx = options.indexOf(option);
                          final isActive = idx == currentIndex;
                          return Expanded(
                            child: Text(
                              label,
                              textAlign: idx == 0
                                  ? TextAlign.left
                                  : idx == options.length - 1
                                      ? TextAlign.right
                                      : TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isActive
                                    ? primary
                                    : themed
                                        ? ws.onThemeColor.withOpacity(0.6)
                                        : cs.onSurfaceVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 4),

                      // Slider
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: primary,
                          inactiveTrackColor:
                              themed ? ws.glassBorder : cs.outlineVariant,
                          thumbColor: primary,
                          overlayColor: primary.withOpacity(0.12),
                          trackHeight: 4,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                            elevation: 4,
                          ),
                        ),
                        child: Slider(
                          value: currentIndex.toDouble(),
                          min: 0,
                          max: (options.length - 1).toDouble(),
                          divisions: options.length - 1,
                          onChanged: _onScaleChanged,
                        ),
                      ),

                      const SizedBox(height: 16),
                      Divider(
                          color: themed ? ws.glassBorder : cs.outlineVariant),
                      const SizedBox(height: 16),

                      // ── Description ───────────────────────────────────
                      Text(
                        t.translate('settingsDisplaySizeDescription'),
                        style: TextStyle(
                          fontSize: 13,
                          color: themed
                              ? ws.onThemeColor.withOpacity(0.7)
                              : cs.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
