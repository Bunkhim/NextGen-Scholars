import 'package:flutter/foundation.dart';
import 'package:scholarship_app/core/api/services/users_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton class to store application form data across screens.
/// Data is persisted to SharedPreferences via [saveToPrefs] / [loadFromPrefs].
///
/// Supports per-user storage keyed by UID so each account retains
/// its own Fill Info data across login/logout cycles.
/// Data is automatically cleaned up after 30 days of inactivity or on
/// account deletion.
class ApplicationData {
  static const String _genericPrefix = 'fill_';

  /// Active user's UID. When set, data is stored under a
  /// user-specific prefix so different accounts don't share Fill Info.
  static String? _activeUid;
  bool _backendRestoreAttempted = false;

  /// The effective SharedPreferences key prefix.
  /// Falls back to generic prefix when no user is set.
  String get _prefix =>
      _activeUid != null ? 'fill_${_activeUid}_' : _genericPrefix;

  // Singleton instance
  static final ApplicationData _instance = ApplicationData._internal();

  factory ApplicationData() {
    return _instance;
  }

  ApplicationData._internal();

  // ── Per-user helpers ───────────────────────────────────────────────────

  /// Set the active user UID. Call this after login/signup to scope
  /// Fill Info data to the logged-in account.
  /// Automatically loads saved data and records last activity.
  Future<void> setActiveUser(String uid) async {
    _activeUid = uid;
    await loadFromPrefs();
    await _recordLastActivity();
  }

  /// Clear the active user (e.g. on logout) WITHOUT deleting stored data.
  /// Records last activity so the 30-day inactivity timer starts.
  Future<void> clearActiveUser() async {
    await _recordLastActivity();
    _activeUid = null;
    _backendRestoreAttempted = false;
    clearAll(); // clear in-memory only; SharedPrefs data stays
  }

