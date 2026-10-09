# TRD.md — EduSwarm Teknik Gereksinimler ve Mimari

> **Proje:** EduSwarm — Otonom Kişiselleştirilmiş Eğitim ve Erken Uyarı Ağı
> **Statü:** Aktif (2026-10-09)
> **Stack özeti:** Flutter Web + Firebase (Authentication + Cloud Firestore + Hosting) + yerel mock JSON
> **Referanslar:** INTENT.md (kapsam, Altın Senaryo) · DESIGN.md (görünüm) · CLAUDE.md (kurallar) · MEMORY.md (kararlar)

Bu doküman EduSwarm'ın **nasıl inşa edileceğini** tanımlar: hangi verinin nerede tutulduğu, bileşenlerin birbiriyle nasıl haberleştiği, veri modelleri ve temel akışların teknik karşılığı. MEMORY.md'deki bekleyen kararlar (veri saklama, anlık iletişim, içerik ayrıştırma) burada karara bağlanmıştır. Ürün kuralları için MEMORY.md K14–K29 esastır; bu doküman onların teknik karşılığıdır.

## 1. Mimari Kararlar

| # | Karar | Gerekçe |
| :--- | :--- | :--- |
| T1 | **Ön yüz:** Flutter Web, tek uygulama; giriş yapan kullanıcının rolüne göre Öğrenci Portalı veya Öğretmen Paneli açılır. | CLAUDE.md §2, MEMORY K6. |
| T2 | **Gerçek kullanıcı verisi:** Cloud Firestore (Firebase, ücretsiz Spark planı), bölge **europe-west3** (Frankfurt), güvenlik kuralları **test modu**. | Öğretmen ve öğrenci **farklı cihazlarda** (ör. öğrenci telefonda, öğretmen projeksiyondaki bilgisayarda) olacak. Uyarının panele anlık düşmesi için ortak, gerçek zamanlı bir veri kaynağı şart. Firestore bunu sunucu kodu yazmadan, canlı dinleme (snapshot) ile sağlar. |
| T3 | **Kalabalık sınıf verisi:** 40+ öğrenci yerel `mock_students.json` dosyasından okunur; Firestore'a yazılmaz. Öğretmen paneli, gerçek öğrencileri (Firestore) ve mock öğrencileri (JSON) tek listede birleştirir. | Mock veri sabit kalır, sahnede bozulmaz; canlı akış yalnızca demodaki gerçek öğrenci için çalışır. |
| T4 | **Statik içerik** (öğrenme stili testi soruları, demo dersi ve soruları, Sokratik ipucu zincirleri ve kontrol soruları, otomatik destek mesajı havuzu) yerel JSON dosyalarında tutulur. | Gerçek LLM yok (MEMORY K9); içerik uygulamayla birlikte paketlenir. |
| T5 | **Kimlik:** Firebase Authentication — **e-posta + şifre** (MEMORY K14). Ad, soyad, rol, öğrenme stili ve KVKK onayı `users/{uid}` belgesine yazılır; şifre Firestore'a **asla** yazılmaz. Oturum Firebase Auth tarafından tarayıcıda kalıcı tutulur. E-posta doğrulama ve şifre sıfırlama kullanılmaz. | Test modundaki açık Firestore'da şifre saklamak güvenli değil; Firebase Auth e-posta/şifre girişini ek sunucu kodu olmadan sağlar. |
| T6 | **İçerik yükleme:** Öğretmen metni yapıştırır ya da `.txt` / `.md` dosyası yükler; içerik **metin olarak** Firestore'da saklanır. PDF ve slayt görseli desteği "zaman kalırsa" (MEMORY K15'in yerini alır). | Dosya depolama servisi (Firebase Storage) kurulumu ve ücret/plan kısıtları hackathon süresine değmez; metin, Story kartlarına bölünebilecek tek format. |
| T7 | **Durum yönetimi:** Firestore verisi için `StreamBuilder`, uygulama genelindeki basit durum (giriş yapan kullanıcı, aktif sınıf) için `provider` paketi + `ChangeNotifier`. | CLAUDE.md §3.2 "Önce Basitlik". Ek mimari öğrenme yükü yok. |
| T8 | **Yayın:** `flutter build web` + Firebase Hosting. Sunumda öğrenci telefonundan açılacak gerçek bir URL olur. | Tek komutla yayın; ayrı sunucu yok. |
| T9 | **Fontlar:** Roboto ve Lexend `assets/fonts/` altında projeye gömülür ve `pubspec.yaml`'da tanımlanır; çalışma anında indirme yapılmaz (MEMORY K29). | Salon Wi-Fi'sı zayıfsa Dislektik mod yanlış fontla açılmasın. |

