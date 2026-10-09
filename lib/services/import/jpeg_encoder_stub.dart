import 'dart:typed_data';

/// Tarayıcı dışında (testler) resim çözücü yok: resimler aktarılmaz.
Future<({String base64, int width, int height})?> encodeJpeg(
  Uint8List bytes,
  String mimeType, {
  required int maxWidth,
  required double quality,
}) async =>
    null;
