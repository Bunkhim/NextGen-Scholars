// import 'package:flutter/material.dart';
// import 'package:scholarship_app/translations/app_localizations.dart';
// import 'package:scholarship_app/services/application_data.dart';
// import 'package:scholarship_app/routes/app_routes.dart';
// import 'package:scholarship_app/screens/fill_information/languages_screen.dart';
// import 'package:scholarship_app/services/wallpaper_service.dart';
// import 'package:scholarship_app/widgets/custom_app_bar.dart';
// import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
// import 'package:scholarship_app/widgets/form_field.dart';
// import 'package:scholarship_app/widgets/section_header.dart';

// class EducationBackgroundScreen extends StatefulWidget {
//   const EducationBackgroundScreen({super.key});

//   @override
//   State<EducationBackgroundScreen> createState() =>
//       _EducationBackgroundScreenState();
// }

// class _EducationBackgroundScreenState extends State<EducationBackgroundScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _institutionController = TextEditingController();
//   final _gpaController = TextEditingController();

//   final _appData = ApplicationData();

//   String? _selectedDegree;
//   String? _selectedMajor;
//   int? _selectedYear;

//   String? _institutionError;
//   String? _gpaError;
//   String? _degreeError;
//   String? _majorError;
//   String? _yearError;

//   bool _hasAttemptedSubmit = false;

//   List<String> _getDegrees(AppLocalizations t) => [
//         t.translate('educationDegreeHighSchool'),
//         t.translate('educationDegreeAssociate'),
//         t.translate('educationDegreeBachelor'),
//         t.translate('educationDegreeMaster'),
//         t.translate('educationDegreePhd'),
//       ];

//   List<String> _getMajors(AppLocalizations t) => [
//         t.translate('educationMajorCS'),
//         t.translate('educationMajorIT'),
//         t.translate('educationMajorSE'),
//         t.translate('educationMajorEngineering'),
//         t.translate('educationMajorBusiness'),
//         t.translate('educationMajorEconomics'),
//         t.translate('educationMajorFinance'),
//         t.translate('educationMajorArts'),
//         t.translate('educationMajorSciences'),
//         t.translate('educationMajorMedicine'),
//         t.translate('educationMajorLaw'),
//         t.translate('educationMajorEducation'),
//         t.translate('educationMajorArchitecture'),
//         t.translate('educationMajorOther'),
//       ];

//   final List<int> _years = List.generate(
//     30,
//     (index) => DateTime.now().year + 5 - index,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//     _institutionController.addListener(_onInstitutionChanged);
//     _gpaController.addListener(_onGpaChanged);
//   }

//   void _loadSavedData() {
//     _institutionController.text = _appData.institution ?? '';
//     _gpaController.text = _appData.gpa ?? '';
//     _selectedDegree = _appData.degree;
//     _selectedMajor = _appData.major;
//     _selectedYear = _appData.graduationYear;
//   }

//   void _saveData() {
//     _appData.institution = _institutionController.text;
//     _appData.gpa = _gpaController.text;
//     _appData.degree = _selectedDegree;
//     _appData.major = _selectedMajor;
//     _appData.graduationYear = _selectedYear;
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

//   void _onInstitutionChanged() {
//     if (_hasAttemptedSubmit) {
//       setState(() {
//         _institutionError = null;
//       });
//     }
//   }

//   void _onGpaChanged() {
//     if (_hasAttemptedSubmit) {
//       setState(() {
//         _gpaError = _validateGpa(_gpaController.text);
//       });
//     }
//   }

//   String? _validateGpa(String value) {
//     final t = AppLocalizations.of(context);
//     if (value.isEmpty) {
//       return t.translate('educationGpaRequired');
//     }
//     final gpa = double.tryParse(value);
//     if (gpa == null) {
//       return t.translate('educationGpaInvalid');
//     }
//     if (gpa < 0.0 || gpa > 4.0) {
//       return t.translate('educationGpaRange');
//     }
//     return null;
//   }

//   void _submitForm() {
//     setState(() {
//       _hasAttemptedSubmit = true;

//       final t = AppLocalizations.of(context);
//       if (_institutionController.text.isEmpty) {
//         _institutionError = t.translate('educationInstitutionRequired');
//       } else if (_institutionController.text.length < 3) {
//         _institutionError = t.translate('educationInstitutionTooShort');
//       } else {
//         _institutionError = null;
//       }

//       if (_gpaController.text.isEmpty) {
//         _gpaError = t.translate('educationGpaRequired');
//       } else {
//         _gpaError = _validateGpa(_gpaController.text);
//       }

//       _degreeError =
//           _selectedDegree == null ? t.translate('educationSelectDegree') : null;
//       _majorError =
//           _selectedMajor == null ? t.translate('educationSelectMajor') : null;
//       _yearError =
//           _selectedYear == null ? t.translate('educationSelectGradYear') : null;
//     });

