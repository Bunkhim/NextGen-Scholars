import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Scholarship data model for the mobile app, mapped from Firestore.
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

  factory FirestoreScholarship.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FirestoreScholarship(
      id: doc.id,
      titleEn: data['titleEn'] ?? '',
      titleKm: data['titleKm'] ?? '',
      descriptionEn: data['descriptionEn'] ?? '',
      descriptionKm: data['descriptionKm'] ?? '',
      country: data['country'] ?? '',
      university: data['university'] ?? '',
      degree: data['degree'] ?? '',
      fieldOfStudy: data['fieldOfStudy'] ?? '',
      fundingType: data['fundingType'] ?? 'Full',
      numberOfPlaces: data['numberOfPlaces'] ?? 0,
      openDate: (data['openDate'] as Timestamp?)?.toDate(),
      deadline: (data['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      applicationLink: data['applicationLink'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      eligibilityEn: data['eligibilityEn'] ?? '',
      eligibilityKm: data['eligibilityKm'] ?? '',
      benefitsEn: data['benefitsEn'] ?? '',
      benefitsKm: data['benefitsKm'] ?? '',
      requiredDocumentsEn: data['requiredDocumentsEn'] ?? '',
      requiredDocumentsKm: data['requiredDocumentsKm'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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

/// Service that reads scholarship data from the shared Firestore collection.
class ScholarshipService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _scholarships => _db.collection('scholarships');

  /// Stream only active scholarships (real-time updates from admin).
  Stream<List<FirestoreScholarship>> streamActiveScholarships() {
    return _scholarships
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final docs = snap.docs
          .map((doc) => FirestoreScholarship.fromFirestore(doc))
          .toList();
      // Sort by createdAt descending — newest scholarship (added from admin) appears first
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    });
  }

  /// Stream all scholarships (real-time).
  Stream<List<FirestoreScholarship>> streamAllScholarships() {
    return _scholarships.snapshots().map((snap) {
      final docs = snap.docs
          .map((doc) => FirestoreScholarship.fromFirestore(doc))
          .toList();
      docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return docs;
    });
  }

  /// Get a single scholarship by ID.
  Future<FirestoreScholarship?> getScholarshipById(String id) async {
    final doc = await _scholarships.doc(id).get();
    if (!doc.exists) return null;
    return FirestoreScholarship.fromFirestore(doc);
  }

  /// Search scholarships by keyword.
  Future<List<FirestoreScholarship>> searchScholarships(String query) async {
    final all = await _scholarships.where('isActive', isEqualTo: true).get();
    final lowerQuery = query.toLowerCase();
    return all.docs
        .map((doc) => FirestoreScholarship.fromFirestore(doc))
        .where((s) =>
            s.titleEn.toLowerCase().contains(lowerQuery) ||
            s.titleKm.contains(query) ||
            s.university.toLowerCase().contains(lowerQuery) ||
            s.country.toLowerCase().contains(lowerQuery) ||
            s.fieldOfStudy.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
