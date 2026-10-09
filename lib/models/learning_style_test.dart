import 'lesson.dart';

/// `assets/content/learning_style_test.json` (DESIGN.md §8.2). İçerik dosyadan gelir;
/// burada yalnızca okuma ve dosyadaki `scoring` + `presentationProfileMap` kuralları var.
class LearningStyleTest {
  LearningStyleTest._({
    required this.intro,
    required this.scale,
    required this.stageLabels,
    required this.questions,
    required this.styleDimensions,
    required this.tieBreakOrder,
    required this.readingComfortThreshold,
    required this.dyslexicIfReadingComfort,
    required this.profileMap,
    required this.results,
    required this.readingSupport,
    required this.footnote,
  });

  factory LearningStyleTest.fromJson(Map<String, dynamic> json) {
    final scoring = json['scoring'] as Map<String, dynamic>;
    final map = Map<String, dynamic>.of(json['presentationProfileMap'] as Map<String, dynamic>);
    final dyslexicFlag = map.remove('dyslexicIfReadingComfortAtLeastThreshold') as bool? ?? false;
    final results = Map<String, dynamic>.of(json['results'] as Map<String, dynamic>);
    final footnote = results.remove('footnote') as String;
    final readingSupport = TestResultText.fromJson(results.remove('readingSupport') as Map<String, dynamic>);
    final stages = ((json['progress'] as Map<String, dynamic>)['stageLabels'] as List)
        .cast<Map<String, dynamic>>()
        .map((s) => (fromQuestion: s['fromQuestion'] as int, label: s['label'] as String))
        .toList()
      ..sort((a, b) => a.fromQuestion.compareTo(b.fromQuestion));
    return LearningStyleTest._(
      intro: json['intro'] as String,
      scale: [
        for (final s in (json['scale'] as List).cast<Map<String, dynamic>>())
          ScaleOption(label: s['label'] as String, value: s['value'] as int, icon: s['icon'] as String?),
      ],
      stageLabels: stages,
      questions: [
        for (final q in (json['questions'] as List).cast<Map<String, dynamic>>())
          TestQuestion(
            id: q['id'] as String,
            dimension: q['dimension'] as String,
            fullIcon: q['fullIcon'] as String,
            text: q['text'] as String,
          ),
      ],
      styleDimensions: (scoring['styleDimensions'] as List).cast<String>(),
      tieBreakOrder: (scoring['styleTieBreakOrder'] as List).cast<String>(),
      readingComfortThreshold: scoring['readingComfortThreshold'] as int,
      dyslexicIfReadingComfort: dyslexicFlag,
      profileMap: map.map((k, v) => MapEntry(k, LearningStyle.fromJson(v as String))),
      results: results.map((k, v) => MapEntry(k, TestResultText.fromJson(v as Map<String, dynamic>))),
      readingSupport: readingSupport,
      footnote: footnote,
    );
  }

  static const readingComfortDimension = 'readingComfort';

  final String intro;
  final List<ScaleOption> scale;
  final List<({int fromQuestion, String label})> stageLabels;
  final List<TestQuestion> questions;
  final List<String> styleDimensions;
  final List<String> tieBreakOrder;
  final int readingComfortThreshold;
  final bool dyslexicIfReadingComfort;
  final Map<String, LearningStyle> profileMap;
  final Map<String, TestResultText> results;
  final TestResultText readingSupport;
  final String footnote;

  /// 1'den başlayan soru numarasına göre dosyadaki aşama etiketi.
  String stageLabel(int questionNumber) {
    var label = stageLabels.first.label;
    for (final s in stageLabels) {
      if (questionNumber >= s.fromQuestion) label = s.label;
    }
    return label;
  }

  /// [answers]: soru id → ölçek değeri (0-3). En yüksek stil boyutu öğrencinin stili
  /// (eşitlikte `styleTieBreakOrder`); readingComfort ≥ eşik → sunum profili dyslexic.
  TestResult score(Map<String, int> answers) {
    final totals = <String, int>{};
    for (final q in questions) {
      totals[q.dimension] = (totals[q.dimension] ?? 0) + (answers[q.id] ?? 0);
    }
    var style = tieBreakOrder.first;
    for (final dim in tieBreakOrder) {
      if (!styleDimensions.contains(dim)) continue;
      if ((totals[dim] ?? 0) > (totals[style] ?? 0)) style = dim;
    }
    final readingSupport =
        dyslexicIfReadingComfort && (totals[readingComfortDimension] ?? 0) >= readingComfortThreshold;
    return TestResult(
      studentStyle: style,
      readingSupport: readingSupport,
      profile: readingSupport ? LearningStyle.dyslexic : profileMap[style]!,
    );
  }
}

class ScaleOption {
  const ScaleOption({required this.label, required this.value, required this.icon});

  final String label;
  final int value;

  /// null → sorunun kendi ikonu (`fullIcon`) gösterilir ("Tam olarak").
  final String? icon;
}

class TestQuestion {
  const TestQuestion({required this.id, required this.dimension, required this.fullIcon, required this.text});

  final String id;
  final String dimension;
  final String fullIcon;
  final String text;
}

class TestResultText {
  const TestResultText({required this.title, required this.icon, required this.description});

  factory TestResultText.fromJson(Map<String, dynamic> json) => TestResultText(
        title: json['title'] as String,
        icon: json['icon'] as String,
        description: json['description'] as String,
      );

  final String title;
  final String icon;
  final String description;
}

class TestResult {
  const TestResult({required this.studentStyle, required this.readingSupport, required this.profile});

  /// `visual` | `readwrite` | `kinesthetic`
  final String studentStyle;
  final bool readingSupport;

  /// Sunum profili → `users/{uid}.learningStyle`.
  final LearningStyle profile;
}
