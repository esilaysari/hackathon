# CLAUDE.md — EduSwarm Projesi Ana Düşünce Sistemi

> Bu dosya her yapay zekâ ve geliştirici oturumunun başında okunur. Projenin teknoloji yığını (stack), davranış ilkeleri, kuralları ve yasakları için tek kaynaktır. Model kendi yorumuna göre karar vermez, burada yazılana bakar.
>
> Bu dosya **her zaman güncel hâliyle** tutulur: geçersiz olan kural doğrudan güncellenir. Kararların geçmişi ve gerekçeleri **MEMORY.md Karar Defteri**'nde yaşar (K1, K2… numaralarıyla).
>
> Kaynak dosyalar: `INTENT.md` (niyet/kapsam) · `DESIGN.md` (tasarım sözleşmesi) · `MEMORY.md` (yol günlüğü, append-only) · `TRD.md` (teknik gereksinimler) · `ROADMAP.md` (görev planı) · bu dosya (davranış + stack + kural).

## 1. Proje

**EduSwarm** — 40+ kişilik kalabalık sınıflarda öğretmenin yüklediği içeriği her öğrenciye öğrenme stiline (Görsel, Dislektik, Metinsel) göre farklı sunan; öğrencinin odak kaybını basit telemetriyle tespit edip arayüzü sadeleştiren (Morphing UI) ve öğretmene erken uyarı gönderen bir **Flutter Web prototipi**.

- **Ana odak:** Yapay zekâyı kopyala-yapıştır için kullanan ya da standart içerikte kopan öğrencileri "Bilişsel Yük Yönetimi" ve "Sokratik Yönlendirme" ile sistemde tutmak.
- **Öğrenci akışı:** Kayıt → kısa öğrenme stili testi → sınıf koduyla katılım → içeriği profiline göre okuma → "Hemen Başla" ile sorular. Hareketsiz kalırsa (okuma ve sözel/görsel 30 sn, işlem 60 sn) arayüz otomatik olarak Story/Flashcard formatına dönüşür, sistem destek mesajı gösterir ve Sokratik Rehber ipucu sorar.
- **Öğretmen akışı:** Kayıt → sınıf oluşturma (6 haneli kod + davet linki) → not/slayt yükleme (PDF / Markdown) + etiketli soru ekleme → dersi gönderme. Panelde özet sayaçları (Dikkat / Kritik), yalnızca **Kritik** durumdaki öğrencilerin listesini ve "Acil Müdahale" uyarılarını (PeerSwarm akran önerisiyle) görür.
- **Bilinçli kısıt:** Gerçek LLM API'si ve kurum entegrasyonu yoktur. AI davranışları kural tabanlı mantık ve mock veriyle simüle edilir.
- **Demo omurgası:** INTENT.md'deki **Altın Senaryo**. Her geliştirme önce bu akışa hizmet eder.

## 2. Stack — Mevcut Durum (2026-10-09)

| Katman | Seçim | Not |
| :--- | :--- | :--- |
| Ön yüz | **Flutter Web (Dart)** | Tek kod tabanı, responsive. Öğrenci Portalı mobil öncelikli, Öğretmen Paneli masaüstü öncelikli (bkz. DESIGN.md §4). Native mobil uygulama yok. |
| Tipografi | **Projeye gömülü fontlar** (`assets/fonts/` + `pubspec.yaml`) | Roboto (genel), Lexend (Dislektik mod). `google_fonts` paketi kullanılmaz; demo internetsiz de doğru fontla açılmalıdır (TRD T9). |
| Tasarım token'ları | **Tek bir tema dosyası** (`lib/theme/tokens.dart`) | DESIGN.md'deki tüm renk, boşluk, radius, gölge ve süre değerleri tek yerde sabit olarak tanımlanır; widget'lar yalnızca bu sabitleri kullanır. |
| Kimlik | **Firebase Authentication** (e-posta + şifre) | Şifre yalnızca Firebase Auth'ta; profil `users/{uid}` belgesinde. Doğrulama ve şifre sıfırlama yok (TRD T5). |
| Veri + anlık iletişim | **Cloud Firestore** (europe-west3, test modu) | Kullanıcılar, sınıflar, üyeler, dersler, uyarılar, bildirimler ve **Sunum Modu** (sınıf ayarı). Canlı dinleme `snapshots()` ile; ayrı sunucu yok. Demo iki ayrı cihazda yapılır (TRD T2). |
| Mock / statik veri | **Yerel JSON** (`assets/`) | 42 mock öğrenci (`mock_students.json`), test soruları, demo dersi, Sokratik ipuçları, destek mesajları. Firestore'a yazılmaz; panel gerçek ve mock öğrencileri tek listede birleştirir (TRD T3, T4). |
| Durum yönetimi | **`StreamBuilder` + `provider`** (`ChangeNotifier`) | Firestore verisi için `StreamBuilder`; giriş yapan kullanıcı ve aktif sınıf için `provider` (TRD T7). |
| İçerik yükleme | **Metin tabanlı** | Yapıştırma veya `.txt` / `.md`; metin başlık-paragraf bazında Story kartlarına bölünür. PDF zaman kalırsa (TRD T6). |
| Telemetri | **Yerel `Timer` + tıklama sayacı** | Eşikler: 30 sn (okuma, sözel/görsel), 60 sn (işlem), Sunum Modunda 5 sn; eşiğin yarısında "Dikkat". |
| Yayın | **Firebase Hosting** | `flutter build web` + `firebase deploy --only hosting`; öğrenci telefonu gerçek URL'den açar (TRD T8). |

