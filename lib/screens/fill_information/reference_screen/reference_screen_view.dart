import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';

part 'reference_screen_controller.dart';
part 'reference_screen_binding.dart';

class ReferenceScreenView extends GetView<ReferenceScreenViewController> {
  const ReferenceScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('referenceAppBar'),
        onBackPressed: () => Get.offAllNamed(Routes.home),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 8,
        totalSteps: 8,
        onBack: () => Get.back(),
        onNext: controller.submitForm,
        onSave: controller.onSave,
        isLastStep: true,
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
              SectionHeader(title: t.translate('referenceSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('referenceFullName')),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: controller.fullNameError.value != null
                            ? Border.all(color: colorScheme.error, width: 1)
                            : null,
                      ),
                      child: CustomTextField(
                        controller: controller.fullNameController,
                        hintText: t.translate('referenceFullNameHint'),
                        validator: (value) => null,
                      ),
                    ),
                    if (controller.fullNameError.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          controller.fullNameError.value!,
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
                    FieldLabel(label: t.translate('referencePosition')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedPosition.value,
                      hintText: t.translate('referencePositionHint'),
                      items: controller.getPositions(t),
                      errorText: controller.positionError.value,
                      onChanged: (value) {
                        controller.selectedPosition.value = value;
                        controller.positionError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('referenceWorkPlace')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: controller.selectedWorkPlace.value,
                      hintText: t.translate('referenceWorkPlaceHint'),
                      items: controller.getWorkPlaces(t),
                      errorText: controller.workPlaceError.value,
                      onChanged: (value) {
                        controller.selectedWorkPlace.value = value;
                        controller.workPlaceError.value = null;
                      },
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('referencePhone')),
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
                        hintText: t.translate('referencePhoneHint'),
                        keyboardType: TextInputType.phone,
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
                    FieldLabel(label: t.translate('referenceEmail')),
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
                        hintText: t.translate('referenceEmailHint'),
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
              const SizedBox(height: 24),
            ],
          )),
        ),
      ),
    );
  }
}
