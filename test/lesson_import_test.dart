import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:archive/archive.dart';
import 'package:eduswarm/models/lesson.dart';
import 'package:eduswarm/models/lesson_draft.dart';
import 'package:eduswarm/services/import/lesson_images.dart';
import 'package:eduswarm/services/import/lesson_importer.dart';
import 'package:eduswarm/services/import/question_extractor.dart';
import 'package:eduswarm/strings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

const _type = QuestionType.verbalVisual;

void main() {
  group('Soru ayıklama', () {
    test('Numaralı + şıklı sorular ayrılır, "Cevap: B" doğru cevap olur, metin kalır', () {
      const text = '''
Pointer bir adres tutar.

1. Bir pointer neyi saklar?
a) Değeri
b) Adresi
c) Tipi
Cevap: B

2) Hangisi adres operatörüdür?
A) *
B) &
C) %
D) #
Doğru cevap: b

Son paragraf.''';
      final r = extractQuestions(text, defaultType: _type);
      expect(r.questions, hasLength(2));
      expect(r.questions[0].text, 'Bir pointer neyi saklar?');
      expect(r.questions[0].options, ['Değeri', 'Adresi', 'Tipi']);
      expect(r.questions[0].correctIndex, 1);
      expect(r.questions[1].options, hasLength(4));
      expect(r.questions[1].correctIndex, 1);
      expect(r.text, 'Pointer bir adres tutar.\n\nSon paragraf.');
    });

    test('Yan yana şıklar ve cevap anahtarı', () {
      const text = '''
1. İlk soru hangisi?
a) bir b) iki c) üç
2. İkinci soru
çok satırlı mı?
A) evet B) hayır C) belki

Cevap Anahtarı
1-C 2-A''';
      final r = extractQuestions(text, defaultType: _type);
      expect(r.questions, hasLength(2));
      expect(r.questions[0].options, ['bir', 'iki', 'üç']);
      expect(r.questions[0].correctIndex, 2);
      expect(r.questions[1].text, 'İkinci soru çok satırlı mı?');
      expect(r.questions[1].correctIndex, 0);
      expect(r.text, isEmpty);
    });

    test('Cevap yoksa doğru cevap boş kalır; şıksız numaralı liste metinde kalır', () {
      const text = '''
1. Giriş
2. Tanımlar

3. Soru?
a) x
b) y
c) z''';
      final r = extractQuestions(text, defaultType: QuestionType.computational);
      expect(r.questions, hasLength(1));
      expect(r.questions.single.correctIndex, isNull);
      expect(r.questions.single.type, QuestionType.computational);
      expect(r.text, '1. Giriş\n2. Tanımlar');
    });

    test('"Cevap: Ağaç" bir cevap satırı sayılmaz', () {
      final r = extractQuestions('1. Soru?\na) x\nb) y\nc) z\nCevap: Ağaç', defaultType: _type);
      expect(r.questions.single.correctIndex, isNull);
      expect(r.text, 'Cevap: Ağaç');
    });
  });

  group('PDF', () {
    test('Metin ve sorular tarayıcıdaki gibi bellekte okunur', () {
      final bytes = _pdf(['Arrays store items in order.', '1. Which index comes first?', 'a) 0', 'b) 1', 'c) 2', 'Cevap: A']);
      final imported = LessonImporter.import('notlar.pdf', bytes, defaultType: _type);
      expect(imported.content, contains('Arrays store items in order.'));
      expect(imported.questions, hasLength(1));
      expect(imported.questions.single.correctIndex, 0);
      expect(imported.notes, [AppStrings.pdfImagesNotImported]);
      expect(imported.images, isNull);
    });

    test('Türkçe karakterler (gömülü TrueType yazı tipi) korunur', () {
      final font = PdfTrueTypeFont(File('assets/fonts/Roboto-Regular.ttf').readAsBytesSync(), 12);
      final bytes = _pdf(['Çağrı işaretçiyi öğrendi.', '1. Hangisi doğru?', 'A) Şu', 'B) İğne', 'C) Göz'], font: font);
      final imported = LessonImporter.import('türkçe.pdf', bytes, defaultType: _type);
      expect(imported.content, 'Çağrı işaretçiyi öğrendi.');
      expect(imported.questions.single.options, ['Şu', 'İğne', 'Göz']);
      expect(imported.questions.single.correctIndex, isNull);
    });

    test('Metinsiz (taranmış gibi) PDF uyarı verir', () {
      final bytes = _pdf(const []);
      expect(
        () => LessonImporter.import('tarama.pdf', bytes, defaultType: _type),
        throwsA(isA<ImportException>().having((e) => e.message, 'message', AppStrings.pdfNoText)),
      );
    });
  });

  group('PPTX', () {
    test('Her slayt bir kart; soru slaytı kart olmaz; otomatik numaralar okunur', () {
      final bytes = _pptx([
        _slide('Pointer nedir?', [_p('Adres tutan değişkendir.'), _p('* ile değere ulaşılır.')]),
        _slide('Soru', [
          _p('Pointer neyi saklar?', autoNum: 'arabicPeriod'),
          _p('Değeri', autoNum: 'alphaLcParenR'),
          _p('Adresi', autoNum: 'alphaLcParenR'),
          _p('Tipi', autoNum: 'alphaLcParenR'),
          _p('Cevap: b'),
        ]),
      ], withImage: true);
      final imported = LessonImporter.import('ders.pptx', bytes, defaultType: _type);
      expect(imported.storyCards, hasLength(1));
      expect(imported.storyCards!.single.text, 'Pointer nedir?');
      expect(imported.storyCards!.single.subtitle, '• Adres tutan değişkendir.\n• * ile değere ulaşılır.');
      expect(imported.questions.single.options, ['Değeri', 'Adresi', 'Tipi']);
      expect(imported.questions.single.correctIndex, 1);
      // Slaytta p:pic yoksa ppt/media'daki dosya alınmaz.
      expect(imported.images, isEmpty);
      expect(imported.notes, isEmpty);
      expect(imported.suggestedTitle, 'Pointer nedir?');
    });

    test('Görseller slayt ilişkilerinden bulunur ve kart/soru/şemaya bağlanır', () {
      final bytes = _pptx(
        [
          _slide('Bellek', [_p('Kutucuklar.')], pictures: ['rId2'], background: 'rId3'),
          _slide('', [], pictures: ['rId2']),
          _slide('Soru', [
            _p('1. Pointer neyi saklar?'),
            _p('a) Değeri'),
            _p('b) Adresi'),
            _p('c) Tipi'),
            _p('Cevap: b'),
          ], pictures: ['rId2']),
          _slide('Son', [_p('Bitti.')], pictures: ['rId4']),
        ],
        rels: {
          1: {'rId2': '../media/image1.png', 'rId3': '../media/bg.png'},
          2: {'rId2': '../media/image2.jpeg'},
          3: {'rId2': '../media/image1.png'},
          4: {'rId4': 'https://example.com/x.png'},
        },
        media: ['image1.png', 'image2.jpeg', 'bg.png'],
      );
      final imported = LessonImporter.import('ders.pptx', bytes, defaultType: _type);
      final cards = imported.storyCards!;
      expect([for (final c in cards) c.text], ['Bellek', '', 'Son']);
      expect([for (final c in cards) c.imageIds], [
        ['img1'],
        ['img2'],
        <String>[],
      ]);
      // Aynı resim iki slaytta: tek görsel; arka plan ve dış bağlantı alınmaz.
      expect(imported.images!.keys, ['img1', 'img2']);
      expect(imported.images!['img1']!.mimeType, 'image/png');
      expect(imported.images!['img2']!.mimeType, 'image/jpeg');
      expect(imported.questions.single.imageIds, ['img1']);
      expect([for (final f in imported.figures) (f.imageId, f.afterParagraph)], [('img1', 1), ('img2', 1)]);

      // Yalnızca küçültülebilen görsellerin id'leri ders belgesine yazılır.
      final draft = LessonDraft(
        title: 'Bellek',
        content: imported.content,
        storyCards: cards,
        questions: imported.questions..single.correctIndex = 1,
        figures: imported.figures,
        images: {'img1': CompressedImage(base64: 'AAAA', width: 4, height: 3)},
      );
      final json = draft.toFirestore('abc');
      expect(json['imageIds'], ['img1']);
      expect((json['storyCards'] as List)[1].containsKey('imageIds'), isFalse);
      final lesson = Lesson.fromJson(json);
      expect(lesson.storyCards!.first.imageIds, ['img1']);
      expect(lesson.questions.single.imageIds, ['img1']);
      expect(lesson.figures.single.imageId, 'img1');
    });

    test('.ppt reddedilir', () {
      expect(
        () => LessonImporter.import('eski.ppt', Uint8List(4), defaultType: _type),
        throwsA(isA<ImportException>().having((e) => e.message, 'message', AppStrings.pptNotSupported)),
      );
    });
  });

  test('Taslak: kart sayısı başlık + bölme; eksik soru gönderilemez; Firestore şeması', () {
    final q = DraftQuestion(text: 'S?', options: ['a', 'b', 'c'], type: QuestionType.computational);
    final draft = LessonDraft(title: 'Başlık', content: 'Bir.\n\nİki.', questions: [q]);
    expect(draft.cardCount, 3);
    expect(q.isComplete, isFalse);
    q.correctIndex = 2;
    expect(q.isComplete, isTrue);
    final json = draft.toFirestore('abc');
    expect(json['topicKey'], 'abc');
    expect(json.containsKey('storyCards'), isFalse);
    final lesson = Lesson.fromJson(json);
    expect(lesson.questions.single.type, QuestionType.computational);
    expect(lesson.questions.single.correctIndex, 2);
  });
}

