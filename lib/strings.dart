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

  // Giriş / Kayıt (DESIGN.md §8.1)
  static const signingIn = 'Giriş yapılıyor…';
  static String signInFailed(Object error) => 'Giriş yapılamadı: $error';
  static const tabSignIn = 'Giriş Yap';
  static const tabRegister = 'Kayıt Ol';
  static const firstName = 'Ad';
  static const lastName = 'Soyad';
  static const email = 'E-posta';
  static const password = 'Şifre';
  static const signInButton = 'Giriş Yap';
  static const registerButton = 'Devam Et';
  static const roleTeacherOption = 'Öğretmen';
  static const roleStudentOption = 'Öğrenci';
  static const kvkkConsent =
      'Öğrenme stilimin ve platformdaki etkileşim verilerimin yalnızca bana yardım etmek amacıyla öğretmenimle paylaşılmasını kabul ediyorum.';
  static const kvkkDetails = 'Ayrıntılar';
  static const kvkkDetailsText =
      'EduSwarm bir prototiptir. Öğrenme stilin ve ders sırasındaki özet etkileşim bilgilerin (ör. hareketsiz kalınan süre) yalnızca öğretmeninin sana zamanında yardım edebilmesi için kullanılır. Ham veriler gösterilmez, üçüncü kişilerle paylaşılmaz.';
  static const close = 'Kapat';
  static const demoTeacher = 'Demo Öğretmen olarak gir';
  static const demoStudent = 'Demo Öğrenci olarak gir';
  static const requiredField = 'Bu alanı doldur';
  static const invalidEmail = 'Geçerli bir e-posta yaz';
  static const shortPassword = 'Şifre en az 6 karakter olmalı';
  static const chooseRole = 'Bir rol seç';
  static const kvkkRequired = 'Devam etmek için onay kutusunu işaretle';
  static const errorWrongCredentials = 'E-posta veya şifre hatalı.';
  static const errorEmailInUse = 'Bu e-postayla zaten bir hesap var; Giriş Yap sekmesini dene.';
  static const errorWeakPassword = 'Şifre çok zayıf; en az 6 karakter kullan.';
  static const errorInvalidEmail = 'E-posta adresi geçersiz.';
  static String errorGeneric(Object error) => 'Bir sorun oluştu: $error';

  // Öğrenme Stili Testi (DESIGN.md §8.2)
  static const testTitle = 'Öğrenme Stili Testi';
  static const testLoading = 'Test yükleniyor…';
  static String testLoadFailed(Object error) => 'Test açılamadı: $error';
  static const testStart = 'Teste Başla';
  static const testNext = 'İleri';
  static const testBack = 'Geri';
  static const testFinish = 'Sonucu Gör';
  static String testPercent(int percent) => '%$percent';
  static String testRemaining(int n) => '$n soru kaldı';
  static const testSaveFailed = 'Sonuç kaydedilemedi; bağlantını kontrol edip tekrar dene.';
  static const testResultTitle = 'Senin öğrenme stilin';
  static const goToMyLessons = 'Derslerime Git';

  /// Öğretmen detayında öğrencinin test sonucu (stil anahtarları test dosyasındaki boyutlar).
  static String studentStyleName(String key) => switch (key) {
        'visual' => 'Görsel öğrenen',
        'readwrite' => 'Okuyarak-yazarak öğrenen',
        'kinesthetic' => 'Kinestetik öğrenen',
        _ => key,
      };
  static const readingSupportOn = 'Okuma desteği açık';

  // Sınıf ve İçerik (DESIGN.md §8.3)

  // Derslerim
  static const myLessonsTitle = 'Derslerim';
  static const myLessonsLoading = 'Dersler yükleniyor…';
  static String estimatedMinutes(int minutes) => '~$minutes dk';
  static const teacherLessonBadge = 'Öğretmeninden';
  static String lessonOpenFailed(Object error) => 'Ders açılamadı: $error';

  // Ağır Görev ve Story Modu (DESIGN.md §8.4, §8.5)
  static const lessonLoading = 'Ders yükleniyor…';
  static const startQuestions = 'Hemen Başla';
  static const simplify = 'Basitleştir';
  static const nextQuestion = 'İleri';
  static const finishQuestions = 'Bitir';
  static const checkAnswer = 'Kontrol Et';
  static String questionProgress(int current, int total) => 'Soru $current / $total';
  /// İlk soru · yarıdan önceki ortalar · yarıyı geçen ortalar · son soru (soru sayısına göre).
  static String questionEncouragement(int index, int total) {
    if (index == 0) return 'Hadi başlayalım!';
    if (index == total - 1) return 'Son soru, neredeyse bitti!';
    return index >= total / 2 ? 'Yarısını geçtin, harika gidiyorsun!' : 'Güzel gidiyorsun, devam et!';
  }
  static const answerCorrect = 'Doğru!';
  static const answerWrong = 'Tekrar düşünelim';
  static const askHint = 'İpucu al';
  static const lessonCompleted = 'Tebrikler, dersi tamamladın.';
  static String scoreSummary(int correct, int total) =>
      "$total sorudan $correct'${_accusative(correct)} doğru yaptın";

  // Belirtme hâli eki: sıfırını, birini, ikisini, üçünü, dördünü, beşini, altısını, yedisini, sekizini, dokuzunu.
  static String _accusative(int n) =>
      const ['ını', 'ini', 'sini', 'ünü', 'ünü', 'ini', 'sını', 'sini', 'ini', 'unu'][n % 10];
  static const storyTapHint = 'Devam etmek için dokun →';
  static const storyBackToTask = 'Soruya Dön';

  // Sokratik Rehber (DESIGN.md §8.6)
  static const notUnderstood = 'Anlamadım';
  static const understood = 'Anladım';
  // Baloncuğun diğer cümleleri lessons/index.json → socraticMessages bölümünden gelir.

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
  static String peerSuggestion(String name) => 'Yardım edebilecek akran: $name (bu konuda başarılı)';
  static const matchPeer = 'Eşleştir';
  static String mockPeerNotified(String name) => "$name'a bildirim gönderildi (simülasyon)";
  static const detailTitle = 'Öğrenci detayı';
  static const detailEmpty = 'Ayrıntı için listeden bir öğrenci seç.';
  static String interactionSummary(int count, int idleSeconds) =>
      '$count etkileşim · $idleSeconds sn hareketsiz';
  static const styleDistributionTitle = 'Öğrenme stili dağılımı';

  // Bildirimler (DESIGN.md §8.9)
  static const notificationOk = 'Tamam';
  static String peerWillHelp(String peerName) => '$peerName sana bu konuda yardım edecek';
  static String peerAskedToHelp(String studentName) =>
      '$studentName bu konuda yardımına ihtiyaç duyuyor; öğretmenin sizi eşleştirdi';
}