### 1.1 Kuş Bakışı

```
┌──────────────── Flutter Web Uygulaması ────────────────┐
│                                                        │
│  Öğrenci Portalı                Öğretmen Paneli        │
│  - Ağır Görev / Story           - Kritik liste         │
│  - Telemetri (Timer)            - Acil Müdahale        │
│  - Sokratik Rehber              - Sunum Modu anahtarı  │
│        │  ▲                            ▲  │            │
└────────┼──┼────────────────────────────┼──┼────────────┘
         │  │      Cloud Firestore       │  │
         │  └── ders, sunum modu ◄───────┼──┘  (öğretmen yazar)
         └────► alert, durum ────────────┘     (öğrenci yazar)
         ◄──── bildirim (akran eşleştirme) ─────     (öğretmen yazar)

  Yerel JSON (uygulamayla paketlenir):
  mock_students.json · learning_style_test.json · socratic_hints.json · demo_lesson.json · support_messages.json
```

## 2. Veri: Ne Nerede Duruyor?

| Veri | Kaynak | Neden |
| :--- | :--- | :--- |
| Kayıtlı kullanıcılar, sınıflar, sınıf üyeleri | Firestore | Cihazlar arası paylaşılmalı |
| Öğretmenin yüklediği ders metni | Firestore | Öğrencinin cihazına ulaşmalı |
| Sunum Modu açık/kapalı | Firestore (sınıf belgesinde) | Öğretmen açınca öğrenci ekranındaki eşik anında 5 sn'ye inmeli |
| Acil Müdahale uyarıları | Firestore | Öğrenciden öğretmene anlık iletim |
| Akran eşleştirme bildirimleri | Firestore | Öğretmenden öğrenciye anlık iletim |
| 40+ mock öğrenci | `assets/mock/mock_students.json` | Ölçek gösterimi; değişmez |
| Öğrenme stili testi soruları | `assets/content/learning_style_test.json` | Statik içerik |
| Sokratik ipucu soruları | `assets/content/socratic_hints.json` | Simüle AI (gerçek LLM yok) |
| Demo dersi ve soruları (yedek içerik) | `assets/content/demo_lesson.json` | Sunumda yükleme adımı aksarsa hazır içerik |
| Otomatik destek mesajları | `assets/content/support_messages.json` | Sistem gönderir, öğretmen değil (MEMORY K22) |

## 3. Veri Modelleri

### 3.1 Firestore Koleksiyonları

**`users/{uid}`** — `uid` Firebase Auth'tan gelir