Uint8List _pdf(List<String> lines, {PdfFont? font}) {
  final document = PdfDocument();
  final page = document.pages.add();
  font ??= PdfStandardFont(PdfFontFamily.helvetica, 12);
  for (var i = 0; i < lines.length; i++) {
    page.graphics.drawString(lines[i], font, bounds: Rect.fromLTWH(0, i * 20.0, 500, 20));
  }
  final bytes = Uint8List.fromList(document.saveSync());
  document.dispose();
  return bytes;
}

String _p(String text, {String? autoNum}) =>
    '<a:p>${autoNum == null ? '' : '<a:pPr><a:buAutoNum type="$autoNum"/></a:pPr>'}<a:r><a:t>$text</a:t></a:r></a:p>';

/// [pictures]: slayttaki `p:pic` resimlerinin ilişki id'leri; [background]: `p:bg` resmi.
String _slide(String title, List<String> paragraphs, {List<String> pictures = const [], String? background}) => '''
<p:sld xmlns:p="p" xmlns:a="a" xmlns:r="r"><p:cSld>
${background == null ? '' : '<p:bg><p:bgPr><a:blipFill><a:blip r:embed="$background"/></a:blipFill></p:bgPr></p:bg>'}
<p:spTree>
${title.isEmpty ? '' : '<p:sp><p:nvSpPr><p:nvPr><p:ph type="title"/></p:nvPr></p:nvSpPr><p:txBody>${_p(title)}</p:txBody></p:sp>'}
<p:sp><p:nvSpPr><p:nvPr><p:ph idx="1"/></p:nvPr></p:nvSpPr><p:txBody>${paragraphs.join()}</p:txBody></p:sp>
${pictures.map((id) => '<p:pic><p:blipFill><a:blip r:embed="$id"/></p:blipFill></p:pic>').join()}
</p:spTree></p:cSld></p:sld>''';

/// [rels]: slayt numarası (1'den) → ilişki id'si → hedef; `http` hedefleri dış bağlantıdır.
Uint8List _pptx(
  List<String> slides, {
  bool withImage = false,
  Map<int, Map<String, String>> rels = const {},
  List<String> media = const [],
}) {
  final archive = Archive();
  void add(String name, String text) => archive.addFile(ArchiveFile.bytes(name, utf8.encode(text)));
  for (var i = 0; i < slides.length; i++) {
    add('ppt/slides/slide${i + 1}.xml', slides[i]);
  }
  for (final MapEntry(key: slide, value: targets) in rels.entries) {
    add('ppt/slides/_rels/slide$slide.xml.rels', '''
<Relationships xmlns="r">${[
      for (final MapEntry(key: id, value: target) in targets.entries)
        '<Relationship Id="$id" Target="$target"${target.startsWith('http') ? ' TargetMode="External"' : ''}/>',
    ].join()}</Relationships>''');
  }
  if (withImage) archive.addFile(ArchiveFile.bytes('ppt/media/image1.png', [1, 2, 3]));
  for (final name in media) {
    archive.addFile(ArchiveFile.bytes('ppt/media/$name', [1, 2, 3]));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}
