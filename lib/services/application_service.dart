import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scholarship_app/services/scholarship_service.dart';

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

  factory ScholarshipApplication.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data()! as Map<String, dynamic>;
    return ScholarshipApplication(
      id: doc.id,
      scholarshipId: d['scholarshipId'] ?? '',
      scholarshipTitle: d['scholarshipTitle'] ?? '',
      university: d['university'] ?? '',
      country: d['country'] ?? '',
      userId: d['userId'] ?? '',
      appliedAt: (d['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: d['status'] ?? 'submitted',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'scholarshipId': scholarshipId,
        'scholarshipTitle': scholarshipTitle,
        'university': university,
        'country': country,
        'userId': userId,
        'appliedAt': Timestamp.fromDate(appliedAt),
        'status': status,
      };

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

/// Service for managing scholarship applications in Firestore.
class ApplicationService {
  static final ApplicationService _instance = ApplicationService._();
  factory ApplicationService() => _instance;
  ApplicationService._();

  final _db = FirebaseFirestore.instance;
  CollectionReference get _applications => _db.collection('applications');
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Submit a new application for a scholarship.
  /// Returns null if not logged in, scholarship doesn't exist, or on error.
  Future<ScholarshipApplication?> apply(
      FirestoreScholarship scholarship) async {
    final uid = _uid;
    if (uid == null) return null;

    // ── Verify scholarship exists in admin's collection & is active ──
    final scholarshipDoc =
        await _db.collection('scholarships').doc(scholarship.id).get();
    if (!scholarshipDoc.exists) return null;
    final sData = scholarshipDoc.data();
    if (sData != null && sData['isActive'] == false) return null;

    // Prevent duplicate application
    final existing = await _applications
        .where('userId', isEqualTo: uid)
        .where('scholarshipId', isEqualTo: scholarship.id)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      return ScholarshipApplication.fromFirestore(existing.docs.first);
    }

    final app = ScholarshipApplication(
      id: '',
      scholarshipId: scholarship.id,
      scholarshipTitle: scholarship.titleEn,
      university: scholarship.university,
      country: scholarship.country,
      userId: uid,
      appliedAt: DateTime.now(),
      status: 'submitted',
    );

    final docRef = await _applications.add(app.toFirestore());

    // Increment application count on user doc
    try {
      await _db.collection('users').doc(uid).update({
        'applications': FieldValue.increment(1),
      });
    } catch (_) {}

    // ── Create notification for admin ─────────────────────────────────────
    try {
      final user = _auth.currentUser;
      final userName = user?.displayName ?? user?.email ?? 'A user';
      await _db.collection('notifications').add({
        'title': 'New Application Received',
        'titleKm': 'ពាក្យសុំថ្មីត្រូវបានទទួល',
        'body':
            '$userName applied for "${scholarship.titleEn}" at ${scholarship.university}.',
        'bodyKm':
            '$userName បានដាក់ពាក្យសុំ "${scholarship.titleKm.isNotEmpty ? scholarship.titleKm : scholarship.titleEn}" នៅ ${scholarship.university}។',
        'type': 'new_application',
        'targetUserId': null, // broadcast to all admins
        'referenceId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'readBy': [],
      });
    } catch (_) {}

    return ScholarshipApplication(
      id: docRef.id,
      scholarshipId: app.scholarshipId,
      scholarshipTitle: app.scholarshipTitle,
      university: app.university,
      country: app.country,
      userId: uid,
      appliedAt: app.appliedAt,
      status: app.status,
    );
  }

  /// Check if the current user already applied to a scholarship.
  Future<bool> hasApplied(String scholarshipId) async {
    final uid = _uid;
    if (uid == null) return false;
    final snap = await _applications
        .where('userId', isEqualTo: uid)
        .where('scholarshipId', isEqualTo: scholarshipId)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  /// Stream all applications for the current user.
  Stream<List<ScholarshipApplication>> streamMyApplications() {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    // Only filter by userId (no orderBy) to avoid composite-index requirement.
    // Sort in-memory instead.
    return _applications
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((doc) => ScholarshipApplication.fromFirestore(doc))
          .toList();
      list.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return list;
    });
  }
}
