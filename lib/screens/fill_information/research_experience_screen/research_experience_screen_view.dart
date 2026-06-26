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

part 'research_experience_screen_controller.dart';
part 'research_experience_screen_binding.dart';

class ResearchExperienceScreenView extends GetView<ResearchExperienceScreenViewController> {
  const ResearchExperienceScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('researchAppBar'),
        onBackPressed: () => Get.offAllNamed(Routes.home),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 5,
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
              SectionHeader(title: t.translate('researchSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('researchExperienceLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedResearchExperience.value,
                      hintText: t.translate('researchExperienceHint'),
                      items: controller.getResearchExperiences(t),
                      errorText: controller.researchExperienceError.value,
                      onChanged: (value) {
                        controller.selectedResearchExperience.value = value;
                        controller.researchExperienceError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('researchAuthorsLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedAuthors.value,
                      hintText: t.translate('researchAuthorsHint'),
                      items: controller.getAuthorsList(t),
                      errorText: controller.authorsError.value,
                      onChanged: (value) {
                        controller.selectedAuthors.value = value;
                        controller.authorsError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('researchFieldLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedResearchField.value,
                      hintText: t.translate('researchFieldHint'),
                      items: controller.getResearchFields(t),
                      errorText: controller.researchFieldError.value,
                      onChanged: (value) {
                        controller.selectedResearchField.value = value;
                        controller.researchFieldError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('researchPublisherLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedPublisher.value,
                      hintText: t.translate('researchPublisherHint'),
                      items: controller.getPublishers(t),
                      errorText: controller.publisherError.value,
                      onChanged: (value) {
                        controller.selectedPublisher.value = value;
                        controller.publisherError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('researchLocationLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedLocation.value,
                      hintText: t.translate('researchLocationHint'),
                      items: controller.getLocations(t),
                      errorText: controller.locationError.value,
                      onChanged: (value) {
                        controller.selectedLocation.value = value;
                        controller.locationError.value = null;
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
