import '../services/story_splitter.dart';
import 'lesson.dart';

/// Öğretmenin yükleme ekranında düzenlediği soru (DESIGN.md §8.3, K16).
class DraftQuestion {
  DraftQuestion({this.text = '', List<String>? options, this.correctIndex, required this.type})
      : options = options ?? ['', '', ''];

  static const minOptions = 3;
  static const maxOptions = 4;

  String text;
  final List<String> options;

  /// null → doğru cevap henüz işaretlenmedi (ör. PDF'te cevap yoktu).
  int? correctIndex;
  QuestionType type;

  bool get isComplete =>
      text.trim().isNotEmpty &&
      options.length >= minOptions &&
      options.every((o) => o.trim().isNotEmpty) &&
      correctIndex != null &&
      correctIndex! < options.length;

  Map<String, dynamic> toJson(String id) => {
        'id': id,
        'text': text.trim(),
        'options': [for (final o in options) o.trim()],
        'correctIndex': correctIndex,
        'type': type == QuestionType.computational ? 'computational' : 'verbal_visual',
      };
}

/// Gönderilmeden önceki ders. Slayttan gelen derste [storyCards] dolu; metin derslerinde
/// kartlar `LessonScreen`'deki gibi başlık + kural tabanlı bölmeyle oluşur (TRD §4.2).
class LessonDraft {
  LessonDraft({required this.title, required this.content, this.storyCards, required this.questions});

  final String title;
  final String content;
  final List<StoryCard>? storyCards;
  final List<DraftQuestion> questions;

  int get cardCount => storyCards?.length ?? 1 + splitIntoStoryCards(content).length;

  /// `classes/{classId}/lessons/{id}` belgesi; `topicKey` belge id'si (uyarı ve skor anahtarı).
  Map<String, dynamic> toFirestore(String topicKey) => {
        'title': title.trim(),
        'topicKey': topicKey,
        'content': content.trim(),
        if (storyCards != null)
          'storyCards': [
            for (final c in storyCards!) {'text': c.text, 'subtitle': ?c.subtitle},
          ],
        'questions': [for (var i = 0; i < questions.length; i++) questions[i].toJson('q${i + 1}')],
      };
}
