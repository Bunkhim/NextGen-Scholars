/// Scholarship model for SQLite storage.
class Scholarship {
  final int? id;
  final String title;
  final String? titleKm;
  final String institution;
  final String? institutionKm;
  final String country;
  final String? countryKm;
  final String type;
  final String? typeKm;
  final String? description;
  final String? descriptionKm;
  final DateTime? deadline;
  final String? amount;
  final String? currency;
  final String? eligibility;
  final String? eligibilityKm;
  final String? benefits;
  final String? benefitsKm;
  final String? requiredDocuments;
  final String? requiredDocumentsKm;
  final String? applicationUrl;
  final String? imageUrl;
  final String? logoUrl;
  final String? level;
  final String? fieldOfStudy;
  final int numberOfPlaces;
  final DateTime? openDate;
  final bool isFeatured;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Firestore document ID — set when this row was created from a Firestore scholarship.
  final String? firestoreId;

  const Scholarship({
    this.id,
    required this.title,
    this.titleKm,
    required this.institution,
    this.institutionKm,
    required this.country,
    this.countryKm,
    required this.type,
    this.typeKm,
    this.description,
    this.descriptionKm,
    this.deadline,
    this.amount,
    this.currency,
    this.eligibility,
    this.eligibilityKm,
    this.benefits,
    this.benefitsKm,
    this.requiredDocuments,
    this.requiredDocumentsKm,
    this.applicationUrl,
    this.imageUrl,
    this.logoUrl,
    this.level,
    this.fieldOfStudy,
    this.numberOfPlaces = 0,
    this.openDate,
    this.isFeatured = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.firestoreId,
  });

  Scholarship copyWith({
    int? id,
    String? title,
    String? titleKm,
    String? institution,
    String? institutionKm,
    String? country,
    String? countryKm,
    String? type,
    String? typeKm,
    String? description,
    String? descriptionKm,
    DateTime? deadline,
    String? amount,
    String? currency,
    String? eligibility,
    String? eligibilityKm,
    String? benefits,
    String? benefitsKm,
    String? requiredDocuments,
    String? requiredDocumentsKm,
    String? applicationUrl,
    String? imageUrl,
    String? logoUrl,
    String? level,
    String? fieldOfStudy,
    int? numberOfPlaces,
    DateTime? openDate,
    bool? isFeatured,
    bool? isActive,
  }) {
    return Scholarship(
      id: id ?? this.id,
      title: title ?? this.title,
      titleKm: titleKm ?? this.titleKm,
      institution: institution ?? this.institution,
      institutionKm: institutionKm ?? this.institutionKm,
      country: country ?? this.country,
      countryKm: countryKm ?? this.countryKm,
      type: type ?? this.type,
      typeKm: typeKm ?? this.typeKm,
      description: description ?? this.description,
      descriptionKm: descriptionKm ?? this.descriptionKm,
      deadline: deadline ?? this.deadline,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      eligibility: eligibility ?? this.eligibility,
      eligibilityKm: eligibilityKm ?? this.eligibilityKm,
      benefits: benefits ?? this.benefits,
      benefitsKm: benefitsKm ?? this.benefitsKm,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      requiredDocumentsKm: requiredDocumentsKm ?? this.requiredDocumentsKm,
      applicationUrl: applicationUrl ?? this.applicationUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      level: level ?? this.level,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      numberOfPlaces: numberOfPlaces ?? this.numberOfPlaces,
      openDate: openDate ?? this.openDate,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'title_km': titleKm,
      'institution': institution,
      'institution_km': institutionKm,
      'country': country,
      'country_km': countryKm,
      'type': type,
      'type_km': typeKm,
      'description': description,
      'description_km': descriptionKm,
      'deadline': deadline?.toIso8601String(),
      'amount': amount,
      'currency': currency,
      'eligibility': eligibility,
      'eligibility_km': eligibilityKm,
      'benefits': benefits,
      'benefits_km': benefitsKm,
      'required_documents': requiredDocuments,
      'required_documents_km': requiredDocumentsKm,
      'application_url': applicationUrl,
      'image_url': imageUrl,
      'logo_url': logoUrl,
      'level': level,
      'field_of_study': fieldOfStudy,
      'number_of_places': numberOfPlaces,
      if (openDate != null) 'open_date': openDate!.toIso8601String(),
      'is_featured': isFeatured ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'updated_at': DateTime.now().toIso8601String(),
      if (firestoreId != null) 'firestore_id': firestoreId,
    };
  }

  factory Scholarship.fromMap(Map<String, dynamic> map) {
    return Scholarship(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      titleKm: map['title_km'] as String?,
      institution: (map['institution'] as String?) ?? '',
      institutionKm: map['institution_km'] as String?,
      country: (map['country'] as String?) ?? '',
      countryKm: map['country_km'] as String?,
      type: (map['type'] as String?) ?? '',
      typeKm: map['type_km'] as String?,
      description: map['description'] as String?,
      descriptionKm: map['description_km'] as String?,
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'] as String)
          : null,
      amount: map['amount'] as String?,
      currency: map['currency'] as String?,
      eligibility: map['eligibility'] as String?,
      eligibilityKm: map['eligibility_km'] as String?,
      benefits: map['benefits'] as String?,
      benefitsKm: map['benefits_km'] as String?,
      requiredDocuments: map['required_documents'] as String?,
      requiredDocumentsKm: map['required_documents_km'] as String?,
      applicationUrl: map['application_url'] as String?,
      imageUrl: map['image_url'] as String?,
      logoUrl: map['logo_url'] as String?,
      level: map['level'] as String?,
      fieldOfStudy: map['field_of_study'] as String?,
      numberOfPlaces: (map['number_of_places'] as int?) ?? 0,
      openDate: map['open_date'] != null
          ? DateTime.tryParse(map['open_date'] as String)
          : null,
      isFeatured: (map['is_featured'] as int?) == 1,
      isActive: (map['is_active'] as int?) == 1,
      firestoreId: map['firestore_id'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'] as String)
          : null,
    );
  }

  /// Check if deadline has passed.
  bool get isExpired => deadline != null && deadline!.isBefore(DateTime.now());

  /// Days remaining until deadline.
  int? get daysRemaining => deadline?.difference(DateTime.now()).inDays;

  @override
  String toString() =>
      'Scholarship(id: $id, title: $title, institution: $institution)';
}
