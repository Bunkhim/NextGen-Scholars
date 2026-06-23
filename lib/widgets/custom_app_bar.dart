import 'package:flutter/material.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ws = WallpaperService();
    final hasTheme = ws.hasTheme;

    final bgColor = hasTheme
        ? ws.appBarColor!
        : (isDark ? colorScheme.surfaceContainerHighest : colorScheme.primary);
    final fgColor = hasTheme
        ? ws.onThemeColor
        : (isDark ? colorScheme.onSurface : colorScheme.onPrimary);

    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: fgColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
      ),
      backgroundColor: bgColor,
      elevation: 0,
      iconTheme: IconThemeData(color: fgColor),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
