import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

/// A modern, classic & standard bottom navigation bar with:
/// - Frosted-glass surface (blur + translucent)
/// - Animated pill indicator that slides between items
/// - Scale + color transitions on icons & labels
/// - Haptic feedback on tap
/// - Theme-aware (light / dark)
class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> items;
  final int? centerIndex;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.centerIndex,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final ws = WallpaperService();
    final hasTheme = ws.hasTheme;
    final navBg = hasTheme ? ws.bottomNavColor : null;
    final themeFg = hasTheme ? ws.onThemeColor : null;

    return Container(
      decoration: BoxDecoration(
        // Subtle top border
        border: Border(
          top: BorderSide(
            color: hasTheme
                ? (ws.isThemeDark
                    ? Colors.white.withOpacity(0.10)
                    : Colors.black.withOpacity(0.08))
                : cs.outlineVariant.withOpacity(0.15),
            width: 0.5,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: EdgeInsets.only(bottom: bottomPadding),
            decoration: BoxDecoration(
              color: navBg ??
                  (isDark
                      ? cs.surface.withOpacity(0.88)
                      : cs.surface.withOpacity(0.92)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: List.generate(items.length, (i) {
                  if (i == centerIndex) {
                    return Expanded(
                      child: _CenterAIButton(
                        item: items[i],
                        isSelected: i == currentIndex,
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          onTap(i);
                        },
                        colorScheme: cs,
                        themeForeground: themeFg,
                      ),
                    );
                  }
                  return Expanded(
                    child: _NavItemWidget(
                      item: items[i],
                      isSelected: i == currentIndex,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(i);
                      },
                      colorScheme: cs,
                      isDark: isDark,
                      themeForeground: themeFg,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Center AI Floating Button ─────────────────────────────────────────────────

class _CenterAIButton extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final Color? themeForeground;

  const _CenterAIButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    this.themeForeground,
  });

  @override
  State<_CenterAIButton> createState() => _CenterAIButtonState();
}

class _CenterAIButtonState extends State<_CenterAIButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _glowAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isSelected) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _CenterAIButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    final accent = cs.primary; // already themed via main.dart

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 3),
              // Floating AI button
              Transform.scale(
                scale: _scaleAnim.value,
                child: Transform.translate(
                  offset: Offset(0, -4 * _glowAnim.value),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.isSelected
                            ? [accent, accent.withOpacity(0.7)]
                            : [
                                accent.withOpacity(0.75),
                                accent.withOpacity(0.55),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              accent.withOpacity(0.15 + 0.25 * _glowAnim.value),
                          blurRadius: 12 + 8 * _glowAnim.value,
                          spreadRadius: 1 * _glowAnim.value,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isSelected
                          ? widget.item.activeIcon
                          : widget.item.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: widget.isSelected ? 11 : 10.5,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.themeForeground != null
                      ? (widget.isSelected
                          ? widget.themeForeground
                          : widget.themeForeground!.withOpacity(0.55))
                      : (widget.isSelected
                          ? cs.primary
                          : cs.onSurfaceVariant.withOpacity(0.5)),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
            ],
          );
        },
      ),
    );
  }
}

class _NavItemWidget extends StatefulWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isDark;
  final Color? themeForeground;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.isDark,
    this.themeForeground,
  });

  @override
  State<_NavItemWidget> createState() => _NavItemWidgetState();
}

class _NavItemWidgetState extends State<_NavItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _pillWidth;
  late Animation<double> _iconScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _pillWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _iconScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.isSelected) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _NavItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final selected = _scaleAnim.value;
          final tf = widget.themeForeground;
          final iconColor = tf != null
              ? Color.lerp(tf.withOpacity(0.45), tf, selected)!
              : Color.lerp(
                  cs.onSurfaceVariant.withOpacity(0.6),
                  cs.primary,
                  selected,
                )!;
          final labelColor = tf != null
              ? Color.lerp(tf.withOpacity(0.45), tf, selected)!
              : Color.lerp(
                  cs.onSurfaceVariant.withOpacity(0.5),
                  cs.primary,
                  selected,
                )!;
          final pillColor = tf ?? cs.primary;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Pill indicator ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 3,
                width: 24 * _pillWidth.value,
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: pillColor.withOpacity(selected),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Icon ──
              Transform.scale(
                scale: _iconScale.value,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow behind active icon
                    if (selected > 0.3)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pillColor.withOpacity(0.08 * selected),
                        ),
                      ),
                    Icon(
                      selected > 0.5
                          ? widget.item.activeIcon
                          : widget.item.icon,
                      size: 24,
                      color: iconColor,
                    ),
                    // Badge
                    if (widget.item.badgeCount != null &&
                        widget.item.badgeCount! > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _Badge(
                          count: widget.item.badgeCount!,
                          colorScheme: cs,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // ── Label ──
              Text(
                widget.item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: lerpDouble(10.5, 11.5, selected)!,
                  fontWeight:
                      selected > 0.5 ? FontWeight.w700 : FontWeight.w500,
                  color: labelColor,
                  letterSpacing: selected > 0.5 ? 0.1 : 0.0,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 2),
            ],
          );
        },
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final int count;
  final ColorScheme colorScheme;

  const _Badge({required this.count, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.surface, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: colorScheme.onError,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ── NavItem Model ─────────────────────────────────────────────────────────────

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}
