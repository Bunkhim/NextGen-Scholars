// ignore_for_file: use_build_context_synchronously, file_names, avoid_print, deprecated_member_use

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:scholarship_app/constants/app_colors.dart';
import 'package:scholarship_app/translations/app_localizations.dart';
import 'package:scholarship_app/screens/main_app/profile_screen.dart';
import 'package:scholarship_app/services/user_firestore_service.dart';
import 'package:scholarship_app/services/wallpaper_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController countryController = TextEditingController();

  // Error state
  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _dobError;
  String? _countryError;
  bool _isSaving = false;
  bool _isLoading = true;

  // Photo
  File? _pickedPhoto;
  String? _existingPhotoUrl;
  final _picker = ImagePicker();

  final List<String> _countryNameKeys = const [
    'countryNameCambodia',
    'countryNameUSA',
    'countryNameUK',
    'countryNameIndia',
    'countryNameChina',
    'countryNameJapan',
    'countryNameSouthKorea',
    'countryNameVietnam',
    'countryNameThailand',
    'countryNameSingapore',
    'countryNameMalaysia',
    'countryNameIndonesia',
    'countryNamePhilippines',
    'countryNameAustralia',
    'countryNameFrance',
    'countryNameGermany',
  ];

  // Track original values for unsaved-changes detection
  late String _originalName;
  late String _originalEmail;
  late String _originalPhone;
  late String _originalDob;
  late String _originalCountry;
  late List<String> _originalInterests;

  List<String> _getInterestedFields(AppLocalizations t) => [
        t.translate('editProfileFieldArt'),
        t.translate('editProfileFieldMedical'),
        t.translate('editProfileFieldFullScholarship'),
        t.translate('editProfileFieldUSA'),
      ];
  late List<bool> selectedFields;
  List<String> _savedInterests = [];

  @override
  void initState() {
    super.initState();
    selectedFields = List<bool>.filled(4, false);
    _originalName = '';
    _originalEmail = '';
    _originalPhone = '';
    _originalDob = '';
    _originalCountry = '';
    _originalInterests = [];
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await UserFirestoreService().getProfile();
      final user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (profile != null) {
        nameController.text = profile['name'] ?? user?.displayName ?? '';
        emailController.text = profile['email'] ?? user?.email ?? '';
        phoneController.text = profile['phone'] ?? '';
        dobController.text = profile['dob'] ?? '';
        countryController.text = profile['country'] ?? '';
        _existingPhotoUrl = profile['photoUrl'] ?? user?.photoURL;
        _savedInterests = List<String>.from(profile['interestedFields'] ?? []);

        // Match saved interests to toggle chips
        final t = AppLocalizations.of(context);
        final fields = _getInterestedFields(t);
        for (int i = 0; i < fields.length; i++) {
          selectedFields[i] = _savedInterests.contains(fields[i]);
        }
      } else if (user != null) {
        nameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
        _existingPhotoUrl = user.photoURL;
      }

      _originalName = nameController.text;
      _originalEmail = emailController.text;
      _originalPhone = phoneController.text;
      _originalDob = dobController.text;
      _originalCountry = countryController.text;
      _originalInterests = List<String>.from(_savedInterests);
    } catch (e) {
      // Fallback to Firebase Auth user data
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && mounted) {
        nameController.text = user.displayName ?? '';
        emailController.text = user.email ?? '';
        _existingPhotoUrl = user.photoURL;
        _originalName = nameController.text;
        _originalEmail = emailController.text;
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  bool get _hasUnsavedChanges {
    return nameController.text != _originalName ||
        emailController.text != _originalEmail ||
        phoneController.text != _originalPhone ||
        dobController.text != _originalDob ||
        countryController.text != _originalCountry ||
        _pickedPhoto != null ||
        _interestsChanged;
  }

  bool get _interestsChanged {
    final t = AppLocalizations.of(context);
    final fields = _getInterestedFields(t);
    final current = <String>[];
    for (int i = 0; i < fields.length; i++) {
      if (selectedFields[i]) current.add(fields[i]);
    }
    if (current.length != _originalInterests.length) return true;
    for (final item in current) {
      if (!_originalInterests.contains(item)) return true;
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final t = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.translate('editProfileUnsavedTitle')),
        content: Text(t.translate('editProfileUnsavedMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t.translate('editProfileDiscard')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t.translate('editProfileKeepEditing')),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    countryController.dispose();
    super.dispose();
  }

  void _showTopMessage(String message, Color backgroundColor) {
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      backgroundColor == Colors.red.shade600
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  bool _isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return RegExp(r'^\d{7,15}$').hasMatch(cleaned);
  }

  bool _isValidName(String name) {
    final trimmed = name.trim();
    if (trimmed.length < 2 || trimmed.length > 50) return false;
    return RegExp(r"^[\p{L}\s'\-.]+$", unicode: true).hasMatch(trimmed);
  }

  bool _isValidDOB(String dob) {
    if (dob.isEmpty) return false;
    try {
      // Try to parse DD/MM/YYYY format
      final parts = dob.split('/');
      if (parts.length != 3) return false;
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day == null || month == null || year == null) return false;
      if (month < 1 || month > 12) return false;
      if (year < 1900 || year > DateTime.now().year - 13) return false;

      // Validate the actual calendar date (catches Feb 30, Apr 31, etc.)
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return false;
      }
      // Block future dates
      if (date.isAfter(DateTime.now())) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isValidCountry(String country) {
    final value = country.trim();
    if (value.length < 2 || value.length > 56) return false;
    return RegExp(r"^[\p{L}\s'\-\.]+$", unicode: true).hasMatch(value);
  }

  void _validateNameLive(String value) {
    final t = AppLocalizations.of(context);
    setState(() {
      if (value.trim().isEmpty) {
        _nameError = t.translate('editProfileNameRequired');
      } else if (!_isValidName(value)) {
        _nameError = t.translate('editProfileNameLength');
      } else {
        _nameError = null;
      }
    });
  }

  void _validateEmailLive(String value) {
    final t = AppLocalizations.of(context);
    setState(() {
      if (value.trim().isEmpty) {
        _emailError = t.translate('editProfileEmailRequired');
      } else if (!_isValidEmail(value.trim())) {
        _emailError = t.translate('editProfileEmailInvalid');
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePhoneLive(String value) {
    final t = AppLocalizations.of(context);
    setState(() {
      if (value.trim().isEmpty) {
        _phoneError = t.translate('editProfilePhoneRequired');
      } else if (!_isValidPhone(value.trim())) {
        _phoneError = t.translate('editProfilePhoneInvalid');
      } else {
        _phoneError = null;
      }
    });
  }

  void _validateDobLive(String value) {
    final t = AppLocalizations.of(context);
    setState(() {
      if (value.trim().isEmpty) {
        _dobError = t.translate('editProfileDobRequired');
      } else if (!_isValidDOB(value.trim())) {
        _dobError = t.translate('editProfileDobInvalid');
      } else {
        _dobError = null;
      }
    });
  }

  void _validateCountryLive(String value) {
    final t = AppLocalizations.of(context);
    setState(() {
      if (value.trim().isEmpty) {
        _countryError = t.translate('editProfileCountryRequired');
      } else if (!_isValidCountry(value)) {
        _countryError = t.translate('editProfileCountryInvalid');
      } else {
        _countryError = null;
      }
    });
  }

  void _validateForm() {
    final t = AppLocalizations.of(context);
    setState(() {
      _nameError = null;
      _emailError = null;
      _phoneError = null;
      _dobError = null;
      _countryError = null;

      final name = nameController.text.trim();
      if (name.isEmpty) {
        _nameError = t.translate('editProfileNameRequired');
      } else if (!_isValidName(name)) {
        _nameError = t.translate('editProfileNameLength');
      }

      final email = emailController.text.trim();
      if (email.isEmpty) {
        _emailError = t.translate('editProfileEmailRequired');
      } else if (!_isValidEmail(email)) {
        _emailError = t.translate('editProfileEmailInvalid');
      }

      final phone = phoneController.text.trim();
      if (phone.isEmpty) {
        _phoneError = t.translate('editProfilePhoneRequired');
      } else if (!_isValidPhone(phone)) {
        _phoneError = t.translate('editProfilePhoneInvalid');
      }

      final dob = dobController.text.trim();
      if (dob.isEmpty) {
        _dobError = t.translate('editProfileDobRequired');
      } else if (!_isValidDOB(dob)) {
        _dobError = t.translate('editProfileDobInvalid');
      }

      final country = countryController.text.trim();
      if (country.isEmpty) {
        _countryError = t.translate('editProfileCountryRequired');
      } else if (!_isValidCountry(country)) {
        _countryError = t.translate('editProfileCountryInvalid');
      }
    });
  }

  bool _hasErrors() {
    return _nameError != null ||
        _emailError != null ||
        _phoneError != null ||
        _dobError != null ||
        _countryError != null;
  }

  void _handleSave() async {
    _validateForm();

    if (_hasErrors()) {
      final t = AppLocalizations.of(context);
      _showTopMessage(
        t.translate('editProfileFixErrors'),
        Colors.red.shade600,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Save photo locally if picked
      String? photoPath = _existingPhotoUrl;
      if (_pickedPhoto != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final ext = p.extension(_pickedPhoto!.path);
        final dest = File('${appDir.path}/profile_photo$ext');
        await _pickedPhoto!.copy(dest.path);
        photoPath = dest.path;
        // Evict cached image so Flutter re-reads the updated file
        await FileImage(dest).evict();
      }

      // ── Notify screens IMMEDIATELY (before Firestore) ──────────────
      ProfileScreen.activePhotoPath = photoPath;
      ProfileScreen.photoRefreshNotifier.value++;

      // Collect selected interests
      final t = AppLocalizations.of(context);
      final fields = _getInterestedFields(t);
      final interests = <String>[];
      for (int i = 0; i < fields.length; i++) {
        if (selectedFields[i]) interests.add(fields[i]);
      }

      // Save to Firestore
      await UserFirestoreService().updateProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        dob: dobController.text.trim(),
        country: countryController.text.trim(),
        photoUrl: photoPath,
        interestedFields: interests,
      );

      // Also update Firebase Auth display name if changed
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newName = nameController.text.trim();
        if (user.displayName != newName) {
          await user.updateDisplayName(newName);
        }
      }

      if (!mounted) return;

      final colorScheme = Theme.of(context).colorScheme;

      _showTopMessage(
        t.translate('editProfileSaveSuccess'),
        colorScheme.primary,
      );

      // Notify stats reload (name, counts, etc.)
      ProfileScreen.refreshNotifier.value++;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);

      _showTopMessage(
        'Error: ${e.toString()}',
        Colors.red.shade600,
      );
    }
  }

  Future<void> _pickPhoto() async {
    final t = AppLocalizations.of(context);
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.translate('editProfileChangePhoto'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.camera_alt_rounded,
                        color: cs.primary, size: 22),
                  ),
                  title: Text(t.translate('editProfileCamera')),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.photo_library_rounded,
                        color: cs.primary, size: 22),
                  ),
                  title: Text(t.translate('editProfileGallery')),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        setState(() => _pickedPhoto = File(picked.path));
      }
    } catch (e) {
      if (!mounted) return;
      _showTopMessage(
        'Failed to pick image: $e',
        Colors.red.shade600,
      );
    }
  }

  Future<void> _showCountryPicker() async {
    final t = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  t.translate('forgotPasswordSelectCountry'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Divider(height: 1, color: cs.outlineVariant.withOpacity(0.5)),
              Expanded(
                child: ListView.builder(
                  itemCount: _countryNameKeys.length,
                  itemBuilder: (_, i) {
                    final name = t.translate(_countryNameKeys[i]);
                    return ListTile(
                      title: Text(name),
                      onTap: () => Navigator.of(ctx).pop(name),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || selected == null) return;
    countryController.text = selected;
    _validateCountryLive(selected);
  }

  /// Whether there's a photo to display (local file or network URL).
  bool get _hasPhotoToShow {
    if (_existingPhotoUrl == null || _existingPhotoUrl!.isEmpty) return false;
    if (_existingPhotoUrl!.startsWith('http')) return true;
    return File(_existingPhotoUrl!).existsSync();
  }

  /// Photo image provider for display.
  ImageProvider? get _photoProvider {
    if (_existingPhotoUrl == null || _existingPhotoUrl!.isEmpty) return null;
    if (_existingPhotoUrl!.startsWith('http')) {
      return NetworkImage(_existingPhotoUrl!);
    }
    final f = File(_existingPhotoUrl!);
    if (f.existsSync()) return FileImage(f);
    return null;
  }

  /// Initials from name for fallback avatar.
  String get _initials {
    final name = nameController.text.trim();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: WallpaperService().hasAny
            ? Colors.transparent
            : colorScheme.surfaceContainerHighest,
        body: Column(
          children: [
            _buildHeroHeader(context, t, colorScheme, isDark),
            _isLoading
                ? Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: colorScheme.primary),
                    ),
                  )
                : Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -20),
                      child: Builder(builder: (context) {
                        final ws = WallpaperService();
                        final themed = ws.hasTheme;
                        return Container(
                          decoration: themed
                              ? ws.glassSection(radius: 28)
                              : BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(28),
                                  ),
                                ),
                          clipBehavior: Clip.antiAlias,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              16,
                              32,
                              16,
                              MediaQuery.of(context).padding.bottom + 24,
                            ),
                            child: Column(
                              children: [
                                _buildSectionCard(
                                  context,
                                  colorScheme,
                                  icon: Icons.person_rounded,
                                  title: 'Personal Information',
                                  children: [
                                    _buildFormField(
                                      context,
                                      t.translate('editProfileFullNameLabel'),
                                      nameController,
                                      Icons.person_outline_rounded,
                                      t.translate('editProfileFullNameHint'),
                                      errorText: _nameError,
                                      maxLength: 50,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onChanged: _validateNameLive,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildFormField(
                                      context,
                                      t.translate('editProfileDobLabel'),
                                      dobController,
                                      Icons.cake_outlined,
                                      t.translate('editProfileDobHint'),
                                      errorText: _dobError,
                                      helperText: 'DD/MM/YYYY',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [_DobInputFormatter()],
                                      onChanged: _validateDobLive,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildFormField(
                                      context,
                                      t.translate('editProfileCountryLabel'),
                                      countryController,
                                      Icons.flag_outlined,
                                      t.translate('editProfileCountryHint'),
                                      errorText: _countryError,
                                      maxLength: 56,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      onChanged: _validateCountryLive,
                                      suffixIcon: IconButton(
                                        tooltip: t.translate(
                                            'forgotPasswordSelectCountry'),
                                        onPressed: _showCountryPicker,
                                        icon: Icon(
                                          Icons.arrow_drop_down_rounded,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSectionCard(
                                  context,
                                  colorScheme,
                                  icon: Icons.contact_mail_rounded,
                                  title: 'Contact Information',
                                  children: [
                                    _buildFormField(
                                      context,
                                      t.translate('editProfileEmailLabel'),
                                      emailController,
                                      Icons.mail_outline_rounded,
                                      t.translate('editProfileEmailHint'),
                                      errorText: _emailError,
                                      keyboardType: TextInputType.emailAddress,
                                      maxLength: 100,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.deny(
                                            RegExp(r'\s')),
                                      ],
                                      onChanged: _validateEmailLive,
                                    ),
                                    const SizedBox(height: 14),
                                    _buildFormField(
                                      context,
                                      t.translate('editProfilePhoneLabel'),
                                      phoneController,
                                      Icons.phone_outlined,
                                      t.translate('editProfilePhoneHint'),
                                      errorText: _phoneError,
                                      keyboardType: TextInputType.phone,
                                      maxLength: 15,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: _validatePhoneLive,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInterestsCard(context, t, colorScheme),
                                const SizedBox(height: 28),
                                _buildSaveButton(
                                    context, t, colorScheme, isDark),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // ── Hero gradient header ───────────────────────────────────────────────────
  Widget _buildHeroHeader(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final ws = WallpaperService();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: ws.hasTheme
            ? ws.heroGradient(
                fallbackColors: [AppColors.primary, AppColors.primaryDark],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A2E)]
                    : [AppColors.primary, AppColors.primaryDark],
              ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -35,
            right: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -10,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final should = await _onWillPop();
                            if (should && mounted) Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          t.translate('editProfileTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 19,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      AnimatedScale(
                        scale: _isSaving ? 0.93 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        curve: Curves.easeOut,
                        child: GestureDetector(
                          onTap: _isSaving ? null : _handleSave,
                          child: Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.88),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.45),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 2),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.14),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isSaving) ...[
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation(
                                          ws.themedPrimary(colorScheme)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  _isSaving
                                      ? t.translate('editProfileSaving')
                                      : t.translate('editProfileSaveButton'),
                                  style: TextStyle(
                                    color: ws.themedPrimary(colorScheme),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.85), width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          gradient: (_pickedPhoto == null && !_hasPhotoToShow)
                              ? LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.25),
                                    Colors.white.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          image: _pickedPhoto != null
                              ? DecorationImage(
                                  image: FileImage(_pickedPhoto!),
                                  fit: BoxFit.cover)
                              : _hasPhotoToShow
                                  ? DecorationImage(
                                      image: _photoProvider!, fit: BoxFit.cover)
                                  : null,
                        ),
                        child: (_pickedPhoto == null && !_hasPhotoToShow)
                            ? Center(
                                child: Text(
                                  _initials,
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(Icons.camera_alt_rounded,
                              color: ws.themedPrimary(colorScheme), size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t.translate('editProfileChangePhoto'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Section card ──────────────────────────────────────────────────────────
  Widget _buildSectionCard(
    BuildContext context,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: themed
            ? ws.glassCard(radius: 20)
            : BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (themed
                              ? ws.themedPrimary(colorScheme)
                              : colorScheme.primary)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon,
                        size: 18,
                        color: themed
                            ? ws.themedPrimary(colorScheme)
                            : colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: themed ? ws.onThemeColor : colorScheme.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: themed
                    ? ws.glassBorder
                    : colorScheme.outlineVariant.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Interests card ────────────────────────────────────────────────────────
  Widget _buildInterestsCard(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
  ) {
    final fields = _getInterestedFields(t);
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: themed
            ? ws.glassCard(radius: 20)
            : BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onSurface.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: (themed
                              ? ws.themedPrimary(colorScheme)
                              : colorScheme.primary)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.interests_rounded,
                        size: 18,
                        color: themed
                            ? ws.themedPrimary(colorScheme)
                            : colorScheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.translate('editProfileInterestedFieldsTitle'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: themed
                                ? ws.onThemeColor
                                : colorScheme.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.translate('editProfileInterestedFieldsSubtitle'),
                          style: TextStyle(
                            fontSize: 12,
                            color: themed
                                ? ws.onThemeColor.withOpacity(0.7)
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: themed
                    ? ws.glassBorder
                    : colorScheme.outlineVariant.withOpacity(0.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(
                  fields.length,
                  (i) => _buildInterestChip(
                    context,
                    fields[i],
                    selectedFields[i],
                    () =>
                        setState(() => selectedFields[i] = !selectedFields[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Full-width save button ────────────────────────────────────────────────
  Widget _buildSaveButton(
    BuildContext context,
    AppLocalizations t,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    final primary = ws.themedPrimary(colorScheme);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themed
                ? [primary, primary.withOpacity(0.7)]
                : isDark
                    ? [const Color(0xFF3A3A3A), const Color(0xFF2C2C2C)]
                    : [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themed
                  ? primary.withOpacity(0.35)
                  : isDark
                      ? Colors.black.withOpacity(0.3)
                      : AppColors.primary.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: _isSaving ? null : _handleSave,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: _isSaving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.white, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          t.translate('editProfileSaveButton'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon,
    String hintText, {
    String? errorText,
    TextInputType? keyboardType,
    String? helperText,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = errorText != null && errorText.isNotEmpty;
    final errorColor = Colors.red.shade600;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    final primary = ws.themedPrimary(colorScheme);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          maxLength: maxLength,
          readOnly: readOnly,
          onTap: onTap,
          style: TextStyle(
            fontSize: 15,
            color: themed ? ws.onThemeColor : colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: hasError
                  ? errorColor
                  : themed
                      ? ws.onThemeColor.withOpacity(0.7)
                      : colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: themed
                  ? ws.onThemeColor.withOpacity(0.4)
                  : colorScheme.outline.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                icon,
                color: hasError ? errorColor : primary,
                size: 20,
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 48, minHeight: 48),
            suffixIcon: suffixIcon,
            counterText: '',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: hasError
                ? errorColor.withOpacity(0.05)
                : themed
                    ? Colors.white.withOpacity(ws.isThemeDark ? 0.10 : 0.35)
                    : colorScheme.surfaceContainerHighest.withOpacity(0.45),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? errorColor
                    : themed
                        ? ws.glassBorder
                        : colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? errorColor
                    : themed
                        ? ws.glassBorder
                        : colorScheme.outlineVariant,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? errorColor : primary,
                width: 2,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const SizedBox(width: 4),
              Icon(Icons.error_outline_rounded, size: 14, color: errorColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText,
                  style: TextStyle(
                    fontSize: 12,
                    color: errorColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ] else if (helperText != null && helperText.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helperText,
              style: TextStyle(
                fontSize: 12,
                color: themed
                    ? ws.onThemeColor.withOpacity(0.5)
                    : colorScheme.outline,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInterestChip(
      BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    final ws = WallpaperService();
    final themed = ws.hasTheme;
    final primary = ws.themedPrimary(colorScheme);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    primary,
                    primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : themed
                  ? Colors.white.withOpacity(ws.isThemeDark ? 0.12 : 0.45)
                  : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primary
                : themed
                    ? ws.glassBorder
                    : colorScheme.outlineVariant,
            width: isSelected ? 0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_rounded, color: colorScheme.onPrimary, size: 16),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Auto-inserts "/" separators as the user types a date in DD/MM/YYYY format.
class _DobInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip everything that isn't a digit
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Cap at 8 digits (DDMMYYYY)
    final capped = digits.length > 8 ? digits.substring(0, 8) : digits;

    // Build the formatted string with auto-inserted slashes
    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 2 || i == 4) buffer.write('/');
      buffer.write(capped[i]);
    }
    final formatted = buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