  /// Record current timestamp as last activity for the active user.
  Future<void> _recordLastActivity() async {
    if (_activeUid == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'fill_${_activeUid}_lastActivity',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Update last activity timestamp (call periodically while user is active).
  Future<void> recordActivity() async => _recordLastActivity();

  /// Remove ALL stored Fill Info data for a specific user (account deletion).
  /// Deletes from both local SharedPreferences and Firestore cloud backup.
  static Future<void> deleteUserData(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final userPrefix = 'fill_${uid}_';
    final keys =
        prefs.getKeys().where((k) => k.startsWith(userPrefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    // Also remove Firestore cloud backup
    await deleteUserCloudData(uid);
  }

  /// Scan all stored user data and remove entries inactive for > 30 days.
  /// Call this on app startup before any user is set.
  static Future<void> cleanupStaleData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    const thirtyDays = Duration(days: 30);

    // Collect unique user UIDs from stored keys
    final allKeys = prefs.getKeys();
    final uidSet = <String>{};
    final uidRegex = RegExp(r'^fill_(.+?)_lastActivity$');
    for (final key in allKeys) {
      final match = uidRegex.firstMatch(key);
      if (match != null) {
        uidSet.add(match.group(1)!);
      }
    }

    // Check each user's last activity
    for (final uid in uidSet) {
      final lastActivityMs = prefs.getInt('fill_${uid}_lastActivity');
      if (lastActivityMs == null) continue;
      final lastActivity = DateTime.fromMillisecondsSinceEpoch(lastActivityMs);
      if (now.difference(lastActivity) > thirtyDays) {
        // Inactive for > 30 days — purge this user's fill info
        await deleteUserData(uid);
      }
    }
  }

  // ── Completeness check ─────────────────────────────────────────────────
  /// Returns true when all required personal-info fields are filled.
  bool get isPersonalInfoComplete =>
      firstName != null &&
      firstName!.isNotEmpty &&
      lastName != null &&
      lastName!.isNotEmpty &&
      gender != null &&
      nationality != null &&
      dateOfBirth != null &&
      phoneNumber != null &&
      phoneNumber!.isNotEmpty &&
      email != null &&
      email!.isNotEmpty;

  /// Returns true when education background is filled.
  bool get isEducationComplete =>
      institution != null &&
      institution!.isNotEmpty &&
      degree != null &&
      major != null &&
      major!.isNotEmpty;

  /// Returns true when all required sections are filled.
  bool get isProfileComplete => isPersonalInfoComplete && isEducationComplete;

  /// Returns a list of section names that are still incomplete.
  List<String> get incompleteSections {
    final missing = <String>[];
    if (!isPersonalInfoComplete) missing.add('Personal Information');
    if (!isEducationComplete) missing.add('Education Background');
    return missing;
  }

  // Personal Information
  String? firstName;
  String? lastName;
  String? gender;
  String? nationality;
  DateTime? dateOfBirth;
  String? phoneNumber;
  String? email;
  String? profileImage;

  // Education Background
  String? institution;
  String? degree;
  String? major;
  int? graduationYear;
  String? gpa;

  // Languages
  String? spokenLanguage;
  String? englishLevel;
  String? ieltsCertificate;

  // Work Experience
  String? workExperience;
  String? workDuration;
  String? workType;

  // Research Experience
  String? researchExperience;
  String? authors;
  String? researchField;
  String? publisher;
  String? researchLocation;

  // Award & Achievement
  String? awardAchievement;
  String? programName;
  String? organization;
  String? awardLocation;
  String? awardDescription;

  // Scholarship Preference
  String? destinationCountry;
  String? preferredUniversity;
  String? preferredDegree;
  String? preferredMajor;

  // Reference
  String? referenceFullName;
  String? referencePosition;
  String? referenceWorkPlace;
  String? referencePhone;
  String? referenceEmail;

  // ── Backend API cloud backup ─────────────────────────────────────────────

  static final _usersApi = UsersApiService();

  bool get _hasAnyData =>
      firstName != null ||
      lastName != null ||
      email != null ||
      phoneNumber != null ||
      institution != null ||
      degree != null;

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'gender': gender,
      'nationality': nationality,
      'dateOfBirth': dateOfBirth?.millisecondsSinceEpoch,
      'phoneNumber': phoneNumber,
      'email': email,
      'photoUrl': profileImage,
      'institution': institution,
      'degree': degree,
      'major': major,
      'graduationYear': graduationYear,
      'gpa': gpa,
      'spokenLanguage': spokenLanguage,
      'englishLevel': englishLevel,
      'ieltsCertificate': ieltsCertificate,
      'workExperience': workExperience,
      'workDuration': workDuration,
      'workType': workType,
      'researchExperience': researchExperience,
      'authors': authors,
      'researchField': researchField,
      'publisher': publisher,
      'researchLocation': researchLocation,
      'awardAchievement': awardAchievement,
      'programName': programName,
      'organization': organization,
      'awardLocation': awardLocation,
      'awardDescription': awardDescription,
      'destinationCountry': destinationCountry,
      'preferredUniversity': preferredUniversity,
      'preferredDegree': preferredDegree,
      'preferredMajor': preferredMajor,
      'referenceFullName': referenceFullName,
      'referencePosition': referencePosition,
      'referenceWorkPlace': referenceWorkPlace,
      'referencePhone': referencePhone,
      'referenceEmail': referenceEmail,
    };
  }

  void fromMap(Map<String, dynamic> map) {
    firstName = map['firstName'] as String?;
    lastName = map['lastName'] as String?;
    gender = map['gender'] as String?;
    nationality = map['nationality'] as String?;
    final dobMs = map['dateOfBirth'] as int?;
    dateOfBirth =
        dobMs != null ? DateTime.fromMillisecondsSinceEpoch(dobMs) : null;
    phoneNumber = map['phoneNumber'] as String?;
    email = map['email'] as String?;
    profileImage = map['photoUrl'] as String?;
    institution = map['institution'] as String?;
    degree = map['degree'] as String?;
    major = map['major'] as String?;
    graduationYear = map['graduationYear'] as int?;
    gpa = map['gpa'] as String?;
    spokenLanguage = map['spokenLanguage'] as String?;
    englishLevel = map['englishLevel'] as String?;
    ieltsCertificate = map['ieltsCertificate'] as String?;
    workExperience = map['workExperience'] as String?;
    workDuration = map['workDuration'] as String?;
    workType = map['workType'] as String?;
    researchExperience = map['researchExperience'] as String?;
    authors = map['authors'] as String?;
    researchField = map['researchField'] as String?;
    publisher = map['publisher'] as String?;
    researchLocation = map['researchLocation'] as String?;
    awardAchievement = map['awardAchievement'] as String?;
    programName = map['programName'] as String?;
    organization = map['organization'] as String?;
    awardLocation = map['awardLocation'] as String?;
    awardDescription = map['awardDescription'] as String?;
    destinationCountry = map['destinationCountry'] as String?;
    preferredUniversity = map['preferredUniversity'] as String?;
    preferredDegree = map['preferredDegree'] as String?;
    preferredMajor = map['preferredMajor'] as String?;
    referenceFullName = map['referenceFullName'] as String?;
    referencePosition = map['referencePosition'] as String?;
    referenceWorkPlace = map['referenceWorkPlace'] as String?;
    referencePhone = map['referencePhone'] as String?;
    referenceEmail = map['referenceEmail'] as String?;
  }

  Future<void> _syncToBackend() async {
    if (_activeUid == null) return;
    try {
      final data = toMap();
      await _usersApi.updateFillInfo(data: data);
      debugPrint('☁️ Fill Info synced to backend');
    } catch (e) {
      debugPrint('⚠️ Fill Info cloud sync failed: $e');
    }
  }

  Future<bool> _restoreFromBackend() async {
    if (_activeUid == null) return false;
    if (_backendRestoreAttempted) return false;
    _backendRestoreAttempted = true;
    try {
      final res = await _usersApi.getFillInfo();
      if (res.isNotEmpty) {
        fromMap(res);
        await _saveToLocal();
        debugPrint('☁️ Fill Info restored from backend');
        return true;
      }
    } catch (e) {
      debugPrint('⚠️ Fill Info cloud restore failed: $e');
    }
    return false;
  }

  static Future<void> deleteUserCloudData(String uid) async {
    try {
      await _usersApi.deleteFillInfo();
      debugPrint('☁️ Fill Info cloud data deleted');
    } catch (e) {
      debugPrint('⚠️ Fill Info cloud delete failed: $e');
    }
  }

  /// Persist all in-memory data to SharedPreferences and sync to Firestore.
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    void setStr(String key, String? v) => v != null
        ? prefs.setString(_prefix + key, v)
        : prefs.remove(_prefix + key);
    void setInt(String key, int? v) => v != null
        ? prefs.setInt(_prefix + key, v)
        : prefs.remove(_prefix + key);

    setStr('firstName', firstName);
    setStr('lastName', lastName);
    setStr('gender', gender);
    setStr('nationality', nationality);
    if (dateOfBirth != null) {
      prefs.setInt(
          '${_prefix}dateOfBirth', dateOfBirth!.millisecondsSinceEpoch);
    } else {
      prefs.remove('${_prefix}dateOfBirth');
    }
    setStr('phoneNumber', phoneNumber);
    setStr('email', email);
    setStr('profileImagePath', profileImage);

    setStr('institution', institution);
    setStr('degree', degree);
    setStr('major', major);
    setInt('graduationYear', graduationYear);
    setStr('gpa', gpa);

    setStr('spokenLanguage', spokenLanguage);
    setStr('englishLevel', englishLevel);
    setStr('ieltsCertificate', ieltsCertificate);

    setStr('workExperience', workExperience);
    setStr('workDuration', workDuration);
    setStr('workType', workType);

    setStr('researchExperience', researchExperience);
    setStr('authors', authors);
    setStr('researchField', researchField);
    setStr('publisher', publisher);
    setStr('researchLocation', researchLocation);

    setStr('awardAchievement', awardAchievement);
    setStr('programName', programName);
    setStr('organization', organization);
    setStr('awardLocation', awardLocation);
    setStr('awardDescription', awardDescription);

    setStr('destinationCountry', destinationCountry);
    setStr('preferredUniversity', preferredUniversity);
    setStr('preferredDegree', preferredDegree);
    setStr('preferredMajor', preferredMajor);

    setStr('referenceFullName', referenceFullName);
    setStr('referencePosition', referencePosition);
    setStr('referenceWorkPlace', referenceWorkPlace);
    setStr('referencePhone', referencePhone);
    setStr('referenceEmail', referenceEmail);

    // Record activity whenever data is saved
    await _recordLastActivity();

    // Sync to Firestore cloud backup (fire-and-forget)
    _syncToBackend();
  }

