// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';
import 'package:scholarship_app/controllers/fill_information/personal_info_controller.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final PersonalInfoController controller = Get.put(PersonalInfoController());
  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedDate.value ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'GB'),
      helpText: t.translate('personalInfoDobHint'),
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: cs.copyWith(primary: cs.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != controller.selectedDate.value) {
      controller.selectDate(picked);
    }
  }

  void _showImageSourceDialog() {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(t.translate('personalInfoImageSourceTitle'),
              style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt,
                    color: WallpaperService().themedPrimary(colorScheme)),
                title: Text(t.translate('personalInfoCameraOption'),
                    style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  controller.pickImage(ImageSource.camera, t);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: WallpaperService().themedPrimary(colorScheme),
                ),
                title: Text(t.translate('personalInfoGalleryOption'),
                    style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  controller.pickImage(ImageSource.gallery, t);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _submitForm() {
    final t = AppLocalizations.of(context);
    final isValid = controller.submitForm(t);
    if (isValid) {
      Get.toNamed(AppRoutes.educationBackgroundScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    // Keep translated validation messages in sync as the user types.
    controller.revalidateTextFields(t);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('personalInfoAppBar'),
        onBackPressed: controller.goHome,
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 1,
        totalSteps: 8,
        onBack: () => Navigator.maybePop(context),
        onNext: _submitForm,
        onSave: () => controller.onSave(t),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Form(
            key: _formKey,
            autovalidateMode: controller.hasAttemptedSubmit.value
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(title: t.translate('personalInfoSection')),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FieldLabel(
                              label: t.translate('personalInfoFirstName')),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: controller.firstNameError.value != null
                                  ? Border.all(
                                      color: colorScheme.error, width: 1)
                                  : null,
                            ),
                            child: CustomTextField(
                              controller: controller.firstNameController,
                              hintText:
                                  t.translate('personalInfoFirstNameHint'),
                              validator: (value) => null,
                            ),
                          ),
                          if (controller.firstNameError.value != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                controller.firstNameError.value!,
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FieldLabel(
                              label: t.translate('personalInfoLastName')),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: controller.lastNameError.value != null
                                  ? Border.all(
                                      color: colorScheme.error, width: 1)
                                  : null,
                            ),
                            child: CustomTextField(
                              controller: controller.lastNameController,
                              hintText:
                                  t.translate('personalInfoLastNameHint'),
                              validator: (value) => null,
                            ),
                          ),
                          if (controller.lastNameError.value != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 12),
                              child: Text(
                                controller.lastNameError.value!,
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                FormFieldContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(label: t.translate('personalInfoGender')),
                      const SizedBox(height: 8),
                      ValidatedDropdown<String>(
                        value: controller.genderKeyToDisplay(
                            controller.selectedGender.value, t),
                        hintText: t.translate('personalInfoSelectHint'),
                        items: controller.getGenders(t),
                        errorText: controller.genderError.value,
                        onChanged: (value) =>
                            controller.selectGender(value, t),
                      ),
                    ],
                  ),
                ),
                FormFieldContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(
                          label: t.translate('personalInfoNationality')),
                      const SizedBox(height: 8),
                      ValidatedDropdown<String>(
                        value: controller.nationalityKeyToDisplay(
                            controller.selectedNationality.value, t),
                        hintText: t.translate('personalInfoSelectHint'),
                        items: controller.getNationalities(t),
                        errorText: controller.nationalityError.value,
                        onChanged: (value) =>
                            controller.selectNationality(value, t),
                      ),
                    ],
                  ),
                ),
                FormFieldContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(label: t.translate('personalInfoDob')),
                      const SizedBox(height: 8),
                      ValidatedDatePickerField(
                        selectedDate: controller.selectedDate.value,
                        onTap: () => _selectDate(context),
                        errorText: controller.dateError.value,
                      ),
                    ],
                  ),
                ),
                FormFieldContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(label: t.translate('personalInfoPhone')),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: controller.phoneError.value != null
                              ? Border.all(color: colorScheme.error, width: 1)
                              : null,
                        ),
                        child: CustomTextField(
                          controller: controller.phoneController,
                          hintText: t.translate('personalInfoPhoneHint'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) => null,
                        ),
                      ),
                      if (controller.phoneError.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            controller.phoneError.value!,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                FormFieldContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FieldLabel(label: t.translate('personalInfoEmail')),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: controller.emailError.value != null
                              ? Border.all(color: colorScheme.error, width: 1)
                              : null,
                        ),
                        child: CustomTextField(
                          controller: controller.emailController,
                          hintText: t.translate('personalInfoEmailHint'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => null,
                        ),
                      ),
                      if (controller.emailError.value != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            controller.emailError.value!,
                            style: TextStyle(
                              color: colorScheme.error,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('personalInfoChooseImage')),
                    const SizedBox(height: 8),
                    ValidatedImagePickerButton(
                      onTap: _showImageSourceDialog,
                      text: controller.profileImage.value == null
                          ? t.translate('personalInfoGalleryButton')
                          : t.translate('personalInfoImageSelected'),
                      hasImage: controller.profileImage.value != null,
                      errorText: controller.imageError.value,
                    ),
                    if (controller.profileImage.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                controller.profileImage.value!,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                onPressed: () => controller.removeImage(t),
                                icon: CircleAvatar(
                                  backgroundColor: colorScheme.error,
                                  radius: 12,
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: colorScheme.onError,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}