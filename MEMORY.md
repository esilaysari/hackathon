# EduSwarm — Proje Yol Günlüğü (MEMORY.md)

**Nasıl kullanılır (her ajan ve ekip üyesi için):**

- Yeni bir oturuma başlarken önce bu dosyayı, özellikle **1. Devamlılık** bölümünü oku.
- Bir görev veya milestone bittiğinde **5. Yol Günlüğü**'ne tarihli ve saatli, kısa bir giriş ekle.
- Teknik veya ürünsel bir karar alındığında **3. Karar Defteri**'ne bir satır ekle. Buraya yazılan bir karar tekrar tartışılmaz. Yeni bilgiyle geçersiz olursa eski satır silinmez; **İPTAL** etiketiyle işaretlenir ve yerine geçen kararın numarası yazılır.
- Bir hata, eksik ya da geçici çözüm fark edildiğinde **4. Bilinen Sorunlar** tablosuna ekle; çözülünce durumunu güncelle.
- Oturumu bitirmeden **1. Devamlılık**'ı güncelle: şu an neredeyiz, sıradaki adım ne, bekleyen bir karar var mı.
- Bu dosya **append-only**'dir: geçmiş kayıtlar düzenlenmez, yalnızca üstüne eklenir. İstisna: 1. Devamlılık, 2. İlerleme Gözlemi ve 4. Bilinen Sorunlar her zaman güncel hâlde tutulur.
- Tarih formatı: `YYYY-MM-DD HH:MM` (hackathon 24 saat sürdüğü için saat de yazılır).
- Bu dosya ile INTENT.md veya DESIGN.md çelişirse **INTENT.md ve DESIGN.md esas alınır**; çelişki 4. Bilinen Sorunlar'a yazılır.
- İlgili dosyalar: `INTENT.md` (niyet ve kapsam), `DESIGN.md` (tasarım sözleşmesi), `CLAUDE.md` (ajan kuralları), `TRD.md` (teknik gereksinimler), `ROADMAP.md` (görev planı).

## 1. Devamlılık — Şu An Neredeyiz

**Son güncelleme:** 2026-10-10 00:20

**Tamamlanan:** INTENT.md, DESIGN.md, CLAUDE.md, TRD.md ve bu dosya birbiriyle hizalandı (K14–K39). `mock_students.json` K24'e göre uyarlandı (42 öğrenci, K38). Proje klasöründe henüz uygulama kodu yok.

**Sıradaki adım:** Kullanıcı Faz 5a + 5b'yi tarayıcıda doğrulayacak (sınıf oluştur/katıl, metin/PDF/PPTX ile ders gönder). Ardından Altın Senaryo provası. DESIGN §8.1–8.3 ve TRD §3.1/§4.4/T6 güncellemeleri sonda toplu yapılacak (Yol Günlüğü notlarına bak).

**Bekleyen kararlar:** Yok — veri saklama, anlık iletişim, durum yönetimi ve içerik yükleme TRD.md ile karara bağlandı (K31–K34).

**Blokaj:** Yok. Flutter 3.47.7 kurulu ve Flutter Web projesi oluşturuldu (K30 karşılandı); `flutter analyze` temiz.

## 2. İlerleme Gözlemi

