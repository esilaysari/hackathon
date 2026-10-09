# EduSwarm — Tasarım Sistemi (DESIGN.md)

> **Kaynak:** EduSwarm - Otonom Kişiselleştirilmiş Eğitim ve Erken Uyarı Ağı Prototipi
> **Teknoloji:** Flutter Web — tek kod tabanı, tarayıcıda çalışan mobil uyumlu (responsive) web uygulaması
> **Tipografi:** Roboto (genel arayüz), Lexend (Dislektik mod)
> **Format:** Modern minimalist, Y2K esintili pastel estetik
> **Amaç:** Öğrenci Portalı ve Öğretmen Paneli'nin tüm tasarım token'ları, kararları ve bileşen kuralları tek dokümanda.

Bu doküman, EduSwarm'ın temelini oluşturan "Bilişsel Yük Yönetimi" ve "Otonom Şekil Değiştiren Arayüz (Morphing UI)" kavramlarını tutarlı bir görsel dilde sunmak için hazırlanmış tasarım sistemidir. Renk, tipografi, boşluk, biçim ve hareket eksenlerinde organize edilmiştir. Klasik, sıkıcı öğrenme yönetim sistemlerinden (LMS) uzaklaşarak genç, dinamik ve şefkatli bir kullanıcı deneyimi hedeflenmiştir.

Ürün kapsamı, kullanıcı yolculuğu ve Altın Senaryo için bkz. **INTENT.md**.

## 1. Tasarım Prensipleri

| Prensip | Açıklama |
| :--- | :--- |
| **Bilişsel Şefkat** | Arayüz asla öğrenciyi yormamalıdır. Zorlu içerik (Ağır Görev) temiz bir şekilde sunulur; hüsran anlarında arayüz otomatik olarak (Morphing UI) en basit forma (Story Modu) geçer. |
| **Erişilebilirlik Önce** | Tüm metin/zemin eşleşmeleri en az **WCAG AA (4.5:1)** kontrast oranını sağlar. Pastel renkler zemin ve vurgu için kullanılır; metin her zaman koyu tondadır. Erişilebilirlik projenin ana fikri olduğu için bu kural istisnasızdır. |
| **Y2K & Minimalizm** | Klasik okul renkleri yerine pastel tonlar, geniş krem boşluklar ve yumuşak gradient'ler kullanılır; uygulama bir sosyal medya akıcılığında hissettirir. |
| **Odaklı Etkileşim** | Ekranda aynı anda yalnızca tek bir ana eylem (CTA) bulunur (Duolingo kart mantığı). Karmaşık menülerden kaçınılır. |
| **Sessiz Uyarılar** | Stres ve hata durumları agresif kırmızılarla değil, yumuşak ve destekleyici tonlarla (şeftali/turuncu) belirtilir. |
| **Öğrenci Kontrolü** | Öğrenci her zaman içeriği kendisi de basitleştirebilir ("Basitleştir" butonu). Sistem yalnızca öğrenci yardım istemeden tıkandığında devreye girer. |

## 2. Renk (Color)

Renk paleti, öğrencinin stresini azaltmak ve uygulamanın modern hissettirmesini sağlamak üzerine kuruludur.

### 2.1 Marka Renk Ölçekleri

#### Yumuşak Lila — Birincil (Primary / Soft Lilac)

| Token | Hex | Rol |
| :--- | :--- | :--- |
| Primary/Lilac-100 | #E8DEF8 | Çok açık vurgular, Story modu pasif ilerleme çubukları, seçili test şıkkı zemini |
| Primary/Lilac-300 | #D0BCFF | İkincil buton zemini, hover durumları |
| Primary/Lilac-500 | #C0A3E5 | **Ana kurumsal renk** — ikonlar, Story modu aktif ilerleme, gradient başlangıcı. *Üzerinde beyaz metin kullanılmaz.* |
| Primary/Lilac-700 | #65558F | **Birincil buton zemini** (beyaz metinle), metin içi vurgular, linkler |

