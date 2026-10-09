import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/lesson.dart';
import '../models/lesson_catalog.dart';

/// Uygulamayla paketlenen statik içeriği okur (TRD T4).
abstract final class ContentService {
  static const _catalogPath = 'assets/content/lessons/index.json';

  /// Hazır ders listesi, Sokratik mesajlar, genel zincir ve demo dersi (K50).
  static Future<LessonCatalog> loadCatalog() async =>
      LessonCatalog.fromJson(jsonDecode(await rootBundle.loadString(_catalogPath)) as Map<String, dynamic>);

  static Future<Lesson> loadBundledLesson(String assetFile) async =>
      Lesson.fromJson(jsonDecode(await rootBundle.loadString(assetFile)) as Map<String, dynamic>);

  /// Anahtarlar: `morph`, `checkCorrect`, `checkWrong` (DESIGN.md §8.9).
  static Future<Map<String, List<String>>> loadSupportMessages() async {
    final raw = await rootBundle.loadString('assets/content/support_messages.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map((key, value) => MapEntry(key, (value as List).cast<String>()));
  }
}
