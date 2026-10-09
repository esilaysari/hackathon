/// Ders metnini Story kartlarına böler (TRD §4.2, kural tabanlı).
///
/// - Boş satırlar paragrafları ayırır; `#` ile başlayan satır ayrı bir başlık kartıdır.
/// - [maxWords]'ten uzun paragraflar cümle sonlarından (`.`, `?`, `!`) bölünür.
///   Tek başına [maxWords]'ten uzun bir cümle bölünmeden tek kart olur.
List<String> splitIntoStoryCards(String content, {int maxWords = 25}) {
  final cards = <String>[];
  for (final paragraph in splitParagraphs(content)) {
    if (paragraph.startsWith('#')) {
      cards.add(paragraph.replaceFirst(RegExp(r'^#+\s*'), ''));
      continue;
    }
    if (_wordCount(paragraph) <= maxWords) {
      cards.add(paragraph);
      continue;
    }
    var chunk = '';
    for (final sentence in paragraph.split(RegExp(r'(?<=[.?!])\s+'))) {
      final candidate = chunk.isEmpty ? sentence : '$chunk $sentence';
      if (chunk.isNotEmpty && _wordCount(candidate) > maxWords) {
        cards.add(chunk);
        chunk = sentence;
      } else {
        chunk = candidate;
      }
    }
    if (chunk.isNotEmpty) cards.add(chunk);
  }
  return cards;
}

/// Boş satırlarla ayrılmış, boşlukları sadeleştirilmiş paragraflar.
List<String> splitParagraphs(String content) => content
    .split(RegExp(r'\n\s*\n'))
    .map((p) => p.trim().replaceAll(RegExp(r'\s+'), ' '))
    .where((p) => p.isNotEmpty)
    .toList();

int _wordCount(String text) => text.split(' ').where((w) => w.isNotEmpty).length;