#### Nane Yeşili — İkincil (Secondary / Mint Green)

| Token | Hex | Rol |
| :--- | :--- | :--- |
| Secondary/Mint-300 | #C8F0E1 | Çok açık başarı vurguları, PeerSwarm öneri kartı zemini |
| Secondary/Mint-500 | #A8E6CF | **Ana ikincil renk** — gradient bitişi, başarı rozetleri |

#### Krem / Kırık Beyaz — Arka Plan

| Token | Hex | Rol |
| :--- | :--- | :--- |
| Background/Cream-Base | #FDFBF7 | **Ana uygulama arka planı** (Scaffold) |
| Background/Cream-Surface | #FFFFFF | Kart yüzeyleri |

#### Antrasit / Gri — Nötr Metin

| Token | Hex | Rol |
| :--- | :--- | :--- |
| Neutral/Grey-900 | #1C1B1F | **Ana metin**, başlıklar, Story kartı metni |
| Neutral/Grey-600 | #49454F | İkincil metin, açıklamalar |
| Neutral/Grey-400 | #CAC4D0 | Pasif durumlar, kenarlıklar, ayraçlar. *Metin için yalnızca dekoratif, okunması zorunlu olmayan yerlerde kullanılır.* |

### 2.2 Semantik ve Uyarı Renkleri

| İsim | Değer | Rol |
| :--- | :--- | :--- |
| Status/Warning (Şeftali) | #FFB347 | "Acil Müdahale" kartı ve "Bilişsel yük algılandı" bildirimi zemini. **Üzerindeki metin Grey-900'dür.** |
| Status/Warning-Soft | #FFE4C2 | Öğretmen panelinde kritik öğrenci satırı zemini |
| Status/Success | #2E7D32 | Başarı bildirimleri (beyaz metinle) |

### 2.3 Kontrol Edilmiş Metin/Zemin Eşleşmeleri

| Zemin | Metin | Kullanım |
| :--- | :--- | :--- |
| Cream-Base / Cream-Surface | Grey-900, Grey-600 | Tüm genel metinler |
| Lilac-700 | Beyaz | Birincil butonlar |
| Lilac-500 → Mint-500 gradient | Grey-900 | Story modu kartı |
| Warning #FFB347 | Grey-900 | Uyarı kartları, SnackBar |
| Success #2E7D32 | Beyaz | Başarı SnackBar |

## 3. Tipografi (Typography)

**Font ailesi:** Roboto (genel arayüz). **Lexend** (Dislektik mod; okuma kolaylığı için tasarlanmış). Her iki font da projeye gömülür (`assets/fonts/`); çalışma anında internetten indirilmez.

### 3.1 Tip Ölçeği

| Stil | Boyut | Ağırlık | Rol |
| :--- | :--- | :--- | :--- |
| Story Display | 32px | Bold (700) | Story modundaki kısa bilgi metinleri |
| Task Title | 28px | Bold (700) | Ana görev kartı başlığı (ör. "Fotosentez") |
| Dashboard Number | 28px | Bold (700) | Öğretmen paneli sayaçları (ör. "42 öğrenci · 3 kritik") |
| App Bar Title | 20px | Bold (700) | Üst bar başlığı ("EduSwarm") |
| Subheading | 18px | Regular (400) | Bölüm başlıkları ("Günlük Hedef") |
| Body-Lg | 16px | Regular (400) | Ana görev metinleri, açıklamalar |
| Button Text | 16px | Medium (500) | Buton metinleri |
| Caption | 13px | Regular (400) | Zaman damgaları, küçük etiketler |

### 3.2 Profil Bazlı Tipografi Kuralları

