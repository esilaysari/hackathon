import 'dart:convert';
import 'dart:typed_data';

import '../../models/lesson.dart';
import '../../models/lesson_draft.dart';
import '../../strings.dart';
import 'pdf_text.dart';
import 'pptx_text.dart';
import 'question_extractor.dart';

/// Dosyadan okunan ders içeriği (TRD T6). Dosyanın kendisi saklanmaz; yalnızca metin.
class ImportedContent {
  const ImportedContent({
    required this.content,
    this.storyCards,
    this.questions = const [],
    this.notes = const [],
    this.suggestedTitle,
  });

  /// Okuma ekranı metni (sorular ayıklandıktan sonra kalan).
  final String content;

  /// Slayttan geldiyse slayt başına bir kart; metin dosyalarında null.
  final List<StoryCard>? storyCards;
  final List<DraftQuestion> questions;

  /// Önizlemede gösterilen bilgi notları (ör. "Slaytlardaki görseller aktarılmadı").
  final List<String> notes;
  final String? suggestedTitle;
}

/// Kullanıcıya gösterilecek, okunabilir içe aktarma hatası.
class ImportException implements Exception {
  const ImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// .txt / .md / .pdf / .pptx → ders taslağı. Hepsi tarayıcıda, saf Dart ile okunur.
abstract final class LessonImporter {
  /// .ppt de seçilebilir ki "Lütfen .pptx olarak kaydedin" uyarısı gösterilebilsin.
  static const extensions = ['pdf', 'pptx', 'ppt', 'md', 'txt'];

  /// [defaultType]: ayıklanan sorulara verilen başlangıç etiketi.
  static ImportedContent import(String fileName, Uint8List bytes, {required QuestionType defaultType}) {
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    return switch (ext) {
      'txt' || 'md' => fromText(utf8.decode(bytes, allowMalformed: true), defaultType: defaultType),
      'pdf' => _fromPdf(bytes, defaultType),
      'pptx' => _fromPptx(bytes, defaultType),
      'ppt' => throw const ImportException(AppStrings.pptNotSupported),
      _ => throw const ImportException(AppStrings.unsupportedFile),
    };
  }

  static ImportedContent fromText(String text, {required QuestionType defaultType}) {
    final extracted = extractQuestions(text, defaultType: defaultType);
    return ImportedContent(content: extracted.text, questions: extracted.questions);
  }

  static ImportedContent _fromPdf(Uint8List bytes, QuestionType defaultType) {
    final String text;
    try {
      text = normalizePdfText(readPdfText(bytes));
    } catch (_) {
      throw const ImportException(AppStrings.pdfNoText);
    }
    if (text.trim().isEmpty) throw const ImportException(AppStrings.pdfNoText);
    final extracted = extractQuestions(text, defaultType: defaultType);
    return ImportedContent(content: paragraphize(extracted.text), questions: extracted.questions);
  }

  static ImportedContent _fromPptx(Uint8List bytes, QuestionType defaultType) {
    final PptxText deck;
    try {
      deck = readPptxText(bytes);
    } catch (_) {
      throw const ImportException(AppStrings.pptxNoText);
    }
    return fromSlides(deck, defaultType: defaultType);
  }

  /// Slaytlar tek metinde ayıklanır (cevap anahtarı başka slaytta olabilir), sonra kalan
  /// satırlar slaytlarına geri dağıtılır. Her slayt bir Story kartı: başlık → kart başlığı,
  /// maddeler → kart metni. Yalnızca soru içeren slayt kart olmaz.
  static ImportedContent fromSlides(PptxText deck, {required QuestionType defaultType}) {
    const separator = '\u0000slide\u0000';
    final joined = deck.slides.map((s) => s.body.join('\n')).join('\n\n$separator\n\n');
    final extracted = extractQuestions(joined, defaultType: defaultType);
    final remainingBodies = extracted.text.split(separator);

    final cards = <StoryCard>[];
    final content = StringBuffer();
    for (var i = 0; i < deck.slides.length; i++) {
      final slide = deck.slides[i];
      final body = i < remainingBodies.length
          ? remainingBodies[i].split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList()
          : <String>[];
      final title = slide.title.trim();
      if (title.isEmpty && body.isEmpty) continue;
      if (body.isEmpty && slide.body.isNotEmpty && title.isNotEmpty) continue; // Soru slaytı.
      final heading = title.isNotEmpty ? title : body.first;
      final bullets = title.isNotEmpty ? body : body.skip(1).toList();
      cards.add(StoryCard(text: heading, subtitle: bullets.isEmpty ? null : bullets.map((b) => '• $b').join('\n')));
      content.write('# $heading\n\n');
      for (final b in bullets) {
        content.write('$b\n\n');
      }
    }
    if (cards.isEmpty && extracted.questions.isEmpty) throw const ImportException(AppStrings.pptxNoText);
    return ImportedContent(
      content: content.toString().trim(),
      storyCards: cards,
      questions: extracted.questions,
      notes: [if (deck.hasImages) AppStrings.pptxImagesSkipped],
      suggestedTitle: deck.slides.map((s) => s.title.trim()).where((t) => t.isNotEmpty).firstOrNull,
    );
  }
}
