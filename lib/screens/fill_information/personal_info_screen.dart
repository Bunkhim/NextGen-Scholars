// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/fill_information/education_background_screen.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _appData = ApplicationData();

  String? _selectedGender;
  String? _selectedNationality;
  DateTime? _selectedDate;
  File? _profileImage;

  String? _genderError;
  String? _nationalityError;
  String? _dateError;
  String? _imageError;
  String? _firstNameError;
  String? _lastNameError;
  String? _phoneError;
  String? _emailError;

  bool _hasAttemptedSubmit = false;

  // ── Locale-independent keys for Gender & Nationality ───────────────────
  static const _genderKeys = ['male', 'female', 'other'];
  static const _genderTranslationKeys = [
    'personalInfoGenderMale',
    'personalInfoGenderFemale',
    'personalInfoGenderOther',
  ];

  static const _nationalityKeys = [
    'cambodian',
    'vietnamese',
    'laotian',
    'chinese',
    'american',
    'japanese',
    'korean',
    'other',
  ];
  static const _nationalityTranslationKeys = [
    'personalInfoNationalityCambodian',
    'personalInfoNationalityVietnamese',
    'personalInfoNationalityLaotian',
    'personalInfoNationalityChinese',
    'personalInfoNationalityAmerican',
    'personalInfoNationalityJapanese',
    'personalInfoNationalityKorean',
    'personalInfoNationalityOther',
  ];

  /// Get translated gender labels (same order as _genderKeys).
  List<String> _getGenders(AppLocalizations t) =>
      _genderTranslationKeys.map((k) => t.translate(k)).toList();

  /// Get translated nationality labels (same order as _nationalityKeys).
  List<String> _getNationalities(AppLocalizations t) =>
      _nationalityTranslationKeys.map((k) => t.translate(k)).toList();

  /// Convert a stored key to a translated display string.
  String? _genderKeyToDisplay(String? key, AppLocalizations t) {
    if (key == null) return null;
    final idx = _genderKeys.indexOf(key);
    if (idx >= 0) return t.translate(_genderTranslationKeys[idx]);
    // Fallback: the stored value might already be a translated string
    // from before this fix — try to match it
    final genders = _getGenders(t);
    if (genders.contains(key)) return key;
    return null;
  }

  String? _nationalityKeyToDisplay(String? key, AppLocalizations t) {
    if (key == null) return null;
    final idx = _nationalityKeys.indexOf(key);
    if (idx >= 0) return t.translate(_nationalityTranslationKeys[idx]);
    final nationalities = _getNationalities(t);
    if (nationalities.contains(key)) return key;
    return null;
  }

  /// Convert a translated display string back to a stored key.
  String? _genderDisplayToKey(String? display, AppLocalizations t) {
    if (display == null) return null;
    final genders = _getGenders(t);
    final idx = genders.indexOf(display);
    if (idx >= 0) return _genderKeys[idx];
    // Already a key?
    if (_genderKeys.contains(display)) return display;
    return display; // fallback
  }

  String? _nationalityDisplayToKey(String? display, AppLocalizations t) {
    if (display == null) return null;
    final nationalities = _getNationalities(t);
    final idx = nationalities.indexOf(display);
    if (idx >= 0) return _nationalityKeys[idx];
    if (_nationalityKeys.contains(display)) return display;
    return display; // fallback
  }

  @override
  void initState() {
    super.initState();

    _loadSavedData();

    _firstNameController.addListener(_onTextFieldChanged);
    _lastNameController.addListener(_onTextFieldChanged);
    _phoneController.addListener(_onTextFieldChanged);
    _emailController.addListener(_onTextFieldChanged);
  }

  void _loadSavedData() {
    _firstNameController.text = _appData.firstName ?? '';
    _lastNameController.text = _appData.lastName ?? '';
    _phoneController.text = _appData.phoneNumber ?? '';
    _emailController.text = _appData.email ?? '';
    // Stored values may be keys ('male') or old translated strings ('Male').
    // Normalize to keys.
    _selectedGender = _normalizeGenderToKey(_appData.gender);
    _selectedNationality = _normalizeNationalityToKey(_appData.nationality);
    _selectedDate = _appData.dateOfBirth;
    _profileImage = _appData.profileImage;
  }

  /// Normalize a possibly-translated gender string to its key.
  String? _normalizeGenderToKey(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (_genderKeys.contains(raw)) return raw;
    // Try matching against known English values
    const enGenders = ['Male', 'Female', 'Other'];
    final idx =
        enGenders.indexWhere((g) => g.toLowerCase() == raw.toLowerCase());
    if (idx >= 0) return _genderKeys[idx];
    // Try matching against known Khmer values
    const kmGenders = ['ប្រុស', 'ស្រី', 'ផ្សេងទៀត'];
    final kidx = kmGenders.indexOf(raw);
    if (kidx >= 0) return _genderKeys[kidx];
    return raw;
  }

  /// Normalize a possibly-translated nationality string to its key.
  String? _normalizeNationalityToKey(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    if (_nationalityKeys.contains(raw)) return raw;
    const enNats = [
      'Cambodian',
      'Vietnamese',
      'Laotian',
      'Chinese',
      'American',
      'Japanese',
      'Korean',
      'Other',
    ];
    final idx = enNats.indexWhere((n) => n.toLowerCase() == raw.toLowerCase());
    if (idx >= 0) return _nationalityKeys[idx];
    const kmNats = [
      'ខ្មែរ',
      'វៀតណាម',
      'ឡាវ',
      'ចិន',
      'អាមេរិកាំង',
      'ជប៉ុន',
      'កូរ៉េ',
      'ផ្សេងទៀត',
    ];
    final kidx = kmNats.indexOf(raw);
    if (kidx >= 0) return _nationalityKeys[kidx];
    return raw;
  }

  void _saveData() {
    _appData.firstName = _firstNameController.text;
    _appData.lastName = _lastNameController.text;
    _appData.phoneNumber = _phoneController.text;
    _appData.email = _emailController.text;
    _appData.gender = _selectedGender;
    _appData.nationality = _selectedNationality;
    _appData.dateOfBirth = _selectedDate;
    _appData.profileImage = _profileImage;
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

  void _onTextFieldChanged() {
    if (_hasAttemptedSubmit) {
      setState(() {
        _firstNameError = _validateName(_firstNameController.text);
        _lastNameError = _validateName(_lastNameController.text);
        _phoneError = _validatePhone(_phoneController.text);
        _emailError = _validateEmail(_emailController.text);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('en', 'GB'),
      helpText: AppLocalizations.of(context).translate('personalInfoDobHint'),
      builder: (context, child) {
        final cs = Theme.of(context).colorScheme;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: cs.copyWith(primary: cs.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateError = null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
          _imageError = null;
        });
      }
    } catch (e) {
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${t.translate('personalInfoErrorPickingImage')}: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        final t = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(t.translate('personalInfoImageSourceTitle'),
              style: TextStyle(color: colorScheme.onSurface)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt,
                    color: WallpaperService().themedPrimary(colorScheme)),
                title: Text(t.translate('personalInfoCameraOption'),
                    style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: WallpaperService().themedPrimary(colorScheme),
                ),
                title: Text(t.translate('personalInfoGalleryOption'),
                    style: TextStyle(color: colorScheme.onSurface)),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String? _validateName(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('personalInfoFieldRequired');
    }
    if (value.length < 2) {
      return t.translate('personalInfoNameMinLength');
    }
    // Allow Unicode letters (Khmer, Latin, etc.) and spaces
    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(value)) {
      return t.translate('personalInfoNameAllowUnicode');
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('personalInfoEmailRequired');
    }
    // Proper email regex that accepts .edu, .org, .co.uk, etc.
    final emailRegex = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return t.translate('personalInfoEmailInvalid');
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final t = AppLocalizations.of(context);
    if (value == null || value.isEmpty) {
      return t.translate('personalInfoPhoneRequired');
    }
    final digitsOnly = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^\d+$').hasMatch(digitsOnly)) {
      return t.translate('personalInfoPhoneDigitsOnly');
    }
    if (digitsOnly.length < 8) {
      return t.translate('personalInfoPhoneMinDigits');
    }
    if (digitsOnly.length > 15) {
      return t.translate('personalInfoPhoneMaxDigits');
    }
    return null;
  }

  void _submitForm() {
    setState(() {
      _hasAttemptedSubmit = true;

      _firstNameError = _validateName(_firstNameController.text);
      _lastNameError = _validateName(_lastNameController.text);
      _phoneError = _validatePhone(_phoneController.text);
      _emailError = _validateEmail(_emailController.text);

      if (_selectedGender == null) {
        _genderError =
            AppLocalizations.of(context).translate('personalInfoSelectGender');
      }
      if (_selectedNationality == null) {
        _nationalityError = AppLocalizations.of(context)
            .translate('personalInfoSelectNationality');
      }
      if (_selectedDate == null) {
        _dateError =
            AppLocalizations.of(context).translate('personalInfoSelectDob');
      }
      if (_profileImage == null) {
        _imageError =
            AppLocalizations.of(context).translate('personalInfoSelectImage');
      }
    });

    bool isFormValid = _firstNameError == null &&
        _lastNameError == null &&
        _phoneError == null &&
        _emailError == null &&
        _genderError == null &&
        _nationalityError == null &&
        _dateError == null &&
        _imageError == null;

    if (isFormValid) {
      _saveData();
      ApplicationData().saveToPrefs();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EducationBackgroundScreen(),
        ),
      );
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
        title: t.translate('personalInfoAppBar'),
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.homeScreen, (_) => false),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 1,
        totalSteps: 8,
        onBack: () => Navigator.maybePop(context),
        onNext: _submitForm,
        onSave: _onSave,
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
              SectionHeader(title: t.translate('personalInfoSection')),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldLabel(label: t.translate('personalInfoFirstName')),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: _firstNameError != null
                                ? Border.all(color: colorScheme.error, width: 1)
                                : null,
                          ),
                          child: CustomTextField(
                            controller: _firstNameController,
                            hintText: t.translate('personalInfoFirstNameHint'),
                            validator: (value) {
                              return null;
                            },
                          ),
                        ),
                        if (_firstNameError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Text(
                              _firstNameError!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FieldLabel(label: t.translate('personalInfoLastName')),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: _lastNameError != null
                                ? Border.all(color: colorScheme.error, width: 1)
                                : null,
                          ),
                          child: CustomTextField(
                            controller: _lastNameController,
                            hintText: t.translate('personalInfoLastNameHint'),
                            validator: (value) {
                              return null;
                            },
                          ),
                        ),
                        if (_lastNameError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 12),
                            child: Text(
                              _lastNameError!,
                              style: TextStyle(
                                color: colorScheme.error,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('personalInfoGender')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _genderKeyToDisplay(_selectedGender, t),
                      hintText: t.translate('personalInfoSelectHint'),
                      items: _getGenders(t),
                      errorText: _genderError,
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = _genderDisplayToKey(value, t);
                          _genderError = null;
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
                    FieldLabel(label: t.translate('personalInfoNationality')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _nationalityKeyToDisplay(_selectedNationality, t),
                      hintText: t.translate('personalInfoSelectHint'),
                      items: _getNationalities(t),
                      errorText: _nationalityError,
                      onChanged: (value) {
                        setState(() {
                          _selectedNationality =
                              _nationalityDisplayToKey(value, t);
                          _nationalityError = null;
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
                    FieldLabel(label: t.translate('personalInfoDob')),
                    const SizedBox(height: 8),
                    ValidatedDatePickerField(
                      selectedDate: _selectedDate,
                      onTap: () => _selectDate(context),
                      errorText: _dateError,
                    ),
                  ],
                ),
              ),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('personalInfoPhone')),
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
                        hintText: t.translate('personalInfoPhoneHint'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          return null;
                        },
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
                    FieldLabel(label: t.translate('personalInfoEmail')),
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
                        hintText: t.translate('personalInfoEmailHint'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          return null;
                        },
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FieldLabel(label: t.translate('personalInfoChooseImage')),
                  const SizedBox(height: 8),
                  ValidatedImagePickerButton(
                    onTap: _showImageSourceDialog,
                    text: _profileImage == null
                        ? t.translate('personalInfoGalleryButton')
                        : t.translate('personalInfoImageSelected'),
                    hasImage: _profileImage != null,
                    errorText: _imageError,
                  ),
                  if (_profileImage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _profileImage!,
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _profileImage = null;
                                  if (_hasAttemptedSubmit) {
                                    _imageError = AppLocalizations.of(context)
                                        .translate('personalInfoSelectImage');
                                  }
                                });
                              },
                              icon: CircleAvatar(
                                backgroundColor: colorScheme.error,
                                radius: 12,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: colorScheme.onError,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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
    _firstNameController.removeListener(_onTextFieldChanged);
    _lastNameController.removeListener(_onTextFieldChanged);
    _phoneController.removeListener(_onTextFieldChanged);
    _emailController.removeListener(_onTextFieldChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
