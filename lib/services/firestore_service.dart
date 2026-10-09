import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/class_code.dart';
import '../models/learning_style_test.dart';
import '../models/lesson_draft.dart';
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

  /// `users/{uid}` belgesinin tamamı (yoksa boş).
  static Future<Map<String, dynamic>> loadUser(String uid) async =>
      (await _db.collection('users').doc(uid).get()).data() ?? const {};

  // --- Kayıt ve test -----------------------------------------------------

  /// Kayıtta profil belgesi; şifre yazılmaz (TRD §3.1, K37). Hata çağırana iletilir.
  static Future<void> createUser(
    String uid, {
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  }) =>
      _db.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
        'learningStyle': null,
        'kvkkConsent': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// Test sonucu: `learningStyle` sunum profili, ayrıca öğrencinin stili ve okuma desteği.
  /// Öğrenci bir sınıftaysa aynı alanlar üyelik belgesine kopyalanır; öğretmen detayda görür.
  static Future<void> saveTestResult(String uid, String? classId, String displayName, TestResult result) async {
    final fields = {
      'learningStyle': result.profile.name,
      'studentStyle': result.studentStyle,
      'readingSupport': result.readingSupport,
    };
    await _db.collection('users').doc(uid).set(fields, SetOptions(merge: true));
    if (classId == null) return;
    await _safe('üyelik → $classId', () => _members(classId).doc(uid).set({
          ...fields,
          'displayName': displayName,
        }, SetOptions(merge: true)));
  }

  // --- Sınıf (DESIGN.md §8.3, TRD §4.4) ----------------------------------

  /// Benzersiz kodla sınıf oluşturur, öğretmenin aktif sınıfı yapar; classId döner.
  static Future<({String classId, String code})> createClass(String teacherId, String name) async {
    var code = ClassCode.generate();
    for (var i = 0; i < 5 && (await _classIdByCode(code)) != null; i++) {
      code = ClassCode.generate();
    }
    final ref = _db.collection('classes').doc();
    await ref.set({
      'name': name,
      'code': code,
      'teacherId': teacherId,
      'presentationMode': false,
      'activeLessonId': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('users').doc(teacherId).set({'activeClassId': ref.id}, SetOptions(merge: true));
    return (classId: ref.id, code: code);
  }

  static Future<String?> _classIdByCode(String code) async {
    final query = await _db.collection('classes').where('code', isEqualTo: code).limit(1).get();
    return query.docs.isEmpty ? null : query.docs.first.id;
  }

  /// Kodla sınıfa katılır: üyelik belgesi (profil kopyası, Odakta, boş skor) + aktif sınıf.
  /// Kod bulunamazsa null döner. Daha önce katıldıysa durum ve skorlar korunur.
  static Future<String?> joinClass(String uid, String code) async {
    final classId = await _classIdByCode(code);
    if (classId == null) return null;
    final user = await loadUser(uid);
    final member = _members(classId).doc(uid);
    final existing = await member.get();
    await member.set({
      'displayName': '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim(),
      'learningStyle': user['learningStyle'],
      'studentStyle': user['studentStyle'],
      'readingSupport': user['readingSupport'] ?? false,
      if (!existing.exists) ...{
        'status': FocusState.focused.name,
        'stuckSince': null,
        'interactionCount': 0,
        'topicScores': <String, int>{},
        'joinedAt': FieldValue.serverTimestamp(),
      },
    }, SetOptions(merge: true));
    await _db.collection('users').doc(uid).set({'activeClassId': classId}, SetOptions(merge: true));
    return classId;
  }

  /// "Dersi Gönder" (TRD §4.4 madde 6): ders belgesi + sınıfın `activeLessonId`'si.
  /// Öğrencinin "Derslerim" listesi `lessons`'ı canlı dinler. Hata çağırana iletilir.
  static Future<void> publishLesson(String classId, LessonDraft draft) async {
    final ref = _class(classId).collection('lessons').doc();
    final batch = _db.batch()
      ..set(ref, {...draft.toFirestore(ref.id), 'createdAt': FieldValue.serverTimestamp()})
      ..update(_class(classId), {'activeLessonId': ref.id});
    await batch.commit();
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
