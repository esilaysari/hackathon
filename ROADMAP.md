# ROADMAP.md — EduSwarm Yol Haritası

> **Kaynak:** INTENT.md (niyet/kapsam) · TRD.md (mimari/şema) · DESIGN.md (görsel sistem) · CLAUDE.md (davranış ilkeleri) · MEMORY.md (kararlar K1–K39)
> **Süre:** 2026-10-09 19:20 → 2026-10-10 06:30 (yemek ve molalar dahil; ~9 saat net çalışma)

Bu doküman geliştirme sürecinin **sırasını ve zamanlamasını** tanımlar. Ne yapılacağı INTENT.md'de, nasıl yapılacağı TRD.md'de, nasıl görüneceği DESIGN.md'de belirlenmiştir; burada yalnızca referans verilir. Çelişki durumunda CLAUDE.md §6 (Kaynak Hiyerarşisi) geçerlidir.

## 1. Yöntem: Faz Sıralaması Nasıl Belirlendi

Üç kritere göre sıralanmıştır; çakışmada üstteki kazanır:

1. **Demo önceliği (K13):** Altın Senaryo'nun ders anı (Morphing UI + Acil Müdahale + Sunum Modu) zaman yetmese bile sahnede gösterilebilmelidir. Bu yüzden önce o yazılır.
2. **Veri önceliği:** Öğretmen paneli ve PeerSwarm, 42 kişilik mock veri (K24, K38) ve Firestore bağlantısı (K31) olmadan çalışamaz; bu temel Faz 0'da atılır.
3. **Çekirdek döngü:** Bilişsel yük algılama → arayüzü otomatik sadeleştirme → öğretmene uyarı. Diğer her şey (Sokratik Rehber, PeerSwarm, kayıt, test) bu döngünün üzerine eklenir.

**Genel kurallar (her fazda geçerli):**

- Platform Flutter Web'dir (K6); başka ön yüz teknolojisine geçilmez.
- Bir faz, önceki fazları bozmadan, cerrahi değişikliklerle eklenir (CLAUDE.md §3.3).
- Bir faz, **Tamamlanma Kriteri** tarayıcıda doğrulanmadan bitmiş sayılmaz; `flutter analyze` temiz olmalıdır.
- Her faz sonunda: Claude İngilizce `tip: açıklama` biçiminde commit mesajı önerir, **commit'i kullanıcı atar** (K28); MEMORY.md'nin İlerleme Gözlemi, Devamlılık ve Yol Günlüğü bölümleri güncellenir.
- **04:30 kod dondurma:** Bu saatten sonra yeni özellik eklenmez; yalnızca demoyu bozan hatalar düzeltilir.

## 2. Faz Özeti ve Zaman Çizelgesi

| Saat | Faz | Odak | Bağımlılık | Karşılanan İhtiyaç (INTENT) |
| :--- | :--- | :--- | :--- | :--- |
| 19:20–20:00 | **0** | Altyapı, Firebase, mock veri, tasarım token'ları | — | Mimari hazırlık |
| 20:00–21:45 | **1–2** | Öğrenci: içerik + sorular, telemetri, Morphing UI, Story modu | Faz 0 | Başarı kriteri 5, 6, 7 |
| 21:45–22:30 | 🍽️ | Yemek molası | | |
| 22:30–00:15 | **3** | Öğretmen Paneli, Acil Müdahale, Sunum Modu (canlı) | Faz 0, 2 | Başarı kriteri 7, 8 |
| 00:15–01:30 | **4** | Sokratik Rehber + PeerSwarm (Kovan Bağlantısı) | Faz 2, 3 | Başarı kriteri 9, 10 |
| 01:30–02:00 | ☕ | Mola | | |
| 02:00–03:45 | **5** | Ürün akışı: giriş/kayıt, test, sınıf kodu, içerik + soru yükleme | Faz 0 | Başarı kriteri 1–4 |
| 03:45–04:30 | **6** | Yayın (Firebase Hosting) ve iki cihazla test | Tüm fazlar | Gerçek zamanlı iletişim (K19) |
| 04:30 | 🧊 | **Kod dondurma** | | |
| 04:30–06:30 | **7** | Altın Senaryo provası, yedek video, sunum, teslim (arada kısa mola) | Tüm fazlar | Hackathon başarısı |

