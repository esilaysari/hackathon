import 'package:eduswarm/screens/teacher/lesson_upload_screen.dart';
import 'package:eduswarm/strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Metin yapıştırınca önizleme güncellenir; eksik soru gönderilmez', (tester) async {
    tester.view
      ..physicalSize = const Size(1200, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: LessonUploadScreen(classId: 'test')));

    expect(find.text(AppStrings.previewSummary(1, 0)), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, AppStrings.lessonTitleField), 'Diziler');
    await tester.enterText(find.widgetWithText(TextField, AppStrings.pasteTextField), 'Bir.\n\nİki.');
    await tester.pump();
    expect(find.text(AppStrings.previewSummary(3, 0)), findsOneWidget);

    await tester.tap(find.text(AppStrings.addQuestion));
    await tester.pump();
    expect(find.text(AppStrings.questionLabel(1)), findsOneWidget);
    expect(find.text(AppStrings.previewSummary(3, 1)), findsOneWidget);
    // Boş soruda metinle eşleşme yok: öğretmen genel ipuçlarının kullanılacağını görür.
    expect(find.text(AppStrings.generatedHintsTitle), findsOneWidget);
    expect(find.text(AppStrings.questionHintsLabel(1)), findsOneWidget);
    expect(find.text(AppStrings.noGeneratedHints), findsWidgets);

    await tester.tap(find.text(AppStrings.sendLesson));
    await tester.pump();
    expect(find.text(AppStrings.questionsIncomplete), findsOneWidget);
  });
}
