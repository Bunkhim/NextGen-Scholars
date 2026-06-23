import 'dart:convert';

/// Application draft model for SQLite storage.
/// Persists user application form data so it survives app restarts.
class ApplicationDraft {
  final int? id;
  final String? userId;
  final String status;
  final String? scholarshipId;

  // Personal info
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final String? nationality;
  final DateTime? dateOfBirth;
  final String? profileImagePath;

  // Education
  final String? institution;
  final String? degree;
  final String? major;
  final int? graduationYear;
  final String? gpa;

  // JSON-encoded complex fields
  final String? languagesJson;
  final String? workExperienceJson;
  final String? researchJson;
  final String? awardsJson;
  final String? referencesJson;
  final String? preferencesJson;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Status constants.
  static const String statusDraft = 'draft';
  static const String statusSubmitted = 'submitted';
  static const String statusReview = 'under_review';
  static const String statusAccepted = 'accepted';
  static const String statusRejected = 'rejected';

  const ApplicationDraft({
    this.id,
    this.userId,
    this.status = statusDraft,
    this.scholarshipId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.gender,
    this.nationality,
    this.dateOfBirth,
    this.profileImagePath,
    this.institution,
    this.degree,
    this.major,
    this.graduationYear,
    this.gpa,
    this.languagesJson,
    this.workExperienceJson,
    this.researchJson,
    this.awardsJson,
    this.referencesJson,
    this.preferencesJson,
    this.createdAt,
    this.updatedAt,
  });

  ApplicationDraft copyWith({
    int? id,
    String? userId,
    String? status,
    String? scholarshipId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? gender,
    String? nationality,
    DateTime? dateOfBirth,
    String? profileImagePath,
    String? institution,
    String? degree,
    String? major,
    int? graduationYear,
    String? gpa,
    String? languagesJson,
    String? workExperienceJson,
    String? researchJson,
    String? awardsJson,
    String? referencesJson,
    String? preferencesJson,
  }) {
    return ApplicationDraft(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      scholarshipId: scholarshipId ?? this.scholarshipId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      institution: institution ?? this.institution,
      degree: degree ?? this.degree,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      gpa: gpa ?? this.gpa,
      languagesJson: languagesJson ?? this.languagesJson,
      workExperienceJson: workExperienceJson ?? this.workExperienceJson,
      researchJson: researchJson ?? this.researchJson,
      awardsJson: awardsJson ?? this.awardsJson,
      referencesJson: referencesJson ?? this.referencesJson,
      preferencesJson: preferencesJson ?? this.preferencesJson,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'status': status,
      'scholarship_id': scholarshipId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone_number': phoneNumber,
      'gender': gender,
      'nationality': nationality,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'profile_image_path': profileImagePath,
      'institution': institution,
      'degree': degree,
      'major': major,
      'graduation_year': graduationYear,
      'gpa': gpa,
      'languages_json': languagesJson,
      'work_experience_json': workExperienceJson,
      'research_json': researchJson,
      'awards_json': awardsJson,
      'references_json': referencesJson,
      'preferences_json': preferencesJson,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory ApplicationDraft.fromMap(Map<String, dynamic> map) {
    return ApplicationDraft(
      id: map['id'] as int?,
      userId: map['user_id'] as String?,
      status: (map['status'] as String?) ?? statusDraft,
      scholarshipId: map['scholarship_id'] as String?,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      email: map['email'] as String?,
      phoneNumber: map['phone_number'] as String?,
      gender: map['gender'] as String?,
      nationality: map['nationality'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.tryParse(map['date_of_birth'] as String)
          : null,
      profileImagePath: map['profile_image_path'] as String?,
      institution: map['institution'] as String?,
      degree: map['degree'] as String?,
      major: map['major'] as String?,
      graduationYear: map['graduation_year'] as int?,
      gpa: map['gpa'] as String?,
      languagesJson: map['languages_json'] as String?,
      workExperienceJson: map['work_experience_json'] as String?,
      researchJson: map['research_json'] as String?,
      awardsJson: map['awards_json'] as String?,
      referencesJson: map['references_json'] as String?,
      preferencesJson: map['preferences_json'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  // ── JSON helpers ──────────────────────────────────────────────

  List<Map<String, dynamic>> get languages => _decodeJsonList(languagesJson);

  List<Map<String, dynamic>> get workExperience =>
      _decodeJsonList(workExperienceJson);

  List<Map<String, dynamic>> get research => _decodeJsonList(researchJson);

  List<Map<String, dynamic>> get awards => _decodeJsonList(awardsJson);

  List<Map<String, dynamic>> get references => _decodeJsonList(referencesJson);

  Map<String, dynamic> get preferences => _decodeJsonMap(preferencesJson);

  static List<Map<String, dynamic>> _decodeJsonList(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static Map<String, dynamic> _decodeJsonMap(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return {};
    try {
      final decoded = json.decode(jsonStr);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  static String encodeJsonList(List<Map<String, dynamic>> list) =>
      json.encode(list);

  static String encodeJsonMap(Map<String, dynamic> map) => json.encode(map);

  /// Completion percentage (0.0 – 1.0).
  double get completionPercentage {
    int filled = 0;
    int total = 10;

    if (firstName != null && firstName!.isNotEmpty) filled++;
    if (lastName != null && lastName!.isNotEmpty) filled++;
    if (email != null && email!.isNotEmpty) filled++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) filled++;
    if (gender != null && gender!.isNotEmpty) filled++;
    if (institution != null && institution!.isNotEmpty) filled++;
    if (degree != null && degree!.isNotEmpty) filled++;
    if (major != null && major!.isNotEmpty) filled++;
    if (gpa != null && gpa!.isNotEmpty) filled++;
    if (nationality != null && nationality!.isNotEmpty) filled++;

    return filled / total;
  }

  @override
  String toString() =>
      'ApplicationDraft(id: $id, status: $status, completion: ${(completionPercentage * 100).toStringAsFixed(0)}%)';
}