## 3. Faz 0 — Altyapı ve Veri (19:20–20:00)

**Hedef:** Hiçbir ekran yazılmadan önce Flutter Web projesinin, Firebase bağlantısının, mock verinin ve tasarım token'larının hazır olması.

- **Teknik kapsam:**
  - Flutter Web projesi; TRD.md'deki paketler (firebase_core, cloud_firestore, firebase_auth, provider, shared_preferences, file_picker vb.).
  - `flutterfire configure` → `firebase_options.dart`; Firestore (europe-west3, test modu, K31) ve Authentication e-posta/şifre (K37) konsolda açık.
  - `assets/mock/mock_students.json` (42 öğrenci, K38) ve `assets/content/` klasörü pubspec.yaml'da tanımlı.
  - Roboto ve Lexend fontları projeye gömülü (K29).
  - `lib/theme/tokens.dart` (DESIGN.md'deki tüm token'lar ve eşik süreleri) ve `lib/strings.dart`.
  - Demo hesapları Auth'ta, demo sınıfı ve demo öğrenci (Dislektik, sınıfa kayıtlı, K26) Firestore'da hazır.
- **Tamamlanma kriteri:** Uygulama `flutter run -d chrome` ile Cream-Base zeminli boş ekranla açılıyor, Firebase hatasız başlıyor ve mock veri okunup konsola öğrenci sayısı (42) yazdırılabiliyor.

## 4. Faz 1–2 — Öğrenci Çekirdeği: Telemetri ve Morphing UI (20:00–21:45)

**Hedef:** Projenin inovasyon noktasını çalışır hâle getirmek: öğrenci tıkandığında arayüzün kendiliğinden sadeleşmesi.

- **Teknik kapsam:**
  - `assets/content/demo_lesson.json`: **C: Pointer'lar** dersi (K36) — içerik metni ve önceden doldurulmuş, Sözel/Görsel veya İşlem etiketli sorular (K16).
  - Ağır Görev / okuma ekranı ve soru ekranı (DESIGN.md §8.4); profil bazlı sunum (K18), Dislektik zemin (K27).
  - Telemetri: `Timer` + `Listener`; okuma ekranı 30 sn, Sözel/Görsel soru 30 sn, İşlem sorusu 60 sn, Sunum Modunda 5 sn (K7, K8, K16). Her etkileşim sayacı sıfırlar.
  - Üç seviyeli durum: Odakta → Dikkat (eşiğin yarısı) → Kritik (eşik) (K17). Dikkat öğrenci ekranını değiştirmez.
  - Kritik'te: 600ms Fade & Scale ile Story moduna geçiş, otomatik destek mesajı ("içeriği kolaylaştırdım", K22).
  - Story modu (DESIGN.md §8.5): kural tabanlı kartlara bölme, ilerleme çubuğu, son kartta "Soruya Dön" ve ters Morphing (K21).
  - "Basitleştir" butonu: Story'ye geçer ama uyarı üretmez (K23).
  - Bu fazda öğretmen bağlantısı henüz yoktur; Sunum Modu geçici olarak koddaki bir sabitle denenir.
- **Tamamlanma kriteri:** Demo dersini açıp hiçbir şeye dokunmadan beklediğimizde (test için 5 sn) arayüz pürüzsüz animasyonla Story moduna geçiyor; kartlar dokunarak ilerliyor; "Soruya Dön" ile geri dönülüyor; "Basitleştir" aynı geçişi elle yapıyor.

## 5. Faz 3 — Öğretmen Paneli ve Erken Uyarı (22:30–00:15)