| Profil | Kural |
| :--- | :--- |
| **Metinsel** | Standart ölçek. Roboto, satır yüksekliği 1.5. |
| **Görsel** | Standart ölçek; metin blokları kısa tutulur, yüklenen slaytlardaki görseller metnin önünde ve büyük gösterilir. |
| **Dislektik** | Lexend; gövde metni **18px**; satır yüksekliği **1.8**; harf aralığı **+0.5px**; kelime aralığı geniş; paragraflar en fazla 3-4 satır; **yalnızca sola hizalı** (iki yana yaslama yok); italik ve tamamı büyük harf kullanılmaz; zemin Cream-Base (saf beyaz yok) — **kart yüzeyleri dahil**: Dislektik profilde kartlar Cream-Surface yerine Cream-Base zeminlidir ve Shadow/Light ile ayrışır. |

## 4. Düzen & Izgara (Layout & Spacing)

- **Tek kod, iki düzen:** Flutter Web üzerinde ekran genişliğine göre değişen responsive düzen.
  - **Öğrenci Portalı — mobil öncelikli:** Dikey kullanım; geniş ekranda içerik en fazla **480px** genişliğinde ortalanmış bir sütunda gösterilir.
  - **Öğretmen Paneli — masaüstü öncelikli:** Geniş ekranda iki sütun (solda kritik öğrenci listesi, sağda seçili öğrenci detayı / uyarı akışı); dar ekranda tek sütuna iner.
- **Kırılım noktaları:** `< 600px` mobil · `600–1023px` tablet · `≥ 1024px` masaüstü.
- **Geniş boşluklar:** Öğrencinin üstüne bilgi yığılmaması için kenarlarda ve elementler arasında bol boşluk bırakılır.

### 4.1 Boşluk (Spacing)

| Token | Değer | Kullanım |
| :--- | :--- | :--- |
| spacing-sm | 10px | Başlık ile açıklama arası |
| spacing-md | 20px | Kart içi boşluklar, elementler arası standart mesafe |
| spacing-lg | 24px | **Ekran sağ/sol kenar boşlukları** (mobil) |
| spacing-xl | 40px | Bölümler arası geniş alanlar, kart iç dolgusu |

## 5. Biçim / Köşe Yarıçapı (Shape)

Keskin köşelerden kaçınılır; yuvarlak hatlar "şefkatli" tasarım dilini yansıtır.

| Token | Değer | Kullanım |
| :--- | :--- | :--- |
| radius-sm | 2px | Story modu ince ilerleme çubukları |
| radius-md | 20px | Butonlar, input alanları, test şıkları |
| radius-lg | 30px | Ağır Görev kartı, öğretmen paneli kartları |
| radius-xl | 40px | Story modu ana kartı |

## 6. Yükseklik & Gölge (Elevation)

| Seviye | Gölge / Efekt | Kullanım |
| :--- | :--- | :--- |
| Shadow/Light | 0 10px 20px rgba(0,0,0,0.05) | Ağır Görev kartı, öğretmen paneli kartları |
| Shadow/Colored | 0 15px 30px rgba(192,163,229,0.3) | Story modu kartı (lila tonlu yumuşak parlama) |
| Shadow/Warning | 0 10px 24px rgba(255,179,71,0.35) | "Acil Müdahale" kartı |

## 7. Hareket & Animasyon (Motion)

Animasyonlar, Morphing UI özelliğinin kalbidir; sistemin öğrenciye yardım ettiğini hissettirir.