  /// Save to SharedPreferences only (no Firestore sync).
  /// Used internally when restoring from Firestore to avoid a loop.
  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();

    void setStr(String key, String? v) => v != null
        ? prefs.setString(_prefix + key, v)
        : prefs.remove(_prefix + key);
    void setInt(String key, int? v) => v != null
        ? prefs.setInt(_prefix + key, v)
        : prefs.remove(_prefix + key);

    setStr('firstName', firstName);
    setStr('lastName', lastName);
    setStr('gender', gender);
    setStr('nationality', nationality);
    if (dateOfBirth != null) {
      prefs.setInt(
          '${_prefix}dateOfBirth', dateOfBirth!.millisecondsSinceEpoch);
    } else {
      prefs.remove('${_prefix}dateOfBirth');
    }
    setStr('phoneNumber', phoneNumber);
    setStr('email', email);
    setStr('profileImagePath', profileImage);

    setStr('institution', institution);
    setStr('degree', degree);
    setStr('major', major);
    setInt('graduationYear', graduationYear);
    setStr('gpa', gpa);

    setStr('spokenLanguage', spokenLanguage);
    setStr('englishLevel', englishLevel);
    setStr('ieltsCertificate', ieltsCertificate);

    setStr('workExperience', workExperience);
    setStr('workDuration', workDuration);
    setStr('workType', workType);

