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

part 'work_experience_screen_controller.dart';
part 'work_experience_screen_binding.dart';

class WorkExperienceScreenView extends GetView<WorkExperienceScreenViewController> {
  const WorkExperienceScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('workExpAppBar'),
        onBackPressed: () => Get.offAllNamed(Routes.home),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 4,
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
              SectionHeader(title: t.translate('workExpSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('workExpExperienceLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedWorkExperience.value,
                      hintText: t.translate('workExpExperienceHint'),
                      items: controller.getWorkExperiences(t),
                      errorText: controller.workExperienceError.value,
                      onChanged: (value) {
                        controller.selectedWorkExperience.value = value;
                        controller.workExperienceError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('workExpDurationLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedWorkDuration.value,
                      hintText: t.translate('workExpDurationHint'),
                      items: controller.getWorkDurations(t),
                      errorText: controller.workDurationError.value,
                      onChanged: (value) {
                        controller.selectedWorkDuration.value = value;
                        controller.workDurationError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('workExpTypeLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedWorkType.value,
                      hintText: t.translate('workExpTypeHint'),
                      items: controller.getWorkTypes(t),
                      errorText: controller.workTypeError.value,
                      onChanged: (value) {
                        controller.selectedWorkType.value = value;
                        controller.workTypeError.value = null;
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
