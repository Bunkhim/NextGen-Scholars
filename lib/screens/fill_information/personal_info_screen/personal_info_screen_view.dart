import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';

part 'personal_info_screen_controller.dart';
part 'personal_info_screen_binding.dart';

class PersonalInfoScreenView extends GetView<PersonalInfoScreenViewController> {
  const PersonalInfoScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('personalInfoAppBar'),
        onBackPressed: () => Get.offAllNamed(Routes.home),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 1,
        totalSteps: 8,
        onBack: () => Get.back(),
        onNext: controller.submitForm,
        onSave: controller.onSave,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          autovalidateMode: controller.hasAttemptedSubmit.value
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Obx(() => Column(
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
                        FieldLabel(label: t.translate('personalInfoFirstName')),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: controller.firstNameError.value != null
                                ? Border.all(color: colorScheme.error, width: 1)
                                : null,
                          ),
                          child: CustomTextField(
                            controller: controller.firstNameController,
                            hintText: t.translate('personalInfoFirstNameHint'),
                            validator: (value) {
                              return null;
                            },
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
                        FieldLabel(label: t.translate('personalInfoLastName')),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: controller.lastNameError.value != null
                                ? Border.all(color: colorScheme.error, width: 1)
                                : null,
                          ),
                          child: CustomTextField(
                            controller: controller.lastNameController,
                            hintText: t.translate('personalInfoLastNameHint'),
                            validator: (value) {
                              return null;
                            },
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
                      value: controller.genderKeyToDisplay(controller.selectedGender.value, t),
                      hintText: t.translate('personalInfoSelectHint'),
                      items: controller.getGenders(t),
                      errorText: controller.genderError.value,
                      onChanged: (value) {
                        controller.selectedGender.value = controller.genderDisplayToKey(value, t);
                        controller.genderError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('personalInfoNationality')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.nationalityKeyToDisplay(controller.selectedNationality.value, t),
                      hintText: t.translate('personalInfoSelectHint'),
                      items: controller.getNationalities(t),
                      errorText: controller.nationalityError.value,
                      onChanged: (value) {
                        controller.selectedNationality.value = controller.nationalityDisplayToKey(value, t);
                        controller.nationalityError.value = null;
                      },
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
                      onTap: () => controller.selectDate(context),
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
                        validator: (value) {
                          return null;
                        },
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
                        validator: (value) {
                          return null;
                        },
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
                    onTap: () => controller.showImageSourceDialog(context),
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
                              onPressed: () {
                                controller.profileImage.value = null;
                                if (controller.hasAttemptedSubmit.value) {
                                  controller.imageError.value = AppLocalizations.of(context)
                                      .translate('personalInfoSelectImage');
                                }
                              },
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
          )),
        ),
      ),
    );
  }
}
