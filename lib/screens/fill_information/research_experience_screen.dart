import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/fill_information/award_achievement_screen.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';

class ResearchExperienceScreen extends StatefulWidget {
  const ResearchExperienceScreen({super.key});

  @override
  State<ResearchExperienceScreen> createState() =>
      _ResearchExperienceScreenState();
}

class _ResearchExperienceScreenState extends State<ResearchExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _hasAttemptedSubmit = false;

  final _appData = ApplicationData();

  String? _selectedResearchExperience;
  String? _selectedAuthors;
  String? _selectedResearchField;
  String? _selectedPublisher;
  String? _selectedLocation;

  String? _researchExperienceError;
  String? _authorsError;
  String? _researchFieldError;
  String? _publisherError;
  String? _locationError;

  List<String> _getResearchExperiences(AppLocalizations t) => [
        t.translate('researchExpNone'),
        t.translate('researchExpUndergrad'),
        t.translate('researchExpGrad'),
        t.translate('researchExpThesis'),
        t.translate('researchExpConference'),
        t.translate('researchExpAssistant'),
        t.translate('researchExpIndependent'),
        t.translate('researchExpPublished'),
        t.translate('researchExpCollaborative'),
      ];

  List<String> _getAuthorsList(AppLocalizations t) => [
        t.translate('researchAuthorSingle'),
        t.translate('researchAuthorFirst'),
        t.translate('researchAuthorCo'),
        t.translate('researchAuthorCorresponding'),
        t.translate('researchAuthorTeamMember'),
      ];

  List<String> _getResearchFields(AppLocalizations t) => [
        t.translate('researchFieldCS'),
        t.translate('researchFieldEngineering'),
        t.translate('researchFieldNatural'),
        t.translate('researchFieldSocial'),
        t.translate('researchFieldMedicine'),
        t.translate('researchFieldBusiness'),
        t.translate('researchFieldEnvironmental'),
        t.translate('researchFieldMath'),
        t.translate('researchFieldPhysics'),
        t.translate('researchFieldChemistry'),
        t.translate('researchFieldBiology'),
        t.translate('researchFieldOther'),
      ];

  List<String> _getPublishers(AppLocalizations t) => [
        t.translate('researchPubNotPublished'),
        t.translate('researchPubJournal'),
        t.translate('researchPubConference'),
        t.translate('researchPubBookChapter'),
        t.translate('researchPubThesis'),
        t.translate('researchPubWorking'),
        t.translate('researchPubOnline'),
        t.translate('researchPubUniversity'),
      ];

  List<String> _getLocations(AppLocalizations t) => [
        t.translate('researchLocCambodia'),
        t.translate('researchLocVietnam'),
        t.translate('researchLocSingapore'),
        t.translate('researchLocMalaysia'),
        t.translate('researchLocUS'),
        t.translate('researchLocUK'),
        t.translate('researchLocAustralia'),
        t.translate('researchLocJapan'),
        t.translate('researchLocSouthKorea'),
        t.translate('researchLocChina'),
        t.translate('researchLocOnline'),
        t.translate('researchLocOther'),
      ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    _selectedResearchExperience = _appData.researchExperience;
    _selectedAuthors = _appData.authors;
    _selectedResearchField = _appData.researchField;
    _selectedPublisher = _appData.publisher;
    _selectedLocation = _appData.researchLocation;
  }

  void _saveData() {
    _appData.researchExperience = _selectedResearchExperience;
    _appData.authors = _selectedAuthors;
    _appData.researchField = _selectedResearchField;
    _appData.publisher = _selectedPublisher;
    _appData.researchLocation = _selectedLocation;
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

  void _submitForm() {
    setState(() {
      _hasAttemptedSubmit = true;

      final t = AppLocalizations.of(context);
      _researchExperienceError = _selectedResearchExperience == null
          ? t.translate('researchSelectExperience')
          : null;
      _authorsError = _selectedAuthors == null
          ? t.translate('researchSelectAuthors')
          : null;
      _researchFieldError = _selectedResearchField == null
          ? t.translate('researchSelectField')
          : null;
      _publisherError = _selectedPublisher == null
          ? t.translate('researchSelectPublisher')
          : null;
      _locationError = _selectedLocation == null
          ? t.translate('researchSelectLocation')
          : null;
    });

    if (_researchExperienceError != null ||
        _authorsError != null ||
        _researchFieldError != null ||
        _publisherError != null ||
        _locationError != null) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AwardAchievementScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: WallpaperService().hasAny ? Colors.transparent : colorScheme.surface,
      appBar: CustomAppBar(
        title: t.translate('researchAppBar'),
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.homeScreen, (_) => false),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 5,
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
              SectionHeader(title: t.translate('researchSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('researchExperienceLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedResearchExperience,
                      hintText: t.translate('researchExperienceHint'),
                      items: _getResearchExperiences(t),
                      errorText: _researchExperienceError,
                      onChanged: (value) {
                        setState(() {
                          _selectedResearchExperience = value;
                          _researchExperienceError = null;
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
                    FieldLabel(label: t.translate('researchAuthorsLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedAuthors,
                      hintText: t.translate('researchAuthorsHint'),
                      items: _getAuthorsList(t),
                      errorText: _authorsError,
                      onChanged: (value) {
                        setState(() {
                          _selectedAuthors = value;
                          _authorsError = null;
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
                    FieldLabel(label: t.translate('researchFieldLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedResearchField,
                      hintText: t.translate('researchFieldHint'),
                      items: _getResearchFields(t),
                      errorText: _researchFieldError,
                      onChanged: (value) {
                        setState(() {
                          _selectedResearchField = value;
                          _researchFieldError = null;
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
                    FieldLabel(label: t.translate('researchPublisherLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedPublisher,
                      hintText: t.translate('researchPublisherHint'),
                      items: _getPublishers(t),
                      errorText: _publisherError,
                      onChanged: (value) {
                        setState(() {
                          _selectedPublisher = value;
                          _publisherError = null;
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
                    FieldLabel(label: t.translate('researchLocationLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedLocation,
                      hintText: t.translate('researchLocationHint'),
                      items: _getLocations(t),
                      errorText: _locationError,
                      onChanged: (value) {
                        setState(() {
                          _selectedLocation = value;
                          _locationError = null;
                        });
                      },
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
}
