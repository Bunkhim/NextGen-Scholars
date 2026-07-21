import 'package:intl/intl.dart';
import 'package:scholarship_app/core/api/services/scholarships_api_service.dart';

/// Scholarship data model for the mobile app.
/// Originally mapped from Firestore; now mapped from FastAPI backend JSON.
class FirestoreScholarship {
  final String id;
  final String titleEn;
  final String titleKm;
  final String descriptionEn;
  final String descriptionKm;
  final String country;
  final String university;
  final String degree; // Bachelor, Master, PhD, Postdoc, Other
  final String fieldOfStudy;
  final String fundingType; // Full, Partial, Tuition-only, Stipend
  final int numberOfPlaces;
  final DateTime? openDate;
  final DateTime deadline;
  final String applicationLink;
  final String imageUrl;
  final String logoUrl;
  final String eligibilityEn;
  final String eligibilityKm;
  final String benefitsEn;
  final String benefitsKm;
  final String requiredDocumentsEn;
  final String requiredDocumentsKm;
  final bool isActive;
  final DateTime createdAt;
  bool isFavorite;

  FirestoreScholarship({
    required this.id,
    required this.titleEn,
    required this.titleKm,
    required this.descriptionEn,
    required this.descriptionKm,
    required this.country,
    required this.university,
    required this.degree,
    required this.fieldOfStudy,
    required this.fundingType,
    this.numberOfPlaces = 0,
    this.openDate,
    required this.deadline,
    required this.applicationLink,
    this.imageUrl = '',
    this.logoUrl = '',
    this.eligibilityEn = '',
    this.eligibilityKm = '',
    this.benefitsEn = '',
    this.benefitsKm = '',
    this.requiredDocumentsEn = '',
    this.requiredDocumentsKm = '',
    this.isActive = true,
    required this.createdAt,
    this.isFavorite = false,
  });

  /// Parse a scholarship from the FastAPI backend JSON response.
  /// Backend returns camelCase keys matching these field names.
  factory FirestoreScholarship.fromJson(Map<String, dynamic> json) {
    return FirestoreScholarship(
      id: (json['id'] ?? '').toString(),
      titleEn: json['titleEn'] ?? '',
      titleKm: json['titleKm'] ?? '',
      descriptionEn: json['descriptionEn'] ?? '',
      descriptionKm: json['descriptionKm'] ?? '',
      country: json['country'] ?? '',
      university: json['university'] ?? '',
      degree: json['degree'] ?? '',
      fieldOfStudy: json['fieldOfStudy'] ?? '',
      fundingType: json['fundingType'] ?? 'Full',
      numberOfPlaces: json['numberOfPlaces'] ?? 0,
      openDate: json['openDate'] != null
          ? DateTime.tryParse(json['openDate'].toString())
          : null,
      deadline: json['deadline'] != null
          ? DateTime.tryParse(json['deadline'].toString()) ?? DateTime.now()
          : DateTime.now(),
      applicationLink: json['applicationLink'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
      eligibilityEn: json['eligibilityEn'] ?? '',
      eligibilityKm: json['eligibilityKm'] ?? '',
      benefitsEn: json['benefitsEn'] ?? '',
      benefitsKm: json['benefitsKm'] ?? '',
      requiredDocumentsEn: json['requiredDocumentsEn'] ?? '',
      requiredDocumentsKm: json['requiredDocumentsKm'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Format deadline as dd-MMM-yyyy
  String get formattedDeadline => DateFormat('dd-MMM-yyyy').format(deadline);

  /// Format open date as dd-MMM-yyyy
  String get formattedOpenDate =>
      openDate != null ? DateFormat('dd-MMM-yyyy').format(openDate!) : '';

  /// Days remaining until deadline
  int get daysRemaining => deadline.difference(DateTime.now()).inDays;

  /// Map degree to localization key
  String get degreeLabelKey {
    switch (degree) {
      case 'Bachelor':
        return 'educationLevelBachelor';
      case 'Master':
        return 'educationLevelMaster';
      case 'PhD':
        return 'educationLevelPhD';
      case 'Postdoc':
        return 'educationLevelPostdoc';
      default:
        return degree;
    }
  }
}

/// Service that reads scholarship data from the FastAPI backend.
class ScholarshipService {
  final ScholarshipsApiService _api = ScholarshipsApiService();

  /// Fetch active scholarships from backend.
  Future<List<FirestoreScholarship>> fetchActiveScholarships({
    String? search,
    String? country,
    String? degree,
    String? funding,
    int skip = 0,
    int limit = 100,
  }) async {
    final res = await _api.listScholarships(
      active: true,
      search: search,
      country: country,
      degree: degree,
      funding: funding,
      skip: skip,
      limit: limit,
    );
    final items = res['items'] as List<dynamic>? ?? [];
    final scholarships =
        items.map((json) => FirestoreScholarship.fromJson(json)).toList();
    scholarships.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return scholarships;
  }

  /// Fetch all scholarships (including inactive) from backend.
  Future<List<FirestoreScholarship>> fetchAllScholarships({
    int skip = 0,
    int limit = 100,
  }) async {
    final res = await _api.listScholarships(
      active: false,
      skip: skip,
      limit: limit,
    );
    final items = res['items'] as List<dynamic>? ?? [];
    final scholarships =
        items.map((json) => FirestoreScholarship.fromJson(json)).toList();
    scholarships.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return scholarships;
  }

  /// Get a single scholarship by ID.
  Future<FirestoreScholarship?> getScholarshipById(String id) async {
    final res = await _api.getScholarship(id);
    if (res.isEmpty) return null;
    return FirestoreScholarship.fromJson(res);
  }

  /// Search scholarships by keyword via backend.
  Future<List<FirestoreScholarship>> searchScholarships(String query) async {
    final res = await _api.listScholarships(
      active: true,
      search: query,
      limit: 100,
    );
    final items = res['items'] as List<dynamic>? ?? [];
    return items.map((json) => FirestoreScholarship.fromJson(json)).toList();
  }

  /// Get available filter options from backend.
  Future<Map<String, dynamic>> getFilterOptions() async {
    return await _api.getFilters();
  }

  /// Match scholarships against user preferences via backend.
  Future<List<FirestoreScholarship>> matchScholarships({
    String destinationCountry = '',
    String preferredDegree = '',
    String preferredMajor = '',
    String preferredUniversity = '',
  }) async {
    final res = await _api.match(
      destinationCountry: destinationCountry,
      preferredDegree: preferredDegree,
      preferredMajor: preferredMajor,
      preferredUniversity: preferredUniversity,
    );
    final items = res['items'] as List<dynamic>? ?? [];
    return items.map((json) => FirestoreScholarship.fromJson(json)).toList();
  }
}
