/// Uygulama adresleri. `/` giriş ve rol yönlendirmesi; diğerleri demo kısayolları (K42, K50).
abstract final class AppRoutes {
  static const home = '/';
  static const teacher = '/teacher'; // Demo öğretmen → panel
  static const student = '/student'; // Demo öğrenci → "Derslerim"
  static const studentDemo = '/student/demo'; // Demo öğrenci → doğrudan demo dersi (Altın Senaryo)
}
