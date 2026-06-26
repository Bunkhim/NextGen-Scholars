// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

part 'setting_screen_controller.dart';
part 'setting_screen_binding.dart';

class SettingScreenView extends GetView<SettingScreenViewController> {
  const SettingScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: AppBar(
        backgroundColor: WallpaperService().hasTheme
            ? WallpaperService().appBarColor
            : colorScheme.surface,
        surfaceTintColor: WallpaperService().hasTheme
            ? Colors.transparent
            : colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: WallpaperService().hasTheme
                  ? WallpaperService().onThemeColor
                  : colorScheme.onSurface),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Settings",
          style: TextStyle(
              color: WallpaperService().hasTheme
                  ? WallpaperService().onThemeColor
                  : colorScheme.onSurface,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Notifications", colorScheme),
            Obx(() => _buildSwitchTile("Push Notifications", controller.pushNotify.value, (val) {
              controller.pushNotify.value = val;
            }, colorScheme)),
            Obx(() => _buildSwitchTile("Email Notifications", controller.emailNotify.value, (val) {
              controller.emailNotify.value = val;
            }, colorScheme)),
            Obx(() => _buildSwitchTile("Deadline Reminders", controller.deadlineReminders.value, (val) {
              controller.deadlineReminders.value = val;
            }, colorScheme)),
            Obx(() => _buildSwitchTile("New Scholarships", controller.newScholarships.value, (val) {
              controller.newScholarships.value = val;
            }, colorScheme)),

            const SizedBox(height: 20),

            _buildSectionHeader("Notifications", colorScheme),
            _buildNavigationTile(
                Icons.language, "Language", "English", colorScheme),
            _buildNavigationTile(Icons.notifications, "Notification Sound",
                "Default", colorScheme),

            const SizedBox(height: 20),

            _buildSectionHeader("About", colorScheme),
            _buildSimpleTile("Privacy Policy", colorScheme),
            _buildSimpleTile("Terms of Service", colorScheme),
            _buildSimpleTile("Help & Support", colorScheme),
            _buildSimpleTile("Rate App", colorScheme),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 14),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged,
      ColorScheme colorScheme) {
    return Column(
      children: [
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          title: Text(title,
              style: TextStyle(fontSize: 15, color: colorScheme.onSurface)),
          value: value,
          activeColor: colorScheme.primary,
          onChanged: onChanged,
        ),
        Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: colorScheme.outlineVariant),
      ],
    );
  }

  Widget _buildNavigationTile(IconData icon, String title, String trailingText,
      ColorScheme colorScheme) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          leading: Icon(icon, color: colorScheme.primary),
          title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(trailingText,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
          onTap: () {},
        ),
        Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: colorScheme.outlineVariant),
      ],
    );
  }

  Widget _buildSimpleTile(String title, ColorScheme colorScheme) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
          trailing:
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          onTap: () {},
        ),
        Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: colorScheme.outlineVariant),
      ],
    );
  }
}
