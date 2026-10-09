import 'dart:convert';

import 'package:eduswarm/models/lesson.dart';
import 'package:eduswarm/strings.dart';
import 'package:eduswarm/widgets/lesson_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 1×1 PNG.
final _png = base64Decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==');

Widget _app(LearningStyle style) => MaterialApp(
      home: Scaffold(
        body: ProfileImages(
          style: style,
          pictures: LessonPicture.ofQuestion(
            const Question(
              id: 'q1',
              text: 'S?',
              options: ['a', 'b', 'c'],
              correctIndex: 0,
              type: QuestionType.verbalVisual,
              imageIds: ['img1', 'eksik'],
            ),
            {'img1': _png},
          ),
        ),
      ),
    );

void main() {
  testWidgets('Görsel profil: görsel öne çıkarılmış kutuda; bulunamayan id atlanır', (tester) async {
    await tester.pumpWidget(_app(LearningStyle.visual));
    expect(find.byType(Image), findsOneWidget);
    expect(find.text(AppStrings.showImage), findsNothing);
  });

  testWidgets('Dislektik profil: görsel sınırlı yükseklikte görünür', (tester) async {
    await tester.pumpWidget(_app(LearningStyle.dyslexic));
    expect(find.byType(Image), findsOneWidget);
    expect(find.text(AppStrings.showImage), findsNothing);
  });

  testWidgets('Metinsel profil: görsel gizli, "Görseli göster" ile açılır ve kapanır', (tester) async {
    await tester.pumpWidget(_app(LearningStyle.textual));
    expect(find.byType(Image), findsNothing);
    await tester.tap(find.text(AppStrings.showImage));
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
    await tester.tap(find.text(AppStrings.hideImage));
    await tester.pump();
    expect(find.byType(Image), findsNothing);
  });
}
