// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

/// Bottom navigation bar shared across all Fill Information screens.
/// Shows: [< Back] [Step X/N ──────] [Next >] and a Save button.
class FillInfoNavBar extends StatelessWidget {
  final int step; // 1-based current step
  final int totalSteps; // total number of steps (8)
  final VoidCallback? onBack; // null = back button is hidden
  final VoidCallback onNext;
  final VoidCallback onSave;
  final bool isLastStep; // shows "Complete" instead of "Next"

  const FillInfoNavBar({
    super.key,
    required this.step,
    required this.totalSteps,
    this.onBack,
    required this.onNext,
    required this.onSave,
    this.isLastStep = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);
    final activeColor = WallpaperService().themedPrimary(colorScheme);
    final dimColor =
        WallpaperService().themedOnSurface(colorScheme).withOpacity(0.3);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                // ── Back ────────────────────────────────────────────
                GestureDetector(
                  onTap: onBack,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chevron_left_rounded,
                        size: 22,
                        color: onBack != null ? activeColor : dimColor,
                      ),
                      Text(
                        t.translate('fillInfoBack'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: onBack != null ? activeColor : dimColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Step indicator ───────────────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${t.translate('fillInfoStep')} $step/$totalSteps',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: WallpaperService()
                              .themedOnSurface(colorScheme)
                              .withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      // Progress line
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: LinearProgressIndicator(
                          value: step / totalSteps,
                          backgroundColor: WallpaperService()
                              .themedOnSurface(colorScheme)
                              .withOpacity(0.12),
                          color: activeColor,
                          borderRadius: BorderRadius.circular(4),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Next ──────────────────────────────────────────────
                GestureDetector(
                  onTap: onNext,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLastStep
                            ? t.translate('fillInfoComplete')
                            : t.translate('fillInfoNext'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: activeColor,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: activeColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Save button ──────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                minimumSize: const Size(0, 52),
              ),
              child: Text(
                t.translate('fillInfoSave'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
