// Faz 1–2 için geçici geliştirme ayarları. Faz 3'te Sunum Modu sınıf belgesinden,
// öğrenme profili kullanıcı belgesinden (Firestore) gelecek.
import 'models/lesson.dart';

abstract final class DevConfig {
  /// true → tüm eşikler 5 sn (MEMORY K8).
  static const presentationMode = true;

  /// Profilleri karşılaştırmak için değiştir: LearningStyle.dyslexic / .visual / .textual
  static const demoLearningStyle = LearningStyle.dyslexic;
}