| Alan | Tip | Açıklama |
| :--- | :--- | :--- |
| `firstName`, `lastName` | String | Ad, soyad |
| `email` | String | E-posta (doğrulanmaz; şifre yalnızca Firebase Auth'ta) |
| `role` | `teacher` \| `student` | Rol |
| `learningStyle` | `visual` \| `dyslexic` \| `textual` \| null | Testten sonra dolar; öğretmende null |
| `kvkkConsent` | Bool | Zorunlu onay |
| `createdAt` | Timestamp | |

**`classes/{classId}`**

| Alan | Tip | Açıklama |
| :--- | :--- | :--- |
| `name` | String | Sınıf adı |
| `code` | String | 6 haneli benzersiz katılım kodu (karışmaması için 0/O, 1/I hariç harf ve rakam) |
| `teacherId` | String | `users` referansı |
| `presentationMode` | Bool | Sunum Modu (true → tüm eşikler 5 sn) |
| `activeLessonId` | String \| null | Şu an gönderilmiş ders |
| `createdAt` | Timestamp | |

**`classes/{classId}/members/{uid}`** — sınıfa katılan gerçek öğrenciler

| Alan | Tip | Açıklama |
| :--- | :--- | :--- |
| `displayName` | String | Tam ad (ör. "Ayşe Yılmaz"); `users` belgesinden kopyalanır |
| `learningStyle` | Enum | `users` belgesinden kopyalanır |
| `status` | `focused` \| `attention` \| `critical` | Odakta / Dikkat / Kritik (MEMORY K17) |
| `stuckSince` | Timestamp \| null | Kritik olduğu an |
| `interactionCount` | Int | Ders boyunca toplam etkileşim sayısı (yalnızca özet; durum değiştiğinde yazılır, MEMORY K23) |
| `topicScores` | Map<String, Int> | Konu bazlı başarı skoru (0-100); kontrol sorusu doğru cevaplanınca artar. PeerSwarm için (MEMORY K22) |
| `joinedAt` | Timestamp | |

**`classes/{classId}/lessons/{lessonId}`**

| Alan | Tip | Açıklama |
| :--- | :--- | :--- |
| `title` | String | Ders başlığı |
| `topicKey` | String | Sokratik ipuçlarıyla eşleşme anahtarı (ör. `pointers`; mock veriyle aynı sözlük) |
| `content` | String | Ders metni (Markdown destekli düz metin); okuma ekranının eşiği her zaman 30 sn |
| `questions` | List<Map> | `{ id, text, options[3-4], correctIndex, type }` — `type`: `verbal_visual` (30 sn) \| `computational` (60 sn); eşiği o an açık olan soru belirler (MEMORY K16) |
| `sentAt` | Timestamp | |

**`classes/{classId}/alerts/{alertId}`**

| Alan | Tip | Açıklama |
| :--- | :--- | :--- |
| `studentId`, `studentName` | String | Kimlik `studentId` ile; `studentName` tam ad |
| `learningStyle` | Enum | |
| `lessonTitle` | String | |
| `suggestedPeer` | Map \| null | `{ id, name, isMock }` — PeerSwarm önerisi |
| `createdAt` | Timestamp | |
| `seen` | Bool | Öğretmen "Gördüm" ya da "Eşleştir" deyince true |
| `matchedPeerId` | String \| null | Öğretmen "Eşleştir"e bastıysa önerilen akranın `id`'si |

**`classes/{classId}/notifications/{notificationId}`** — öğrenci bildirim kartı (DESIGN §8.9)

| Alan | Tip | Açıklama |
| :--- | :--- | :--- |
| `toUserId` | String | Bildirimi alacak gerçek öğrenci (mock öğrencilere bildirim yazılmaz) |
| `text` | String | Ör. "Mehmet Çelik sana bu konuda yardım edecek" |
| `createdAt` | Timestamp | |

> Otomatik destek mesajları (Morphing anı, kontrol sorusu doğru) Firestore'a yazılmaz; öğrencinin cihazında `support_messages.json` havuzundan yerel olarak gösterilir.

> **Kimlik ve isimler:** Öğretmen panelinde öğrencilerin **tam adı her zaman gösterilir**; öğretmenin kime yardım edeceğini bilmesi gerekir. Sistem öğrencileri **yalnızca `id` ile** ayırt eder: uyarılar, durum güncellemeleri ve PeerSwarm eşleştirmesi hep `id` üzerinden yapılır, isimle eşleştirme yapılmaz. Panelde aynı tam ada sahip birden fazla öğrenci varsa isimlerin yanında e-postanın `@` öncesi kısmı küçük bir etiketle gösterilir (ör. "Mehmet Kaya · mkaya"); mock öğrencilerde bu durumda `id` kullanılır.

> **Gizlilik (MEMORY K23):** Firestore'a ham telemetri (tek tek tıklamalar, hareket verisi, zaman damgası dizileri) **yazılmaz**. Yalnızca durum geçişleri (`attention`, `critical`), kritik olma zamanı ve özet `interactionCount` yazılır; öğretmen bunları yalnızca öğrenci detayında özet olarak görür.

### 3.2 Yerel JSON Dosyaları

**`assets/mock/mock_students.json`** (42 kayıt)

```json
[
  {
    "id": "mock_01",
    "firstName": "Rümeyda",
    "lastName": "Yılmaz",
    "displayName": "Rümeyda Yılmaz",
    "learningStyle": "visual",
    "status": "attention",
    "currentTopic": "pointers",
    "currentTopicTitle": "C: Pointer'lar",
    "stuckMinutes": null,
    "topicScores": { "pointers": 47, "logic_gates": 62, "memory_allocation": 58, "data_structures": 71, "binary_search": 66, "system_calls": 54 },
    "isMock": true
  },
  {
    "id": "mock_04",
    "firstName": "Can",
    "lastName": "Özkan",
    "displayName": "Can Özkan",
    "learningStyle": "dyslexic",
    "status": "critical",
    "currentTopic": "data_structures",
    "currentTopicTitle": "Veri Yapıları",
    "stuckMinutes": 4,
    "topicScores": { "pointers": 61, "logic_gates": 55, "memory_allocation": 70, "data_structures": 28, "binary_search": 64, "system_calls": 59 },
    "isMock": true
  }
]
```

| Alan | Tip | Açıklama |
| :--- | :--- | :--- |
| `id` | String | `mock_01` … `mock_42` |
| `firstName`, `lastName` | String | Ad, soyad (uydurma) |
| `displayName` | String | Panelde gösterilen tam ad |
| `learningStyle` | `visual` \| `dyslexic` \| `textual` | Öğrenme profili |
| `status` | `focused` \| `attention` \| `critical` | Odakta / Dikkat / Kritik |
| `currentTopic` | String | Konu anahtarı (`topicKey` ile aynı sözlük) |
| `currentTopicTitle` | String | Panelde gösterilen Türkçe konu adı |
| `stuckMinutes` | Int \| null | Yalnızca `critical` öğrencilerde dolu |
| `topicScores` | Map<String, Int> | Altı konunun her biri için 0-100 başarı skoru; PeerSwarm için |
| `isMock` | Bool | Her zaman `true` |

**Mevcut veri seti (42 kayıt, MEMORY K24):** 14 Görsel · 14 Dislektik · 14 Metinsel; 2 `critical`, 5 `attention`, 35 `focused`. Konu anahtarları: `pointers`, `logic_gates`, `memory_allocation`, `data_structures`, `binary_search`, `system_calls`. Her konu için skoru 90'ın üzerinde en az bir `focused` öğrenci vardır (ör. `pointers` → Pelin Turan, 98).

> **Önemli:** PeerSwarm önerisinin mock öğrencilerden gelebilmesi için Altın Senaryo'daki demo dersinin `topicKey`'i bu altı anahtardan biri olmalıdır (öneri: `pointers`). `socratic_hints.json`'da da aynı anahtar için bir ipucu zinciri bulunmalıdır.

Kurallar: isimler uydurmadır; başlangıçta yaklaşık 2 `critical` ve 5 `attention` bulunur (MEMORY K24) — demodaki gerçek öğrencinin uyarısı kalabalıkta kaybolmasın; her konu için yüksek skorlu en az bir `focused` öğrenci bulunur (PeerSwarm önerisi boş kalmasın); profil dağılımı dengelidir. Ham telemetri alanları (stres puanı, tıklama sayısı) bulunmaz.

**`assets/content/learning_style_test.json`** — her şık bir profile puan verir:

```json
[
  {
    "id": "q1",
    "text": "Yeni bir konuyu öğrenirken en çok neye ihtiyaç duyarsın?",
    "options": [
      { "text": "Şema, görsel veya video", "style": "visual" },
      { "text": "Kısa parçalara bölünmüş, rahat okunan metin", "style": "dyslexic" },
      { "text": "Ayrıntılı, düzenli yazılı anlatım", "style": "textual" }
    ]
  }
]
```

Hesaplama: en çok puan alan profil seçilir; eşitlikte sıralama `dyslexic` > `visual` > `textual` (en destekleyici mod öncelikli).

**`assets/content/socratic_hints.json`** — `topicKey` başına 2-3 adımlı ipucu zinciri ve bir kontrol sorusu (MEMORY K20):

```json
{
  "pointers": {
    "hints": [
      "Bir değişkenin değeri ile bellekte durduğu yer arasında sence ne fark var?",
      "Bir adresi saklayan değişken, o adresteki değere nasıl ulaşıyor olabilir?",
      "`*p` ile `&x` yazdığında bilgisayardan farklı olarak ne istiyorsun?"
    ],
    "check": {
      "text": "`int x = 5; int *p = &x;` ise `*p` neyi verir?",
      "options": ["x'in adresini", "5 değerini", "p'nin adresini"],
      "correctIndex": 1
    }
  },
  "_default": {
    "hints": [
      "Bu metindeki en önemli kelime sence hangisi?",
      "O kelimeyi kendi cümlenle anlatmaya çalışır mısın?"
    ],
    "check": null
  }
}
```

Zincir konu başınadır; o konudaki tüm sorular aynı zinciri kullanır. Öğretmenin yüklediği dersin `topicKey`'i dosyada yoksa `_default` kullanılır; `check` null ise "Anladım" doğrudan durumu `focused` yapar.

**`assets/content/support_messages.json`** — sistemin otomatik gönderdiği mesaj havuzu (DESIGN §8.9):

```json
{
  "morph": ["Biraz zorlandın gibi, içeriği kolaylaştırdım."],
  "checkCorrect": ["Harika! Zor kısmı aştın.", "Çok iyi, bunu kendin buldun."],
  "checkWrong": ["Çok yaklaştın, şuna bir bak:"]
}
```

## 4. Temel Akışlar

### 4.1 Telemetri ve Otomatik Morphing (Öğrenci)

1. Okuma ve soru ekranlarında bir Dart `Timer` çalışır. Eşik: `presentationMode` true ise **5 sn**; değilse okuma ekranı ve `verbal_visual` sorular **30 sn**, `computational` sorular **60 sn**.
2. Ekran bir `Listener` widget'ı ile sarılır: her dokunma, tıklama, kaydırma veya tuş olayı zamanlayıcıyı sıfırlar ve yerel `interactionCount`'u artırır. Durum `attention` ise `focused`'a geri yazılır.
3. Eşiğin **yarısı** aşılırsa `members/{uid}.status = "attention"` yazılır; öğrenci ekranında hiçbir şey değişmez (MEMORY K17).
4. Eşik aşılırsa:
   a. Ekran durumu `story` olur; DESIGN.md §7'deki 600ms Fade & Scale animasyonu oynar ve `support_messages.morph` SnackBar'ı gösterilir.
   b. Firestore'da `members/{uid}`: `status = "critical"`, `stuckSince = now`, `interactionCount` yazılır.
   c. `alerts` koleksiyonuna yeni bir belge eklenir (PeerSwarm önerisiyle, bkz. 4.3).
   d. Sokratik Rehber baloncuğu ilk ipucuyla belirir.
5. Öğrenci **"Basitleştir"e kendisi basarsa** yalnızca 4a (SnackBar hariç) ve 4d çalışır; Firestore'a durum veya uyarı yazılmaz (MEMORY K23).
6. **Sokratik akış (MEMORY K20):** "Anlamadım" → sıradaki ipucu; zincir biterse baloncuk akran desteği önerir. "Anladım" → `check` sorusu; doğruysa `checkCorrect` mesajı, `status = "focused"`, `topicScores[topicKey]` artırılır; yanlışsa `checkWrong` + sıradaki ipucu.
7. **Story sonu (MEMORY K21):** Son karttaki "Soruya Dön" öğrenciyi takıldığı okuma/soru ekranına döndürür, sayaç sıfırlanır, Morphing ters yönde oynar.
8. Eşik bir derste **en fazla bir kez** uyarı üretir (aynı öğrenci için uyarı yağmuru olmaz).

### 4.2 Story Kartlarına Bölme (kural tabanlı)

1. Ders metni boş satırlara göre paragraflara ayrılır; Markdown başlıkları (`#`) ayrı kart olur.
2. 25 kelimeden uzun paragraflar cümle sonlarından (`.`, `?`, `!`) bölünür; her kart en fazla ~25 kelime.
3. Profil `dyslexic` ise kartlar Lexend ve DESIGN.md §3.2 kurallarıyla gösterilir.

### 4.3 Öğretmen Paneli ve Acil Müdahale

1. Panel, `members` ve `alerts` koleksiyonlarını canlı dinler (`snapshots()`) ve `mock_students.json`'u bir kez okur.
2. İki kaynak tek listede birleştirilir; yalnızca `status == "critical"` olanlar gösterilir. Gerçek öğrenciler en üstte.
3. Sayaçlar ("42 öğrenci · 5 dikkat · 3 kritik") ve öğrenme stili dağılımı iki kaynağın toplamından hesaplanır. Bir öğrenci seçilince detayda profil, konu, durum ve özet ("12 etkileşim · 45 sn hareketsiz") gösterilir.
4. Yeni bir `alerts` belgesi geldiğinde "Acil Müdahale" kartı DESIGN.md §7 animasyonuyla listenin en üstüne girer.
5. **PeerSwarm önerisi (MEMORY K22):** Gerçek üyeler ve mock öğrenciler arasında, durumu `focused` olan ve `topicScores[topicKey]` değeri en yüksek kişi seçilir (eşitlikte gerçek üye önce). Kimse yoksa öneri bölümü gizlenir. Seçim isimle değil `id` ile yapılır.
6. "Eşleştir" → `alerts/{id}.seen = true`, `matchedPeerId` yazılır; takılan öğrenciye ve akran gerçek bir üyeyse ona `notifications` belgesi eklenir. Kart listeden kalkar.
7. "Gördüm" → `alerts/{id}.seen = true`, kart listeden kalkar. Öğretmenin elle mesaj yazma özelliği yoktur.

### 4.4 Kayıt, Test ve Sınıf

1. **Kayıt / Giriş:** Kayıt sekmesi → `createUserWithEmailAndPassword` → `users/{uid}` belgesi oluşturulur. Giriş sekmesi → `signInWithEmailAndPassword`. Uygulama açılışında oturum açıksa doğrudan role göre ilgili panele gidilir.
2. **Demo girişleri:** "Demo Öğretmen" ve "Demo Öğrenci" butonları, Firebase Auth'ta önceden oluşturulmuş sabit demo hesaplarıyla giriş yapar. Demo Öğrenci'nin profili Dislektik ve demo sınıfına kayıtlıdır (MEMORY K26 yedek planı).
3. **Öğrenme stili testi:** Öğrenci ilk girişte testi çözer → sonuç `users.learningStyle`'a yazılır.
4. **Sınıf oluşturma:** Öğretmen ad girer → benzersiz 6 haneli `code` üretilir (çakışma varsa yeniden üretilir) → ekranda kod ve davet linki (`.../#/join?code=ABC234`) gösterilir.
5. **Katılma:** Öğrenci kodu girer ya da linkle gelir → `code` ile sınıf aranır → `members/{uid}` oluşturulur (`status = "focused"`, boş `topicScores`).
6. **Ders gönderme:** Öğretmen metni yapıştırır veya `.txt`/`.md` yükler, başlık ve konuyu seçer, soruları ekleyip her birini `Sözel/Görsel` ya da `İşlem` olarak etiketler (demo dersinde hazır gelir) → `lessons` belgesi oluşturulur → `classes.activeLessonId` güncellenir → öğrenci ekranı canlı dinlediği için ders anında açılır.

## 5. Proje Klasör Yapısı

```
eduswarm/
├── INTENT.md · DESIGN.md · MEMORY.md · CLAUDE.md · TRD.md · ROADMAP.md
├── assets/
│   ├── fonts/                    # Roboto, Lexend (gömülü, T9)
│   ├── mock/mock_students.json
│   └── content/
│       ├── learning_style_test.json
│       ├── socratic_hints.json
│       ├── support_messages.json
│       └── demo_lesson.json
└── lib/
    ├── main.dart                 # uygulama girişi, yönlendirme
    ├── firebase_options.dart     # flutterfire configure ile otomatik oluşur
    ├── theme/tokens.dart         # DESIGN.md token'ları (renk, boşluk, radius, gölge, süre)
    ├── strings.dart              # kullanıcıya görünen Türkçe metinler
    ├── models/                   # AppUser, ClassRoom, Member, Lesson, Question, Alert, AppNotification, MockStudent
    ├── services/                 # auth_service.dart, firestore_service.dart, mock_data_service.dart, telemetry.dart
    ├── screens/
    │   ├── auth/                 # kayıt, öğrenme stili testi
    │   ├── student/              # sınıfa katıl, ağır görev, story modu
    │   └── teacher/              # sınıf oluştur, ders gönder, panel
    └── widgets/                  # story kartı, sokratik baloncuk, acil müdahale kartı
```

## 6. Kurulum ve Komutlar

```bash
# Bir kez
npm install -g firebase-tools          # Firebase CLI
firebase login
dart pub global activate flutterfire_cli
flutterfire configure                  # Firebase projesini seçer, firebase_options.dart üretir

# Paketler
flutter pub add firebase_core firebase_auth cloud_firestore provider file_picker
# Fontlar google_fonts ile değil, assets/fonts/ + pubspec.yaml ile eklenir (T9)

# Geliştirme
flutter run -d chrome
flutter analyze

# Yayın
flutter build web
firebase deploy --only hosting
```

**Firebase konsolu:** Firestore bölgesi `europe-west3`; Authentication'da "E-posta/Şifre" sağlayıcısı açılır ve demo öğretmen/öğrenci hesapları elle oluşturulur.

**Firestore güvenlik kuralları:** Prototip için okuma/yazma açık "test modu" kuralları kullanılır (30 gün sonra kendiliğinden kapanır). Bu bilinçli bir hackathon kısıtıdır; gerçek üründe kimlik doğrulama ve sınıf bazlı yetki kuralları eklenir.

## 7. Teknik Sınırlar ve Riskler

| Risk | Etki | Azaltma |
| :--- | :--- | :--- |
| Salonda internet yok/zayıf | Uyarı öğretmen paneline düşmez | Telefonun mobil verisinden hotspot hazırla; sunumdan önce iki cihazla prova yap. |
| Firebase kurulumu zaman alır | Öncelikli işlerin gecikmesi | İlk iş olarak kur (~30-45 dk); ders anı akışı Firebase'e bağlı. |
| Açık güvenlik kuralları | Herkes veriyi okuyup yazabilir | Yalnızca uydurma veri kullan; jüriye kısıt olarak açıkla. |
| Gerçek LLM yok | Sokratik ipuçları önceden yazılmış | Altın Senaryo'daki konu için zengin bir ipucu zinciri hazırla; mimarinin LLM'e bağlanmaya hazır olduğunu (ipucu servisi tek bir dosyada) göster. |
| PDF/slayt desteklenmiyor | Öğretmen yalnızca metin yükleyebilir | Sunumda metin yükleme göster; PDF'i "sonraki adım" olarak anlat. |
