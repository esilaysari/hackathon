import 'dart:convert';

import 'package:flutter/services.dart';

/// Yerel mock verisini okur (TRD T3). Firestore'a yazılmaz.
abstract final class MockDataService {
  static const _studentsPath = 'assets/mock/mock_students.json';

  static Future<List<Map<String, dynamic>>> loadStudents() async {
    final raw = await rootBundle.loadString(_studentsPath);
    return (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
  }
}
