import '../models/lesson.dart';
import '../models/lesson_catalog.dart';
import 'content_service.dart';
import 'firestore_service.dart';

/// Bir ders kartını kaynağına göre (hazır asset ya da öğretmenin Firestore dersi) yükler (K50).
abstract final class LessonRepository {
  static Future<Lesson> load(LessonEntry entry, String classId) {
    final file = entry.assetFile;
    if (file != null) return ContentService.loadBundledLesson(file);
    return FirestoreService.loadLesson(classId, entry.firestoreId!);
  }
}