**Ortam:** Flutter SDK kurulu ve PATH'te olmalıdır (2026-10-09 itibarıyla kurulum bekleniyor). Flutter erişilemiyorsa Claude kodu analiz edip çalıştıramadığını açıkça söyler; doğrulanmamış kodu "bitti" diye raporlamaz.

**Sık kullanılan komutlar:**

```bash
flutter pub get          # bağımlılıkları kur
flutter run -d chrome    # tarayıcıda çalıştır
flutter analyze          # statik analiz (commit öncesi temiz olmalı)
flutter build web        # sunum için derleme
firebase deploy --only hosting   # Firebase Hosting'e yayın
```

## 3. Davranış İlkeleri

> Andrej Karpathy'nin LLM'lerle kod yazarken gözlemlediği yaygın hatalardan türetilen ilkelerden uyarlanmıştır. Bu dört ilke stack'ten bağımsız olarak her görevde geçerlidir.

### 3.1 Önce Düşün, Sonra Kodla

Varsayımda bulunma. Kafa karışıklığını gizleme. Trade-off'ları yüzeye çıkar.

- Belirsiz bir talepte varsayımını açıkça söyle, gerekiyorsa sor.
- INTENT.md, DESIGN.md ve kod arasında çelişki görürsen sessizce geçme; söyle ve MEMORY.md "Bilinen Sorunlar"a ekle.
- **Test:** Kafan karıştıysa, kodu yazmadan önce bunu söyledin mi?

### 3.2 Önce Basitlik

Problemi çözen minimum kod. Spekülatif hiçbir şey yok.

- İstenmeyen özellik ekleme, tek kullanımlık kod için soyutlama kurma.
- Makine öğrenmesi ya da karmaşık analiz kurma; basit `Timer` ve sayaçlarla yetin.
- **Test:** Kıdemli bir mühendis buna "gereksiz karmaşık" der mi?

### 3.3 Cerrahi Değişiklik

Yalnızca dokunman gerekene dokun. Yalnızca kendi dağınıklığını temizle.

- Görevle ilgisiz kodu, yorumu veya formatı "iyileştirmeye" çalışma.
- **Test:** Diff'teki her satır kullanıcının isteğine doğrudan bağlanabiliyor mu?

### 3.4 Hedef Odaklı Yürütme

Başarı kriterini tanımla. Doğrulanana kadar döngüde kal.

- Çok adımlı görevlerde numaralı plan ver ve her adım için açık bir "doğrulama:" cümlesi yaz (ör. "doğrulama: Sunum Modu açıkken 5 sn sonra Story moduna geçiliyor").
- Bir özelliği bitti saymadan önce `flutter analyze` temiz olmalı ve özellik tarayıcıda denenmiş olmalı.

## 4. Proje Kuralları

### 4.1 Ürün Kuralları

