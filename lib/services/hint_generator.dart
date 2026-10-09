import 'dart:math';

import '../strings.dart';

/// Öğretmenin yüklediği ders metninden kural tabanlı Sokratik ipucu üretir (LLM yok, K9).
/// Soru ipucu: soru + şıklarla en çok ortak kelimeyi paylaşan cümle bulunur, oradaki
/// ayırt edici kavramla 3 adımlı zincir kurulur. Doğru şıkkın metni hiçbir ipucunda geçmez.
/// Eşleşme yoksa null döner; ekran genel zincire düşer.
class HintGenerator {
  HintGenerator(String content) : _sentences = _splitSentences(content) {
    for (final s in _sentences) {
      for (final stem in s.stems) {
        _df[stem] = (_df[stem] ?? 0) + 1;
      }
      for (final t in s.tokens) {
        final stem = t.stem;
        if (stem == null) continue;
        _tf[stem] = (_tf[stem] ?? 0) + 1;
        if (t.isCode) _code.add(stem);
        if (t.isCall) _calls.add(stem);
        // Gösterilecek hâl: en kısa biçim ("belleği" değil "bellek"); başlıktaki "Bellek"
        // yerine cümle içindeki küçük harfli hâl tercih edilir.
        final current = _forms[stem];
        if (current == null ||
            t.word.length < current.length ||
            (t.word.length == current.length && t.word == turkishLower(t.word))) {
          _forms[stem] = t.word;
        }
      }
    }
  }

  final List<_Sentence> _sentences;
  final Map<String, int> _df = {};
  final Map<String, int> _tf = {};
  final Map<String, String> _forms = {};
  final Set<String> _code = {};
  final Set<String> _calls = {};

  /// Kavramın ipucunda görünen hâli: fonksiyon çağrısıysa `malloc()`.
  String _display(String stem) => _calls.contains(stem) ? '${_forms[stem]}()' : _forms[stem]!;

  /// Kod kelimeleri ("int", "malloc()") cümle başında da büyük harfe çevrilmez.
  String _capitalize(String stem) {
    final s = _display(stem);
    if (_code.contains(stem) || _calls.contains(stem)) return s;
    final first = switch (s[0]) { 'i' => 'İ', 'ı' => 'I', final c => c.toUpperCase() };
    return '$first${s.substring(1)}';
  }

  static const _maxSentenceLength = 120;

  /// Okuma ekranı: metinde en sık geçen 2-3 kavramla 3 ipucu.
  List<String>? readingHints() {
    final ranked = _tf.keys.where((k) => _tf[k]! >= 2).toList()
      ..sort((a, b) {
        final byCount = _tf[b]!.compareTo(_tf[a]!);
        return byCount != 0 ? byCount : b.length.compareTo(a.length);
      });
    if (ranked.length < 2) return null;
    final c = ranked.take(3).toList();
    return [
      AppStrings.readingHintWhy(_display(c[0])),
      AppStrings.readingHintRelation(_capitalize(c[0]), _display(c[1])),
      AppStrings.readingHintExplain(_capitalize(c.length > 2 ? c[2] : c[1])),
    ];
  }

