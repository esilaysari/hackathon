import 'dart:convert';
import 'dart:io';

import 'package:eduswarm/models/learning_style_test.dart';
import 'package:eduswarm/models/lesson.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final quiz = LearningStyleTest.fromJson(
    jsonDecode(File('assets/content/learning_style_test.json').readAsStringSync()) as Map<String, dynamic>,
  );

  /// Her boyuta aynı puanı veren cevaplar.
  Map<String, int> answers(Map<String, int> byDimension) =>
      {for (final q in quiz.questions) q.id: byDimension[q.dimension] ?? 0};

  test('Dosya: 12 soru, 4\'lü ölçek, yalnızca "Tam olarak" sorunun ikonunu kullanır', () {
    expect(quiz.questions, hasLength(12));
    expect(quiz.scale.map((s) => s.label), ['Hiç değil', 'Biraz', 'Çoğunlukla', 'Tam olarak']);
    expect(quiz.scale.where((s) => s.icon == null).single.label, 'Tam olarak');
    for (final dim in quiz.styleDimensions) {
      expect(quiz.results.containsKey(dim), isTrue, reason: dim);
    }
  });

  test('Aşama etiketleri soru numarasına göre', () {
    expect(quiz.stageLabel(1), 'Isınma turu');
    expect(quiz.stageLabel(5), 'Yarıyı geçtin');
    expect(quiz.stageLabel(11), 'Son etap');
    expect(quiz.stageLabel(12), 'Son soru');
  });

  test('En yüksek boyut stil olur; profil eşlemesi dosyadan', () {
    final r = quiz.score(answers({'readwrite': 3, 'visual': 1}));
    expect(r.studentStyle, 'readwrite');
    expect(r.profile, LearningStyle.textual);
    expect(r.readingSupport, isFalse);

    final k = quiz.score(answers({'kinesthetic': 2}));
    expect(k.studentStyle, 'kinesthetic');
    expect(k.profile, LearningStyle.visual);
  });

  test('Eşitlikte styleTieBreakOrder: visual > kinesthetic > readwrite', () {
    expect(quiz.score(answers({'visual': 2, 'readwrite': 2})).studentStyle, 'visual');
    expect(quiz.score(answers({'kinesthetic': 2, 'readwrite': 2})).studentStyle, 'kinesthetic');
    expect(quiz.score({}).studentStyle, 'visual');
  });

  test('readingComfort eşiğe (6) ulaşınca profil Dislektik, stil korunur', () {
    final r = quiz.score(answers({'readwrite': 3, 'readingComfort': 2})); // 3 × 2 = 6
    expect(r.readingSupport, isTrue);
    expect(r.profile, LearningStyle.dyslexic);
    expect(r.studentStyle, 'readwrite');

    final below = quiz.score({...answers({'readwrite': 3, 'readingComfort': 2}), 'q12': 1}); // 5
    expect(below.readingSupport, isFalse);
    expect(below.profile, LearningStyle.textual);
  });
}
