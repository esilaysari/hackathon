import 'package:cloud_firestore/cloud_firestore.dart';

import 'lesson.dart';

/// `classes/{classId}/alerts/{alertId}` (TRD §3.1).
class EmergencyAlert {
  const EmergencyAlert({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.learningStyle,
    required this.lessonTitle,
    required this.createdAt,
  });

  factory EmergencyAlert.fromFirestore(String id, Map<String, dynamic> data) => EmergencyAlert(
        id: id,
        studentId: data['studentId'] as String,
        studentName: data['studentName'] as String,
        learningStyle: LearningStyle.fromJson(data['learningStyle'] as String),
        lessonTitle: data['lessonTitle'] as String,
        // Sunucu zaman damgası henüz yazılmadıysa (yerel önbellek) şimdiki zaman.
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  final String id;
  final String studentId;
  final String studentName;
  final LearningStyle learningStyle;
  final String lessonTitle;
  final DateTime createdAt;
}
