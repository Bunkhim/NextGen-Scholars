import 'package:flutter/material.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/services/application_data.dart';
import 'package:scholarship_app/routes/app_routes.dart';
import 'package:scholarship_app/screens/fill_information/reference_screen.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';
import 'package:scholarship_app/widgets/custom_app_bar.dart';
import 'package:scholarship_app/widgets/fill_info_nav_bar.dart';
import 'package:scholarship_app/widgets/form_field.dart';
import 'package:scholarship_app/widgets/section_header.dart';

class ScholarshipPreferenceScreen extends StatefulWidget {
  const ScholarshipPreferenceScreen({super.key});

  @override
  State<ScholarshipPreferenceScreen> createState() =>
      _ScholarshipPreferenceScreenState();
}

class _ScholarshipPreferenceScreenState
    extends State<ScholarshipPreferenceScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _hasAttemptedSubmit = false;

  final _appData = ApplicationData();

  String? _selectedDestinationCountry;
  String? _selectedPreferredUniversity;
  String? _selectedPreferredDegree;
  String? _selectedPreferredMajor;

  String? _destinationCountryError;
  String? _preferredUniversityError;
  String? _preferredDegreeError;
  String? _preferredMajorError;

  List<String> _getDestinationCountries(AppLocalizations t) => [
        t.translate('prefCountryCambodia'),
        t.translate('prefCountryUS'),
        t.translate('prefCountryUK'),
        t.translate('prefCountryCanada'),
        t.translate('prefCountryAustralia'),
        t.translate('prefCountryGermany'),
        t.translate('prefCountryFrance'),
        t.translate('prefCountryJapan'),
        t.translate('prefCountrySouthKorea'),
        t.translate('prefCountrySingapore'),
        t.translate('prefCountryMalaysia'),
        t.translate('prefCountryChina'),
        t.translate('prefCountryNetherlands'),
        t.translate('prefCountrySweden'),
        t.translate('prefCountryNewZealand'),
        t.translate('prefCountryOther'),
      ];

  List<String> _getPreferredUniversities(AppLocalizations t) => [
        // Cambodia
        t.translate('prefUniRUPP'),
        t.translate('prefUniITC'),
        t.translate('prefUniRUA'),
        t.translate('prefUniRUFA'),
        t.translate('prefUniRULE'),
        t.translate('prefUniNUM'),
        t.translate('prefUniUC'),
        t.translate('prefUniPuthisastra'),
        t.translate('prefUniPannasastra'),
        t.translate('prefUniAsiaEuro'),
        t.translate('prefUniUHS'),
        t.translate('prefUniIU'),
        t.translate('prefUniWestern'),
        t.translate('prefUniAUPP'),
        t.translate('prefUniBuildBright'),
        t.translate('prefUniCMU'),
        t.translate('prefUniCamEd'),
        t.translate('prefUniPPIU'),
        t.translate('prefUniIIC'),
        t.translate('prefUniNPIC'),
        t.translate('prefUniLimkokwing'),

        // International
        t.translate('prefUniHarvard'),
        t.translate('prefUniStanford'),
        t.translate('prefUniMIT'),
        t.translate('prefUniOxford'),
        t.translate('prefUniCambridge'),
        t.translate('prefUniImperial'),
        t.translate('prefUniETH'),
        t.translate('prefUniToronto'),
        t.translate('prefUniMelbourne'),
        t.translate('prefUniNUS'),
        t.translate('prefUniUCL'),
        t.translate('prefUniCaltech'),
        t.translate('prefUniPrinceton'),
        t.translate('prefUniYale'),

        t.translate('prefUniOther'),
      ];

  List<String> _getPreferredDegrees(AppLocalizations t) => [
        t.translate('prefDegreeBachelor'),
        t.translate('prefDegreeMaster'),
        t.translate('prefDegreePhd'),
        t.translate('prefDegreeAssociate'),
        t.translate('prefDegreeProfCert'),
        t.translate('prefDegreeDiploma'),
      ];

  List<String> _getPreferredMajors(AppLocalizations t) => [
        t.translate('prefMajorCS'),
        t.translate('prefMajorIT'),
        t.translate('prefMajorSE'),
        t.translate('prefMajorDataScience'),
        t.translate('prefMajorAI'),
        t.translate('prefMajorBusiness'),
        t.translate('prefMajorAccounting'),
        t.translate('prefMajorMarketing'),
        t.translate('prefMajorFinance'),
        t.translate('prefMajorEconomics'),
        t.translate('prefMajorMechEng'),
        t.translate('prefMajorElecEng'),
        t.translate('prefMajorCivilEng'),
        t.translate('prefMajorArchitecture'),
        t.translate('prefMajorMedicine'),
        t.translate('prefMajorNursing'),
        t.translate('prefMajorLaw'),
        t.translate('prefMajorPsychology'),
        t.translate('prefMajorEducation'),
        t.translate('prefMajorGraphicDesign'),
        t.translate('prefMajorOther'),
      ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  void _loadSavedData() {
    _selectedDestinationCountry = _appData.destinationCountry;
    _selectedPreferredUniversity = _appData.preferredUniversity;
    _selectedPreferredDegree = _appData.preferredDegree;
    _selectedPreferredMajor = _appData.preferredMajor;
  }

  void _saveData() {
    _appData.destinationCountry = _selectedDestinationCountry;
    _appData.preferredUniversity = _selectedPreferredUniversity;
    _appData.preferredDegree = _selectedPreferredDegree;
    _appData.preferredMajor = _selectedPreferredMajor;
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
      _destinationCountryError = _selectedDestinationCountry == null
          ? t.translate('prefSelectCountry')
          : null;
      _preferredUniversityError = _selectedPreferredUniversity == null
          ? t.translate('prefSelectUniversity')
          : null;
      _preferredDegreeError = _selectedPreferredDegree == null
          ? t.translate('prefSelectDegree')
          : null;
      _preferredMajorError = _selectedPreferredMajor == null
          ? t.translate('prefSelectMajor')
          : null;
    });

    if (_destinationCountryError != null ||
        _preferredUniversityError != null ||
        _preferredDegreeError != null ||
        _preferredMajorError != null) {
      return;
    }

    _saveData();
    ApplicationData().saveToPrefs();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReferenceScreen()),
    );
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
        onBackPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, AppRoutes.homeScreen, (_) => false),
      ),
      bottomNavigationBar: FillInfoNavBar(
        step: 7,
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
              SectionHeader(title: t.translate('prefSection')),
              const SizedBox(height: 20),
              FormFieldContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FieldLabel(label: t.translate('prefCountryLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedDestinationCountry,
                      hintText: t.translate('prefCountryHint'),
                      items: _getDestinationCountries(t),
                      errorText: _destinationCountryError,
                      onChanged: (value) {
                        setState(() {
                          _selectedDestinationCountry = value;
                          _destinationCountryError = null;
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
                    FieldLabel(label: t.translate('prefUniversityLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedPreferredUniversity,
                      hintText: t.translate('prefUniversityHint'),
                      items: _getPreferredUniversities(t),
                      errorText: _preferredUniversityError,
                      onChanged: (value) {
                        setState(() {
                          _selectedPreferredUniversity = value;
                          _preferredUniversityError = null;
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
                    FieldLabel(label: t.translate('prefDegreeLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedPreferredDegree,
                      hintText: t.translate('prefDegreeHint'),
                      items: _getPreferredDegrees(t),
                      errorText: _preferredDegreeError,
                      onChanged: (value) {
                        setState(() {
                          _selectedPreferredDegree = value;
                          _preferredDegreeError = null;
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
                    FieldLabel(label: t.translate('prefMajorLabel')),
                    const SizedBox(height: 8),
                    ValidatedDropdown<String>(
                      value: _selectedPreferredMajor,
                      hintText: t.translate('prefMajorHint'),
                      items: _getPreferredMajors(t),
                      errorText: _preferredMajorError,
                      onChanged: (value) {
                        setState(() {
                          _selectedPreferredMajor = value;
                          _preferredMajorError = null;
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
