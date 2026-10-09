// Geliştirme ayarları. Sunum Modu artık sınıf belgesinden canlı okunur (MEMORY K29).
import 'models/lesson.dart';

abstract final class DevConfig {
  /// null → profil `users/{uid}.learningStyle`'dan okunur.
  /// Profilleri karşılaştırmak için doldur: LearningStyle.dyslexic / .visual / .textual
  static const LearningStyle? learningStyleOverride = null;
}
