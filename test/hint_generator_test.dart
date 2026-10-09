import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/models/lesson.dart';
import 'package:eduswarm/models/lesson_draft.dart';
import 'package:eduswarm/services/hint_generator.dart';

const _content = '''
# Dinamik Bellek

C dilinde program çalışırken bellek ayırmak için malloc() fonksiyonu kullanılır. malloc(), istenen bayt kadar yer ayırır ve o bölgenin adresini bir pointer olarak döndürür.

İşimiz bitince ayrılan belleği free() ile geri veririz. Belleği geri vermeyi unutursak bellek sızıntısı oluşur.

Pointer bir değişkenin adresini tutar. Pointer üzerinden adresteki değere ulaşmak için * işleci kullanılır.
''';

void main() {
  final generator = HintGenerator(_content);

  test('Soru ipucu: ilgili cümle ve kavram bulunur, doğru şık hiçbir ipucunda geçmez', () {
    const options = ['malloc()', 'free()', 'printf()'];
    final hints = generator.questionHints(
      text: 'Ayrılan belleği geri vermek için hangi fonksiyon kullanılır?',
      options: options,
      correctIndex: 1,
    );
    expect(hints, hasLength(3));
    expect(hints![0], contains('Metinde'));
    expect(hints[0], contains('bellek'));
    expect(hints[2], startsWith("Şu cümleye tekrar bak: '"));
    expect(hints[2], contains('…'));
    for (final h in hints) {
      expect(h.toLowerCase(), isNot(contains('free')));
    }
  });

  test('Kod parçası kavram olabilir: malloc() olduğu gibi görünür', () {
    final hints = generator.questionHints(
      text: 'malloc() fonksiyonu ne döndürür?',
      options: ['Bir adres (pointer)', 'Bir tamsayı', 'Hiçbir şey'],
      correctIndex: 0,
    )!;
    expect(hints[0], contains('malloc()'));
    // "Malloc()" diye büyük harfe çevrilmez.
    expect(hints[1], startsWith('malloc()'));
    for (final h in hints) {
      expect(h.toLowerCase(), isNot(contains('bir adres (pointer)')));
    }
  });

  test('Metinle hiç ortak kelime yoksa null (genel zincir)', () {
    expect(
      generator.questionHints(text: 'Fotosentez nerede gerçekleşir?', options: ['Yaprak', 'Kök', 'Gövde'], correctIndex: 0),
      isNull,
    );
  });

  test('Okuma ipuçları sık geçen kavramlardan üretilir', () {
    final hints = generator.readingHints()!;
    expect(hints, hasLength(3));
    expect(hints.join(' ').toLowerCase(), anyOf(contains('bellek'), contains('pointer')));
    expect(HintGenerator('Kısa bir metin.').readingHints(), isNull);
  });

  test('Ek temizliği: belleği / bellekte / bellek aynı köke iner', () {
    expect(HintGenerator.stem('belleği'), 'bellek');
    expect(HintGenerator.stem('bellekte'), 'bellek');
    expect(HintGenerator.stem('Fonksiyonlar'), 'fonksiyon');
    expect(HintGenerator.stem('ile'), isNull);
    expect(HintGenerator.stem('ve'), isNull);
  });

  test('LessonDraft Firestore belgesine soru başına zincir yazar; eşleşmeyen soru atlanır', () {
    final draft = LessonDraft(
      title: 'Bellek',
      content: _content,
      questions: [
        DraftQuestion(
          text: 'Ayrılan belleği geri vermek için hangi fonksiyon kullanılır?',
          options: ['malloc()', 'free()', 'printf()'],
          correctIndex: 1,
          type: QuestionType.verbalVisual,
        ),
        DraftQuestion(
          text: 'Fotosentez nerede gerçekleşir?',
          options: ['Yaprak', 'Kök', 'Gövde'],
          correctIndex: 0,
          type: QuestionType.verbalVisual,
        ),
      ],
    );
    final lesson = Lesson.fromJson(draft.toFirestore('abc'));
    expect(lesson.socratic.keys, unorderedEquals(['reading', 'q1']));
    expect(lesson.socratic['q1']!.hints, hasLength(3));
    expect(lesson.socratic['q1']!.check, isNull);
  });
}
