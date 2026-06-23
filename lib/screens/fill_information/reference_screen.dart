import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
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
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _hasAttemptedSubmit = false;

  final _appData = ApplicationData();

  String? _selectedPosition;
  String? _selectedWorkPlace;

  String? _fullNameError;
  String? _positionError;
  String? _workPlaceError;
  String? _phoneError;
  String? _emailError;

  List<String> _getPositions(AppLocalizations t) => [
        t.translate('referenceProfessor'),
        t.translate('referenceAssocProfessor'),
        t.translate('referenceAsstProfessor'),
        t.translate('referenceLecturer'),
        t.translate('referenceTeacher'),
        t.translate('referenceDeptHead'),
        t.translate('referenceAcademicAdvisor'),
        t.translate('referenceResearchSupervisor'),
        t.translate('referenceManager'),
        t.translate('referenceDirector'),
        t.translate('referenceSupervisor'),
        t.translate('referenceTeamLeader'),
        t.translate('referenceHRManager'),
        t.translate('referenceOther'),
      ];

  List<String> _getWorkPlaces(AppLocalizations t) => [
        t.translate('referenceWpUniversity'),
        t.translate('referenceWpCollege'),
        t.translate('referenceWpHighSchool'),
        t.translate('referenceWpResearchInst'),
        t.translate('referenceWpPrivateCompany'),
        t.translate('referenceWpGovernment'),
        t.translate('referenceWpNonProfit'),
        t.translate('referenceWpInternational'),
        t.translate('referenceWpEducational'),
        t.translate('referenceWpCorporate'),
        t.translate('referenceWpOther'),
      ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    _fullNameController.addListener(_onFullNameChanged);
    _phoneController.addListener(_onPhoneChanged);
    _emailController.addListener(_onEmailChanged);
  }

  void _loadSavedData() {
    _fullNameController.text = _appData.referenceFullName ?? '';
    _phoneController.text = _appData.referencePhone ?? '';
    _emailController.text = _appData.referenceEmail ?? '';
    _selectedPosition = _appData.referencePosition;
    _selectedWorkPlace = _appData.referenceWorkPlace;
  }

  void _saveData() {
    _appData.referenceFullName = _fullNameController.text;
    _appData.referencePhone = _phoneController.text;
    _appData.referenceEmail = _emailController.text;
    _appData.referencePosition = _selectedPosition;
    _appData.referenceWorkPlace = _selectedWorkPlace;
  }

  void _onSave() {
    _saveData();
    ApplicationData().saveToPrefs();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate('fillInfoSaved')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onFullNameChanged() {
    if (_hasAttemptedSubmit) {
      setState(() {
        _fullNameError = _validateName(_fullNameController.text);
      });
    }
  }

  void _onPhoneChanged() {
    if (_hasAttemptedSubmit) {
      setState(() {
        _phoneError = _validatePhone(_phoneController.text);
      });
    }
  }

  void _onEmailChanged() {
    if (_hasAttemptedSubmit) {
      setState(() {
        _emailError = _validateEmail(_emailController.text);
      });
    }
  }

  String? _validateName(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('referenceNameRequired');
    }
    if (value.length < 2) {
      return t.translate('referenceNameMinLength');
    }
    // Allow Unicode letters (Khmer, Latin, etc.) and spaces
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(value)) {
      return t.translate('referenceNameAllowUnicode');
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('referencePhoneRequired');
    }
    final digitsOnly = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return t.translate('referencePhoneDigitsOnly');
    }
    if (digitsOnly.length < 8) {
      return t.translate('referencePhoneMinDigits');
    }
    if (digitsOnly.length > 15) {
      return t.translate('referencePhoneMaxDigits');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('referenceEmailRequired');
    }
    // Proper email regex that accepts .edu, .org, .co.uk, etc.
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return t.translate('referenceEmailInvalid');
    }
    return null;
  }

  void _submitForm() {
    setState(() {
      _hasAttemptedSubmit = true;

      _fullNameError = _validateName(_fullNameController.text);
      _phoneError = _validatePhone(_phoneController.text);
      _emailError = _validateEmail(_emailController.text);

      _positionError = _selectedPosition == null
          ? AppLocalizations.of(context).translate('referenceSelectPosition')
          : null;
      _workPlaceError = _selectedWorkPlace == null
          ? AppLocalizations.of(context).translate('referenceSelectWorkPlace')
          : null;
    });

    bool isFormValid = _fullNameError == null &&
        _phoneError == null &&
        _emailError == null &&
        _positionError == null &&
        _workPlaceError == null;

    if (!isFormValid) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();

    // success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            AppLocalizations.of(context).translate('referenceSubmitSuccess')),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    // Navigate back after successful submission
    if (mounted) {
      Navigator.of(context).pop(true);
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
        title: t.translate('referenceAppBar'),
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.homeScreen, (_) => false),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 8,
        totalSteps: 8,
        onBack: () => Navigator.maybePop(context),
        onNext: _submitForm,
        onSave: _onSave,
        isLastStep: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: _hasAttemptedSubmit
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
                        border: _fullNameError != null
                            ? Border.all(color: colorScheme.error, width: 1)
                            : null,
                      ),
                      child: CustomTextField(
                        controller: _fullNameController,
                        hintText: t.translate('referenceFullNameHint'),
                        validator: (value) => null,
                      ),
                    ),
                    if (_fullNameError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          _fullNameError!,
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
                      value: _selectedPosition,
                      hintText: t.translate('referencePositionHint'),
                      items: _getPositions(t),
                      errorText: _positionError,
                      onChanged: (value) {
                        setState(() {
                          _selectedPosition = value;
                          _positionError = null;
                        });
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
                      value: _selectedWorkPlace,
                      hintText: t.translate('referenceWorkPlaceHint'),
                      items: _getWorkPlaces(t),
                      errorText: _workPlaceError,
                      onChanged: (value) {
                        setState(() {
                          _selectedWorkPlace = value;
                          _workPlaceError = null;
                        });
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
                        border: _phoneError != null
                            ? Border.all(color: colorScheme.error, width: 1)
                            : null,
                      ),
                      child: CustomTextField(
                        controller: _phoneController,
                        hintText: t.translate('referencePhoneHint'),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) => null,
                      ),
                    ),
                    if (_phoneError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          _phoneError!,
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
                        border: _emailError != null
                            ? Border.all(color: colorScheme.error, width: 1)
                            : null,
                      ),
                      child: CustomTextField(
                        controller: _emailController,
                        hintText: t.translate('referenceEmailHint'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => null,
                      ),
                    ),
                    if (_emailError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          _emailError!,
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
    );
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFullNameChanged);
    _phoneController.removeListener(_onPhoneChanged);
    _emailController.removeListener(_onEmailChanged);
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