| Durum | Efekt / Süre | Açıklama |
| :--- | :--- | :--- |
| **Morphing** | 600ms Fade & Scale | Ağır Görev'den Story moduna geçiş. Eski ekran küçülerek kaybolur (Scale Down + Fade Out), yeni ekran büyüyerek belirir (Scale Up + Fade In). |
| **Story kart geçişi** | 300ms CrossFade | Öğrenci dokunduğunda metin yumuşakça değişir. Ani kesme yapılmaz. |
| **Uyarı belirmesi (SnackBar)** | Standart Slide-Up | Morphing anında alttan çıkan şeftali renkli "Biraz zorlandın gibi, içeriği kolaylaştırdım" bilgilendirmesi. |
| **Öğretmen uyarı kartı** | 400ms Slide-In + hafif nabız | Yeni "Acil Müdahale" kartı listenin en üstüne kayarak girer ve bir kez yumuşakça büyüyüp küçülür. Sürekli yanıp sönme yapılmaz. |
| **Ters Morphing** | 600ms Fade & Scale | Story sonunda "Soruya Dön" ile normal görünüme dönüş; Morphing'in tersi. |
| **Sokratik baloncuk** | 250ms Fade + Slide-Up | Morphing tamamlandıktan sonra belirir. |
| **Öğrenci bildirim kartı** | 300ms Slide-Down | Üstten kayarak girer, birkaç saniye sonra yukarı kayarak çıkar. |
| **Hareket azaltma** | — | Tarayıcıda "hareketi azalt" tercihi açıksa ölçek animasyonları kapatılır, yalnızca fade kullanılır. |

## 8. Bileşen Kuralları (Component Rules)

### 8.1 Kayıt / Giriş Ekranı

- Tek kart, ortalanmış; üstte iki sekme: **Giriş Yap** / **Kayıt Ol**.
- **Giriş Yap:** E-posta, Şifre. Birincil buton: "Giriş Yap" (Lilac-700).
- **Kayıt Ol:** **Ad, Soyad, E-posta, Şifre** ve **rol seçimi** (Öğretmen / Öğrenci; iki büyük seçilebilir kart, seçili olan Lilac-100 zemin + Lilac-700 kenarlık).
  - **KVKK onay kutusu** (zorunlu): "Öğrenme stilimin ve platformdaki etkileşim verilerimin yalnızca bana yardım etmek amacıyla öğretmenimle paylaşılmasını kabul ediyorum." Yanında "Ayrıntılar" linki.
  - Birincil buton: "Devam Et" (Lilac-700).
- Altta küçük **demo giriş butonları**: "Demo Öğretmen olarak gir", "Demo Öğrenci olarak gir" (sunumda form doldurmamak için).

### 8.2 Öğrenme Stili Testi

- Her ekranda **tek soru**; üstte "Soru 3 / 6" ve ince ilerleme çubuğu.
- Şıklar büyük, dokunulabilir kartlar (radius-md); seçili şık Lilac-100 zemin + Lilac-700 kenarlık.
- Soru metni Body-Lg; teste girerken kısa bir not: "Doğru ya da yanlış cevap yok."
- Sonuç ekranı: profil adı (ör. "Dislektik dostu okuma"), bir cümlelik açıklama, ikon ve "Sınıfıma Katıl" butonu. Profil adı yargılayıcı değil, destekleyici bir dille yazılır.

### 8.3 Sınıf Oluşturma ve Katılma

- **Öğretmen:** Sınıf adı girilir → büyük, kopyalanabilir **6 haneli sınıf kodu** (Task Title boyutunda, harfler arası geniş) ve "Linki Kopyala" butonu gösterilir. Sunumda jüriye göstermek için kod ekranda okunaklı olmalıdır.
- **Öğrenci:** Tek bir kod giriş alanı + "Katıl" butonu; davet linkiyle gelindiyse kod otomatik dolu gelir.
- **İçerik yükleme (öğretmen):** Sürükle-bırak alanı (kesikli Lilac-300 kenarlık, radius-lg), "Ders notunu veya slaytı yükle (PDF, Markdown, metin)" metni; yüklenen dosya kart olarak listelenir.
- **Soru ekleme (öğretmen):** Yükleme alanının altında "+ Soru Ekle" (ikincil buton). Her soru bir kart: soru metni, 3-4 şık, doğru cevap seçimi ve **tip etiketi** — iki seçenekli chip: "Sözel/Görsel (30 sn)" / "İşlem (60 sn)"; seçili chip Lilac-100 zemin + Lilac-700 kenarlık. Demo dersinde sorular önceden doldurulmuş gelir.
- En altta tek birincil buton: "Dersi Gönder".

### 8.4 Ağır Görev Görünümü (Main Task View)

