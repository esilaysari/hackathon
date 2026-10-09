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
    required this.topicKey,
    required this.idleSeconds,
    required this.createdAt,
  });

  factory EmergencyAlert.fromFirestore(String id, Map<String, dynamic> data) => EmergencyAlert(
        id: id,
        studentId: data['studentId'] as String,
        studentName: data['studentName'] as String,
        learningStyle: LearningStyle.fromJson(data['learningStyle'] as String),
        lessonTitle: data['lessonTitle'] as String,
        topicKey: data['topicKey'] as String? ?? '',
        idleSeconds: data['idleSeconds'] as int? ?? 0,
        // Sunucu zaman damgası henüz yazılmadıysa (yerel önbellek) şimdiki zaman.
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

  final String id;
  final String studentId;
  final String studentName;
  final LearningStyle learningStyle;
  final String lessonTitle;
  final String topicKey;
  final int idleSeconds;
  final DateTime createdAt;

  /// Kartta gösterilen süre: hareketsiz geçen süre + uyarıdan beri geçen süre (K48).
  /// Sunucu ve tarayıcı saati arasındaki küçük fark negatif süre üretmesin diye sıfırla sınırlanır.
  Duration stuckFor(DateTime now) => _nonNegative(now.difference(createdAt)) + Duration(seconds: idleSeconds);

  static Duration _nonNegative(Duration d) => d.isNegative ? Duration.zero : d;
}
