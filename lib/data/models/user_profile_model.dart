/// User profile model for SQLite storage.
class UserProfile {
  final int? id;
  final String? firebaseUid;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final String? nationality;
  final DateTime? dateOfBirth;
  final String? profileImagePath;
  final String? institution;
  final String? degree;
  final String? major;
  final int? graduationYear;
  final String? gpa;
  final String? spokenLanguage;
  final String? englishLevel;
  final String? ieltsCertificate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.id,
    this.firebaseUid,
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
    this.spokenLanguage,
    this.englishLevel,
    this.ieltsCertificate,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy with modified fields.
  UserProfile copyWith({
    int? id,
    String? firebaseUid,
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
    String? spokenLanguage,
    String? englishLevel,
    String? ieltsCertificate,
  }) {
    return UserProfile(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
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
      spokenLanguage: spokenLanguage ?? this.spokenLanguage,
      englishLevel: englishLevel ?? this.englishLevel,
      ieltsCertificate: ieltsCertificate ?? this.ieltsCertificate,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Convert to SQLite-compatible map.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'firebase_uid': firebaseUid,
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
      'spoken_language': spokenLanguage,
      'english_level': englishLevel,
      'ielts_certificate': ieltsCertificate,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Create from SQLite row.
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as int?,
      firebaseUid: map['firebase_uid'] as String?,
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
      spokenLanguage: map['spoken_language'] as String?,
      englishLevel: map['english_level'] as String?,
      ieltsCertificate: map['ielts_certificate'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  /// Display name helper.
  String get fullName {
    final parts = [firstName, lastName].where((s) => s != null && s.isNotEmpty);
    return parts.join(' ');
  }

  @override
  String toString() => 'UserProfile(id: $id, name: $fullName, email: $email)';
}