//     bool isFormValid = _institutionError == null &&
//         _gpaError == null &&
//         _degreeError == null &&
//         _majorError == null &&
//         _yearError == null;

//     if (!isFormValid) {
//       return;
//     }

//     _saveData();
//     ApplicationData().saveToPrefs();

//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const LanguagesScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final t = AppLocalizations.of(context);

//     return Scaffold(
//       backgroundColor:
//           WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
//       appBar: CustomAppBar(
//         title: t.translate('educationAppBar'),
//         onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
//             context, AppRoutes.homeScreen, (_) => false),
//       ),
//       bottomNavigationBar: FillInfoNavBar(
//         step: 2,
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
//               SectionHeader(title: t.translate('educationSection')),
//               const SizedBox(height: 20),
//               FormFieldContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     FieldLabel(label: t.translate('educationInstitution')),
//                     const SizedBox(height: 8),
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         border: _institutionError != null
//                             ? Border.all(color: colorScheme.error, width: 1)
//                             : null,
//                       ),
//                       child: CustomTextField(
//                         controller: _institutionController,
//                         hintText: t.translate('educationInstitutionHint'),
//                         suffixIcon: Icon(
//                           Icons.edit,
//                           color: WallpaperService()
//                               .themedOnSurfaceVariant(colorScheme),
//                         ),
//                         validator: (value) {
//                           return null;
//                         },
//                       ),
//                     ),
//                     if (_institutionError != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8, left: 12),
//                         child: Text(
//                           _institutionError!,
//                           style: TextStyle(
//                             color: colorScheme.error,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               FormFieldContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     FieldLabel(label: t.translate('educationDegree')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedDegree,
//                       hintText: t.translate('educationDegreeHint'),
//                       items: _getDegrees(t),
//                       errorText: _degreeError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedDegree = value;
//                           _degreeError = null;
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
//                     FieldLabel(label: t.translate('educationMajor')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedMajor,
//                       hintText: t.translate('educationMajorHint'),
//                       items: _getMajors(t),
//                       errorText: _majorError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedMajor = value;
//                           _majorError = null;
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
//                     FieldLabel(label: t.translate('educationGradYear')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<int>(
//                       value: _selectedYear,
//                       hintText: t.translate('educationGradYearHint'),
//                       items: _years,
//                       errorText: _yearError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedYear = value;
//                           _yearError = null;
//                         });
//                       },
//                       itemLabel: (year) => year.toString(),
//                     ),
//                   ],
//                 ),
//               ),
//               FormFieldContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     FieldLabel(label: t.translate('educationGpa')),
//                     const SizedBox(height: 8),
//                     Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(12),
//                         border: _gpaError != null
//                             ? Border.all(color: colorScheme.error, width: 1)
//                             : null,
//                       ),
//                       child: CustomTextField(
//                         controller: _gpaController,
//                         hintText: t.translate('educationGpaHint'),
//                         keyboardType: const TextInputType.numberWithOptions(
//                           decimal: true,
//                         ),
//                         suffixIcon: Icon(
//                           Icons.edit,
//                           color: WallpaperService()
//                               .themedOnSurfaceVariant(colorScheme),
//                         ),
//                         validator: (value) {
//                           return null;
//                         },
//                       ),
//                     ),
//                     if (_gpaError != null)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8, left: 12),
//                         child: Text(
//                           _gpaError!,
//                           style: TextStyle(
//                             color: colorScheme.error,
//                             fontSize: 10,
//                           ),
//                         ),
//                       ),
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

//   @override
//   void dispose() {
//     _institutionController.removeListener(_onInstitutionChanged);
//     _gpaController.removeListener(_onGpaChanged);
//     _institutionController.dispose();
//     _gpaController.dispose();
//     super.dispose();
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
import 'package:scholarship_app/controllers/fill_information/education_background_controller.dart';

class EducationBackgroundScreen extends StatefulWidget {
  const EducationBackgroundScreen({super.key});

  @override
  State<EducationBackgroundScreen> createState() =>
      _EducationBackgroundScreenState();
}

class _EducationBackgroundScreenState extends State<EducationBackgroundScreen> {
  final EducationBackgroundController controller =
      Get.put(EducationBackgroundController());
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    final t = AppLocalizations.of(context);
    final isValid = controller.submitForm(t);
    if (isValid) {
      Get.toNamed(AppRoutes.languagesScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    controller.revalidateGpa(t);

    return Scaffold(
      backgroundColor:
          WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('educationAppBar'),
        onBackPressed: controller.goHome,
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 2,
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
                          validator: (value) => null,
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
                        onChanged: controller.selectDegree,
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
                        onChanged: controller.selectMajor,
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
                        onChanged: controller.selectYear,
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
                          validator: (value) => null,
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
            ),
          ),
        ),
        ),
      ),
    );
  }
}