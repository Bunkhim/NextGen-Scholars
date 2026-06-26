// ignore_for_file: use_build_context_synchronously, file_names, avoid_print, deprecated_member_use

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scholarship_app/constants/app_colors.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/screens/main_app/profile_screen/profile_screen_view.dart';
import 'package:scholarship_app/services/user_firestore_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

part 'edit_profile_controller.dart';
part 'edit_profile_binding.dart';

class EditProfileView extends GetView<EditProfileViewController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(context);
        if (shouldPop && context.mounted) Get.back();
      },
      child: Scaffold(
        backgroundColor: WallpaperService().hasAny
            ? Colors.transparent
            : colorScheme.surfaceContainerHighest,
        body: Column(
          children: [
            _buildHeroHeader(context, t, colorScheme, isDark),
            Obx(() {
              if (controller.isLoading.value) {
                return Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: colorScheme.primary),
                  ),
                );
              }
              return Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Builder(builder: (context) {
                    final ws = WallpaperService();
                    final themed = ws.hasTheme;
                    return Container(
                      decoration: themed
                          ? ws.glassSection(radius: 28)
                          : BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                      clipBehavior: Clip.antiAlias,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          16, 32, 16,
                          MediaQuery.of(context).padding.bottom + 24,
                        ),
                        child: Column(
                          children: [
                            _buildSectionCard(
                              context, colorScheme,
                              icon: Icons.person_rounded,
                              title: 'Personal Information',
                              children: [
                                _buildFormField(
                                  context,
                                  t.translate('editProfileFullNameLabel'),
                                  controller.nameController,
                                  Icons.person_outline_rounded,
                                  t.translate('editProfileFullNameHint'),
                                  errorText: controller.nameError.value,
                                  maxLength: 50,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: controller.validateNameLive,
                                ),
                                const SizedBox(height: 14),
                                _buildFormField(
                                  context,
                                  t.translate('editProfileDobLabel'),
                                  controller.dobController,
                                  Icons.cake_outlined,
                                  t.translate('editProfileDobHint'),
                                  errorText: controller.dobError.value,
                                  helperText: 'DD/MM/YYYY',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [_DobInputFormatter()],
                                  onChanged: controller.validateDobLive,
                                ),
                                const SizedBox(height: 14),
                                _buildFormField(
                                  context,
                                  t.translate('editProfileCountryLabel'),
                                  controller.countryController,
                                  Icons.flag_outlined,
                                  t.translate('editProfileCountryHint'),
                                  errorText: controller.countryError.value,
                                  maxLength: 56,
                                  textCapitalization: TextCapitalization.words,
                                  onChanged: controller.validateCountryLive,
                                  suffixIcon: IconButton(
                                    tooltip: t.translate('forgotPasswordSelectCountry'),
                                    onPressed: () => _showCountryPicker(context, t),
                                    icon: Icon(
                                      Icons.arrow_drop_down_rounded,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSectionCard(
                              context, colorScheme,
                              icon: Icons.contact_mail_rounded,
                              title: 'Contact Information',
                              children: [
                                _buildFormField(
                                  context,
                                  t.translate('editProfileEmailLabel'),
                                  controller.emailController,
                                  Icons.mail_outline_rounded,
                                  t.translate('editProfileEmailHint'),
                                  errorText: controller.emailError.value,
                                  keyboardType: TextInputType.emailAddress,
                                  maxLength: 100,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                                  ],
                                  onChanged: controller.validateEmailLive,
                                ),
                                const SizedBox(height: 14),
                                _buildFormField(
                                  context,
                                  t.translate('editProfilePhoneLabel'),
                                  controller.phoneController,
                                  Icons.phone_outlined,
                                  t.translate('editProfilePhoneHint'),
                                  errorText: controller.phoneError.value,
                                  keyboardType: TextInputType.phone,
                                  maxLength: 15,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: controller.validatePhoneLive,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Obx(() => _buildInterestsCard(context, t, colorScheme)),
                            const SizedBox(height: 28),
                            Obx(() => _buildSaveButton(context, t, colorScheme, isDark)),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final ws = WallpaperService();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: ws.hasTheme
            ? ws.heroGradient(
                fallbackColors: [AppColors.primary, AppColors.primaryDark],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A2E)]
                    : [AppColors.primary, AppColors.primaryDark],
              ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -35, right: -20,
            child: Container(
              width: 140, height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -20, left: -10,
            child: Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final should = await _onWillPop(context);
                            if (should && context.mounted) Get.back();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          t.translate('editProfileTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 19,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Obx(() {
                        final saving = controller.isSaving.value;
                        return AnimatedScale(
                          scale: saving ? 0.93 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOut,
                          child: GestureDetector(
                            onTap: saving ? null : () => controller.handleSave(context),
                            child: Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.88),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.45),
                                    blurRadius: 18, spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.14),
                                    blurRadius: 10, offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (saving) ...[
                                    SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        valueColor: AlwaysStoppedAnimation(
                                            ws.themedPrimary(colorScheme)),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    saving
                                        ? t.translate('editProfileSaving')
                                        : t.translate('editProfileSaveButton'),
                                    style: TextStyle(
                                      color: ws.themedPrimary(colorScheme),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _pickPhoto(context),
                  child: Obx(() {
                    final picked = controller.pickedPhoto.value;
                    final hasPhoto = controller.hasPhotoToShow;
                    final initials = controller.initials;
                    return Stack(
                      children: [
                        Container(
                          width: 104, height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withOpacity(0.85), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 18, offset: const Offset(0, 6),
                              ),
                            ],
                            gradient: (picked == null && !hasPhoto)
                                ? LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.25),
                                      Colors.white.withOpacity(0.1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            image: picked != null
                                ? DecorationImage(
                                    image: FileImage(picked), fit: BoxFit.cover)
                                : hasPhoto
                                    ? DecorationImage(
                                        image: controller.photoProvider!,
                                        fit: BoxFit.cover)
                                    : null,
                          ),
                          child: (picked == null && !hasPhoto)
                              ? Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 2, right: 2,
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 8, offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(Icons.camera_alt_rounded,
                                color: ws.themedPrimary(colorScheme), size: 18),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Text(
                  t.translate('editProfileChangePhoto'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13, fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: themed
            ? ws.glassCard(radius: 20)
            : BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.06),
                    blurRadius: 12, offset: const Offset(0, 4),
                  ),
                ],
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: (themed ? ws.themedPrimary(colorScheme) : colorScheme.primary).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18,
                        color: themed ? ws.themedPrimary(colorScheme) : colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: themed ? ws.onThemeColor : colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: themed ? ws.glassBorder : colorScheme.outlineVariant.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsCard(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
  ) {
    final fields = controller.getInterestedFields(t);
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: themed
            ? ws.glassCard(radius: 20)
            : BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.06),
                    blurRadius: 12, offset: const Offset(0, 4),
                  ),
                ],
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: (themed ? ws.themedPrimary(colorScheme) : colorScheme.primary).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.interests_rounded, size: 18,
                        color: themed ? ws.themedPrimary(colorScheme) : colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.translate('editProfileInterestedFieldsTitle'),
                          style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: themed ? ws.onThemeColor : colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.translate('editProfileInterestedFieldsSubtitle'),
                          style: TextStyle(
                            fontSize: 12,
                            color: themed ? ws.onThemeColor.withOpacity(0.7) : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: themed ? ws.glassBorder : colorScheme.outlineVariant.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Obx(() => Wrap(
                spacing: 10, runSpacing: 10,
                children: List.generate(
                  fields.length,
                  (i) => _buildInterestChip(
                    context, fields[i],
                    controller.selectedFields[i],
                    () => controller.selectedFields[i] = !controller.selectedFields[i],
                  ),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    final primary = ws.themedPrimary(colorScheme);
    final saving = controller.isSaving.value;
    return SizedBox(
      width: double.infinity, height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themed
                ? [primary, primary.withOpacity(0.7)]
                : isDark
                    ? [const Color(0xFF3A3A3A), const Color(0xFF2C2C2C)]
                    : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themed
                  ? primary.withOpacity(0.35)
                  : isDark
                      ? Colors.black.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.35),
              blurRadius: 14, offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: saving ? null : () => controller.handleSave(context),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: saving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          t.translate('editProfileSaveButton'),
                          style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700,
                            fontSize: 16, letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    String hintText, {
    String? errorText,
    TextInputType? keyboardType,
    String? helperText,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = errorText != null && errorText.isNotEmpty;
    final errorColor = Colors.red.shade600;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    final primary = ws.themedPrimary(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            fontSize: 15,
            color: themed ? ws.onThemeColor : colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: hasError
                  ? errorColor
                  : themed
                      ? ws.onThemeColor.withOpacity(0.7)
                      : colorScheme.onSurfaceVariant,
              fontSize: 14, fontWeight: FontWeight.w500,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: themed
                  ? ws.onThemeColor.withOpacity(0.4)
                  : colorScheme.outline.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(icon, color: hasError ? errorColor : primary, size: 20),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: suffixIcon,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: hasError
                ? errorColor.withOpacity(0.05)
                : themed
                    ? Colors.white.withOpacity(ws.isThemeDark ? 0.10 : 0.35)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.45),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? errorColor
                    : themed ? ws.glassBorder : colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? errorColor
                    : themed ? ws.glassBorder : colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? errorColor : primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 4),
              Icon(Icons.error_outline_rounded, size: 14, color: errorColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  style: TextStyle(
                    fontSize: 12, color: errorColor, fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ] else if (helperText != null && helperText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 12,
                color: themed
                    ? ws.onThemeColor.withOpacity(0.5)
                    : colorScheme.outline,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInterestChip(
    BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    final primary = ws.themedPrimary(colorScheme);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : themed
                  ? Colors.white.withOpacity(ws.isThemeDark ? 0.12 : 0.45)
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primary
                : themed ? ws.glassBorder : colorScheme.outlineVariant,
            width: isSelected ? 0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.25),
                    blurRadius: 10, offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, color: colorScheme.onPrimary, size: 16),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13, letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    if (!controller.hasUnsavedChanges) return true;
    final t = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('editProfileUnsavedTitle')),
        content: Text(t.translate('editProfileUnsavedMessage')),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(t.translate('editProfileDiscard')),
          ),
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(t.translate('editProfileKeepEditing')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showTopMessage(BuildContext context, String message, Color backgroundColor) {
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8, offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      backgroundColor == Colors.red.shade600
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.translate('editProfileChangePhoto'),
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.camera_alt_rounded, color: cs.primary, size: 22),
                  ),
                  title: Text(t.translate('editProfileCamera')),
                  onTap: () => Get.back(result: ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.photo_library_rounded, color: cs.primary, size: 22),
                  ),
                  title: Text(t.translate('editProfileGallery')),
                  onTap: () => Get.back(result: ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 512, maxHeight: 512, imageQuality: 80,
      );
      if (picked != null && context.mounted) {
        controller.pickedPhoto.value = File(picked.path);
      }
    } catch (e) {
      if (context.mounted) {
        _showTopMessage(context, 'Failed to pick image: $e', Colors.red.shade600);
      }
    }
  }

  Future<void> _showCountryPicker(BuildContext context, AppLocalizations t) async {
    final cs = Theme.of(context).colorScheme;
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42, height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t.translate('forgotPasswordSelectCountry'),
                  style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: cs.onSurface,
                  ),
                ),
              ),
              Divider(height: 1, color: cs.outlineVariant.withOpacity(0.5)),
              Expanded(
                child: ListView.builder(
                  itemCount: controller.countryNameKeys.length,
                  itemBuilder: (_, i) {
                    final name = t.translate(controller.countryNameKeys[i]);
                    return ListTile(
                      title: Text(name),
                      onTap: () => Get.back(result: name),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    controller.countryController.text = selected;
    controller.validateCountryLive(selected);
  }
}

class _DobInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final capped = digits.length > 8 ? digits.substring(0, 8) : digits;
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(capped[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
