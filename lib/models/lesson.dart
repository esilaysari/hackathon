import 'dart:typed_data';

import 'socratic.dart';

/// Öğrenme profili (TRD §3.1 `learningStyle`).
enum LearningStyle {
  visual,
  dyslexic,
  textual;

  static LearningStyle fromJson(String value) => LearningStyle.values.byName(value);
}

/// Sorunun hareketsizlik eşiğini belirleyen etiketi (MEMORY K16).
enum QuestionType {
  verbalVisual,
  computational;

  static QuestionType fromJson(String value) => switch (value) {
        'verbal_visual' => QuestionType.verbalVisual,
        'computational' => QuestionType.computational,
        _ => throw FormatException('Bilinmeyen soru tipi: $value'),
      };
}

/// Yüklenen derste kart/soru/şema → görsel id eşlemesi (`images/{id}` belgeleri, K54).
List<String> parseImageIds(Object? raw) => raw is List ? raw.cast<String>() : const [];

/// `optionsAreCode`: şık başına liste (`[true, false, …]`) ya da hepsi için tek bool.
List<bool> parseOptionsAreCode(Object? raw, int optionCount) => switch (raw) {
      List<dynamic> list => [for (var i = 0; i < optionCount; i++) i < list.length && list[i] == true],
      bool all => List.filled(optionCount, all),
      _ => List.filled(optionCount, false),
    };

/// Elle hazırlanmış Story kartı (TRD §3.2 `storyCards`).
class StoryCard {
  const StoryCard({
    required this.text,
    this.subtitle,
    this.code,
    this.image,
    this.imageAlt,
    this.imageIds = const [],
  });

  factory StoryCard.fromJson(Map<String, dynamic> json) => StoryCard(
        text: json['text'] as String,
        subtitle: json['subtitle'] as String?,
        code: json['code'] as String?,
        image: json['image'] as String?,
        imageAlt: json['imageAlt'] as String?,
        imageIds: parseImageIds(json['imageIds']),
      );

  /// Slayttaki yalnızca görselden oluşan kartlarda boş olabilir.
  final String text;
  final String? subtitle;
  final String? code;

  /// Hazır derste asset yolu; [imageAlt] yalnızca ekran okuyucuya verilir.
  final String? image;
  final String? imageAlt;

  /// Öğretmenin sunumundan aktarılan slayt görselleri ([Lesson.images] anahtarları).
  final List<String> imageIds;
}

/// Okuma ekranında [afterParagraph]. paragrafın (0'dan) hemen altında gösterilen şema:
/// hazır derste asset ([image]), yüklenen derste slayt görseli ([imageId]).
class LessonFigure {
  const LessonFigure({required this.afterParagraph, this.image, this.imageId, required this.alt});

  factory LessonFigure.fromJson(Map<String, dynamic> json) => LessonFigure(
        afterParagraph: json['afterParagraph'] as int,
        image: json['image'] as String?,
        imageId: json['imageId'] as String?,
        alt: json['alt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'afterParagraph': afterParagraph,
        'image': ?image,
        'imageId': ?imageId,
        'alt': alt,
      };

  final int afterParagraph;
  final String? image;
  final String? imageId;
  final String alt;
}

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.type,
    this.code,
    this.optionsAreCode = const [],
    this.imageIds = const [],
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List).cast<String>();
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      code: json['code'] as String?,
      options: options,
      optionsAreCode: parseOptionsAreCode(json['optionsAreCode'], options.length),
      correctIndex: json['correctIndex'] as int,
      type: QuestionType.fromJson(json['type'] as String),
      imageIds: parseImageIds(json['imageIds']),
    );
  }

  final String id;
  final String text;
  final String? code;
  final List<String> options;
  final List<bool> optionsAreCode;
  final int correctIndex;
  final QuestionType type;

  /// Sorunun geldiği slaydın görselleri ([Lesson.images] anahtarları).
  final List<String> imageIds;
}

class Lesson {
  const Lesson({
    required this.title,
    required this.topicKey,
    required this.content,
    required this.questions,
    this.storyCards,
    this.figures = const [],
    this.socratic = const {},
    this.images = const {},
  });

  /// Hazır ders dosyası (`assets/content/lessons/*.json`) ya da öğretmenin Firestore'a
  /// yüklediği ders; ikincisinde storyCards, figures ve socratic olmayabilir.
  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        title: json['title'] as String,
        topicKey: json['topicKey'] as String,
        content: json['content'] as String,
        storyCards: (json['storyCards'] as List?)
            ?.map((c) => StoryCard.fromJson(c as Map<String, dynamic>))
            .toList(),
        figures: [
          for (final f in json['figures'] as List? ?? const []) LessonFigure.fromJson(f as Map<String, dynamic>),
        ],
        questions: [
          for (final q in json['questions'] as List? ?? const []) Question.fromJson(q as Map<String, dynamic>),
        ],
        socratic: {
          for (final entry in (json['socratic'] as Map<String, dynamic>? ?? const {}).entries)
            entry.key: SocraticChain.fromJson(entry.value as Map<String, dynamic>),
        },
      );

  final String title;
  final String topicKey;
  final String content;

  /// Elle hazırlanmış kartlar; null ise (öğretmenin yüklediği içerik) kurala göre bölünür.
  final List<StoryCard>? storyCards;
  final List<LessonFigure> figures;
  final List<Question> questions;

  /// Ders başına Sokratik zincirler: `reading` ve soru id'leri (K46). Boşsa genel zincir.
  final Map<String, SocraticChain> socratic;

  /// Yüklenen dersin slayt görselleri (id → JPEG); ders belgesinin altındaki
  /// `images/{id}` belgelerinden okunur (K54). Hazır derslerde boş.
  final Map<String, Uint8List> images;

  Lesson withImages(Map<String, Uint8List> images) => Lesson(
        title: title,
        topicKey: topicKey,
        content: content,
        questions: questions,
        storyCards: storyCards,
        figures: figures,
        socratic: socratic,
        images: images,
      );
}
