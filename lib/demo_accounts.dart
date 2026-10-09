// Demo hesapları ve demo sınıfı sabitleri (MEMORY K26, K37).
// Uydurma demo hesaplarıdır; gerçek kişi bilgisi içermez. Demo giriş butonları
// bu bilgileri istemcide kullandığı için web paketinde zaten görünürdür.

abstract final class DemoAccounts {
  static const password = 'demo1234';

  static const teacherEmail = 'demo.ogretmen@eduswarm.dev';
  static const teacherFirstName = 'Nur';
  static const teacherLastName = 'Demirtaş';

  static const studentEmail = 'demo.ogrenci@eduswarm.dev';
  static const studentFirstName = 'Ayşe';
  static const studentLastName = 'Yılmaz';
  static const studentLearningStyle = 'dyslexic';

  /// Demo sınıfı: 3 hazır ders ve 42 mock öğrenci yalnızca burada görünür (K52).
  static const classId = 'demo_class';
  static const className = 'Programlamaya Giriş';
  static const classCode = 'PTR234'; // 0/O ve 1/I içermez (TRD §3.1).

  static bool isDemoEmail(String? email) => email == teacherEmail || email == studentEmail;

  static bool isDemoClass(String classId) => classId == DemoAccounts.classId;
}
