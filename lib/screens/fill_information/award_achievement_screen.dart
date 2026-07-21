// import 'package:flutter/material.dart';
// import 'package:scholarship_app/translations/app_localizations.dart';
// import 'package:scholarship_app/services/application_data.dart';
// import 'package:scholarship_app/routes/app_routes.dart';
// import 'package:scholarship_app/screens/fill_information/scholarship_preference_screen.dart';
// import 'package:scholarship_app/services/wallpaper_service.dart';
// import 'package:scholarship_app/widgets/custom_app_bar.dart';
// import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
// import 'package:scholarship_app/widgets/form_field.dart';
// import 'package:scholarship_app/widgets/section_header.dart';

// class AwardAchievementScreen extends StatefulWidget {
//   const AwardAchievementScreen({super.key});

//   @override
//   State<AwardAchievementScreen> createState() => _AwardAchievementScreenState();
// }

// class _AwardAchievementScreenState extends State<AwardAchievementScreen> {
//   final _formKey = GlobalKey<FormState>();

//   bool _hasAttemptedSubmit = false;

//   final _appData = ApplicationData();

//   String? _selectedAwardAchievement;
//   String? _selectedProgramName;
//   String? _selectedOrganization;
//   String? _selectedLocation;
//   String? _selectedDescription;

//   String? _awardAchievementError;
//   String? _programNameError;
//   String? _organizationError;
//   String? _locationError;
//   String? _descriptionError;

//   List<String> _getAwardAchievements(AppLocalizations t) => [
//         t.translate('awardNone'),
//         t.translate('awardAcademicExcellence'),
//         t.translate('awardScholarshipRecipient'),
//         t.translate('awardCompetitionWinner'),
//         t.translate('awardDeansList'),
//         t.translate('awardHonorRoll'),
//         t.translate('awardBestStudent'),
//         t.translate('awardResearchGrant'),
//         t.translate('awardLeadership'),
//         t.translate('awardCommunityService'),
//         t.translate('awardSports'),
//         t.translate('awardArtsCulture'),
//         t.translate('awardOther'),
//       ];

//   List<String> _getProgramNames(AppLocalizations t) => [
//         t.translate('awardProgScholarship'),
//         t.translate('awardProgAcademic'),
//         t.translate('awardProgCompetition'),
//         t.translate('awardProgResearch'),
//         t.translate('awardProgLeadership'),
//         t.translate('awardProgCommunity'),
//         t.translate('awardProgSports'),
//         t.translate('awardProgArts'),
//         t.translate('awardProgInnovation'),
//         t.translate('awardProgEntrepreneurship'),
//         t.translate('awardProgExchange'),
//         t.translate('awardProgOther'),
//       ];

//   List<String> _getOrganizations(AppLocalizations t) => [
//         t.translate('awardOrgUniversity'),
//         t.translate('awardOrgGovernment'),
//         t.translate('awardOrgPrivate'),
//         t.translate('awardOrgNonProfit'),
//         t.translate('awardOrgInternational'),
//         t.translate('awardOrgResearch'),
//         t.translate('awardOrgProfessional'),
//         t.translate('awardOrgCommunity'),
//         t.translate('awardOrgEduFoundation'),
//         t.translate('awardOrgCorpFoundation'),
//         t.translate('awardOrgOther'),
//       ];

//   List<String> _getLocations(AppLocalizations t) => [
//         t.translate('awardLocCambodia'),
//         t.translate('awardLocVietnam'),
//         t.translate('awardLocSingapore'),
//         t.translate('awardLocMalaysia'),
//         t.translate('awardLocIndonesia'),
//         t.translate('awardLocPhilippines'),
//         t.translate('awardLocUS'),
//         t.translate('awardLocUK'),
//         t.translate('awardLocAustralia'),
//         t.translate('awardLocJapan'),
//         t.translate('awardLocSouthKorea'),
//         t.translate('awardLocChina'),
//         t.translate('awardLocInternational'),
//         t.translate('awardLocOther'),
//       ];

//   List<String> _getDescriptions(AppLocalizations t) => [
//         t.translate('awardDescTop1'),
//         t.translate('awardDescTop5'),
//         t.translate('awardDescTop10'),
//         t.translate('awardDescFirst'),
//         t.translate('awardDescSecond'),
//         t.translate('awardDescThird'),
//         t.translate('awardDescHonorable'),
//         t.translate('awardDescFinalist'),
//         t.translate('awardDescParticipant'),
//         t.translate('awardDescCertAchievement'),
//         t.translate('awardDescCertCompletion'),
//         t.translate('awardDescOther'),
//       ];

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedData();
//   }