**Hedef:** Kalabalık sınıfı yöneten öğretmenin, tüm sınıf yerine yalnızca zorlanan öğrencileri **anında** görmesi.

- **Teknik kapsam:**
  - Öğrenci durumu ve uyarılar Firestore'a yazılır, panel `snapshots()` ile canlı dinler (K31). Ham telemetri yazılmaz (K23).
  - Öğretmen Paneli (DESIGN.md §8.7): özet şeridi (toplam · Dikkat · Kritik), yalnızca Kritik öğrencilerin listesi (42 mock + gerçek öğrenciler birleşik, K32), öğrenme stili dağılımı, öğrenci seçilince yalnızca özet bilgi (K23).
  - Öğrenciler tam adla gösterilir, `id` ile eşleştirilir (K35).
  - "Acil Müdahale" kartı (§8.8): listenin en üstüne animasyonla girer, "Gördüm" ile kapanır.
  - **Sunum Modu anahtarı:** sınıf ayarı olarak Firestore'a yazılır; öğrenci cihazındaki eşik anında 5 sn'ye iner (K8, K29).
- **Tamamlanma kriteri:** Aynı bilgisayarda iki tarayıcı penceresi açıkken (biri öğretmen, biri demo öğrenci), öğretmen Sunum Modu'nu açıyor; öğrenci 5 sn hareketsiz kalınca öğrencinin ekranı Story'ye dönüşüyor ve **aynı anda** öğretmen panelinde Acil Müdahale kartı beliriyor. Sayaçlar "44 öğrenci · … kritik" gibi mock + gerçek toplamı gösteriyor.

## 6. Faz 4 — Sokratik Rehber ve PeerSwarm (Kovan Bağlantısı) (00:15–01:30)

**Hedef:** Sistemin yalnızca öğretmeni uyarmadığını, öğrenciyi düşünmeye yönlendirdiğini ve sınıfı (kovanı) bir destek ağı olarak kullandığını göstermek.

- **Teknik kapsam:**
  - `assets/content/socratic_hints.json`: `pointers` için soru başına 2-3 ipucu zinciri ve 3-4 şıklı kontrol sorusu.
  - Sokratik baloncuk (DESIGN.md §8.6): "Anlamadım" → sıradaki ipucu; ipuçları biterse akran desteği önerilir. "Anladım" → kontrol sorusu; doğruysa durum Odakta'ya döner ve otomatik tebrik mesajı gider, yanlışsa sıradaki ipucu (K20, K22).
  - PeerSwarm: o konuda `topicScores` en yüksek ve Odakta olan akran seçilir (demo: Pelin Turan, K36). Uyarı kartında öneri + "Eşleştir"; Eşleştir'e basılınca iki öğrenciye bildirim kartı gider (K22, DESIGN.md §8.9).
- **Tamamlanma kriteri:** Story modundaki öğrenci ipuçlarıyla ilerleyip kontrol sorusunu doğru cevaplayınca durumu Odakta'ya dönüyor ve paneldeki kritik sayısı azalıyor; öğretmen "Eşleştir"e basınca öğrenci ekranında akran bildirimi görünüyor.

## 7. Faz 5 — Ürün Akışı: Giriş, Test, Sınıf, İçerik (02:00–03:45)

**Hedef:** Demoyu "hazır hesap" yerine gerçek bir ürün akışıyla başlatabilmek.

- **Teknik kapsam:**
  - Giriş/Kayıt tek kartta iki sekme; kayıt: ad, soyad, e-posta, şifre, rol, zorunlu KVKK onayı; Firebase Auth (K14, K37). Demo giriş butonları.
  - Öğrenme stili testi (`assets/content/learning_style_test.json`, ekran başına tek soru); sonuç öğretmen paneline yansır.
  - Sınıf oluşturma, 6 haneli kod + davet linki, kodla katılma (DESIGN.md §8.3).
  - Ders gönderme: metin yapıştırma veya `.txt`/`.md` yükleme (K33) + soru ekleme formu ve Sözel/Görsel–İşlem etiketi (K16).