Öğrencinin ilk karşılaştığı, öğretmenin yüklediği içeriği profiline göre gösteren ekran.

- **Zemin:** Cream-Surface kart, Cream-Base arka plan. Dislektik profilde kart da Cream-Base olur (bkz. 3.2).
- **İçerik:** Üstte ikon (Lilac-500), ortada başlık (Task Title), altta gövde metni (profil tipografi kurallarına göre, bkz. 3.2).
- **Etkileşim:** Altta iki buton. Birincil: "Hemen Başla" (Lilac-700 zemin, beyaz metin). İkincil: "Basitleştir" (beyaz zemin, Lilac-700 kenarlık ve metin).
- **Akış (içerik → sorular):** Öğrenci önce ders metnini okur; "Hemen Başla" onu öğretmenin eklediği sorulara geçirir. Sorular, test ekranıyla aynı düzende gösterilir (her ekranda tek soru, büyük şık kartları, üstte "Soru 2 / 5"). "Basitleştir" butonu soru ekranlarında da bulunur.
- **"Basitleştir"e basılırsa:** Story moduna geçilir ama öğretmene uyarı gönderilmez; öğrenci yardımı kendisi istemiştir.
- **Otomatik tetikleyici (telemetri):** Hareketsizlik sayacı hem okuma hem soru ekranlarında çalışır; öğrenci etkileşimde bulunmazsa sistem Story moduna geçer ve öğretmene uyarı gönderir. Eşikler:
  - Okuma ekranı ve sözel / görsel sorular: **30 saniye**
  - İşlem gerektiren sorular: **60 saniye**
  - Sunum Modu açıkken: tüm ekranlar için **5 saniye**
  - Eşiğin yarısı aşıldığında öğrencinin durumu "Dikkat" olur (öğrenci ekranında görsel değişiklik yok; yalnızca öğretmen sayacına yansır).

### 8.5 Story Modu Görünümü (Bite-Sized View)

Öğrenci tıkandığında sistemin sunduğu kurtarıcı arayüz.

- **İlerleme çubuğu:** En üstte, Instagram hikâyelerindeki gibi yan yana ince çubuklar (height: 4px, radius-sm). Aktif: Lilac-700; pasif: Lilac-100.
- **Ana kart:** Büyük kart (radius-xl), Lilac-500 → Mint-500 **linear gradient** zemin, Shadow/Colored.
- **Metin:** Kartın ortasında Story Display (32px, Bold), **Grey-900**. Dislektik profilde Lexend kullanılır.
- **Etkileşim:** Ekrana dokunulduğunda metin değişir, ilerleme çubuğu bir adım ilerler. Altta "Devam etmek için dokun →" (Grey-600).
- **İçerik bölme:** Kartlar, yüklenen içeriğin başlık/paragraf bazında kural tabanlı bölünmesiyle oluşur; her kart tek bir fikir taşır.
- **Story sonu:** Son kartta tek birincil buton: "Soruya Dön". Öğrenci takıldığı ekrana döner, hareketsizlik sayacı sıfırlanır; geçişte Morphing animasyonu ters yönde oynar.

### 8.6 Sokratik Rehber Baloncuğu

- Story kartının altında, Cream-Surface zeminli konuşma baloncuğu (radius-lg, Shadow/Light); solda küçük rehber ikonu (Lilac-500).
- Metin Body-Lg, Grey-900. Rehber **asla doğrudan cevap vermez**; tek bir ipucu sorusu sorar (ör. "Bitkiler güneş ışığını neden bu kadar önemsiyor olabilir?").
- Altta iki küçük buton: **"Anlamadım"** (ikincil) ve **"Anladım"** (birincil).
  - **Anlamadım:** Zincirdeki bir sonraki ipucu gelir (her soru için 2-3 ipucu; adım adım derinleşir). İpuçları bittiğinde baloncuk "Bir akranınla çalışmak ister misin?" sorusunu sorar (PeerSwarm).
  - **Anladım:** Baloncukta 3-4 şıklı kısa bir **kontrol sorusu** açılır. Doğruysa otomatik tebrik mesajı gelir (bkz. 8.9) ve durum "Odakta"ya döner; yanlışsa şefkatli bir dille ("Çok yaklaştın, şuna bir bak:") sıradaki ipucu verilir.

