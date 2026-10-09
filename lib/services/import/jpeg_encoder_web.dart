import 'dart:js_interop';
import 'dart:math';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import '../../theme/tokens.dart';

/// JPEG saydamlık tutmaz; saydam PNG'ler uygulama zemini (Cream-Base) üzerine düzleştirilir.
final _background = '#${(AppColors.creamBase.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Resmi tarayıcıda çözer (`<img>`), canvas'ta [maxWidth]'e küçültür ve JPEG olarak verir.
/// Tarayıcının çözemediği biçimde (EMF, WMF, TIFF…) null döner.
Future<({String base64, int width, int height})?> encodeJpeg(
  Uint8List bytes,
  String mimeType, {
  required int maxWidth,
  required double quality,
}) async {
  final url = web.URL.createObjectURL(web.Blob(<JSAny>[bytes.toJS].toJS, web.BlobPropertyBag(type: mimeType)));
  try {
    final img = web.HTMLImageElement()..src = url;
    await img.decode().toDart;
    if (img.naturalWidth == 0 || img.naturalHeight == 0) return null;
    final scale = img.naturalWidth > maxWidth ? maxWidth / img.naturalWidth : 1.0;
    final width = max(1, (img.naturalWidth * scale).round());
    final height = max(1, (img.naturalHeight * scale).round());
    final canvas = web.HTMLCanvasElement()
      ..width = width
      ..height = height;
    (canvas.getContext('2d')! as web.CanvasRenderingContext2D)
      ..fillStyle = _background.toJS
      ..fillRect(0, 0, width, height)
      ..drawImage(img, 0, 0, width, height);
    final dataUrl = canvas.toDataURL('image/jpeg', quality.toJS);
    return (base64: dataUrl.substring(dataUrl.indexOf(',') + 1), width: width, height: height);
  } catch (_) {
    return null;
  } finally {
    web.URL.revokeObjectURL(url);
  }
}
