// import 'package:flutter/material.dart';
// import 'package:scholarship_app/translations/app_localizations.dart';
// import 'package:scholarship_app/services/application_data.dart';
// import 'package:scholarship_app/routes/app_routes.dart';
// import 'package:scholarship_app/screens/fill_information/research_experience_screen.dart';
// import 'package:scholarship_app/services/wallpaper_service.dart';
// import 'package:scholarship_app/widgets/custom_app_bar.dart';
// import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
// import 'package:scholarship_app/widgets/form_field.dart';
// import 'package:scholarship_app/widgets/section_header.dart';

// class WorkExperienceScreen extends StatefulWidget {
//   const WorkExperienceScreen({super.key});

//   @override
//   State<WorkExperienceScreen> createState() => _WorkExperienceScreenState();
// }

// class _WorkExperienceScreenState extends State<WorkExperienceScreen> {
//   final _formKey = GlobalKey<FormState>();

//   bool _hasAttemptedSubmit = false;

//   final _appData = ApplicationData();

//   String? _selectedWorkExperience;
//   String? _selectedWorkDuration;
//   String? _selectedWorkType;

//   String? _workExperienceError;
//   String? _workDurationError;
//   String? _workTypeError;

//   List<String> _getWorkExperiences(AppLocalizations t) => [
//         t.translate('workExpNoExperience'),
//         t.translate('workExpFreshGraduate'),
//         t.translate('workExpIntern'),
//         t.translate('workExp1To2Years'),
//         t.translate('workExp2To5Years'),
//         t.translate('workExp5To10Years'),
//         t.translate('workExp10PlusYears'),
//       ];

//   List<String> _getWorkDurations(AppLocalizations t) => [
//         t.translate('workExpDurationLess6Months'),
//         t.translate('workExpDuration6MonthsTo1Year'),
//         t.translate('workExpDuration1To2Years'),
//         t.translate('workExpDuration2To3Years'),
//         t.translate('workExpDuration3To5Years'),
//         t.translate('workExpDuration5PlusYears'),
//       ];

//   List<String> _getWorkTypes(AppLocalizations t) => [
//         t.translate('workExpTypeFullTime'),
//         t.translate('workExpTypePartTime'),
//         t.translate('workExpTypeInternship'),
//         t.translate('workExpTypeVolunteer'),
//         t.translate('workExpTypeFreelance'),
//         t.translate('workExpTypeContract'),
//         t.translate('workExpTypeSelfEmployed'),
//       ];

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//   }

//   void _loadSavedData() {
//     _selectedWorkExperience = _appData.workExperience;
//     _selectedWorkDuration = _appData.workDuration;
//     _selectedWorkType = _appData.workType;
//   }

//   void _saveData() {
//     _appData.workExperience = _selectedWorkExperience;
//     _appData.workDuration = _selectedWorkDuration;
//     _appData.workType = _selectedWorkType;
//   }

//   void _onSave() {
//     _saveData();
//     ApplicationData().saveToPrefs();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(AppLocalizations.of(context).translate('fillInfoSaved')),
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   void _submitForm() {
//     setState(() {
//       _hasAttemptedSubmit = true;
//       final t = AppLocalizations.of(context);
//       _workExperienceError = _selectedWorkExperience == null
//           ? t.translate('workExpSelectExperience')
//           : null;
//       _workDurationError = _selectedWorkDuration == null
//           ? t.translate('workExpSelectDuration')
//           : null;
//       _workTypeError =
//           _selectedWorkType == null ? t.translate('workExpSelectType') : null;
//     });

//     if (_workExperienceError != null ||
//         _workDurationError != null ||
//         _workTypeError != null) {
//       return;
//     }

//     _saveData();
//     ApplicationData().saveToPrefs();

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const ResearchExperienceScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final t = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor: WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
//       appBar: CustomAppBar(
//         title: t.translate('workExpAppBar'),
//         onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
//             context, AppRoutes.homeScreen, (_) => false),
//       ),
//       bottomNavigationBar: FillInfoNavBar(
//         step: 4,
//         totalSteps: 8,
//         onBack: () => Navigator.maybePop(context),
//         onNext: _submitForm,
//         onSave: _onSave,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           autovalidateMode: _hasAttemptedSubmit
//               ? AutovalidateMode.onUserInteraction
//               : AutovalidateMode.disabled,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SectionHeader(title: t.translate('workExpSection')),
//               const SizedBox(height: 20),
//               FormFieldContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     FieldLabel(label: t.translate('workExpExperienceLabel')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedWorkExperience,
//                       hintText: t.translate('workExpExperienceHint'),
//                       items: _getWorkExperiences(t),
//                       errorText: _workExperienceError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedWorkExperience = value;
//                           _workExperienceError = null;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               FormFieldContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     FieldLabel(label: t.translate('workExpDurationLabel')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedWorkDuration,
//                       hintText: t.translate('workExpDurationHint'),
//                       items: _getWorkDurations(t),
//                       errorText: _workDurationError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedWorkDuration = value;
//                           _workDurationError = null;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               FormFieldContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     FieldLabel(label: t.translate('workExpTypeLabel')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedWorkType,
//                       hintText: t.translate('workExpTypeHint'),
//                       items: _getWorkTypes(t),
//                       errorText: _workTypeError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedWorkType = value;
//                           _workTypeError = null;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';
import 'package:scholarship_app/controllers/fill_information/work_experience_controller.dart';

class WorkExperienceScreen extends StatefulWidget {
  const WorkExperienceScreen({super.key});

  @override
  State<WorkExperienceScreen> createState() => _WorkExperienceScreenState();
}

class _WorkExperienceScreenState extends State<WorkExperienceScreen> {
  final WorkExperienceController controller =
      Get.put(WorkExperienceController());
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    final t = AppLocalizations.of(context);
    final isValid = controller.submitForm(t);
    if (isValid) {
      Get.toNamed(AppRoutes.researchExperienceScreen);
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
        title: t.translate('workExpAppBar'),
        onBackPressed: controller.goHome,
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 4,
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
                        onChanged: controller.selectWorkExperience,
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
                        onChanged: controller.selectWorkDuration,
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
                        onChanged: controller.selectWorkType,
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
