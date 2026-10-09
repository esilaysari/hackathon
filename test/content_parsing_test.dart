import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/models/lesson.dart';
import 'package:eduswarm/models/lesson_catalog.dart';
import 'package:eduswarm/services/story_splitter.dart';

Map<String, dynamic> readJson(String path) => jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

// Elle düzenlenen içerik dosyalarının kodla uyumunu korur (K49, K50). Ders sayısı sabit
// değildir: index.json'da ne kadar ders varsa hepsi denetlenir.
void main() {
  final catalog = LessonCatalog.fromJson(readJson('assets/content/lessons/index.json'));
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('index.json: ders listesi, demo dersi, Sokratik mesajlar ve genel zincir', () {
    expect(catalog.lessons, isNotEmpty);
    expect(catalog.lessons.map((l) => l.topicKey).toSet().length, catalog.lessons.length, reason: 'topicKey tekil');
    expect(catalog.demoLesson.topicKey, catalog.demoLessonKey);
    expect(catalog.socraticMessages.solved, isNotEmpty);
    expect(catalog.defaultSocratic.hints, isNotEmpty);
    expect(catalog.defaultSocratic.check, isNull, reason: '"Anladım" doğrudan Odakta\'ya döndürür');
  });

  for (final entry in catalog.lessons) {
    group('Ders: ${entry.topicKey}', () {
      final lesson = Lesson.fromJson(readJson(entry.assetFile!));
      final paragraphs = splitParagraphs(lesson.content);

      test('başlık ve topicKey index.json ile tutarlı', () {
        expect(lesson.topicKey, entry.topicKey);
        expect(lesson.title, entry.title);
      });

      test('sorular geçerli; okuma ve her soru için Sokratik zincir var', () {
        expect(lesson.questions, isNotEmpty);
        expect(lesson.socratic.keys, containsAll(['reading', ...lesson.questions.map((q) => q.id)]));
        for (final q in lesson.questions) {
          expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1), reason: q.id);
          expect(q.optionsAreCode.length, q.options.length, reason: q.id);
        }
        for (final chain in lesson.socratic.values) {
          expect(chain.hints, isNotEmpty);
          final check = chain.check;
          if (check != null) expect(check.correctIndex, inInclusiveRange(0, check.options.length - 1));
        }
      });

      test('storyCards ve şemalar: dosyalar mevcut, pubspec\'te tanımlı, paragraf sırası geçerli', () {
        expect(lesson.storyCards, isNotNull);
        final images = [
          for (final c in lesson.storyCards!)
            if (c.image != null) c.image!,
          for (final f in lesson.figures) f.image,
        ];
        for (final path in images) {
          expect(File(path).existsSync(), isTrue, reason: path);
          final folder = '${path.substring(0, path.lastIndexOf('/'))}/';
          expect(pubspec, contains(folder), reason: '$folder pubspec.yaml assets listesinde olmalı');
        }
        for (final c in lesson.storyCards!.where((c) => c.image != null)) {
          expect(c.imageAlt, isNotEmpty, reason: 'Ekran okuyucu için imageAlt');
        }
        for (final f in lesson.figures) {
          expect(f.afterParagraph, inInclusiveRange(0, paragraphs.length - 1), reason: f.image);
          expect(f.alt, isNotEmpty);
        }
      });
    });
  }

  test('Öğretmenin Firestore dersi: storyCards/figures/socratic olmadan da okunur', () {
    final lesson = Lesson.fromJson({
      'title': 'Yüklenen Ders',
      'topicKey': 'custom',
      'content': 'İlk cümle burada. İkinci cümle.',
      'questions': <dynamic>[],
    });
    expect(lesson.storyCards, isNull);
    expect(lesson.figures, isEmpty);
    expect(lesson.socratic, isEmpty);
    final entry = LessonEntry.fromFirestore('abc', {'title': 'Yüklenen Ders', 'topicKey': 'custom', 'content': lesson.content});
    expect(entry.summary, 'İlk cümle burada.');
    expect(entry.isTeacherLesson, isTrue);
    expect(catalog.merge([entry]).first.firestoreId, 'abc', reason: 'Öğretmenin dersleri üstte');
  });

  test('optionsAreCode: şık başına liste, tek bool veya yok', () {
    expect(parseOptionsAreCode([true, false], 3), [true, false, false]);
    expect(parseOptionsAreCode(true, 2), [true, true]);
    expect(parseOptionsAreCode(null, 2), [false, false]);
  });
}
