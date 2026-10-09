import '../../models/lesson.dart';
import '../../models/lesson_draft.dart';

/// Metinden numaralı, şıklı soruları ayıklar (PDF ve slayt içe aktarma, kural tabanlı).
///
/// - Soru: `1.` ya da `1)` ile başlayan satır; altında `a)` `b)` … ya da `A)` `B)` …
///   (aynı satırda yan yana da olabilir). En az 3 şık yoksa numaralı liste sayılır, metinde kalır.
/// - Doğru cevap: sorudan sonra `Cevap: B` / `Doğru cevap: b` / `Yanıt: B` ya da metnin
///   herhangi bir yerinde "Cevap Anahtarı" başlığı altında `1-B 2-C` / `1) B` / `1. B`.
/// - Sorulara ve cevaplara ait satırlar metinden çıkarılır; kalan metin [ExtractedQuestions.text].
class ExtractedQuestions {
  const ExtractedQuestions({required this.text, required this.questions});

  final String text;
  final List<DraftQuestion> questions;
}

ExtractedQuestions extractQuestions(String input, {required QuestionType defaultType}) {
  final lines = input.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  final consumed = List.filled(lines.length, false);
  final key = _readAnswerKey(lines, consumed);

  final questions = <DraftQuestion>[];
  final numbers = <int>[];
  _Block? block;
  var lastFinishedIndex = -1; // Az önce biten bloğun soru sırası (ayrı satırdaki cevap için).

  void finish() {
    final b = block;
    block = null;
    if (b == null) return;
    if (b.options.length < DraftQuestion.minOptions) return; // Numaralı liste: metinde kalır.
    for (final i in b.lines) {
      consumed[i] = true;
    }
    questions.add(DraftQuestion(
      text: b.text.join(' ').trim(),
      options: [for (final o in b.options) o.trim()],
      correctIndex: b.answer,
      type: defaultType,
    ));
    numbers.add(b.number);
    lastFinishedIndex = questions.length - 1;
  }

  for (var i = 0; i < lines.length; i++) {
    if (consumed[i]) continue;
    final line = lines[i].trim();

    final answer = _answerLine.firstMatch(line);
    if (answer != null) {
      final index = _letterIndex(answer.group(1)!);
      if (block != null && block!.options.length >= DraftQuestion.minOptions) {
        block!
          ..answer = index
          ..lines.add(i);
        finish();
        continue;
      }
      if (block == null && lastFinishedIndex >= 0 && questions[lastFinishedIndex].correctIndex == null) {
        questions[lastFinishedIndex].correctIndex = index;
        consumed[i] = true;
        continue;
      }
    }

    final start = _questionStart.firstMatch(line);
    if (start != null) {
      finish();
      final b = _Block(int.parse(start.group(1)!))..lines.add(i);
      _addSegments(b, start.group(2)!);
      block = b;
      continue;
    }

    final current = block;
    if (current == null) {
      if (line.isNotEmpty) lastFinishedIndex = -1;
      continue;
    }
    if (line.isEmpty) {
      finish();
      continue;
    }
    if (_optionStart.hasMatch(line) && _addSegments(current, line, optionsOnly: true)) {
      current.lines.add(i);
      continue;
    }
    if (current.options.isEmpty) {
      // Birden fazla satıra yayılan soru metni.
      current.text.add(line);
      current.lines.add(i);
      continue;
    }
    finish();
    i--; // Bu satır bloğa ait değil; normal metin olarak yeniden değerlendir.
  }
  finish();

  for (var q = 0; q < questions.length; q++) {
    final fromKey = key[numbers[q]];
    if (questions[q].correctIndex == null && fromKey != null && fromKey < questions[q].options.length) {
      questions[q].correctIndex = fromKey;
    }
  }

  final remaining = [
    for (var i = 0; i < lines.length; i++)
      if (!consumed[i]) lines[i].trimRight(),
  ].join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
  return ExtractedQuestions(text: remaining, questions: questions);
}

class _Block {
  _Block(this.number);

  final int number;
  final List<String> text = [];
  final List<String> options = [];
  final List<int> lines = [];
  int? answer;
}

