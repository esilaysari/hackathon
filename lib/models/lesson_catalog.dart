import 'socratic.dart';

/// "Derslerim" listesindeki bir ders kartı. İki kaynaktan gelir: uygulamayla paketlenen
/// hazır dersler (`index.json`) ve öğretmenin Firestore'a yüklediği dersler (K50).
class LessonEntry {
  const LessonEntry({
    required this.topicKey,
    required this.title,
    required this.summary,
    required this.iconName,
    this.estimatedMinutes,
    this.assetFile,
    this.firestoreId,
  });

  factory LessonEntry.fromIndex(Map<String, dynamic> json) => LessonEntry(
        topicKey: json['topicKey'] as String,
        title: json['title'] as String,
        summary: json['summary'] as String,
        iconName: json['icon'] as String?,
        estimatedMinutes: json['estimatedMinutes'] as int?,
        assetFile: json['file'] as String,
      );

  /// Öğretmenin dersi: özet yoksa içeriğin ilk cümlesi, ikon yoksa varsayılan, süre yoksa gizli.
  factory LessonEntry.fromFirestore(String id, Map<String, dynamic> data) => LessonEntry(
        topicKey: data['topicKey'] as String,
        title: data['title'] as String,
        summary: data['summary'] as String? ?? firstSentence(data['content'] as String? ?? ''),
        iconName: data['icon'] as String?,
        estimatedMinutes: data['estimatedMinutes'] as int?,
        firestoreId: id,
      );

  final String topicKey;
  final String title;
  final String summary;
  final String? iconName;
  final int? estimatedMinutes;

  /// Hazır dersin dosya yolu; öğretmenin dersinde null.
  final String? assetFile;

  /// Öğretmenin dersinin `classes/{classId}/lessons/{id}` belgesi; hazır derste null.
  final String? firestoreId;

  bool get isTeacherLesson => firestoreId != null;
}

/// İlk cümle (en fazla ~120 karakter); ters tırnaklar ve başlık işaretleri temizlenir.
String firstSentence(String content) {
  final text = content.replaceAll('`', '').replaceAll(RegExp(r'^#+\s*', multiLine: true), '').trim();
  final match = RegExp(r'^.*?[.!?](\s|$)', dotAll: true).firstMatch(text);
  final sentence = (match?.group(0) ?? text).replaceAll(RegExp(r'\s+'), ' ').trim();
  return sentence.length <= 120 ? sentence : '${sentence.substring(0, 117)}…';
}

/// `assets/content/lessons/index.json`.
class LessonCatalog {
  const LessonCatalog({
    required this.lessons,
    required this.demoLessonKey,
    required this.socraticMessages,
    required this.defaultSocratic,
  });

  factory LessonCatalog.fromJson(Map<String, dynamic> json) => LessonCatalog(
        lessons: [for (final l in json['lessons'] as List) LessonEntry.fromIndex(l as Map<String, dynamic>)],
        demoLessonKey: json['demoLessonKey'] as String,
        socraticMessages: SocraticMessages.fromJson(json['socraticMessages'] as Map<String, dynamic>),
        defaultSocratic: SocraticChain.fromJson(json['defaultSocratic'] as Map<String, dynamic>),
      );

  final List<LessonEntry> lessons;
  final String demoLessonKey;
  final SocraticMessages socraticMessages;

  /// Konuya özel zinciri olmayan dersler (öğretmenin yüklediği) için genel üst-bilişsel zincir.
  final SocraticChain defaultSocratic;

  LessonEntry get demoLesson => lessons.firstWhere((l) => l.topicKey == demoLessonKey);

  /// Öğretmenin dersleri üstte, hazır dersler altta (K50).
  List<LessonEntry> merge(List<LessonEntry> teacherLessons) => [...teacherLessons, ...lessons];
}
