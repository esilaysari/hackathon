import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/lesson.dart';

/// Uygulamayla paketlenen statik içeriği okur (TRD T4).
abstract final class ContentService {
  static Future<Lesson> loadDemoLesson() async {
    final raw = await rootBundle.loadString('assets/content/demo_lesson.json');
    return Lesson.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Anahtarlar: `morph`, `checkCorrect`, `checkWrong` (DESIGN.md §8.9).
  static Future<Map<String, List<String>>> loadSupportMessages() async {
    final raw = await rootBundle.loadString('assets/content/support_messages.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return json.map((key, value) => MapEntry(key, (value as List).cast<String>()));
  }
}
