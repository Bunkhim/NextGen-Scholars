import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/controllers/fill_information/reference_controller.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';

class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ReferenceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ReferenceController>()
        ? Get.find<ReferenceController>()
        : Get.put(ReferenceController());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
        backgroundColor: WallpaperService().hasAny
            ? Colors.transparent
            : colorScheme.surface,
        appBar: CustomAppBar(
          title: t.translate('referenceAppBar'),
          onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.homeScreen, (_) => false),
        ),
        bottomNavigationBar: FillInfoNavBar(
          step: 8,
          totalSteps: 8,
          onBack: () => Navigator.maybePop(context),
          onNext: () {
            if (controller.submitForm(t)) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(t.translate('referenceSubmitSuccess')),
                  backgroundColor: const Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            }
          },
          onSave: () => controller.onSave(t),
          isLastStep: true,
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
                            controller.selectPosition(value);
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
                            controller.selectWorkPlace(value);
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
              ),
            ),
          ),
        )
      );
  }

  @override
  void dispose() {
    if (Get.isRegistered<ReferenceController>()) {
      Get.delete<ReferenceController>();
    }
    super.dispose();
  }
}