    setStr('researchExperience', researchExperience);
    setStr('authors', authors);
    setStr('researchField', researchField);
    setStr('publisher', publisher);
    setStr('researchLocation', researchLocation);

    setStr('awardAchievement', awardAchievement);
    setStr('programName', programName);
    setStr('organization', organization);
    setStr('awardLocation', awardLocation);
    setStr('awardDescription', awardDescription);

    setStr('destinationCountry', destinationCountry);
    setStr('preferredUniversity', preferredUniversity);
    setStr('preferredDegree', preferredDegree);
    setStr('preferredMajor', preferredMajor);

    setStr('referenceFullName', referenceFullName);
    setStr('referencePosition', referencePosition);
    setStr('referenceWorkPlace', referenceWorkPlace);
    setStr('referencePhone', referencePhone);
    setStr('referenceEmail', referenceEmail);

    await _recordLastActivity();
  }

  /// Load all persisted data from SharedPreferences into memory.
  /// If local data is empty (e.g. after reinstall), automatically
  /// restores from Firestore cloud backup.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    String? s(String key) => prefs.getString(_prefix + key);
    int? i(String key) => prefs.getInt(_prefix + key);

    firstName = s('firstName');
    lastName = s('lastName');
    gender = s('gender');
    nationality = s('nationality');
    final dobMs = i('dateOfBirth');
    dateOfBirth =
        dobMs != null ? DateTime.fromMillisecondsSinceEpoch(dobMs) : null;
    phoneNumber = s('phoneNumber');
    email = s('email');
    final imgPath = s('profileImagePath');
    profileImage = imgPath;

    institution = s('institution');
    degree = s('degree');
    major = s('major');
    graduationYear = i('graduationYear');
    gpa = s('gpa');

    spokenLanguage = s('spokenLanguage');
    englishLevel = s('englishLevel');
    ieltsCertificate = s('ieltsCertificate');

    workExperience = s('workExperience');
    workDuration = s('workDuration');
    workType = s('workType');

    researchExperience = s('researchExperience');
    authors = s('authors');
    researchField = s('researchField');
    publisher = s('publisher');
    researchLocation = s('researchLocation');

    awardAchievement = s('awardAchievement');
    programName = s('programName');
    organization = s('organization');
    awardLocation = s('awardLocation');
    awardDescription = s('awardDescription');

    destinationCountry = s('destinationCountry');
    preferredUniversity = s('preferredUniversity');
    preferredDegree = s('preferredDegree');
    preferredMajor = s('preferredMajor');

    referenceFullName = s('referenceFullName');
    referencePosition = s('referencePosition');
    referenceWorkPlace = s('referenceWorkPlace');
    referencePhone = s('referencePhone');
    referenceEmail = s('referenceEmail');

    // If local storage is empty (e.g. app was reinstalled), try Firestore
    if (!_hasAnyData && _activeUid != null) {
      await _restoreFromBackend();
    }
  }

  /// Clear all data and remove from SharedPreferences.
  Future<void> clearAllAndPrefs() async {
    clearAll();
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      prefs.remove(k);
    }
  }

  /// Clear all data (useful for resetting the form)
  void clearAll() {
    firstName = null;
    lastName = null;
    gender = null;
    nationality = null;
    dateOfBirth = null;
    phoneNumber = null;
    email = null;
    profileImage = null;
    institution = null;
    degree = null;
    major = null;
    graduationYear = null;
    gpa = null;
    spokenLanguage = null;
    englishLevel = null;
    ieltsCertificate = null;
    workExperience = null;
    workDuration = null;
    workType = null;
    researchExperience = null;
    authors = null;
    researchField = null;
    publisher = null;
    researchLocation = null;
    awardAchievement = null;
    programName = null;
    organization = null;
    awardLocation = null;
    awardDescription = null;
    destinationCountry = null;
    preferredUniversity = null;
    preferredDegree = null;
    preferredMajor = null;
    referenceFullName = null;
    referencePosition = null;
    referenceWorkPlace = null;
    referencePhone = null;
    referenceEmail = null;
  }

  /// Clear only personal information
  void clearPersonalInfo() {
    firstName = null;
    lastName = null;
    gender = null;
    nationality = null;
    dateOfBirth = null;
    phoneNumber = null;
    email = null;
    profileImage = null;
  }

  /// Clear only education background
  void clearEducation() {
    institution = null;
    degree = null;
    major = null;
    graduationYear = null;
    gpa = null;
  }

  /// Clear only languages
  void clearLanguages() {
    spokenLanguage = null;
    englishLevel = null;
    ieltsCertificate = null;
  }

  /// Clear only work experience
  void clearWorkExperience() {
    workExperience = null;
    workDuration = null;
    workType = null;
  }

  /// Clear only research experience
  void clearResearchExperience() {
    researchExperience = null;
    authors = null;
    researchField = null;
    publisher = null;
    researchLocation = null;
  }

  /// Clear only award & achievement
  void clearAwardAchievement() {
    awardAchievement = null;
    programName = null;
    organization = null;
    awardLocation = null;
    awardDescription = null;
  }

  /// Clear only scholarship preference
  void clearScholarshipPreference() {
    destinationCountry = null;
    preferredUniversity = null;
    preferredDegree = null;
    preferredMajor = null;
  }

  /// Clear only reference
  void clearReference() {
    referenceFullName = null;
    referencePosition = null;
    referenceWorkPlace = null;
    referencePhone = null;
    referenceEmail = null;
  }
}