final _questionStart = RegExp(r'^(\d{1,2})\s*[.)]\s+(.+)$');
final _optionStart = RegExp(r'^[A-Ea-e]\s*[.)]\s+');
/// Harften sonra başka harf gelmemeli ("Cevap: Ağaç" bir cevap satırı değildir).
const _letterEnd = r'(?![A-Za-zÇĞİÖŞÜçğıöşü])';
final _answerLine =
    RegExp(r'^(?:doğru\s+)?(?:cevap|yan[ıiIİ]t)\s*[:：\-–]?\s*\(?([A-Ea-e])' + _letterEnd, caseSensitive: false);

/// Şık işaretleri: satır başında `a)` / `a.`; satır içinde yalnızca `b)` biçimi (yanlış bölmeyi önlemek için).
final _inlineOption = RegExp(r'(?:^|\s)([A-Ea-e])\s*\)\s+');
final _leadingOption = RegExp(r'^([A-Ea-e])\s*[.)]\s+');

/// [text]'i soru metni ve sıralı şıklara ayırıp [b]'ye ekler. [optionsOnly] → satır şıkla
/// başlamalı ve harfler sırayı (a, b, c…) izlemeli; izlemiyorsa false döner, hiçbir şey eklenmez.
bool _addSegments(_Block b, String text, {bool optionsOnly = false}) {
  final marks = <({int start, int end, int letter})>[];
  final leading = _leadingOption.firstMatch(text);
  if (leading != null) marks.add((start: 0, end: leading.end, letter: _letterIndex(leading.group(1)!)));
  for (final m in _inlineOption.allMatches(text)) {
    if (m.start == 0 && leading != null) continue;
    marks.add((start: m.start, end: m.end, letter: _letterIndex(m.group(1)!)));
  }
  // Harfler mevcut şık sayısından itibaren sırayla gelmeli; gelmeyen işaretler metnin parçasıdır.
  final valid = <({int start, int end, int letter})>[];
  for (final m in marks) {
    if (m.letter == b.options.length + valid.length) valid.add(m);
  }
  if (optionsOnly && (valid.isEmpty || valid.first.start != 0)) return false;
  if (valid.isEmpty) {
    b.text.add(text);
    return true;
  }
  final prefix = text.substring(0, valid.first.start).trim();
  if (prefix.isNotEmpty) b.text.add(prefix);
  for (var k = 0; k < valid.length; k++) {
    final end = k + 1 < valid.length ? valid[k + 1].start : text.length;
    b.options.add(text.substring(valid[k].end, end).trim());
  }
  return true;
}

int _letterIndex(String letter) => letter.toLowerCase().codeUnitAt(0) - 'a'.codeUnitAt(0);

final _keyHeading = RegExp(r'^(?:cevap|yan[ıiIİ]t)\s+anahtar[ıiIİ]\s*:?\s*(.*)$', caseSensitive: false);
final _keyPair = RegExp(r'(\d{1,2})\s*[-.):=]\s*([A-Ea-e])' + _letterEnd);
final _keyLine = RegExp(r'^(?:\s*\d{1,2}\s*[-.):=]\s*[A-Ea-e]' + _letterEnd + r'[\s,;]*)+$');

/// "Cevap Anahtarı" başlığı ve altındaki `1-B 2-C` satırları → soru numarası → şık sırası.
Map<int, int> _readAnswerKey(List<String> lines, List<bool> consumed) {
  final key = <int, int>{};
  for (var i = 0; i < lines.length; i++) {
    final heading = _keyHeading.firstMatch(lines[i].trim());
    if (heading == null) continue;
    consumed[i] = true;
    for (final m in _keyPair.allMatches(heading.group(1)!)) {
      key[int.parse(m.group(1)!)] = _letterIndex(m.group(2)!);
    }
    for (var j = i + 1; j < lines.length; j++) {
      final line = lines[j].trim();
      if (line.isEmpty) {
        consumed[j] = true;
        continue;
      }
      if (!_keyLine.hasMatch(line)) break;
      consumed[j] = true;
      for (final m in _keyPair.allMatches(line)) {
        key[int.parse(m.group(1)!)] = _letterIndex(m.group(2)!);
      }
    }
  }
  return key;
}