- **Telemetri:** Odak kaybı yalnızca **hareketsizlik süresi** ile ölçülür; **tıklama sayacı** kaydedilir ama bu sürümde kararı etkilemez. Eşik, açık olan ekrana göre belirlenir: okuma ekranı ve "Sözel/Görsel" etiketli sorular 30 sn, "İşlem" etiketli sorular 60 sn; **Sunum Modu** açıkken hepsi 5 sn. Eşikler kodda tek yerde, değiştirilebilir sabitler olarak tutulur. Herhangi bir etkileşim sayacı sıfırlar.
- **Odak durumu üç seviyelidir:** Odakta → **Dikkat** (eşiğin yarısı; yalnızca öğretmen sayacına yansır, öğrenci ekranı değişmez) → **Kritik** (eşik aşıldı).
- **Otomatik Morphing:** Kritik'te sistem ağır görev ekranından Story/Flashcard formatına **kullanıcıya sormadan**, DESIGN.md §7'deki animasyonla geçer, destek mesajı gösterir ve öğretmene uyarı gönderir. Story'nin son kartındaki "Soruya Dön" öğrenciyi takıldığı ekrana döndürür ve sayacı sıfırlar.
- **Manuel basitleştirme:** Öğrenci "Basitleştir"e kendisi basarsa Story moduna geçilir ama **öğretmene uyarı gönderilmez**.
- **Sokratik Rehber:** Öğrenciye asla doğrudan cevap veya çözüm verilmez. Her soru için 2-3 ipucundan oluşan bir zincir vardır. "Anlamadım" → sıradaki ipucu (zincir biterse akran desteği önerilir). "Anladım" → 3-4 şıklı kontrol sorusu; doğruysa durum Odakta'ya döner, yanlışsa sıradaki ipucu verilir.
- **Otomatik destek mesajları:** Öğrenciye mesajları öğretmen değil **sistem** gönderir: Morphing anında ve kontrol sorusu doğru cevaplandığında (DESIGN.md §8.9). Mesajlar hazır havuzdan gelir, yargılayıcı değildir.
- **Profil uyarlaması kural tabanlıdır:** Dislektik modda DESIGN.md §3.2 tipografisi uygulanır; Görsel modda kart düzeni ve görseller öne alınır; Metinsel mod klasik okuma düzenidir. Story kartları içeriğin başlık/paragraf bazında bölünmesiyle oluşur.
- **İçerik ve sorular:** Öğretmen PDF veya Markdown/metin yükler (PPTX yok) ve soruları "Sözel/Görsel" ya da "İşlem" olarak etiketler.
- **Öğretmen Paneli (triage):** 40+ öğrencinin tamamı değil, yalnızca **Kritik** öğrenciler listelenir; Dikkat ve Kritik sayıları özet şeritte görünür. Ham telemetri hiçbir yerde gösterilmez; öğretmen bir öğrenciyi seçtiğinde yalnızca özet (ör. "12 etkileşim · 45 sn hareketsiz"), profil, konu ve takılma süresi görünür.
- **PeerSwarm:** O konuda başarı skoru en yüksek ve durumu Odakta olan akran önerilir. Uyarı kartında yalnızca "Eşleştir" ve "Gördüm" bulunur; öğretmenin elle mesaj yazma özelliği yoktur.
- **Kayıt ve test sade kalır:** Giriş/Kayıt sekmeli tek kart; kayıtta ad, soyad, e-posta, şifre, rol ve zorunlu KVKK onayı. Öğrenme stili testi 5-8 soru, ekran başına tek soru. Demo için hazır "Demo Öğretmen / Demo Öğrenci" girişleri bulunur; kayıt ekranları yetişmezse Altın Senaryo bu girişlerle doğrudan ders anından başlar (INTENT.md "Kısa yol").

### 4.2 Tasarım Kuralları