| Aşama | Dosya / Çıktı | Durum |
| :--- | :--- | :--- |
| Niyet ve Bağlam | INTENT.md | ✅ Tamamlandı — 2026-10-09 |
| Tasarım Sözleşmesi | DESIGN.md | ✅ Tamamlandı — 2026-10-09 |
| Proje Belleği | MEMORY.md | ✅ Bu dosya — 2026-10-09 |
| Mock Veri Seti (42 öğrenci, K24) | mock_students.json | ✅ Uyarlandı — 2026-10-09 (K38) |
| Proje Kuralları | CLAUDE.md | ✅ Tamamlandı — 2026-10-09 |
| Teknik Gereksinimler | TRD.md | ✅ Tamamlandı — 2026-10-09 |
| Görev Planı | ROADMAP.md | ✅ Tamamlandı — 2026-10-09 |
| Ajan Kural Dosyaları | .claude/rules/ | ⬜ Başlanmadı |
| Git deposu ve GitHub | github.com/esilaysari/hackathon | ✅ Kuruldu (commit'leri kullanıcı atar, K28) |
| Öğrenci Portalı: Ağır Görev + Morphing + Story | lib/screens/student/, lib/widgets/ | ✅ Tamamlandı — 2026-10-09 (tarayıcıda doğrulandı) |
| Öğretmen Paneli: kritik liste + Acil Müdahale + Sunum Modu | lib/screens/teacher/, lib/widgets/teacher/ | ✅ Tamamlandı — 2026-10-09 (iki pencereyle doğrulandı) |
| Sokratik Rehber + PeerSwarm önerisi | lib/widgets/socratic_bubble.dart, lib/services/socratic_session.dart | ✅ Tamamlandı — 2026-10-09 |
| Hazır dersler (3) + "Derslerim" + şemalar | assets/content/lessons/, lib/screens/student/my_lessons_screen.dart | 🔄 Kod tamam, 32 test geçiyor; kullanıcının tarayıcı testi bekleniyor |
| Kayıt, öğrenme stili testi, sınıf kodu, içerik yükleme | lib/screens/auth_screen.dart, home_gate.dart, student/learning_style_test_screen.dart | 🔄 Faz 5a + 5b kod tamam (51 test); tarayıcı testi kullanıcıda |
| Sunum provası (Altın Senaryo) | — | ⬜ Başlanmadı |

## 3. Karar Defteri

| # | Tarih | Karar | Gerekçe |
| :--- | :--- | :--- | :--- |
| K1 | 2026-10-09 | **Ana Odak (Morphing UI):** Sistem, öğrencinin odak kaybını telemetriyle tespit edip arayüzü anlık olarak değiştiren bir bilişsel yük yönetimi platformu olacak. | Standart "YZ ile cevap veren" uygulamalardan farklılaşmak ve jüriye yenilikçi bir UX sunmak. |
| K2 | 2026-10-09 | **İsim:** Proje adı "BiteSync" yerine "EduSwarm" olarak sabitlendi. | Kalabalık sınıf (swarm) yönetimi vizyonunu yansıtmak. |
| K3 | 2026-10-09 | ~~**Telemetri:** 10 saniyelik hareketsizlik ve "rage tap" gibi basit etkileşimler stres belirtisi sayılacak.~~ **İPTAL → K7, K8** | Eşik süreleri değişti; "rage tap" INTENT'te kapsam dışına alındı. |
| K4 | 2026-10-09 | ~~**Veri Stratejisi:** 40 kişilik statik JSON tabanlı mock veri kullanılacak; öğrencilerin yaklaşık %20'si "Kritik" durumda olacak. Öğretmen panelinde yalnızca Kritik öğrenciler listelenecek.~~ **İPTAL → K24** | Kalabalık sınıf yönetimini canlı demoda göstermek. |
| K5 | 2026-10-09 | ~~**Geliştirme:** v0.dev veya Lovable gibi araçlarla PWA/Web App arayüzleri üretilecek.~~ **İPTAL → K6** | Bu araçlar React tabanlı kod üretir; Flutter Web kararıyla uyumsuz. |
| K6 | 2026-10-09 | **Platform:** Flutter Web; tek kod tabanı, mobil uyumlu. Öğrenci Portalı mobil öncelikli, Öğretmen Paneli masaüstü öncelikli. Kod, VS Code'da Claude ile, doküman zinciri (INTENT → DESIGN → MEMORY → CLAUDE → TRD → ROADMAP) izlenerek yazılacak. | Tek kodla hem telefon hem bilgisayar desteği; native uygulama kapsam dışı. |
| K7 | 2026-10-09 | **Odak kaybı eşikleri:** Sözel/görsel sorularda 30 sn, işlem gerektiren sorularda 60 sn hareketsizlik. Telemetri yalnızca zamanlayıcı ve basit tıklama sayacından oluşur. | Soru tipine göre gerçekçi düşünme süresi tanımak. |
| K8 | 2026-10-09 | **Sunum Modu:** Öğretmen panelindeki anahtar açıkken tüm eşikler 5 sn'ye iner. Jüriye açıkça gösterilir. | Sahnede jüriyi 30 sn bekletmemek. |
| K9 | 2026-10-09 | **Yapay zekâ simülasyonu:** Gerçek LLM API'si kullanılmayacak. İçerik, profillere göre kural tabanlı uyarlanacak; Sokratik Rehber soruları önceden hazırlanmış mock veriden gelecek. | API maliyeti, bağlantı ve sahnede öngörülemeyen cevap riski. |
| K10 | 2026-10-09 | ~~**Kullanıcı akışı:** Ad/soyad/e-posta + rol ile kayıt (KVKK onayıyla), kısa öğrenme stili testi, 6 haneli sınıf kodu / davet linki, öğretmenin kendi notunu yüklemesi. E-posta doğrulama ve şifre sıfırlama yok; demo için hazır hesaplar bulunacak.~~ **İPTAL → K14** | Gerçekçi bir ürün akışı göstermek, ama 24 saate sığacak sadelikte. |
| K11 | 2026-10-09 | **Erişilebilirlik:** Tüm metin/zemin eşleşmeleri en az WCAG AA (4.5:1). Dislektik modda Lexend yazı tipi, 18px gövde, 1.8 satır yüksekliği, yalnızca sola hizalı metin. | Erişilebilirlik projenin ana fikri; jüri bunu sorgulayabilir. |
| K12 | 2026-10-09 | ~~**Gizlilik:** Öğrenci "Basitleştir"e kendisi basarsa öğretmene uyarı gitmez. Öğretmen panelinde ham telemetri gösterilmez, yalnızca "destek gerekiyor" özeti görünür.~~ **İPTAL → K23** | "Öğrenciyi aşırı izleme" algısını önlemek; öğrenci kontrolünü korumak. |
| K13 | 2026-10-09 | **Önceliklendirme:** Önce Altın Senaryo'nun ders anı (Morphing UI + Acil Müdahale + Sunum Modu), sonra Sokratik Rehber ve PeerSwarm, en son kayıt/test/sınıf ekranları. | Zaman yetmezse bile en etkileyici kısmın hazır olması. |
| K14 | 2026-10-09 | **Kullanıcı akışı (güncel):** Giriş/Kayıt tek kartta iki sekme. Kayıt: ad, soyad, e-posta, **şifre**, rol + KVKK onayı; giriş e-posta + şifre. Kısa öğrenme stili testi, 6 haneli sınıf kodu / davet linki. E-posta doğrulama ve şifre sıfırlama yok; demo için hazır hesaplar ve demo giriş butonları bulunur. | K10'a şifre eklendi; giriş ile kayıt ayrıldı. |
| K15 | 2026-10-09 | ~~**İçerik formatı:** Öğretmen PDF veya Metin/Markdown yükler. PPTX doğrudan işlenmez; slaytlar PDF olarak yüklenir.~~ **İPTAL → K33** | Kural tabanlı kartlara bölme için okunabilir metin gerekir; PPTX ayrıştırma 24 saat için riskli. |
| K16 | 2026-10-09 | **Sorular ve etiketler:** Öğretmen, yüklemenin altındaki formla soru (metin, 3-4 şık, doğru cevap) ekler ve her soruyu "Sözel/Görsel" (30 sn) ya da "İşlem" (60 sn) olarak etiketler. Öğrenci akışı: önce içerik okunur (okuma ekranı eşiği 30 sn), "Hemen Başla" ile sorulara geçilir. Demo dersinde sorular önceden doldurulmuş gelir. | K7'deki soru tipine bağlı eşiğin kaynağını netleştirmek. |
| K17 | 2026-10-09 | **Üç seviyeli odak durumu:** Odakta / Dikkat (eşiğin yarısı aşıldı) / Kritik (eşik aşıldı). Dikkat yalnızca öğretmen panelinin özet şeridinde sayaç olarak görünür; öğrenci ekranında değişiklik yapmaz. Morphing, otomatik mesaj ve Acil Müdahale yalnızca Kritik'te tetiklenir. Herhangi bir etkileşim sayacı sıfırlar. | Öğretmene sınıfın genel nabzını göstermek; öğrenciyi erken rahatsız etmemek. |
| K18 | 2026-10-09 | **Profil bazlı sunum:** Dislektik (Lexend, 18px, 1.8 satır yüksekliği), Görsel (kart düzeni, ikonlar, görseller önde), Metinsel (klasik başlıklı okuma) — hepsi kural tabanlı. | Üç profil için de görünür fark; ayrı şablon maliyetinden kaçınmak. |
| K19 | 2026-10-09 | **Gerçek zamanlı iletişim:** Ders içeriği öğrencilere, uyarılar öğretmen paneline anlık ulaşır; demo iki ayrı cihazda yapılır (öğretmen laptop, öğrenci telefon). Altyapı TRD.md'de seçilecek. | "Anında" uyarı vaadinin sahnede inandırıcı olması. |
| K20 | 2026-10-09 | **Sokratik Rehber:** Her soru için 2-3 ipucundan oluşan zincir. Butonlar "Anladım" / "Anlamadım". Anlamadım → sıradaki ipucu; ipuçları biterse akran desteği önerilir. Anladım → 3-4 şıklı kontrol sorusu; doğruysa durum Odakta'ya döner, yanlışsa sıradaki ipucu. | Öğrencinin "anladım" beyanını doğrulamak; doğrudan cevap vermemek. |
| K21 | 2026-10-09 | **Story sonu:** Son kartta "Soruya Dön"; öğrenci takıldığı ekrana döner, sayaç sıfırlanır, Morphing ters yönde oynar. | Story modunun çıkmaz sokak olmaması. |
| K22 | 2026-10-09 | **PeerSwarm ve öğretmen eylemleri:** Mock öğrencilerin konu bazlı başarı skoru vardır; o konuda skoru en yüksek ve durumu Odakta olan akran önerilir. Uyarı kartında "Eşleştir" (iki öğrenciye bildirim kartı gider) ve "Gördüm" bulunur. Öğretmen elle mesaj yazmaz; destek mesajlarını **sistem otomatik** gönderir: Morphing anında ("içeriği kolaylaştırdım") ve kontrol sorusu doğru cevaplandığında (tebrik). | Öğretmenin 40+ kişilik sınıfta tek tek mesaj yazacak vakti yok; destek otomatik olmalı. |
| K23 | 2026-10-09 | **Gizlilik (güncel):** Öğrenci "Basitleştir"e kendisi basarsa öğretmene uyarı gitmez. Ham telemetri (tek tek tıklamalar, zaman damgaları) hiçbir yerde gösterilmez; öğretmen bir öğrenciyi seçtiğinde yalnızca özet görünür (ör. "12 etkileşim · 45 sn hareketsiz"). Tıklama sayısı bu sürümde karar mantığını etkilemez. | K12'yi INTENT'teki "tıklama sayısı kaydedilir" kararıyla uzlaştırmak. |
| K24 | 2026-10-09 | **Mock veri dağılımı:** 42 mock öğrenci; başlangıçta yaklaşık 2 Kritik, 5 Dikkat, kalanı Odakta. Her öğrencide profil, konu, odak durumu, takılma süresi ve konu bazlı başarı skoru (PeerSwarm) bulunur. | Gerçek öğrencinin uyarı kartının kalabalıkta kaybolmaması; DESIGN 8.7 örneğiyle uyum. |
| K25 | 2026-10-09 | ~~**Eski denemeler:** `main.dart` ve `mock_students.json` kullanılmayacak; kod ve mock veri güncel dokümanlara göre sıfırdan yazılacak.~~ **İPTAL → K38** | İkisi de eski kararlarla yazılmıştı ve proje klasöründe yok. |
| K26 | 2026-10-09 | **Demo yedek planı (K13 eki):** Kayıt/test/sınıf ekranları yetişmezse demo, "Demo Öğrenci olarak gir" butonuyla açılan hazır hesapla (profil Dislektik, sınıfa kayıtlı) doğrudan ders anından başlar. | K13 önceliği korunurken Altın Senaryo'nun her koşulda gösterilebilmesi. |
| K27 | 2026-10-09 | **Dislektik zemin:** Dislektik profilde kart yüzeyleri dahil saf beyaz kullanılmaz; kartlar Cream-Base zeminli olur ve gölgeyle ayrışır. | DESIGN §3.2 ile §8.4 arasındaki çelişkiyi gidermek; parlak beyazın göz yorgunluğundan kaçınmak. |
| K28 | 2026-10-09 | **Git akışı:** Commit'leri kullanıcı atar; Claude commit/push çalıştırmaz, özellik bitince İngilizce `tip: açıklama` biçiminde mesaj önerir (ör. `feat: ...`, `docs: ...`). | Mevcut commit geçmişiyle tutarlılık; kullanıcı kontrolü. |
| K29 | 2026-10-09 | **Fontlar ve Sunum Modu:** Roboto ve Lexend projeye gömülür (çalışma anında indirme yok). Sunum Modu sınıfın bir ayarıdır; gerçek zamanlı kanalla tüm öğrenci cihazlarına yayılır. | Salon Wi-Fi'sına bağımlı kalmamak; eşik öğrencinin cihazında sayıldığı için ayarın oraya ulaşması gerekir. |
| K30 | 2026-10-09 | **Geliştirme ortamı:** Flutter SDK geliştirme bilgisayarına kurulup PATH'e eklenecek; Claude `flutter analyze` ve tarayıcı denemesi yapamazsa bunu açıkça söyler. | CLAUDE.md §3.4 doğrulama kuralının uygulanabilmesi. |
| K31 | 2026-10-09 | **Veri ve anlık iletişim:** Cloud Firestore (Spark planı), bölge europe-west3, güvenlik kuralları test modu. Ders gönderimi, uyarılar, durum geçişleri, bildirimler ve Sunum Modu `snapshots()` ile canlı iletilir (TRD T2). | Farklı cihazlar arasında sunucu kodu yazmadan gerçek zamanlı iletişim; K19'un altyapısı. |
| K32 | 2026-10-09 | **Hibrit veri:** Gerçek kullanıcılar Firestore'da; 42 mock öğrenci ve statik içerik (test, demo dersi, ipuçları, destek mesajları) yerel JSON'da. Panel iki kaynağı tek listede birleştirir (TRD T3, T4). | Mock veri sahnede bozulmasın; canlı akış yalnızca gerçek öğrenci için. |
| K33 | 2026-10-09 | **İçerik yükleme:** Yapıştırılan metin veya `.txt` / `.md`; içerik metin olarak Firestore'da saklanır. PDF ve slayt görseli zaman kalırsa (TRD T6). | Firebase Storage kurulumu ve PDF ayrıştırma 24 saate değmez; metin Story kartlarına bölünebilen tek format. K15'in yerini alır. |
| K34 | 2026-10-09 | **Durum yönetimi:** Firestore verisi için `StreamBuilder`, giriş yapan kullanıcı ve aktif sınıf için `provider` + `ChangeNotifier` (TRD T7). | Önce Basitlik; ek mimari öğrenme yükü yok. |
| K35 | 2026-10-09 | **Kimlik ve isimler:** Öğretmen panelinde öğrencinin tam adı gösterilir; aynı ad varsa e-postanın `@` öncesi (mock'ta `id`) küçük etiketle eklenir. Sistem öğrencileri yalnızca `id` ile ayırt eder (uyarı, durum, PeerSwarm). | Öğretmen kime yardım edeceğini bilmeli; isim çakışması eşleştirmeyi bozmamalı. |
| K36 | 2026-10-09 | **Demo dersi konusu:** "C: Pointer'lar" (`topicKey: pointers`). Sokratik zincir ve kontrol sorusu bu konu için hazırlanır; PeerSwarm önerisi Pelin Turan (pointers skoru 98). | Mock verideki konu sözlüğüyle eşleşmeli; PeerSwarm önerisi boş kalmamalı. |
| K37 | 2026-10-09 | **Kimlik doğrulama:** Firebase Authentication, e-posta + şifre sağlayıcısı. Şifre Firestore'a yazılmaz; demo hesapları Auth'ta önceden oluşturulur (TRD T5). | K14 şifre istiyor; test modundaki açık Firestore'da şifre saklamak güvenli değil. TRD'nin eski "şifresiz" T5 maddesinin yerini alır. |
| K38 | 2026-10-09 | **Mock veri uyarlaması:** Ekipten gelen `mock_students.json` sıfırdan yazılmak yerine uyarlandı: 42 kayıt (14/14/14 profil), `status`: `focused` / `attention` / `critical` (2 kritik, 5 dikkat), `completedTopics` yerine `topicScores` (0-100). | Mevcut dosya sağlamdı; yalnızca K17, K22 ve K24'e uyum gerekiyordu. K25'in yerini alır. |
| K39 | 2026-10-09 | **Yayın:** `flutter build web` + Firebase Hosting (TRD T8). | Öğrenci telefonu gerçek bir URL'den açar; ayrı sunucu yok. |
| K40 | 2026-10-09 | **Zaman planı:** Geliştirme ROADMAP.md'deki faz sırasına göre yürür (Faz 0–7, 2026-10-09 19:20 → 2026-10-10 06:30). **04:30 kod dondurma:** bu saatten sonra yeni özellik eklenmez, yalnızca demoyu bozan hatalar düzeltilir. **HSD Bounty pop-up'ı kapsam dışıdır;** akran desteği için yerine PeerSwarm "Eşleştir" (K22) kullanılır. | Sunum öncesi en az 2 saat prova ve teslim payı bırakmak; aynı ihtiyacı karşılayan iki özellik yazmamak. |
| K41 | 2026-10-09 | **Demo kimlikleri:** Firebase projesi `eduswarm-985b9`. Demo öğretmen "Nur Demirtaş" (demo.ogretmen@eduswarm.dev), demo öğrenci "Ayşe Yılmaz" (demo.ogrenci@eduswarm.dev, Dislektik), demo sınıfı `classes/demo_class` "Programlamaya Giriş", kod `PTR234`. E-postalar ve ortak demo şifresi yalnızca `lib/demo_accounts.dart`'ta tutulur; demo verisi `lib/seed.dart` ile yazılır. | Uydurma isimler mock veriyle çakışmaz; DESIGN §8.8 örneğindeki "Ayşe Yılmaz" ile uyumlu. Şifre tek yerde, sunumdan sonra değiştirilebilir. |
| K42 | 2026-10-09 | **Geçici demo adresleri:** Faz 5'teki Giriş/Kayıt'a kadar `/#/teacher` demo öğretmen, `/#/student` demo öğrenci hesabıyla otomatik giriş yapar; `/` iki role bağlantı verir. Firebase Auth oturumu sekmeye özeldir (`Persistence.SESSION`). | İki rolü aynı tarayıcıda iki pencerede test edebilmek; varsayılan (LOCAL) kalıcılıkta oturum sekmeler arasında paylaşıldığı için iki pencere aynı hesaba düşerdi. |
| K43 | 2026-10-09 | **Öğrenci → Firestore:** Her durum geçişinde `members/{uid}.status` yazılır; Kritik'te ayrıca `stuckSince`, `interactionCount`, `idleSeconds` (özet). Uyarı id'si `{uid}_{topicKey}`: bir derste en fazla bir açık uyarı. "Basitleştir" hiçbir şey yazmaz. Sunum Modu sınıf belgesinden canlı okunur, değişince sayaç yeni eşikle yeniden başlar. Profil `users/{uid}.learningStyle`'dan okunur; `DevConfig.learningStyleOverride` (varsayılan null) test için kalır. | K17, K23, K29'un teknik karşılığı; uyarı yağmurunu önlemek için sorgu yerine deterministik belge id'si. |
| K44 | 2026-10-09 | **K34 ertelendi:** `provider` bu fazda kullanılmadı; rolü adres, uid'yi giriş katmanı veriyor. Giriş yapan kullanıcı ve aktif sınıf için `provider` Faz 5'teki Giriş/Kayıt ile eklenecek. Firestore verisi için `StreamBuilder` kullanılıyor. | Faz 3'te paylaşılacak uygulama durumu yok; gereksiz katmandan kaçınmak (Önce Basitlik). |
| K45 | 2026-10-09 | **Soru ekranı akışı:** şık seç → "Kontrol Et" → "Doğru!" (Mint-300) / "Tekrar düşünelim" (Warning-Soft) → "İleri". Yanlışta doğru cevap gösterilmez; "İpucu al" o sorunun Sokratik zincirini açar ve öğretmene uyarı üretmez. Bitiş özeti ilk denemelere göre. Üstte ilerleme çubuğu ve aşamaya göre sakin bir destek cümlesi. | Öğrenciyi cevaba değil düşünmeye yönlendirmek; tekrar denemeye izin verirken skoru dürüst tutmak. |
| K46 | 2026-10-09 | **Sokratik zincirler soru başına:** `socratic_hints.json` anahtarları `reading` + soru id'leri; zincir takılınan ekrana göre seçilir. İpuçları bitince baloncuk yalnızca bilgi verir ("öğretmenin seni eşleştirebilir"), Firestore'a yazmaz. Story'de kontrol sorusu doğruysa ve Kritik'ten gelindiyse durum Odakta + `topicScores` +10. | K20'nin "her soru için" ifadesiyle uyum; okuma ekranında takılan öğrenciye de zincir sunmak. TRD'deki "konu başına zincir" ifadesinin yerini alır. |
| K47 | 2026-10-09 | **PeerSwarm panelde hesaplanır:** öneri `ClassOverview.suggestPeer` ile canlı seçilir (Odakta, takılan öğrenci değil, skoru en yüksek, eşitlikte gerçek önce); uyarı belgesine `suggestedPeer` yazılmaz. "Eşleştir" tek batch: uyarı kapanır, öğrenciye (ve gerçekse akrana) `notifications`; mock akran için yalnızca simülasyon (SnackBar + konsol). | Öneri her zaman güncel veriyle seçilsin; mock öğrencilerin cihazı yok. |
| K48 | 2026-10-09 | **Canlı süre:** Panel saniyede bir yeniden çizilir. Takılma süresi = şimdi − `stuckSince` + `idleSeconds` (uyarıda `createdAt` + `idleSeconds`); ilk anda "0 sn" yerine eşik süresi görünür (Sunum Modunda 5 sn, normalde 30/60 sn). Mock süreler panel açıldıktan sonra akar. Saat farkından doğan negatif süre sıfırlanır. | Öğretmenin öğrencinin gerçekte ne kadar süredir zorlandığını görmesi. |
| K49 | 2026-10-09 | **El yapımı içerik ve kod gösterimi:** Kullanıcı `demo_lesson.json` ve `socratic_hints.json`'u elle güncelledi; kod içeriğe uyarlandı, içerik değiştirilmedi. `storyCards` varsa Story bunları kullanır (subtitle, code), yoksa kural tabanlı bölme. `code` alanları Lilac-100 kod kutusunda, gömülü Roboto Mono ile (14px / Story 20px); `optionsAreCode` şık başına liste; ipuçlarındaki ters tırnaklar satır içi monospace. Sokratik baloncuk metinleri `messages`'tan; çözülünce "solved" + "solvedNext" 3 sn görünür, baloncuk kapanır, Story'de "Soruya Dön" hemen görünür. Ayrı tebrik bildirim kartı kaldırıldı (aynı mesaj iki kez çıkmasın). | Kod örneklerinin okunabilirliği; içerik ekibinin metinleri koda dokunmadan düzenleyebilmesi. |
| K50 | 2026-10-09 | **Hazır dersler ve "Derslerim":** İçerik `assets/content/lessons/` altında: `index.json` (ders listesi, `socraticMessages`, `defaultSocratic`, `demoLessonKey: pointers`) + ders başına dosya (içerik, `figures`, `storyCards`, 5 soru, `socratic`). `demo_lesson.json` ve `socratic_hints.json` taşındı ve silindi. Öğrenci `/#/student`'ta "Derslerim"i görür (hazır dersler + öğretmenin Firestore dersleri birleşik, öğretmeninkiler üstte, sayı sabit değil); `/#/student/demo` doğrudan demo dersini açar. Seçilen dersin topicKey/başlığı durum, uyarı ve PeerSwarm'da kullanılır. Konuya özel zinciri olmayan derslerde `index.json`'daki genel üst-bilişsel zincir (kontrol sorusu yok → "Anladım" doğrudan Odakta). Şemalar ilgili paragrafın altında; Görsel profilde tam genişlik ve öne çıkarılmış, diğerlerinde en fazla 220px; alt metinler yalnızca ekran okuyucuya. Aşama cümleleri soru sayısına göre (ilk · yarıdan önce "Güzel gidiyorsun, devam et!" · yarıdan sonra · son). | Birden fazla ders ve öğretmen içeriği için ölçeklenebilir yapı; Altın Senaryo kısayolu korunur; şemalar zaten açıklama içerdiği için alt metin ekranı kalabalıklaştırmaz. |

## 4. Bilinen Sorunlar ve Teknik Borç

| # | Tarih | Sorun | Durum |
| :--- | :--- | :--- | :--- |
| S1 | 2026-10-09 | `main.dart` eski 10 sn eşiğiyle ve DESIGN.md öncesinde yazıldı; renkler, kontrast ve eşikler güncel değil. | Kapandı — K25 (kullanılmayacak) |
| S2 | 2026-10-09 | `mock_students.json` alanlarının DESIGN.md 8.7 (profil, konu, takılma süresi, PeerSwarm için tamamlanan konular) ile uyumu kontrol edilmedi. Eski "Kırmızı Liste" ifadesi "Kritik" olarak değiştirilmeli. | Çözüldü — K38 (mevcut dosya uyarlandı) |
| S3 | 2026-10-09 | DESIGN.md diskte eski bir sürümle değiştirilmişti (8.1, 8.3–8.9'daki K14–K22 karşılıkları kaybolmuştu). | Çözüldü — son commit'teki sürüm geri getirildi, yeni "tam ad" değişiklikleri (K35) üzerine eklendi |
| S4 | 2026-10-09 | Faz 1–2 için widget testi yazılmadı (zaman kısıtı): "5 sn hareketsizlikte Story'ye geçiş" ve "Basitleştir Kritik üretmez" senaryoları şimdilik tarayıcıda elle test ediliyor. Yalnızca `story_splitter` ve `FocusTracker` birim testleri var. | Açık — kod dondurmadan (04:30) önce vakit kalırsa |
| S5 | 2026-10-09 | DESIGN.md'de tanımlı olmayan üç değer tokens.dart'a eklendi: Morphing ölçek başlangıcı (0.85), Story ilerleme çubukları arası boşluk (4px) ve devre dışı birincil buton (Grey-400 zemin + Grey-900 metin, §2.3 listesinde yok; kontrast ~9.8:1). | Kapandı — DESIGN.md §2.3, §7 ve §8.5'e işlendi |

## 5. Yol Günlüğü

- **2026-10-09 — Konsept Geliştirme ve Pivot**
  - Projenin temel fikri, yapay zekânın tembellik yaratan bir araç olması probleminden yola çıkarak "öğrenciyi araştırtan ve yorulduğunda onu kurtaran" bir sisteme (EduSwarm) dönüştürüldü.
  - VS Code odaklı başlangıç fikri, daha geniş bir kullanıcı kitlesine hitap etmek ve sunum kolaylığı sağlamak amacıyla mobil/web uygulama mimarisine evrildi.
- **2026-10-09 — Dokümantasyon ve İlk Kod Denemesi**
  - Projenin amacını, hedef kitlesini ve başarı kriterlerini netleştiren `INTENT.md` oluşturuldu.
  - Lila/nane yeşili paleti ve animasyon kurallarını belirleyen `DESIGN.md` hazırlandı.
  - Morphing UI mantığını simüle eden örnek Flutter kodu (`main.dart`) ve 40 kişilik mock veri seti (`mock_students.json`) hazırlandı.
- **2026-10-09 — Proje Belleğinin Kurulması**
  - Kararların ve ilerlemenin kaydedileceği bu dosya oluşturuldu.
- **2026-10-09 16:50 — Dokümanların Hizalanması**
  - INTENT.md güncellendi: kullanıcı yolculuğu (kayıt, öğrenme stili testi, sınıf kodu, içerik yükleme), Altın Senaryo, 30/60 sn eşikler ve Sunum Modu eklendi.
  - DESIGN.md Flutter Web'e göre yeniden düzenlendi: kontrast düzeltmeleri, profil bazlı tipografi, yeni bileşenler (kayıt, test, sınıf kodu, Sokratik baloncuk, öğretmen paneli, Acil Müdahale kartı).
  - MEMORY.md'de K3 ve K5 iptal edildi; K6–K13 kararları ve Bilinen Sorunlar bölümü eklendi.
- **2026-10-09 17:36 — INTENT / DESIGN / MEMORY Hizalaması (Claude ile soru-cevap)**
  - INTENT.md: şifreli giriş, PDF/Markdown yükleme, soru etiketleri, üç seviyeli odak durumu, Anladım/Anlamadım akışı, PeerSwarm konu skoru, gerçek zamanlı iletişim ve otomatik destek mesajları eklendi; dosya adı `intentt.md` → `INTENT.md` düzeltildi.
  - DESIGN.md: sekmeli Giriş/Kayıt (8.1), soru ekleme formu (8.3), içerik → sorular akışı ve Dikkat eşiği (8.4), Story sonu (8.5), Anladım/Anlamadım (8.6), Dikkat sayacı ve öğrenci detayı (8.7), "Mesaj Gönder"siz uyarı kartı (8.8), öğrenci bildirim kartı ve otomatik mesajlar (8.9, yeni), ters Morphing ve bildirim animasyonları eklendi.
  - MEMORY.md: K4, K10, K12 iptal edildi; K14–K26 eklendi; S1 ve S2 kapatıldı.
- **2026-10-09 18:02 — CLAUDE.md Hizalaması**
  - CLAUDE.md §1, §2 ve §4.1 K14–K26 kararlarına göre güncellendi; stack tablosuna içerik ayrıştırma satırı ve ortam notu eklendi.
  - DESIGN.md §3 ve §8.4'te Dislektik kart zemini (K27) ve gömülü fontlar (K29) netleştirildi.
  - K27–K30 eklendi; Flutter kurulumu blokaj olarak işaretlendi.
- **2026-10-09 18:50 — TRD Hizalaması ve Teknik Kararlar**
  - TRD.md K14–K29'a göre güncellendi: Firebase Auth (e-posta/şifre), `focused/attention/critical` durumları, soru bazında tip, Anladım/Anlamadım + kontrol sorusu, `topicScores` ile PeerSwarm, Eşleştir + bildirimler, destek mesajı havuzu, gömülü fontlar (T9), Story sonu.
  - CLAUDE.md §2 Stack tablosu TRD'ye göre yeniden yazıldı; "bekleyen karar" satırları kaldırıldı.
  - DESIGN.md eski sürümle değiştirilmişti; güncel sürüm geri getirildi ve tam ad değişiklikleri eklendi (S3).
  - `mock_students.json` 42 öğrenciye uyarlandı (K38).
  - K15 ve K25 iptal edildi; K31–K39 eklendi; bekleyen kararlar kapandı. Flutter Web + Firebase için `.gitignore` eklendi.
- **2026-10-09 19:20 — ROADMAP Blok 0: Flutter İskeleti**
  - `flutter create --platforms web --project-name eduswarm .` ile proje oluşturuldu; .md dosyaları ve `.gitignore` korundu.
  - `mock_students.json` → `assets/mock/`; `assets/content/` ve `assets/fonts/` klasörleri açıldı, `pubspec.yaml`'a mock ve content eklendi.
  - Paketler: firebase_core, firebase_auth, cloud_firestore, provider, file_picker. `shared_preferences` ve `google_fonts` eklenmedi (K37, K29).
  - `lib/theme/tokens.dart` (DESIGN.md token'ları), `lib/strings.dart` iskeleti, sade `main.dart` (Cream-Base zemin + "EduSwarm") ve buna uygun widget testi yazıldı.
  - Doğrulama: `flutter analyze` → No issues found; `flutter test` → geçti; `flutter build web` → başarılı.
- **2026-10-09 19:25 — ROADMAP.md Eklendi**
  - ROADMAP.md (Faz 0–7, 04:30 kod dondurma) projeye eklendi ve İlerleme Gözlemi'nde tamamlandı olarak işaretlendi.
  - K40 eklendi (zaman planı, kod dondurma, HSD Bounty kapsam dışı).
  - Flutter blokajı kaldırıldı; sıradaki adım ROADMAP Faz 0: Firebase bağlantısı.
- **2026-10-09 19:46 — ROADMAP Faz 0 Tamamlandı**
  - `main.dart` Firebase'i `DefaultFirebaseOptions.currentPlatform` ile başlatıyor; debug modda mock öğrenci sayısını yazdırıyor (`services/mock_data_service.dart`).
  - Roboto (unhinted, Regular/Medium/Bold) ve Lexend (Regular/Medium/Bold) resmi Google depolarından bir kez indirilip `assets/fonts/`'a gömüldü, OFL lisanslarıyla birlikte; `pubspec.yaml`'da tanımlandı.
  - `lib/demo_accounts.dart` (demo sabitleri) ve `lib/seed.dart` (demo öğretmen, demo öğrenci, demo sınıfı + üyelik) eklendi; K41.
  - Doğrulama: `flutter analyze` temiz, `flutter test` geçti, `flutter run -d chrome` → Firebase hatasız başladı, konsolda "Mock öğrenci sayısı: 42". Seed henüz çalıştırılmadı (kullanıcı çalıştıracak).
- **2026-10-09 20:50 — ROADMAP Faz 1–2: Öğrenci Çekirdeği**
  - İçerik: `assets/content/demo_lesson.json` (C: Pointer'lar, 5 paragraf, 3 soru: 2 Sözel/Görsel + 1 İşlem) ve `support_messages.json`.
  - `tokens.dart`'a `AppThresholds` (30/30/60/5 sn) eklendi; geçici `lib/dev_config.dart` (Sunum Modu = true, profil = Dislektik).
  - Model `models/lesson.dart`; servisler `content_service`, `story_splitter` (TRD §4.2), `telemetry` (`FocusTracker`: Odakta → Dikkat → Kritik, durum geçişleri konsola).
  - Ekran `screens/student/lesson_screen.dart`: okuma → sorular, `Listener` + klavye ile telemetri, Kritik'te 600ms Fade & Scale + SnackBar, Story modu (10 kart, ilerleme çubuğu, "Soruya Dön" + ters animasyon), "Basitleştir" uyarısız geçiş; profil bazlı sunum `theme/profile_style.dart`.
  - Kaydırma olayları sayacı sıfırlıyor ama etkileşim sayısına eklenmiyor (ilk denemede tekerlek olayları sayıyı yüzlere çıkarıyordu).
  - Doğrulama: `flutter analyze` temiz, 8 test geçti; Chrome'da otomatik Dikkat → Kritik → Story geçişi log'da görüldü. S4, S5 eklendi.
- **2026-10-09 20:58 — Faz 1–2 Tamamlandı**
  - Kullanıcı tarayıcıda elle doğruladı: otomatik Morphing, Story modu, "Soruya Dön", "Basitleştir" ve profiller çalışıyor.
  - S5 kapatıldı: Morphing ölçeği (0.85), Story çubuk boşluğu (4px) ve devre dışı buton eşleşmesi (Grey-400 + Grey-900) DESIGN.md'ye işlendi.
  - Soruların doğru/yanlış kontrolü bilinçli olarak Faz 4'teki kontrol sorusuna bırakıldı.
- **2026-10-09 21:13 — ROADMAP Faz 3: Öğretmen Paneli ve Canlı Erken Uyarı**
  - Adresler `/`, `/#/teacher`, `/#/student`; `services/auth_service.dart` demo girişi (sekmeye özel oturum), `screens/demo_sign_in_gate.dart` (K42).
  - `services/firestore_service.dart`: sınıf, üyeler ve açık uyarılar canlı; durum, uyarı, Sunum Modu ve "Gördüm" yazımı. Öğrenci ekranı Firestore'a bağlandı; `DevConfig.presentationMode` kaldırıldı (K43).
  - Öğretmen Paneli `screens/teacher/teacher_panel_screen.dart` + `widgets/teacher/`: özet şeridi (toplam · dikkat · kritik), Sunum Modu anahtarı, yalnızca Kritik listesi (gerçekler üstte), öğrenci detayı (yalnızca özet), stil dağılımı, Acil Müdahale kartı (400ms giriş + tek nabız, "Gördüm"). Tam ad + aynı adda ayırt edici etiket (K35).
  - `models/student_summary.dart` (`ClassOverview`), `models/alert.dart`; `test/student_summary_test.dart` eklendi.
  - Acil Müdahale kartında 🚨 yerine Material ikon kullanıldı (emoji yazı tipi internetten iner); DESIGN §7 ve §8.8, TRD §3.1 ve §4.4 güncellendi. K34 Faz 5'e ertelendi (K44).
  - Doğrulama: `flutter analyze` temiz, 12 test geçti, `flutter build web` başarılı. İki pencere testi kullanıcıda.
- **2026-10-09 21:50 — ROADMAP Faz 4: Sokratik Rehber ve PeerSwarm**
  - Faz 3 kullanıcı tarafından iki pencereyle doğrulandı (İlerleme Gözlemi ✅).
  - Soru ekranı: ilerleme çubuğu, aşama cümlesi, "Kontrol Et" → Doğru!/Tekrar düşünelim, "İpucu al", bitişte "3 sorudan 2'sini doğru yaptın" (Türkçe belirtme eki sayıya göre seçiliyor) — K45.
  - `socratic_hints.json` (reading + q1–q3, 2-3 ipucu + farklı kontrol sorusu), `models/socratic.dart`, `services/socratic_session.dart`, `widgets/socratic_bubble.dart` (Story'de Morphing'den sonra belirir), `widgets/option_tile.dart` — K46.
  - Öğrenci bildirim kartı `widgets/student_notification.dart` (5 sn); tebrik ve akran eşleştirme bildirimleri.
  - PeerSwarm: `ClassOverview.suggestPeer`, Acil Müdahale kartında Mint-300 öneri + "Eşleştir", mock akran simülasyonu; "Gördüm" Grey-900 metin linki — K47.
  - Faz 3 düzeltmeleri: saniyelik canlı süre (ilk anda eşik süresi), kritik satırlar tam genişlik/eşit yükseklik — K48.
  - Doğrulama: `flutter analyze` temiz, 20 test geçti (`socratic_session_test`, `student_summary_test` genişletildi), `flutter build web` başarılı. İki pencere testi kullanıcıda.
- **2026-10-09 22:06 — İçerik Uyarlaması: Story Kartları, Kod Kutuları, Sokratik Mesajlar**
  - `models/lesson.dart` (`StoryCard`, `Question.code`, `optionsAreCode`), `models/socratic.dart` (`CheckQuestion.code`, `SocraticMessages`, `SocraticContent`), `widgets/code_block.dart`; `LessonText` ters tırnakları monospace gösteriyor.
  - Roboto Mono (Regular, Medium) resmi googlefonts/RobotoMono deposundan bir kez indirilip `assets/fonts/`'a gömüldü (OFL lisansıyla).
  - Story: `storyCards` + subtitle + kod kutusu; Sokratik çözülünce "Soruya Dön" hemen görünür. "Bu adımı kendin çözdün." metni kaldırıldı.
  - `test/content_parsing_test.dart`: gerçek JSON dosyalarını ayrıştırarak içerik-kod uyumunu koruyor.
  - DESIGN §3.3 (yeni), §8.5, §8.6, §8.9 ve TRD ders/ipucu şeması güncellendi; K49.
  - Doğrulama: `flutter analyze` temiz, 23 test geçti.
- **2026-10-09 22:27 — Hazır Dersler, "Derslerim" ve Görseller**
  - Kullanıcı 3 hazır ders (pointers, logic_gates, binary_search) ve 12 görsel ekledi; içerik değiştirilmedi. `index.json`'a kullanıcının izniyle `defaultSocratic` (genel üst-bilişsel zincir) eklendi.
  - Model: `LessonFigure`, `StoryCard.image/imageAlt`, `Lesson.figures/socratic`; `models/lesson_catalog.dart` (`LessonEntry`, `LessonCatalog`). Servis: `ContentService.loadCatalog/loadBundledLesson`, `LessonRepository`, `FirestoreService.watchLessons/loadLesson`.
  - Ekranlar: `my_lessons_screen.dart` ("Derslerim"), `demo_lesson_launcher.dart` (`/#/student/demo`); `LessonScreen` seçilen dersi alır, geri dönüşte durum Odakta yazılır. `widgets/lesson_image.dart` (Story görseli + okuma şeması, Semantics).
  - `demo_lesson.json` ve `socratic_hints.json` silindi; `pubspec.yaml`'a `lessons/` ve üç görsel klasörü eklendi.
  - `content_parsing_test.dart` index'teki her dersi, zincirleri, görsel dosyalarını ve pubspec tanımlarını denetliyor. TRD §3.2, §4.5 (yeni), §5; DESIGN §8.4, §8.5, §8.9a (yeni) güncellendi. K50.
  - Doğrulama: `flutter analyze` temiz, 32 test geçti.
- **2026-10-09 23:10 — Faz 5a: Giriş/Kayıt ve Öğrenme Stili Testi**
  - `provider` eklendi (K34/K44 karşılandı): `services/session.dart` (`Session` ChangeNotifier: `AppUser`, `activeClassId`). `activeClassId` sınıf kodu gelene kadar sabit `demo_class`.
  - `/` artık `HomeGate`: giriş yoksa `AuthScreen` (iki sekme, rol kartları, zorunlu KVKK + "Ayrıntılar", demo butonları); öğretmen → panel; öğrenci `learningStyle == null` → test, değilse "Derslerim". `/#/teacher`, `/#/student`, `/#/student/demo` aynen çalışıyor (`routes.dart`). `role_chooser_screen.dart` silindi.
  - Test: `models/learning_style_test.dart` JSON'u aynen okur ve `scoring` + `presentationProfileMap` ile puanlar; giriş notu → 12 soru (ilerleme: "Soru n / 12", %, aşama etiketi, çubuk, "k soru kaldı"; "Tam olarak" şıkkında sorunun ikonu) → sonuç (stil kartı, okuma desteği kartı, dipnot, "Derslerime Git").
  - Firestore: `users/{uid}` → `learningStyle` (sunum profili), `studentStyle`, `readingSupport`; aynı alanlar + `displayName` aktif sınıfın `members/{uid}` belgesine yazılır. Öğretmen detayında "Görsel öğrenen · Okuma desteği açık" görünür. Demo öğrenci (Dislektik) testi atlar (K26).
  - **Toplu belge güncellemesi için (DESIGN/TRD):** DESIGN §8.2 "Soru 3 / 6" → 12 soru + oyunlaştırılmış ilerleme, sonuç butonu "Sınıfıma Katıl" → "Derslerime Git", aşama etiketi Mint-300 rozet, ölçek şıklarında ikon; TRD §3.1 `users` ve `members`'a `studentStyle`, `readingSupport`; TRD §4.4 madde 0 (geçici adresler) artık demo kısayolları. Test hata metinleri Warning-Soft kutuda, input hata kenarı Warning (sert kırmızı yok).
  - Bilinen risk: test ikonları emoji; Flutter Web (CanvasKit) emoji fontunu internetten çeker, internetsiz demoda kutucuk görünebilir (T9 ile çelişki adayı).
  - Doğrulama: `flutter analyze` temiz, 37 test geçti (`learning_style_test_test.dart` yeni, `widget_test.dart` Giriş/Kayıt'a uyarlandı), `flutter build web` başarılı. Tarayıcı testi kullanıcıda.
- **2026-10-10 00:20 — Faz 5b: Sınıf Kodu ve Öğretmenin İçerik Yüklemesi**
  - Aktif sınıf artık `users/{uid}.activeClassId` (Session'da; demo hesaplarında alan yoksa e-postadan `demo_class`). Öğretmen sınıfsızsa `CreateClassScreen` (kod `models/class_code.dart`: 0/O, 1/I yok, çakışmada yeniden üretim), öğrenci test → `JoinClassScreen` → Derslerim. Davet linki `#/join?code=…` (`main.dart` artık `onGenerateRoute`; açılışta altına `/` yığılmıyor). Panelde "Davet" (kod + Kodu/Linki Kopyala) ve "Ders Gönder" butonları.
  - Test sonucu artık `members`'a yalnızca öğrenci bir sınıftaysa yazılır; katılırken profil alanları üyeliğe kopyalanır (daha önce katıldıysa durum/skor korunur).
  - `LessonUploadScreen`: başlık, kesikli yükleme alanı, yapıştırma alanı, soru tipi varsayılanı, soru kartları (3-4 şık, daire ile doğru cevap, tip çipi), önizleme "N kart, M soru bulundu" + notlar, "Dersi Gönder" → `classes/{id}/lessons/{auto}` (`topicKey` = belge id, `activeLessonId` güncellenir). Sokratik: `index.json` genel zinciri (mevcut fallback).
  - İçe aktarma (`services/import/`): .txt/.md, PDF (`syncfusion_flutter_pdf`, saf Dart; dosya saklanmaz, metin yoksa "Bu PDF'ten metin okunamadı"), .pptx (`archive` + `xml`; slayt sırası presentation.xml'den, başlık yer tutucusu → kart başlığı, maddeler → "• " satırları, otomatik numaralar `buAutoNum`'dan üretilir, `ppt/media` varsa "Slaytlardaki görseller aktarılmadı"), .ppt → ".pptx olarak kaydedin". Soru ayıklama: `1.`/`1)` + `a)`/`A)` (yan yana da), `Cevap: B` / `Doğru cevap` / `Yanıt`, "Cevap Anahtarı" `1-B`; cevapsız soruda öğretmen önizlemede işaretler, işaretlenmeden gönderilemez.
  - Okuma ekranı: `#` ile başlayan paragraflar kalın başlık (Markdown/PPTX dersleri için).
  - Paylaşılan form bileşenleri `widgets/form_widgets.dart` (input teması, WarningNote, SurfaceCard, CenteredColumn, SelectChip); Auth ve test ekranı bunlara taşındı.
  - **Toplu belge güncellemesi için:** K33 (PDF + PPTX metin olarak artık var; K15'teki "PPTX yok" kararı fiilen değişti → yeni karar satırı gerekli), TRD T6 ve §3.1 (`users.activeClassId`, ders belgesinde `storyCards` öğretmen dersinde de olabilir), DESIGN §8.3 (Davet diyaloğu, "Kodu Kopyala", varsayılan tip çipi, önizleme şeridi Mint-300, yükleme metninde PowerPoint), CLAUDE.md §2 içerik yükleme satırı.
  - Lisans notu: `syncfusion_flutter_pdf` Syncfusion Community License gerektirir (yıllık geliri 1M USD altı, 5'ten az geliştirici); hackathon prototipi için uygun, ürünleşirse gözden geçirilmeli.
  - Doğrulama: `flutter analyze` temiz, 51 test geçti (`class_code_test`, `lesson_import_test` — bellekte üretilen PDF/Türkçe PDF/PPTX, `lesson_upload_screen_test`), `flutter build web` başarılı. Tarayıcı testi kullanıcıda.