  /// Soru ekranı: [correctIndex] null olabilir (öğretmen henüz işaretlemedi).
  List<String>? questionHints({required String text, required List<String> options, int? correctIndex}) {
    final questionStems = _stemsOf(text);
    final matchStems = {...questionStems, for (final o in options) ..._stemsOf(o)};
    final correct = correctIndex != null && correctIndex < options.length ? options[correctIndex].trim() : '';
    final correctStems = _stemsOf(correct);

    final scored = [
      for (final s in _sentences) (sentence: s, score: _score(s.stems.intersection(matchStems))),
    ]..sort((a, b) => b.score.compareTo(a.score));
    if (scored.isEmpty || scored.first.score == 0) return null;
    final best = scored.first.sentence;
    final chosen = [
      best,
      if (scored.length > 1 && scored[1].score >= scored.first.score / 2) scored[1].sentence,
    ];

    // Kavram: soruda da seçilen cümlelerde de geçen, en ayırt edici kelime (tf·idf:
    // metinde tekrar eden ama her cümlede geçmeyen). Doğru şıkkın kelimeleri seçilmez.
    final chosenStems = {for (final s in chosen) ...s.stems};
    double weight(String stem) => _tf[stem]! * log(1 + _sentences.length / _df[stem]!);
    final candidates = questionStems.intersection(chosenStems).difference(correctStems).toList()
      ..sort((a, b) {
        final byWeight = weight(b).compareTo(weight(a));
        return byWeight != 0 ? byWeight : b.length.compareTo(a.length);
      });
    if (candidates.isEmpty) return null;
    final stem = candidates.first;
    final concept = _display(stem);

    final sentence = _shorten(_mask(best.text, correct, correctStems.difference(questionStems)), concept);
    return [
      _maskPhrase(AppStrings.hintRecall(concept), correct),
      _maskPhrase(AppStrings.hintPurpose(_capitalize(stem)), correct),
      AppStrings.hintLookAgain(sentence),
    ];
  }

  double _score(Set<String> stems) =>
      stems.fold(0, (sum, s) => sum + log(1 + _sentences.length / _df[s]!));

  /// Cümlede doğru şıkkı gizler: önce şıkkın tamamı, sonra soruda geçmeyen kelimeleri.
  static String _mask(String text, String correct, Set<String> correctOnlyStems) => _maskPhrase(text, correct)
      .replaceAllMapped(_word, (m) => correctOnlyStems.contains(stem(m[0]!)) ? '…' : m[0]!)
      .replaceAll('`', '')
      .replaceAll('…()', '…')
      .replaceAll(RegExp(r'…(\s*…)+'), '…')
      .replaceAll(RegExp(r'…[.!?]'), '…');

  static String _maskPhrase(String text, String phrase) {
    if (phrase.isEmpty) return text;
    final pattern = RegExp(
      '(?<![\\p{L}\\p{N}_])${RegExp.escape(phrase)}(?![\\p{L}\\p{N}_])',
      caseSensitive: false,
      unicode: true,
    );
    return text.replaceAll(pattern, '…');
  }

  /// Uzun cümleden kavramın çevresindeki kısım alınır.
  static String _shorten(String text, String concept) {
    if (text.length <= _maxSentenceLength) return text;
    final at = max(0, text.indexOf(concept.replaceAll('()', '')));
    var start = max(0, min(at - 40, text.length - _maxSentenceLength));
    if (start > 0) start = text.indexOf(' ', start) + 1;
    var end = min(text.length, start + _maxSentenceLength);
    if (end < text.length) {
      final space = text.lastIndexOf(' ', end);
      if (space > start) end = space;
    }
    return '${start > 0 ? '…' : ''}${text.substring(start, end).trim()}${end < text.length ? '…' : ''}';
  }

  // --- Metin işleme ------------------------------------------------------

  static final _sentenceEnd = RegExp(r'(?<=[.!?…])\s+');
  static final _linePrefix = RegExp(r'^\s*(#+|•|-|\*|\d+[.)])\s+');
  static final _word = RegExp(r'[\p{L}\p{N}_]+', unicode: true);

  static List<_Sentence> _splitSentences(String content) => [
        for (final line in content.split('\n'))
          for (final part in line.replaceFirst(_linePrefix, '').split(_sentenceEnd))
            if (part.trim().isNotEmpty) _Sentence(part.trim()),
      ];

  static Set<String> _stemsOf(String text) => {for (final m in _word.allMatches(text)) ?stem(m[0]!)};

