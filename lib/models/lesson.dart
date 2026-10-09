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

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'] as String,
        text: json['text'] as String,
        options: (json['options'] as List).cast<String>(),
        correctIndex: json['correctIndex'] as int,
        type: QuestionType.fromJson(json['type'] as String),
      );

  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;
  final QuestionType type;
}

class Lesson {
  const Lesson({
    required this.title,
    required this.topicKey,
    required this.content,
    required this.questions,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        title: json['title'] as String,
        topicKey: json['topicKey'] as String,
        content: json['content'] as String,
        questions: (json['questions'] as List)
            .map((q) => Question.fromJson(q as Map<String, dynamic>))
            .toList(),
      );

  final String title;
  final String topicKey;
  final String content;
  final List<Question> questions;
}
