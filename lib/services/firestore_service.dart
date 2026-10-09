import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/lesson.dart';
import 'telemetry.dart';

/// Firestore okuma/yazma (TRD T2, §3.1). Ham telemetri yazılmaz; yalnızca durum
/// geçişleri ve özet sayılar (K23). Yazma hataları uygulamayı çökertmez.
abstract final class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _class(String classId) =>
      _db.collection('classes').doc(classId);
  static CollectionReference<Map<String, dynamic>> _members(String classId) =>
      _class(classId).collection('members');
  static CollectionReference<Map<String, dynamic>> _alerts(String classId) =>
      _class(classId).collection('alerts');

  // --- Okuma -------------------------------------------------------------

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watchClass(String classId) =>
      _class(classId).snapshots();

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchMembers(String classId) =>
      _members(classId).snapshots();

  /// Kapatılmamış uyarılar; sıralama istemcide yapılır (bileşik indeks gerekmesin).
  static Stream<QuerySnapshot<Map<String, dynamic>>> watchOpenAlerts(String classId) =>
      _alerts(classId).where('seen', isEqualTo: false).snapshots();

  /// Öğretmenin sınıfa yüklediği dersler (Faz 5b'de dolacak; K50).
  static Stream<QuerySnapshot<Map<String, dynamic>>> watchLessons(String classId) =>
      _class(classId).collection('lessons').snapshots();

  static Future<Lesson> loadLesson(String classId, String lessonId) async {
    final doc = await _class(classId).collection('lessons').doc(lessonId).get();
    return Lesson.fromJson(doc.data()!);
  }

  static Future<({String fullName, LearningStyle? learningStyle})> loadProfile(String uid) async {
    final data = (await _db.collection('users').doc(uid).get()).data() ?? const {};
    final style = data['learningStyle'] as String?;
    return (
      fullName: '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      learningStyle: style == null ? null : LearningStyle.fromJson(style),
    );
  }

  // --- Öğrenci yazar -----------------------------------------------------

  /// Ders açıldığında üyelik belgesini sıfırlar (önceki oturumdan kalan Kritik silinir).
  static Future<void> startLesson(String classId, String uid, Lesson lesson) =>
      _safe('ders başladı', () => _members(classId).doc(uid).set({
            'status': FocusState.focused.name,
            'stuckSince': null,
            'interactionCount': 0,
            'idleSeconds': 0,
            'currentTopic': lesson.topicKey,
            'currentTopicTitle': lesson.title,
          }, SetOptions(merge: true)));

  static Future<void> updateStatus(
    String classId,
    String uid, {
    required FocusState status,
    required int interactionCount,
    int? idleSeconds,
  }) =>
      _safe('durum → ${status.name}', () => _members(classId).doc(uid).set({
            'status': status.name,
            'stuckSince': status == FocusState.critical ? FieldValue.serverTimestamp() : null,
            'interactionCount': interactionCount,
            'idleSeconds': ?idleSeconds,
          }, SetOptions(merge: true)));

  /// Uyarı id'si `{uid}_{topicKey}`: açık uyarı varken ikincisi yazılmaz.
  static Future<void> raiseAlertIfNoneOpen(
    String classId, {
    required String studentId,
    required String studentName,
    required LearningStyle learningStyle,
    required Lesson lesson,
    required int idleSeconds,
  }) =>
      _safe('uyarı', () async {
        final ref = _alerts(classId).doc('${studentId}_${lesson.topicKey}');
        final existing = await ref.get();
        if (existing.exists && existing.data()?['seen'] == false) {
          debugPrint('Firestore: açık uyarı zaten var, yenisi yazılmadı');
          return;
        }
        await ref.set({
          'studentId': studentId,
          'studentName': studentName,
          'learningStyle': learningStyle.name,
          'lessonTitle': lesson.title,
          'topicKey': lesson.topicKey,
          'idleSeconds': idleSeconds,
          'matchedPeerId': null,
          'seen': false,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

  /// Sokratik kontrol sorusu doğru: durum Odakta, konu skoru +[scoreGain] (K20, K22).
  static Future<void> markRecovered(String classId, String uid, String topicKey, int scoreGain) =>
      _safe('toparlandı → focused', () => _members(classId).doc(uid).set({
            'status': FocusState.focused.name,
            'stuckSince': null,
            'topicScores': {topicKey: FieldValue.increment(scoreGain)},
          }, SetOptions(merge: true)));

  /// Öğrenciye gelen bildirimler (DESIGN.md §8.9).
  static Stream<QuerySnapshot<Map<String, dynamic>>> watchNotifications(String classId, String uid) =>
      _class(classId).collection('notifications').where('toUserId', isEqualTo: uid).snapshots();

  // --- Öğretmen yazar ----------------------------------------------------

  /// "Eşleştir": uyarı kapanır, takılan öğrenciye ve (gerçekse) akrana bildirim gider.
  /// Mock akrana bildirim yazılmaz; simülasyon çağıran tarafta gösterilir (K47).
  static Future<void> matchPeer(
    String classId, {
    required String alertId,
    required String studentId,
    required String studentName,
    required String peerId,
    required String peerName,
    required bool peerIsMock,
    required String studentText,
    required String peerText,
  }) =>
      _safe('eşleştirme → $peerName', () async {
        final batch = _db.batch();
        final notifications = _class(classId).collection('notifications');
        batch.update(_alerts(classId).doc(alertId), {'seen': true, 'matchedPeerId': peerId});
        batch.set(notifications.doc(), {
          'toUserId': studentId,
          'text': studentText,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (!peerIsMock) {
          batch.set(notifications.doc(), {
            'toUserId': peerId,
            'text': peerText,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      });

  static Future<void> setPresentationMode(String classId, bool enabled) =>
      _safe('Sunum Modu → $enabled', () => _class(classId).update({'presentationMode': enabled}));

  static Future<void> markAlertSeen(String classId, String alertId) =>
      _safe('uyarı görüldü', () => _alerts(classId).doc(alertId).update({'seen': true}));

  static Future<void> _safe(String label, Future<void> Function() write) async {
    try {
      await write();
      debugPrint('Firestore: $label');
    } catch (e) {
      debugPrint('Firestore hatası ($label): $e');
    }
  }
}
