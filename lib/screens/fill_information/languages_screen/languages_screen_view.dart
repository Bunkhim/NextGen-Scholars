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

part 'languages_screen_controller.dart';
part 'languages_screen_binding.dart';

class LanguagesScreenView extends GetView<LanguagesScreenViewController> {
  const LanguagesScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('languagesAppBar'),
        onBackPressed: () => Get.offAllNamed(Routes.home),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 3,
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
              SectionHeader(title: t.translate('languagesSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('languagesSpokenLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedSpokenLanguage.value,
                      hintText: t.translate('languagesSpokenHint'),
                      items: controller.getSpokenLanguages(t),
                      errorText: controller.spokenLanguageError.value,
                      onChanged: (value) {
                        controller.selectedSpokenLanguage.value = value;
                        controller.spokenLanguageError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(
                        label: t.translate('languagesEnglishLevelLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedEnglishLevel.value,
                      hintText: t.translate('languagesEnglishLevelHint'),
                      items: controller.getEnglishLevels(t),
                      errorText: controller.englishLevelError.value,
                      onChanged: (value) {
                        controller.selectedEnglishLevel.value = value;
                        controller.englishLevelError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('languagesIeltsCertLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedIELTSCertificate.value,
                      hintText: t.translate('languagesIeltsCertHint'),
                      items: controller.getIeltsCertificates(t),
                      errorText: controller.ieltsCertificateError.value,
                      onChanged: (value) {
                        controller.selectedIELTSCertificate.value = value;
                        controller.ieltsCertificateError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 24),
            ],
          )),
        ),
      ),
    );
  }
}