- **Tamamlanma kriteri:** Yeni bir öğrenci kayıt olup testi çözüyor, öğretmenin ekrandaki koduyla sınıfa katılıyor ve öğretmenin gönderdiği ders öğrencinin ekranında anında açılıyor.

## 8. Faz 6 — Yayın ve İki Cihaz Testi (03:45–04:30)

- **Teknik kapsam:** `flutter build web` + `firebase deploy --only hosting` (K39); telefon ve bilgisayarla gerçek ağ üzerinden test; salon interneti zayıfsa telefon hotspot'u ile deneme.
- **Tamamlanma kriteri:** Öğrenci **telefondan** canlı URL'yi açıyor, öğretmen bilgisayardan paneli açıyor; Altın Senaryo iki cihaz arasında baştan sona çalışıyor.

## 9. Faz 7 — Altın Senaryo Provası ve Teslim (04:30–06:30)

- **Kapsam:**
  - Sahne düzeni: öğretmen paneli projeksiyonda, öğrenci telefonu kameraya/jüriye gösteriliyor (ya da yedek olarak aynı ekranda iki pencere).
  - Altın Senaryo en az **3 kez** baştan sona prova; Sunum Modu'nun jüriye açıkça gösterilmesi (K8).
  - Ekran kaydıyla **yedek demo videosu**.
  - README, sunum slaytları ve konuşma metni; son commit ve push.
- **Tamamlanma kriteri:** Ekip, öğretmen panelinden dersi gönderip öğrenci ekranının şekil değiştirdiğini, öğretmene uyarının anında düştüğünü, Sokratik Rehber ve PeerSwarm'ı tek akışta kesintisiz gösterebiliyor.

## 10. Kesme Planı (Zaman Yetmezse)

| Durum | Ne kesilir |
| :--- | :--- |
| 21:45'te Faz 1–2 bitmedi | Profil farkları yalnızca Dislektik'e indirilir; "Soruya Dön" ters animasyonu sadeleştirilir. |
| 00:15'te Faz 3 bitmedi | Faz 5 tamamen kesilir; demo "Demo Öğrenci olarak gir" butonuyla ders anından başlar (K26). |
| 01:30'da Faz 4 bitmedi | Önce "Eşleştir" bildirimi kesilir (öneri yalnızca kartta görünür); sonra kontrol sorusu kesilir (Anladım doğrudan Odakta'ya döndürür). |
| 03:45'te Faz 5 bitmedi | Sırasıyla kesilir: dosya yükleme (yalnızca metin yapıştırma) → soru ekleme formu (demo sorular hazır gelir) → sınıf kodu (sabit demo sınıfı) → öğrenme stili testi (demo öğrenci sabit Dislektik). Giriş/Kayıt en son kesilir. |
| 04:30'da iki cihaz testi başarısız | Demo aynı bilgisayarda iki tarayıcı penceresiyle yapılır; yedek video hazır tutulur. |

## 11. Ekip İçinde Paralel Çalışma (birden fazla kişiyseniz)

- **Kişi 1 — Öğrenci tarafı:** Faz 1–2, sonra Sokratik baloncuk.
- **Kişi 2 — Öğretmen tarafı ve Firebase:** Faz 0'daki Firebase kurulumu, Faz 3, PeerSwarm.
- **Kişi 3 — İçerik ve sunum (kod gerektirmez):** Pointer dersi metni, sorular ve etiketleri, Sokratik ipuçları ve kontrol soruları, öğrenme stili test soruları, sunum slaytları ve konuşma metni. Ders ve ipucu içerikleri **21:00'e kadar** hazır olmalı.

Aynı dosyada aynı anda çalışmamak için herkes kendi `screens/` alt klasöründe çalışır; `tokens.dart` ve `strings.dart`'a ekleme yapmadan önce birbirinize haber verin.
