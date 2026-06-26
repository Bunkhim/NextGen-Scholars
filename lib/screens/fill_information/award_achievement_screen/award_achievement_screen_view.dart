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

part 'award_achievement_screen_controller.dart';
part 'award_achievement_screen_binding.dart';

class AwardAchievementScreenView extends GetView<AwardAchievementScreenViewController> {
  const AwardAchievementScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('awardAppBar'),
        onBackPressed: () => Get.offAllNamed(Routes.home),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 6,
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
              SectionHeader(title: t.translate('awardSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('awardAchievementLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedAwardAchievement.value,
                      hintText: t.translate('awardAchievementHint'),
                      items: controller.getAwardAchievements(t),
                      errorText: controller.awardAchievementError.value,
                      onChanged: (value) {
                        controller.selectedAwardAchievement.value = value;
                        controller.awardAchievementError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('awardProgramNameLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedProgramName.value,
                      hintText: t.translate('awardProgramNameHint'),
                      items: controller.getProgramNames(t),
                      errorText: controller.programNameError.value,
                      onChanged: (value) {
                        controller.selectedProgramName.value = value;
                        controller.programNameError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('awardOrganizationLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedOrganization.value,
                      hintText: t.translate('awardOrganizationHint'),
                      items: controller.getOrganizations(t),
                      errorText: controller.organizationError.value,
                      onChanged: (value) {
                        controller.selectedOrganization.value = value;
                        controller.organizationError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('awardLocationLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedLocation.value,
                      hintText: t.translate('awardLocationHint'),
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
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('awardDescriptionLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedDescription.value,
                      hintText: t.translate('awardDescriptionHint'),
                      items: controller.getDescriptions(t),
                      errorText: controller.descriptionError.value,
                      onChanged: (value) {
                        controller.selectedDescription.value = value;
                        controller.descriptionError.value = null;
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
