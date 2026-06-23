import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service to sync Firebase Auth users to Firestore `users` collection.
///
/// The document ID matches the Firebase Auth UID, ensuring a 1-to-1 mapping.
/// Fields align with the admin dashboard's UserModel.
class UserFirestoreService {
  static final UserFirestoreService _instance = UserFirestoreService._();
  factory UserFirestoreService() => _instance;
  UserFirestoreService._();

  final _db = FirebaseFirestore.instance;
  CollectionReference get _users => _db.collection('users');

  // ──────────────────────────────────────────────────────
  //  Create / Ensure user document
  // ──────────────────────────────────────────────────────

  /// Create a new user document after email/password registration.
  Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    String? phone,
    String? photoUrl,
  }) async {
    final doc = _users.doc(uid);
    final snapshot = await doc.get();

    // Don't overwrite if already exists (e.g. re-registration attempt)
    if (snapshot.exists) {
      await doc.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    await doc.set({
      'name': name,
      'email': email,
      'phone': phone,
      'role': 'user',
      'isActive': true,
      'photoUrl': photoUrl,
      'savedScholarships': 0,
      'applications': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  /// Ensure a user document exists for Google/social sign-in.
  /// Creates one if missing, updates lastLoginAt if it exists.
  Future<void> ensureUser(User firebaseUser) async {
    final doc = _users.doc(firebaseUser.uid);
    final snapshot = await doc.get();

    if (snapshot.exists) {
      // Returning user — just update lastLoginAt
      await doc.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } else {
      // First-time social login — create document
      await doc.set({
        'name': firebaseUser.displayName ?? '',
        'email': firebaseUser.email ?? '',
        'phone': firebaseUser.phoneNumber,
        'role': 'user',
        'isActive': true,
        'photoUrl': firebaseUser.photoURL,
        'savedScholarships': 0,
        'applications': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ──────────────────────────────────────────────────────
  //  Update helpers
  // ──────────────────────────────────────────────────────

  /// Update lastLoginAt for an existing user (email/password login).
  Future<void> updateLastLogin(String uid) async {
    try {
      await _users.doc(uid).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Document may not exist yet — ignore silently
    }
  }

  /// Get the current user's profile data from Firestore.
  Future<Map<String, dynamic>?> getProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _users.doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
    } catch (_) {}
    return null;
  }

  /// Stream the current user's profile data in real time.
  Stream<Map<String, dynamic>?> streamProfile() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return _users.doc(uid).snapshots().map((snap) {
      if (snap.exists) return snap.data() as Map<String, dynamic>?;
      return null;
    });
  }

  /// Update profile fields for the current user.
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? dob,
    String? country,
    List<String>? interestedFields,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (phone != null) updates['phone'] = phone;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (dob != null) updates['dob'] = dob;
    if (country != null) updates['country'] = country;
    if (interestedFields != null) {
      updates['interestedFields'] = interestedFields;
    }

    if (updates.isNotEmpty) {
      await _users.doc(uid).update(updates);
    }
  }

  /// Delete the user's Firestore document AND all associated applications.
  Future<void> deleteUserDocument(String uid) async {
    try {
      // Delete all applications by this user
      final applicationsRef = _db.collection('applications');
      final appSnapshot =
          await applicationsRef.where('userId', isEqualTo: uid).get();

      final batch = _db.batch();
      for (final doc in appSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the user document
      batch.delete(_users.doc(uid));

      await batch.commit();
    } catch (_) {}
  }
}
