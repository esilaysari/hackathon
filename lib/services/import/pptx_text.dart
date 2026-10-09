import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:xml/xml.dart';

/// Bir slaytın metni: başlık yer tutucusu ve diğer kutulardaki paragraflar (maddeler).
class SlideText {
  const SlideText({required this.title, required this.body});

  final String title;
  final List<String> body;
}

class PptxText {
  const PptxText({required this.slides, required this.hasImages});

  final List<SlideText> slides;

  /// Sunumda resim var mı (`ppt/media/`); resimler aktarılmaz, önizlemede not düşülür.
  final bool hasImages;
}

/// .pptx bir zip'tir; slaytlar `ppt/slides/slideN.xml`. Saf Dart, çalışma anında indirme yok.
/// Bozuk / pptx olmayan dosyada [FormatException] fırlatır.
PptxText readPptxText(Uint8List bytes) {
  final archive = ZipDecoder().decodeBytes(bytes);
  final slidePaths = _slideOrder(archive);
  if (slidePaths.isEmpty) throw const FormatException('Sunumda slayt bulunamadı');
  return PptxText(
    slides: [
      for (final path in slidePaths)
        if (_xml(archive, path) case final doc?) _readSlide(doc),
    ],
    hasImages: archive.files.any((f) => f.isFile && f.name.startsWith('ppt/media/')),
  );
}

XmlDocument? _xml(Archive archive, String path) {
  final file = archive.findFile(path);
  final data = file?.readBytes();
  return data == null ? null : XmlDocument.parse(utf8.decode(data, allowMalformed: true));
}

/// Sunumdaki sıra (`presentation.xml` → ilişkiler); okunamazsa dosya adındaki numara.
List<String> _slideOrder(Archive archive) {
  final byNumber = archive.files
      .map((f) => f.name)
      .where((n) => RegExp(r'^ppt/slides/slide\d+\.xml$').hasMatch(n))
      .toList()
    ..sort((a, b) => _number(a).compareTo(_number(b)));
  try {
    final presentation = _xml(archive, 'ppt/presentation.xml');
    final rels = _xml(archive, 'ppt/_rels/presentation.xml.rels');
    if (presentation == null || rels == null) return byNumber;
    final targets = {
      for (final r in rels.findAllElements('Relationship'))
        r.getAttribute('Id'): r.getAttribute('Target'),
    };
    final ordered = [
      for (final id in presentation.findAllElements('p:sldId'))
        if (targets[id.getAttribute('r:id')] case final target?) 'ppt/${target.replaceFirst(RegExp(r'^/?ppt/'), '')}',
    ].where(byNumber.contains).toList();
    return ordered.isEmpty ? byNumber : ordered;
  } on XmlException {
    return byNumber;
  }
}

int _number(String path) => int.parse(RegExp(r'(\d+)\.xml$').firstMatch(path)!.group(1)!);

SlideText _readSlide(XmlDocument doc) {
  final title = <String>[];
  final body = <String>[];
  for (final shape in doc.findAllElements('p:sp')) {
    final type = shape.findAllElements('p:ph').firstOrNull?.getAttribute('type');
    final isTitle = type == 'title' || type == 'ctrTitle';
    final counters = <String, int>{};
    for (final paragraph in shape.findAllElements('a:p')) {
      final text = _paragraphText(paragraph);
      if (text.isEmpty) continue;
      (isTitle ? title : body).add('${_autoNumber(paragraph, counters)}$text');
    }
  }
  // Tablolar (p:graphicFrame) da madde olarak alınır.
  for (final frame in doc.findAllElements('p:graphicFrame')) {
    for (final paragraph in frame.findAllElements('a:p')) {
      final text = _paragraphText(paragraph);
      if (text.isNotEmpty) body.add(text);
    }
  }
  return SlideText(title: title.join(' '), body: body);
}

/// PowerPoint'in otomatik numaraları (`a:buAutoNum`) metinde yazmaz; soru ayıklayıcı
/// görebilsin diye "1. " / "a) " gibi önek üretilir. Yeni bir rakam maddesi harf sayacını
/// sıfırlar (her sorunun şıkları a'dan başlar).
String _autoNumber(XmlElement paragraph, Map<String, int> counters) {
  final auto = paragraph.getElement('a:pPr')?.getElement('a:buAutoNum');
  final type = auto?.getAttribute('type');
  if (type == null) return '';
  final start = int.tryParse(auto!.getAttribute('startAt') ?? '') ?? 1;
  final n = counters[type] = (counters[type] ?? start - 1) + 1;
  if (type.startsWith('arabic')) counters.removeWhere((k, _) => k.startsWith('alpha'));
  final label = switch (type) {
    _ when type.startsWith('alphaLc') => String.fromCharCode(0x60 + n),
    _ when type.startsWith('alphaUc') => String.fromCharCode(0x40 + n),
    _ when type.startsWith('arabic') => '$n',
    _ => null,
  };
  if (label == null) return '';
  return type.endsWith('ParenR') || type.endsWith('ParenBoth') ? '$label) ' : '$label. ';
}

/// `a:t` parçaları birleşir; `a:br` satır sonu boşluğa dönüşür.
String _paragraphText(XmlElement paragraph) {
  final buffer = StringBuffer();
  for (final node in paragraph.descendants.whereType<XmlElement>()) {
    if (node.name.qualified == 'a:t') buffer.write(node.innerText);
    if (node.name.qualified == 'a:br') buffer.write(' ');
  }
  return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
}