- Tüm renk, boşluk, radius, gölge ve animasyon değerleri DESIGN.md'den gelir ve tema dosyasındaki sabitlerle kullanılır.
- Tüm metin/zemin eşleşmeleri en az **WCAG AA (4.5:1)** kontrastı sağlar; DESIGN.md §2.3'teki onaylı eşleşmelerin dışına çıkılmaz. Pastel zeminlerde (Lilac-500, Mint-500, Warning) metin her zaman Grey-900'dür.
- Saf beyaz (#FFFFFF) yalnızca kart yüzeylerinde kullanılır; arka plan Cream-Base (#FDFBF7) olur. **Dislektik profilde kartlar da Cream-Base'dir**; hiçbir yerde saf beyaz kullanılmaz.
- Sert renkler (canlı kırmızı, parlak mavi) kullanılmaz.

### 4.3 Kod ve Dil Kuralları

- Kullanıcıya görünen tüm metinler **Türkçe**; sınıf, değişken ve dosya adları **İngilizce**.
- Kullanıcıya görünen metinler widget'ların içine dağılmaz, bir arada tutulur (sunumdan önce metin düzeltmesi kolay olsun).
- Mock veri dosyaları gerçek kişilere ait bilgi içermez; isimler uydurmadır.

### 4.4 Çalışma Akışı

- **Oturum başında:** MEMORY.md'nin "Devamlılık" ve "Bilinen Sorunlar" bölümlerini oku.
- **Önceliğe uy:** (1) Ağır Görev → Morphing → Story + Acil Müdahale + Sunum Modu, (2) Sokratik Rehber + PeerSwarm, (3) kayıt, test, sınıf kodu, içerik yükleme. Bir üst öncelik çalışmadan alttakine geçme.
- **Altın Senaryo'yu koru:** Çalışan Altın Senaryo akışını bozabilecek bir değişiklikten önce uyar.
- **Her özellik bitince:** Commit'leri kullanıcı atar; Claude commit atmaz. Claude özelliğin bittiğini söyler, MEMORY.md Yol Günlüğü'ne kısa bir giriş ekler ve İngilizce, `tip: açıklama` biçiminde bir commit mesajı önerir (ör. `feat: add story mode morphing animation`, `docs: update memory.md`).
- **Oturum sonunda:** MEMORY.md "Devamlılık" bölümünü güncelle.

## 5. Yapma (Yasaklar)

- Gerçek bir e-Okul, OBS veya resmi kurum API'siyle entegrasyon kurmaya **çalışma**.
- Gerçek bir LLM API'si (OpenAI, Gemini, Claude vb.) **bağlama**. Sokratik yanıtlar ve profil uyarlamaları kural tabanlı mantık ve mock veriden gelir.
- Uzun, akademik öğrenme stili envanterleri, e-posta doğrulama, şifre sıfırlama veya sosyal medya ile giriş **inşa etme**.
- Göz takibi, kamera, mikrofon veya "rage tap" gibi gelişmiş davranış analizleri **yazma**.
- React, HTML/Tailwind veya başka bir ön yüz teknolojisine **geçme**; proje Flutter Web'dir.
- DESIGN.md'de tanımlanmayan bir rengi, boşluk, radius veya süre değerini **hardcode etme**.
- TRD.md'de belirlenen mimariden (Firestore, Firebase Auth, `StreamBuilder` + `provider`) farklı bir state management kütüphanesi, backend veya veritabanı **ekleme**; gerekirse önce kullanıcıya sor.
- API anahtarı, şifre veya kişisel veri içeren dosyaları commit'e **önerme**; `.gitignore`'a eklenmesini söyle.
- `git commit` / `git push` **çalıştırma**; commit'leri kullanıcı atar.
- Fontları veya başka bir demo varlığını çalışma anında internetten **indirme**.

## 6. Kaynak Hiyerarşisi — Çelişki Çıkarsa

| Konu | Kazanan dosya |
| :--- | :--- |
| Ürün kapsamı, kullanıcı amacı, kapsam dışı öğeler, Altın Senaryo | INTENT.md |
| Renk, tipografi, boşluk, biçim, hareket, bileşen görünümü | DESIGN.md |
| Davranış ilkeleri, stack, proje kuralları, yasaklar | CLAUDE.md (bu dosya) |
| Teknik mimari, veri modeli, durum yönetimi (oluşturulduğunda) | TRD.md |
| Görev sırası ve zamanlama (oluşturulduğunda) | ROADMAP.md |
| "Şu an neredeyiz", karar geçmişi ve gerekçeler | MEMORY.md |

Bu dosyalar birbirini tekrar etmez, birbirine referans verir. Bir konuda hangi dosya "sahipse" karar oradan okunur. Çelişki fark edilirse kod yazmadan önce kullanıcıya söylenir ve MEMORY.md "Bilinen Sorunlar"a eklenir.

## 7. Bu Dosya Nasıl Büyür

- TRD.md'de bir teknik karar değiştiğinde §2 Stack tablosu güncellenir; karar ve gerekçesi MEMORY.md Karar Defteri'ne yazılır.
- Morphing UI veya telemetriyle ilgili yeni bir davranış kuralı gerekirse §4.1'e eklenir.
- Tekrarlayan, dosya veya klasöre özgü kurallar büyürse `.claude/rules/` altına ayrı dosyalar olarak taşınır ve buradan referans verilir.
