// Kullanıcıya görünen tüm Türkçe metinler burada toplanır (CLAUDE.md §4.3).
// Yeni ekranlar metinlerini ilgili bölüme ekler.

abstract final class AppStrings {
  // Genel
  static const appTitle = 'EduSwarm';

  // Giriş / Kayıt (DESIGN.md §8.1)

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

  // Bildirimler (DESIGN.md §8.9)
}
