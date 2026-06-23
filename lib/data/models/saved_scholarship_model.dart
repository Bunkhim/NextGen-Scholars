/// Saved scholarship (bookmark) model for SQLite.
class SavedScholarshipModel {
  final int? id;
  final int scholarshipId;
  final String? userId;
  final String? notes;
  final bool isVisible;
  final int priority;
  final DateTime? savedAt;

  const SavedScholarshipModel({
    this.id,
    required this.scholarshipId,
    this.userId,
    this.notes,
    this.isVisible = true,
    this.priority = 0,
    this.savedAt,
  });

  SavedScholarshipModel copyWith({
    int? id,
    int? scholarshipId,
    String? userId,
    String? notes,
    bool? isVisible,
    int? priority,
  }) {
    return SavedScholarshipModel(
      id: id ?? this.id,
      scholarshipId: scholarshipId ?? this.scholarshipId,
      userId: userId ?? this.userId,
      notes: notes ?? this.notes,
      isVisible: isVisible ?? this.isVisible,
      priority: priority ?? this.priority,
      savedAt: savedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'scholarship_id': scholarshipId,
      'user_id': userId,
      'notes': notes,
      'is_visible': isVisible ? 1 : 0,
      'priority': priority,
    };
  }

  factory SavedScholarshipModel.fromMap(Map<String, dynamic> map) {
    return SavedScholarshipModel(
      id: map['id'] as int?,
      scholarshipId: (map['scholarship_id'] as int?) ?? 0,
      userId: map['user_id'] as String?,
      notes: map['notes'] as String?,
      isVisible: (map['is_visible'] as int?) == 1,
      priority: (map['priority'] as int?) ?? 0,
      savedAt: map['saved_at'] != null
          ? DateTime.tryParse(map['saved_at'] as String)
          : null,
    );
  }

  @override
  String toString() =>
      'SavedScholarshipModel(id: $id, scholarshipId: $scholarshipId)';
}
