// ignore_for_file: deprecated_member_use

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/display_settings_service.dart';
import 'package:scholarship_app/services/language_service.dart';
import 'package:scholarship_app/services/theme_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

part 'settings_screen_controller.dart';
part 'settings_screen_binding.dart';

class SettingsScreenView extends GetView<SettingsScreenViewController> {
  const SettingsScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: WallpaperService().hasTheme
                          ? WallpaperService().onThemeColor
                          : colorScheme.onSurface,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                  Expanded(
                    child: Text(
                      t.translate('settingsTitle'),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: WallpaperService().hasTheme
                            ? WallpaperService().onThemeColor
                            : colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(title: t.translate('settingsNotificationsSection')),
                    Obx(() => _ToggleTile(
                      icon: Icons.notifications_outlined,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsPushNotifications'),
                      value: controller.pushNotifications.value,
                      onChanged: (v) => controller.setPushNotifications(v),
                    )),
                    _Divider(),
                    Obx(() => _ToggleTile(
                      icon: Icons.email_outlined,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsEmailNotifications'),
                      value: controller.emailNotifications.value,
                      onChanged: (v) => controller.setEmailNotifications(v),
                    )),
                    _Divider(),
                    Obx(() => _ToggleTile(
                      icon: Icons.alarm_outlined,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsDeadlineReminders'),
                      value: controller.deadlineReminders.value,
                      onChanged: (v) => controller.setDeadlineReminders(v),
                    )),
                    _Divider(),
                    Obx(() => _ToggleTile(
                      icon: Icons.school_outlined,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsNewScholarships'),
                      value: controller.newScholarships.value,
                      onChanged: (v) => controller.setNewScholarships(v),
                    )),
                    const SizedBox(height: 8),
                    _SectionHeader(title: t.translate('settingsAppSettingsSection')),
                    Obx(() => _ArrowTile(
                      icon: Icons.language_rounded,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsLanguage'),
                      trailing: controller.selectedLanguage.value,
                      onTap: () => controller.showLanguagePicker(context),
                    )),
                    _Divider(),
                    Obx(() => _ArrowTile(
                      icon: Icons.notifications_active_outlined,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsNotificationSound'),
                      trailing: controller.notificationSound.value,
                      onTap: () => controller.showSoundPicker(context),
                    )),
                    _Divider(),
                    Obx(() => _ToggleTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsDarkMode'),
                      value: controller.darkMode.value,
                      onChanged: (v) => controller.setDarkMode(v),
                    )),
                    const SizedBox(height: 8),
                    _SectionHeader(title: t.translate('settingsDisplaySection')),
                    _ArrowTile(
                      icon: Icons.font_download_outlined,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsFont'),
                      trailing: DisplaySettingsService().currentFontDisplayName,
                      onTap: () async {
                        await Get.toNamed(Routes.fontPicker);
                      },
                    ),
                    _Divider(),
                    _ArrowTile(
                      icon: Icons.format_size_rounded,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsFontSize'),
                      trailing: t.translate(DisplaySettingsService().currentTextScaleLabelKey()),
                      onTap: () async {
                        await Get.toNamed(Routes.fontSize);
                      },
                    ),
                    _Divider(),
                    _ArrowTile(
                      icon: Icons.display_settings_rounded,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsDisplaySize'),
                      trailing: t.translate(DisplaySettingsService().currentDisplayScaleLabelKey()),
                      onTap: () async {
                        await Get.toNamed(Routes.displaySize);
                      },
                    ),
                    _Divider(),
                    _ArrowTile(
                      icon: Icons.wallpaper_rounded,
                      iconColor: colorScheme.primary,
                      label: t.translate('settingsWallpaper'),
                      trailing: WallpaperService().hasAny
                          ? t.translate(WallpaperService().displayLabelKey)
                          : t.translate('settingsWallpaperNone'),
                      onTap: () async {
                        await Get.toNamed(Routes.wallpaper);
                      },
                    ),
                    const SizedBox(height: 8),
                    _SectionHeader(title: t.translate('settingsAboutSection')),
                    _ArrowTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: colorScheme.onSurfaceVariant,
                      label: t.translate('settingsPrivacyPolicy'),
                      onTap: () => controller.openLink('Privacy Policy'),
                    ),
                    _Divider(),
                    _ArrowTile(
                      icon: Icons.description_outlined,
                      iconColor: colorScheme.onSurfaceVariant,
                      label: t.translate('settingsTermsOfService'),
                      onTap: () => controller.openLink('Terms of Service'),
                    ),
                    _Divider(),
                    _ArrowTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: colorScheme.onSurfaceVariant,
                      label: t.translate('settingsHelpSupport'),
                      onTap: () => controller.openLink('Help & Support'),
                    ),
                    _Divider(),
                    _ArrowTile(
                      icon: Icons.star_outline_rounded,
                      iconColor: colorScheme.onSurfaceVariant,
                      label: t.translate('settingsRateApp'),
                      onTap: () => controller.openLink('Rate App'),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Text(
                        t.translate('settingsVersion'),
                        style: TextStyle(fontSize: 13, color: colorScheme.outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Container(
      width: double.infinity,
      color: themed ? null : colorScheme.surfaceContainerHighest,
      decoration: themed ? ws.glassSection() : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: themed
              ? ws.onThemeColor.withOpacity(0.7)
              : colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: themed ? ws.onThemeColor : colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ArrowTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _ArrowTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: themed ? ws.onThemeColor : colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: TextStyle(
                  fontSize: 14,
                  color: themed
                      ? ws.onThemeColor.withOpacity(0.7)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: themed
                  ? ws.onThemeColor.withOpacity(0.6)
                  : colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 54),
      child: Divider(height: 1, color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final String selected;
  final ValueChanged<String> onSelect;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          ...items.map((item) {
            final isSelected = item == selected;
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    onSelect(item);
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 22),
                      ],
                    ),
                  ),
                ),
                if (item != items.last)
                  Divider(height: 1, color: colorScheme.outlineVariant),
              ],
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
