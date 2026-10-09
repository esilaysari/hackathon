import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

/// PDF'in metnini tarayıcıda okur (saf Dart; çalışma anında hiçbir şey indirilmez).
/// Taranmış (yalnızca görsel) PDF'te boş metin döner.
String readPdfText(Uint8List bytes) {
  final document = PdfDocument(inputBytes: bytes);
  try {
    return PdfTextExtractor(document).extractText();
  } finally {
    document.dispose();
  }
}

/// Satır sonlarını `\n` yapar. Çıkarıcı satırların çoğunun arasına boş satır koyuyorsa
/// (her metin parçası ayrı satır) boş satırlar atılır; paragraflar [paragraphize] ile kurulur.
String normalizePdfText(String raw) {
  final lines = raw.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  final empty = lines.where((l) => l.trim().isEmpty).length;
  final filled = lines.length - empty;
  if (filled > 1 && empty >= (filled - 1) * 0.8) {
    return lines.where((l) => l.trim().isNotEmpty).join('\n');
  }
  return lines.join('\n');
}

/// PDF satırlarını paragraflara ayırır: PDF'te boş satır olmadığı için, en uzun satırdan
/// belirgin kısa olup nokta/soru/ünlem/iki nokta ile biten satır paragrafı bitirir.
/// Zaten boş satır içeren metin olduğu gibi kalır.
String paragraphize(String text) {
  final lines = text.split('\n').map((l) => l.trimRight()).toList();
  if (lines.any((l) => l.trim().isEmpty)) return text;
  final longest = lines.fold<int>(0, (m, l) => l.length > m ? l.length : m);
  final buffer = StringBuffer();
  for (final line in lines) {
    buffer.writeln(line);
    final ends = RegExp(r'[.!?:]$').hasMatch(line);
    if (ends && line.length < longest * 0.8) buffer.writeln();
  }
  return buffer.toString().trim();
}
