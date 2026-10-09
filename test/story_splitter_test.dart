import 'package:flutter_test/flutter_test.dart';

import 'package:eduswarm/services/story_splitter.dart';

int words(String s) => s.split(' ').where((w) => w.isNotEmpty).length;

void main() {
  test('Kısa paragraflar ayrı kart olur, başlık işareti silinir', () {
    final cards = splitIntoStoryCards('# Pointer\n\nKısa bir paragraf.\n\n\nİkinci paragraf.');
    expect(cards, ['Pointer', 'Kısa bir paragraf.', 'İkinci paragraf.']);
  });

  test('Uzun paragraf cümle sonlarından en fazla maxWords kelimelik kartlara bölünür', () {
    final paragraph = List.generate(6, (i) => 'Bu cümle tam olarak altı kelime $i.').join(' ');
    final cards = splitIntoStoryCards(paragraph, maxWords: 15);
    expect(cards.length, greaterThan(1));
    for (final card in cards) {
      expect(words(card), lessThanOrEqualTo(15));
      expect(card.endsWith('.'), isTrue);
    }
    expect(cards.join(' '), paragraph);
  });

  test('maxWords sınırını aşan tek cümle bölünmeden tek kart olur', () {
    final sentence = '${List.filled(30, 'kelime').join(' ')}.';
    expect(splitIntoStoryCards(sentence, maxWords: 25), [sentence]);
  });

  test('Satır içi boşluklar sadeleştirilir', () {
    expect(splitParagraphs('  bir\n  iki   üç  \n\n dört '), ['bir iki üç', 'dört']);
  });
}
