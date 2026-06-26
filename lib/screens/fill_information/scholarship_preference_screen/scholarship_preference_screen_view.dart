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

part 'scholarship_preference_screen_controller.dart';
part 'scholarship_preference_screen_binding.dart';

class ScholarshipPreferenceScreenView extends GetView<ScholarshipPreferenceScreenViewController> {
  const ScholarshipPreferenceScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('prefAppBar'),
        onBackPressed: () => Get.offAllNamed(Routes.home),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 7,
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
              SectionHeader(title: t.translate('prefSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('prefCountryLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedDestinationCountry.value,
                      hintText: t.translate('prefCountryHint'),
                      items: controller.getDestinationCountries(t),
                      errorText: controller.destinationCountryError.value,
                      onChanged: (value) {
                        controller.selectedDestinationCountry.value = value;
                        controller.destinationCountryError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('prefUniversityLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedPreferredUniversity.value,
                      hintText: t.translate('prefUniversityHint'),
                      items: controller.getPreferredUniversities(t),
                      errorText: controller.preferredUniversityError.value,
                      onChanged: (value) {
                        controller.selectedPreferredUniversity.value = value;
                        controller.preferredUniversityError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('prefDegreeLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedPreferredDegree.value,
                      hintText: t.translate('prefDegreeHint'),
                      items: controller.getPreferredDegrees(t),
                      errorText: controller.preferredDegreeError.value,
                      onChanged: (value) {
                        controller.selectedPreferredDegree.value = value;
                        controller.preferredDegreeError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('prefMajorLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedPreferredMajor.value,
                      hintText: t.translate('prefMajorHint'),
                      items: controller.getPreferredMajors(t),
                      errorText: controller.preferredMajorError.value,
                      onChanged: (value) {
                        controller.selectedPreferredMajor.value = value;
                        controller.preferredMajorError.value = null;
                      },
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
