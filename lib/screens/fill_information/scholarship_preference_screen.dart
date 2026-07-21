import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';
import 'package:scholarship_app/controllers/fill_information/scholarship_preference_controller.dart';

class ScholarshipPreferenceScreen extends StatefulWidget {
  const ScholarshipPreferenceScreen({super.key});

  @override
  State<ScholarshipPreferenceScreen> createState() =>
      _ScholarshipPreferenceScreenState();
}

class _ScholarshipPreferenceScreenState
    extends State<ScholarshipPreferenceScreen> {
  final ScholarshipPreferenceController controller =
      Get.put(ScholarshipPreferenceController());
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    final t = AppLocalizations.of(context);
    final isValid = controller.submitForm(t);
    if (isValid) {
      Get.toNamed(AppRoutes.referenceScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('prefAppBar'),
        onBackPressed: controller.goHome,
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 7,
        totalSteps: 8,
        onBack: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.maybePop(context);
        },
        onNext: _submitForm,
        onSave: () => controller.onSave(t),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
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
                        onChanged: controller.selectDestinationCountry,
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
                        onChanged: controller.selectPreferredUniversity,
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
                        onChanged: controller.selectPreferredDegree,
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
                        onChanged: controller.selectPreferredMajor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}
