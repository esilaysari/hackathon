// DESIGN.md'deki tüm tasarım token'ları. Widget'lar renk, boşluk, radius,
// gölge, tipografi ve süre değerlerini yalnızca buradan kullanır (CLAUDE.md §4.2).
import 'package:flutter/material.dart';

/// DESIGN.md §2 — Renk.
abstract final class AppColors {
  // 2.1 Yumuşak Lila — Birincil
  static const lilac100 = Color(0xFFE8DEF8);
  static const lilac300 = Color(0xFFD0BCFF);
  static const lilac500 = Color(0xFFC0A3E5); // Üzerinde beyaz metin kullanılmaz.
  static const lilac700 = Color(0xFF65558F); // Birincil buton zemini (beyaz metinle).

  // 2.1 Nane Yeşili — İkincil
  static const mint300 = Color(0xFFC8F0E1);
  static const mint500 = Color(0xFFA8E6CF);

  // 2.1 Krem — Arka Plan
  static const creamBase = Color(0xFFFDFBF7); // Scaffold; Dislektik profilde kartlar da bu renk.
  static const creamSurface = Color(0xFFFFFFFF); // Kart yüzeyleri.

  // 2.1 Antrasit / Gri — Nötr Metin
  static const grey900 = Color(0xFF1C1B1F);
  static const grey600 = Color(0xFF49454F);
  static const grey400 = Color(0xFFCAC4D0); // Yalnızca dekoratif; okunması gereken metinde kullanılmaz.

  // 2.2 Semantik ve Uyarı
  static const warning = Color(0xFFFFB347); // Üzerindeki metin grey900.
  static const warningSoft = Color(0xFFFFE4C2);
  static const success = Color(0xFF2E7D32); // Üzerindeki metin onDark.

  // 2.3 Onaylı eşleşmelerdeki "beyaz" metin (Lilac-700 ve Success zemin üzerinde).
  static const onDark = Color(0xFFFFFFFF);

  /// Story modu kartı zemini: Lilac-500 → Mint-500, metin grey900.
  static const storyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lilac500, mint500],
  );
}

/// DESIGN.md §3 — Tipografi.
abstract final class AppFonts {
  static const roboto = 'Roboto';
  static const lexend = 'Lexend'; // Dislektik mod.
  static const mono = 'RobotoMono'; // Kod kutuları ve satır içi kod.
}

abstract final class AppTextStyles {
  static const storyDisplay = TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.grey900);
  static const taskTitle = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.grey900);
  static const dashboardNumber = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.grey900);
  static const appBarTitle = TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.grey900);
  static const subheading = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.grey900);
  static const bodyLg = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.grey900);
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const caption = TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.grey600);

  /// Story kartında başlığın altındaki alt başlık.
  static const storySubtitle = TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.grey900);

  /// Kod kutusu (Lilac-100 zemin): metinden küçük, monospace, satırlar korunur.
  static const code = TextStyle(fontFamily: AppFonts.mono, fontSize: 14, height: 1.5, color: AppColors.grey900);
  static const storyCode = TextStyle(fontFamily: AppFonts.mono, fontSize: 20, height: 1.4, color: AppColors.grey900);
}

/// DESIGN.md §3.2 — Profil bazlı gövde metni kuralları.
abstract final class ProfileTypography {
  static const textualLineHeight = 1.5;

  static const dyslexicFontSize = 18.0;
  static const dyslexicLineHeight = 1.8;
  static const dyslexicLetterSpacing = 0.5;
  static const dyslexicMaxParagraphLines = 4;
}

/// DESIGN.md §4 — Düzen ve boşluk.
abstract final class AppSpacing {
  static const sm = 10.0; // Başlık ile açıklama arası.
  static const md = 20.0; // Kart içi, elementler arası standart.
  static const lg = 24.0; // Mobil ekran sağ/sol kenar boşluğu.
  static const xl = 40.0; // Bölümler arası, kart iç dolgusu.
}

abstract final class AppLayout {
  static const tabletBreakpoint = 600.0; // < 600 mobil.
  static const desktopBreakpoint = 1024.0; // 600–1023 tablet, ≥ 1024 masaüstü.
  static const studentMaxWidth = 480.0; // Öğrenci Portalı ortalanmış sütun.
  static const storyProgressHeight = 4.0;
  static const storyProgressGap = 4.0; // Story ilerleme çubukları arası ince boşluk.
  static const storyCardHeightFactor = 0.5; // Story kartı en az ekran yüksekliğinin yarısı.
  static const figureMaxHeight = 220.0; // Okuma ekranı şeması (Görsel profilde sınır yok, tam genişlik).
}

/// DESIGN.md §5 — Köşe yarıçapı.
abstract final class AppRadius {
  static const sm = 2.0; // Story ilerleme çubukları.
  static const md = 20.0; // Butonlar, input'lar, test şıkları.
  static const lg = 30.0; // Ağır Görev kartı, öğretmen paneli kartları.
  static const xl = 40.0; // Story modu ana kartı.
}

/// DESIGN.md §6 — Yükseklik ve gölge.
abstract final class AppShadows {
  static const light = [
    BoxShadow(offset: Offset(0, 10), blurRadius: 20, color: Color(0x0D000000)), // rgba(0,0,0,0.05)
  ];
  static const colored = [
    BoxShadow(offset: Offset(0, 15), blurRadius: 30, color: Color(0x4DC0A3E5)), // rgba(192,163,229,0.3)
  ];
  static const warning = [
    BoxShadow(offset: Offset(0, 10), blurRadius: 24, color: Color(0x59FFB347)), // rgba(255,179,71,0.35)
  ];
}

/// DESIGN.md §7 — Hareket ve animasyon süreleri.
abstract final class AppDurations {
  static const morphing = Duration(milliseconds: 600); // Ters Morphing de aynı süre.
  static const storyCardSwitch = Duration(milliseconds: 300);
  static const teacherAlertSlideIn = Duration(milliseconds: 400);
  static const socraticBubble = Duration(milliseconds: 250);
  static const studentNotification = Duration(milliseconds: 300);
  static const notificationVisible = Duration(seconds: 5); // Bildirim kartı ekranda kalma süresi.
  static const socraticSolvedVisible = Duration(seconds: 3); // Çözüldü mesajı, sonra baloncuk kapanır.

  /// Morphing'de ekranın küçüldüğü / büyümeye başladığı ölçek.
  static const morphScaleBegin = 0.85;

  /// Acil Müdahale kartının girişten sonraki tek "nabız" büyümesi (1.0 → 1.03 → 1.0).
  static const alertPulseScale = 1.03;
}

/// Odak kaybı eşikleri (CLAUDE.md §4.1, MEMORY K7, K8, K16). Dikkat = eşiğin yarısı (K17).
abstract final class AppThresholds {
  static const reading = Duration(seconds: 30);
  static const verbalVisual = Duration(seconds: 30);
  static const computational = Duration(seconds: 60);
  static const presentationMode = Duration(seconds: 5);
}
