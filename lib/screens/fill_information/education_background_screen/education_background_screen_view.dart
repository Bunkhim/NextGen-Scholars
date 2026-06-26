import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';

part 'education_background_screen_controller.dart';
part 'education_background_screen_binding.dart';

class EducationBackgroundScreenView extends GetView<EducationBackgroundScreenViewController> {
  const EducationBackgroundScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('educationAppBar'),
        onBackPressed: () => Get.offAllNamed(Routes.home),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 2,
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
              SectionHeader(title: t.translate('educationSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('educationInstitution')),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: controller.institutionError.value != null
                            ? Border.all(color: colorScheme.error, width: 1)
                            : null,
                      ),
                      child: CustomTextField(
                        controller: controller.institutionController,
                        hintText: t.translate('educationInstitutionHint'),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: WallpaperService()
                              .themedOnSurfaceVariant(colorScheme),
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                    if (controller.institutionError.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          controller.institutionError.value!,
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
                    FieldLabel(label: t.translate('educationDegree')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedDegree.value,
                      hintText: t.translate('educationDegreeHint'),
                      items: controller.getDegrees(t),
                      errorText: controller.degreeError.value,
                      onChanged: (value) {
                        controller.selectedDegree.value = value;
                        controller.degreeError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('educationMajor')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedMajor.value,
                      hintText: t.translate('educationMajorHint'),
                      items: controller.getMajors(t),
                      errorText: controller.majorError.value,
                      onChanged: (value) {
                        controller.selectedMajor.value = value;
                        controller.majorError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('educationGradYear')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<int>(
                      value: controller.selectedYear.value,
                      hintText: t.translate('educationGradYearHint'),
                      items: controller.years,
                      errorText: controller.yearError.value,
                      onChanged: (value) {
                        controller.selectedYear.value = value;
                        controller.yearError.value = null;
                      },
                      itemLabel: (year) => year.toString(),
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('educationGpa')),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: controller.gpaError.value != null
                            ? Border.all(color: colorScheme.error, width: 1)
                            : null,
                      ),
                      child: CustomTextField(
                        controller: controller.gpaController,
                        hintText: t.translate('educationGpaHint'),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: WallpaperService()
                              .themedOnSurfaceVariant(colorScheme),
                        ),
                        validator: (value) {
                          return null;
                        },
                      ),
                    ),
                    if (controller.gpaError.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          controller.gpaError.value!,
                          style: TextStyle(
                            color: colorScheme.error,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          )),
        ),
      ),
    );
  }
}