  /// Küçük harf + basit ek temizliği; yaygın kelime ya da 3 harften kısaysa null.
  static String? stem(String word) {
    final lower = turkishLower(word);
    if (lower.length < 3 || _stopWords.contains(lower) || RegExp(r'^\d+$').hasMatch(lower)) return null;
    var s = lower;
    for (var pass = 0; pass < 3; pass++) {
      final suffix = _suffixes.where((x) => s.endsWith(x) && s.length - x.length >= 3).firstOrNull;
      if (suffix == null) break;
      s = s.substring(0, s.length - suffix.length);
    }
    if (s.endsWith('ğ')) s = '${s.substring(0, s.length - 1)}k'; // belleği → bellek
    return _stopWords.contains(s) ? null : s;
  }

  static String turkishLower(String s) => s.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

  static const _suffixes = [
    'lerinden', 'larından', 'lerinde', 'larında', 'lerini', 'larını', 'lerine', 'larına', //
    'lerin', 'ların', 'leri', 'ları', 'ler', 'lar', 'ndan', 'nden', 'nın', 'nin', 'nun', 'nün',
    'dır', 'dir', 'dur', 'dür', 'tır', 'tir', 'tur', 'tür', 'dan', 'den', 'tan', 'ten',
    'nda', 'nde', 'yla', 'yle', 'da', 'de', 'ta', 'te', 'ya', 'ye', 'yı', 'yi', 'yu', 'yü',
    'sı', 'si', 'su', 'sü', 'ın', 'in', 'un', 'ün', 'ı', 'i', 'u', 'ü', 'a', 'e',
  ];

  static const _stopWords = {
    've', 'veya', 'ile', 'bir', 'bu', 'şu', 'için', 'gibi', 'daha', 'çok', 'ama', 'fakat', 'ancak',
    'ise', 'ki', 'ne', 'neden', 'nasıl', 'hangi', 'hangisi', 'hangisidir', 'aşağıdaki', 'aşağıdakilerden',
    'nedir', 'midir', 'mıdır', 'mudur', 'olan', 'olarak', 'olur', 'olursa', 'olduğu', 'olduğunu', 'olmak',
    'her', 'hiç', 'kadar', 'sonra', 'önce', 'şey', 'var', 'yok', 'değil', 'eder', 'yapar', 'göre', 'doğru',
    'yanlış', 'cevap', 'soru', 'bunu', 'buna', 'bunun', 'şunu', 'onu', 'ona', 'onun', 'bunlar', 'şöyle',
    'böyle', 'iki', 'üç', 'tek', 'sadece', 'yalnızca', 'kendi', 'diğer', 'başka', 'zaman', 'verilen',
    'yukarıdaki', 'örnek', 'örneğin', 'artık', 'bile', 'hem', 'çünkü', 'eğer', 'yani', 'tüm', 'bütün',
    'aynı', 'böylece', 'içinde', 'üzerinde', 'arasında', 'sonucu', 'durumda', 'olabilir', 'oldu', 'olacak',
    'nedeni', 'yerine', 'mümkün', 'genellikle', 'demek', 'demektir', 'denir', 'şekilde', 'biri', 'birini',
  };
}

class _Token {
  _Token(this.word, this.stem, {required this.isCode, required this.isCall});

  final String word;
  final String? stem;

  /// `…` kod parçasının içinde ya da `_`/rakam içeren bir tanımlayıcı.
  final bool isCode;

  /// Hemen ardından `(` geliyor: `malloc(`.
  final bool isCall;
}

class _Sentence {
  _Sentence(this.text)
      : tokens = [
          for (final m in HintGenerator._word.allMatches(text))
            _Token(
              m[0]!,
              HintGenerator.stem(m[0]!),
              isCode: '`'.allMatches(text.substring(0, m.start)).length.isOdd || RegExp(r'[_\d]').hasMatch(m[0]!),
              isCall: text.startsWith('(', m.end),
            ),
        ];

  final String text;
  final List<_Token> tokens;

  late final Set<String> stems = {for (final t in tokens) ?t.stem};
}
