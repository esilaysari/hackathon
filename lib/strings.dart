// Kullanıcıya görünen tüm Türkçe metinler burada toplanır (CLAUDE.md §4.3).
// Yeni ekranlar metinlerini ilgili bölüme ekler.
import 'models/lesson.dart';
import 'services/telemetry.dart';

abstract final class AppStrings {
  // Genel
  static const appTitle = 'EduSwarm';

  static String learningStyleName(LearningStyle style) => switch (style) {
        LearningStyle.visual => 'Görsel',
        LearningStyle.dyslexic => 'Dislektik',
        LearningStyle.textual => 'Metinsel',
      };

  static String focusStateName(FocusState state) => switch (state) {
        FocusState.focused => 'Odakta',
        FocusState.attention => 'Dikkat',
        FocusState.critical => 'Kritik',
      };

  /// "45 sn" / "3 dk"
  static String shortDuration(Duration d) =>
      d.inSeconds < 60 ? '${d.inSeconds} sn' : '${d.inMinutes} dk';

  // Giriş / Kayıt (DESIGN.md §8.1) — Faz 5'e kadar demo rol seçimi
  static const roleTeacher = 'Öğretmen Paneli';
  static const roleStudent = 'Öğrenci Portalı';
  static const signingIn = 'Giriş yapılıyor…';
  static String signInFailed(Object error) => 'Giriş yapılamadı: $error';

  // Öğrenme Stili Testi (DESIGN.md §8.2)

  // Sınıf ve İçerik (DESIGN.md §8.3)

  // Ağır Görev ve Story Modu (DESIGN.md §8.4, §8.5)
  static const lessonLoading = 'Ders yükleniyor…';
  static const startQuestions = 'Hemen Başla';
  static const simplify = 'Basitleştir';
  static const nextQuestion = 'İleri';
  static const finishQuestions = 'Bitir';
  static String questionProgress(int current, int total) => 'Soru $current / $total';
  static const lessonCompleted = 'Tebrikler, dersi tamamladın.';
  static const storyTapHint = 'Devam etmek için dokun →';
  static const storyBackToTask = 'Soruya Dön';

  // Sokratik Rehber (DESIGN.md §8.6)

  // Öğretmen Paneli ve Acil Müdahale (DESIGN.md §8.7, §8.8)
  static const panelLoading = 'Sınıf yükleniyor…';
  static String classCode(String code) => 'Kod: $code';
  static String studentCount(int n) => '$n öğrenci';
  static String attentionCount(int n) => '$n dikkat';
  static String criticalCount(int n) => '$n kritik';
  static const presentationMode = 'Sunum Modu';
  static const presentationModeBadge = '5 sn';
  static const criticalListTitle = 'Kritik öğrenciler';
  static const noCriticalStudents = 'Şu an kritik öğrenci yok.';
  static String stuckFor(Duration d) => '${shortDuration(d)} takılı';
  static const alertsTitle = 'Acil Müdahale';
  static String alertHeadline(String name) => '$name bu konuda zorlanıyor';
  static const alertSystemAction = 'Sistem içeriği Story moduna dönüştürdü ve destek mesajı gönderdi.';
  static const alertSeen = 'Gördüm';
  static const detailTitle = 'Öğrenci detayı';
  static const detailEmpty = 'Ayrıntı için listeden bir öğrenci seç.';
  static String interactionSummary(int count, int idleSeconds) =>
      '$count etkileşim · $idleSeconds sn hareketsiz';
  static const styleDistributionTitle = 'Öğrenme stili dağılımı';

  // Bildirimler (DESIGN.md §8.9)
}
