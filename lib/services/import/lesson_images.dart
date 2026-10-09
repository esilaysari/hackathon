import 'dart:convert';
import 'dart:typed_data';

import 'jpeg_encoder_stub.dart' if (dart.library.js_interop) 'jpeg_encoder_web.dart';

/// Sunumdan okunan ham resim (henüz küçültülmemiş).
class SourceImage {
  const SourceImage({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;

  /// Dosya uzantısından tarayıcının çözebileceği tür; bilinmeyen (EMF, WMF, TIFF…) çözülemez.
  static String mimeTypeOf(String path) => switch (path.split('.').last.toLowerCase()) {
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        'gif' => 'image/gif',
        'bmp' => 'image/bmp',
        'webp' => 'image/webp',
        'svg' => 'image/svg+xml',
        _ => 'application/octet-stream',
      };
}

/// Firestore'a yazılmaya hazır JPEG (base64). Önizleme küçük resimleri [bytes]'ı kullanır.
class CompressedImage {
  CompressedImage({required this.base64, required this.width, required this.height});

  final String base64;
  final int width;
  final int height;

  late final Uint8List bytes = base64Decode(base64);
}

/// Slayt resimlerini tarayıcıda en fazla [maxWidth] px genişliğe küçültüp JPEG'e çevirir (K54).
/// Çalışma anında internetten bir şey indirilmez; tarayıcının kendi resim çözücüsü kullanılır.
abstract final class ImageCompressor {
  static const maxWidth = 1000;

  /// Firestore belge sınırı 1 MiB; base64 metni + alan adları için pay bırakılır.
  static const maxBase64Length = 900000;

  /// Sınır aşılırsa kalite sırayla düşürülür; yine aşılırsa genişlik 2/3'üne iner.
  static const qualities = [0.8, 0.65, 0.5, 0.35];
  static const _widthSteps = 3;

  /// Çözülemeyen ya da sığdırılamayan resimler sonuçta yer almaz.
  static Future<Map<String, CompressedImage>> compressAll(Map<String, SourceImage> images) async {
    final result = <String, CompressedImage>{};
    for (final entry in images.entries) {
      final compressed = await compress(entry.value);
      if (compressed != null) result[entry.key] = compressed;
    }
    return result;
  }

  static Future<CompressedImage?> compress(SourceImage image) async {
    var width = maxWidth;
    for (var step = 0; step < _widthSteps; step++) {
      for (final quality in qualities) {
        final jpeg = await encodeJpeg(image.bytes, image.mimeType, maxWidth: width, quality: quality);
        if (jpeg == null) return null;
        if (jpeg.base64.length <= maxBase64Length) {
          return CompressedImage(base64: jpeg.base64, width: jpeg.width, height: jpeg.height);
        }
      }
      width = width * 2 ~/ 3;
    }
    return null;
  }
}