### 8.7 Öğretmen Paneli

- **Üst özet şeridi:** Sınıf adı, sınıf kodu ve sayaçlar (Dashboard Number): "42 öğrenci · 5 dikkat · 3 kritik". "Dikkat" sayacı Lilac-100 zeminli rozet, "kritik" sayacı Warning-Soft zeminli rozet içinde gösterilir. Sağ üstte **Sunum Modu anahtarı** (açıkken yanında küçük "5 sn" etiketi).
- **Kritik öğrenci listesi:** Yalnızca "Kritik" eşiğini aşan öğrenciler gösterilir (40+ mock öğrenciden süzülmüş). Her satır Warning-Soft zeminli: **tam ad** (aynı ada sahip iki öğrenci varsa yanında Caption boyutunda Grey-600 ayırt edici etiket, ör. "· mkaya"), profil etiketi (ör. "Dislektik"), ne kadar süredir takıldığı, konu adı.
- **Öğrenme stili dağılımı:** Küçük bir özet kartı (ör. Görsel 15 · Dislektik 8 · Metinsel 19).
- **Öğrenci detayı (sağ sütun):** Listeden bir öğrenci seçildiğinde profil, konu, durum ve kısa bir etkileşim özeti gösterilir (ör. "12 etkileşim · 45 sn hareketsiz").
- **Gizlilik ilkesi:** Ham telemetri (tek tek fare hareketleri, tıklama zaman damgaları) hiçbir yerde gösterilmez; yalnızca öğrenci detayında özet sayılar ve "destek gerekiyor" bilgisi yer alır.

### 8.8 "Acil Müdahale" Uyarı Kartı ve PeerSwarm Önerisi

- **Uyarı kartı:** Warning (#FFB347) zemin, Grey-900 metin, Shadow/Warning, radius-lg. İçerik: 🚨 ikon, "Ayşe Yılmaz bu konuda zorlanıyor", konu adı, süre ve "Sistem içeriği Story moduna dönüştürdü ve destek mesajı gönderdi" bilgisi.
- **PeerSwarm önerisi:** Kartın içinde Mint-300 zeminli küçük bir alt bölüm: "Yardım edebilecek akran: Mehmet Çelik (bu konuda başarılı)" + "Eşleştir" butonu.
- **Eylemler:** "Eşleştir" (birincil) ve küçük bir "Gördüm" metin linki. Eşleştirilen ya da "Gördüm" denen kart listeden kalkar. Öğretmen öğrenciye elle mesaj yazmaz; destek mesajlarını sistem otomatik gönderir (bkz. 8.9).

### 8.9 Öğrenci Bildirim Kartı ve Otomatik Destek Mesajları

- **Bildirim kartı:** Ekranın üstünden kayarak gelen küçük kart; Mint-300 zemin, Grey-900 metin, radius-md, Shadow/Light. Öğrencinin akışını bölmez; birkaç saniye sonra kendiliğinden kapanır ya da "Tamam" ile kapatılır.
- **Akran eşleştirme:** Öğretmen "Eşleştir"e bastığında iki öğrenciye de bildirim kartı gelir (ör. "Mehmet Çelik sana bu konuda yardım edecek").
- **Otomatik destek mesajları (sistem gönderir, öğretmen değil):**
  - **Morphing anında:** Şeftali SnackBar — "Biraz zorlandın gibi, içeriği kolaylaştırdım."
  - **Kontrol sorusu doğru cevaplandığında:** Bildirim kartı — "Harika! Zor kısmı aştın."
- Mesajlar destekleyici ve yargılamayan bir dille yazılır; hazır bir mesaj havuzundan seçilir.