//   void _loadSavedData() {
//     _selectedAwardAchievement = _appData.awardAchievement;
//     _selectedProgramName = _appData.programName;
//     _selectedOrganization = _appData.organization;
//     _selectedLocation = _appData.awardLocation;
//     _selectedDescription = _appData.awardDescription;
//   }

//   void _saveData() {
//     _appData.awardAchievement = _selectedAwardAchievement;
//     _appData.programName = _selectedProgramName;
//     _appData.organization = _selectedOrganization;
//     _appData.awardLocation = _selectedLocation;
//     _appData.awardDescription = _selectedDescription;
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
//       _awardAchievementError = _selectedAwardAchievement == null
//           ? t.translate('awardSelectAchievement')
//           : null;
//       _programNameError = _selectedProgramName == null
//           ? t.translate('awardSelectProgram')
//           : null;
//       _organizationError = _selectedOrganization == null
//           ? t.translate('awardSelectOrganization')
//           : null;
//       _locationError =
//           _selectedLocation == null ? t.translate('awardSelectLocation') : null;
//       _descriptionError = _selectedDescription == null
//           ? t.translate('awardSelectDescription')
//           : null;
//     });

//     if (_awardAchievementError != null ||
//         _programNameError != null ||
//         _organizationError != null ||
//         _locationError != null ||
//         _descriptionError != null) {
//       return;
//     }

//     _saveData();
//     ApplicationData().saveToPrefs();

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ScholarshipPreferenceScreen(),
//       ),
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
//         title: t.translate('awardAppBar'),
//         onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
//             context, AppRoutes.homeScreen, (_) => false),
//       ),
//       bottomNavigationBar: FillInfoNavBar(
//         step: 6,
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
//               SectionHeader(title: t.translate('awardSection')),
//               const SizedBox(height: 20),
//               FormFieldContainer(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     FieldLabel(label: t.translate('awardAchievementLabel')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedAwardAchievement,
//                       hintText: t.translate('awardAchievementHint'),
//                       items: _getAwardAchievements(t),
//                       errorText: _awardAchievementError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedAwardAchievement = value;
//                           _awardAchievementError = null;
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
//                     FieldLabel(label: t.translate('awardProgramNameLabel')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedProgramName,
//                       hintText: t.translate('awardProgramNameHint'),
//                       items: _getProgramNames(t),
//                       errorText: _programNameError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedProgramName = value;
//                           _programNameError = null;
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
//                     FieldLabel(label: t.translate('awardOrganizationLabel')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedOrganization,
//                       hintText: t.translate('awardOrganizationHint'),
//                       items: _getOrganizations(t),
//                       errorText: _organizationError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedOrganization = value;
//                           _organizationError = null;
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
//                     FieldLabel(label: t.translate('awardLocationLabel')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedLocation,
//                       hintText: t.translate('awardLocationHint'),
//                       items: _getLocations(t),
//                       errorText: _locationError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedLocation = value;
//                           _locationError = null;
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
//                     FieldLabel(label: t.translate('awardDescriptionLabel')),
//                     const SizedBox(height: 8),
//                     ValidatedDropdown<String>(
//                       value: _selectedDescription,
//                       hintText: t.translate('awardDescriptionHint'),
//                       items: _getDescriptions(t),
//                       errorText: _descriptionError,
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedDescription = value;
//                           _descriptionError = null;
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
import 'package:scholarship_app/controllers/fill_information/award_achievement_controller.dart';

class AwardAchievementScreen extends StatefulWidget {
  const AwardAchievementScreen({super.key});

  @override
  State<AwardAchievementScreen> createState() => _AwardAchievementScreenState();
}

class _AwardAchievementScreenState extends State<AwardAchievementScreen> {
  final AwardAchievementController controller =
      Get.put(AwardAchievementController());
  final _formKey = GlobalKey<FormState>();

  void _submitForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    final t = AppLocalizations.of(context);
    final isValid = controller.submitForm(t);
    if (isValid) {
      Get.toNamed(AppRoutes.scholarshipPreferenceScreen);
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
        title: t.translate('awardAppBar'),
        onBackPressed: controller.goHome,
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 6,
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
                        onChanged: controller.selectAwardAchievement,
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
                        onChanged: controller.selectProgramName,
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
                        onChanged: controller.selectOrganization,
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
                        onChanged: controller.selectLocation,
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
                        onChanged: controller.selectDescription,
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
