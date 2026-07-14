import 'package:scholarship_app/core/api/services/applications_api_service.dart';

/// Represents a user's scholarship application.
class ScholarshipApplication {
  final String id;
  final String scholarshipId;
  final String scholarshipTitle;
  final String university;
  final String country;
  final String userId;
  final DateTime appliedAt;

  /// "submitted" → "under_review" → "interview" → "accepted" / "rejected"
  final String status;

  const ScholarshipApplication({
    required this.id,
    required this.scholarshipId,
    required this.scholarshipTitle,
    required this.university,
    required this.country,
    required this.userId,
    required this.appliedAt,
    required this.status,
  });

  /// Parse from the FastAPI backend JSON response.
  factory ScholarshipApplication.fromJson(Map<String, dynamic> json) {
    return ScholarshipApplication(
      id: (json['id'] ?? '').toString(),
      scholarshipId: (json['scholarshipId'] ?? '').toString(),
      scholarshipTitle: json['scholarshipTitle'] ?? '',
      university: json['university'] ?? '',
      country: json['country'] ?? '',
      userId: (json['userId'] ?? '').toString(),
      appliedAt: json['appliedAt'] != null
          ? DateTime.tryParse(json['appliedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: json['status'] ?? 'submitted',
    );
  }

  // ── Status helpers ──────────────────────────────────────────────────────
  bool get isSubmitted => status == 'submitted';
  bool get isUnderReview => status == 'under_review';
  bool get isInterview => status == 'interview';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  int get stepIndex {
    switch (status) {
      case 'submitted':
        return 0;
      case 'under_review':
        return 1;
      case 'interview':
        return 1; // same visual step as review
      case 'accepted':
      case 'rejected':
        return 2;
      default:
        return 0;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'submitted':
        return 'Pending';
      case 'under_review':
        return 'Under Review';
      case 'interview':
        return 'Interview Schedule';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}

/// Service for managing scholarship applications via the FastAPI backend.
class ApplicationService {
  static final ApplicationService _instance = ApplicationService._();
  factory ApplicationService() => _instance;
  ApplicationService._();

  final ApplicationsApiService _api = ApplicationsApiService();

  /// Submit a new application for a scholarship.
  /// The backend handles: application creation + notification + counter increment.
  /// Returns null on error or if not logged in.
  Future<ScholarshipApplication?> apply(dynamic scholarship) async {
    try {
      final scholarshipId = scholarship.id;
      final res = await _api.apply(scholarshipId: scholarshipId);
      if (res.containsKey('id')) {
        return ScholarshipApplication.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Check if the current user already applied to a scholarship.
  Future<bool> hasApplied(String scholarshipId) async {
    try {
      final res = await _api.checkApplication(scholarshipId: scholarshipId);
      return res['applied'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Fetch all applications for the current user from the backend.
  Future<List<ScholarshipApplication>> fetchMyApplications() async {
    try {
      final items = await _api.myApplications();
      final applications = items
          .map((json) => ScholarshipApplication.fromJson(json))
          .toList();
      applications.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return applications;
    } catch (_) {
      return [];
    }
  }

  /// Get a single application by ID from the backend.
  Future<ScholarshipApplication?> getApplication(String id) async {
    try {
      final res = await _api.getApplication(id);
      if (res.isNotEmpty && res.containsKey('id')) {
        return ScholarshipApplication.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
