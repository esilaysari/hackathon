# EduSwarm — INTENT.md

> Yol haritasındaki ilk doküman. Projenin **niyetini ve amacını** tanımlar; tasarım (DESIGN.md) ve teknik kararlar (TRD.md) sonraki adımlarda ele alınır.

## Bağlam

Kalabalık sınıflarda (40-50 kişi) ve büyük öğrenci topluluklarında eğitimcilerin her öğrencinin öğrenme stiline (görsel, dislektik, metinsel), anlama hızına ve odak durumuna uygun materyal hazırlaması ve sınıfı eş zamanlı takip etmesi pratikte imkânsızdır. Herkese aynı biçimde sunulan içerik, öğrencilerin hızla hüsrana uğramasına, dersten kopmasına ya da yapay zekâ araçlarını yalnızca "kopyala-yapıştır" amacıyla kullanmasına yol açar.

**EduSwarm**, eğitimcinin kendi ders notlarını ve slaytlarını yüklediği; bu içeriği sınıftaki her öğrenciye, kısa bir öğrenme stili testiyle belirlenen profiline göre farklı biçimde sunan; öğrencinin platformdaki davranışından (hareketsizlik süresi, tıklama sayısı) odak kaybını tespit ettiğinde hem öğrencinin ekranını sadeleştiren hem de eğitimciye erken uyarı gönderen, kovan zekâsı (swarm intelligence) yaklaşımıyla çalışan bir eğitim platformudur.

Bu proje 24 saatlik bir hackathon prototipidir. Yapay zekâ davranışları ve bazı veri kaynakları bu süreye uygun olarak **simüle edilir**.

## Hedef

- Eğitimcinin bir sınıf oluşturup kendi ders içeriğini paylaşabilmesi ve kalabalık grubu **tek bir panelden** yönetebilmesi.
- Öğrencinin öğrenme stilinin kısa bir testle belirlenmesi ve bu bilginin eğitimciyle paylaşılması.
- Öğrencinin içeriği kendi profiline (Görsel, Dislektik, Metinsel) uygun, gerektiğinde **otomatik olarak şekil değiştiren** (Morphing UI) bir arayüzde tüketmesi.
- Odak kaybı yaşayan öğrencinin sistemden kopmadan önce fark edilip **basitleştirilmiş mikro-öğrenme formatına** (Flashcard/Story) ve **akran desteğine** (PeerSwarm) yönlendirilmesi.
- Böylece eğitimde fırsat eşitliği ve kesintisiz odaklanmaya katkı sağlanması.

## Kullanıcılar

1. **Eğitimci / Topluluk Lideri (Öğretmen Paneli):** Sınıf oluşturur, sınıf kodunu/linkini öğrencilerle paylaşır, ders notlarını ve slaytlarını yükler, öğrencilerin öğrenme stillerini görür ve kopma noktasına gelen öğrencileri anlık takip eder.
2. **Öğrenci (Öğrenci Portalı):** Kayıt olur, öğrenme stili testini çözer, sınıf koduyla sınıfa katılır, içeriği kendi stiline uygun biçimde tüketir ve zorlandığında sistem tarafından desteklenir.

## Kullanıcı Yolculuğu (Genel Akış)

1. **Kayıt / Giriş:** Kullanıcı ad, soyad, e-posta, şifre ve rolünü (Öğretmen / Öğrenci) girerek kayıt olur; sonraki girişleri e-posta + şifre ile yapar.
2. **Öğretmen:** Bir sınıf oluşturur → sistem bir **sınıf kodu ve davet linki** üretir → öğretmen bunu öğrencilerle paylaşır → derse ait notlarını/slaytlarını **PDF veya Metin/Markdown** olarak yükler → içerikteki her soruyu/bölümü **"Sözel/Görsel"** ya da **"İşlem"** olarak etiketler (hareketsizlik eşiği bu etikete göre belirlenir).
3. **Öğrenci:** İlk girişte **kısa bir öğrenme stili testi** (5-8 soru) çözer → sonuçta profili (Görsel / Dislektik / Metinsel) belirlenir → bu bilgi öğretmen paneline iletilir.
4. **Öğrenci:** Sınıf kodu veya davet linkiyle sınıfa katılır.
5. **Ders anı:** Öğretmen içeriği gönderir; içerik **gerçek zamanlı** olarak (öğretmen ve öğrenci ayrı cihazlardayken de) öğrencilere ulaşır ve her öğrenci onu kendi profiline göre görür. Projenin asıl kısmı (Morphing UI, odak kaybı tespiti, erken uyarı, Sokratik Rehber, PeerSwarm) bu aşamada çalışır.

## Altın Senaryo (Demo Akışı)

Sahnede gösterilecek ve tüm geliştirme ile provaların odaklanacağı tek uçtan uca akış:

1. Öğretmen (önceden kayıtlı demo hesabıyla) yeni bir sınıf oluşturur, ders notunu yükler ve sınıf kodunu ekranda gösterir.
2. Bir öğrenci kayıt olur, öğrenme stili testini hızlıca çözer ve **Dislektik** profili alır; bu bilgi anında öğretmen panelinde görünür.
3. Öğrenci sınıf koduyla sınıfa katılır; sınıf listesinde önceden yüklenmiş 40+ mock öğrenci de yer alır.
4. Öğretmen dersi gönderir; öğrencinin ekranında içerik dislektik dostu biçimde ama hâlâ uzun bir metin olarak açılır.
5. Öğrenci, öğretmenin soruya verdiği etikete göre belirlenen süre boyunca etkileşimde bulunmaz (odak kaybı simülasyonu). Sözel/görsel sorularda bu süre **30 saniye**, işlem gerektiren sorularda daha uzundur (ör. 60 saniye).
6. Arayüz akıcı bir geçişle metni **Flashcard/Story** formatına dönüştürür ve Sokratik Rehber cevabı vermek yerine ilk ipucu sorusunu sorar.
7. Aynı anda Öğretmen Panelinde ilgili öğrenci için **"Acil Müdahale"** uyarısı belirir; uyarıda yardım edebilecek bir akran önerisi (PeerSwarm) yer alır. Öğretmen tek tıkla akranı eşleştirir (iki öğrenciye de bildirim gider) veya öğrenciye kısa bir mesaj gönderir.

> **Sunum Modu:** Jüri karşısında akışın uzamaması için Öğretmen Panelinde bir "Sunum Modu" anahtarı bulunur. Açıkken hareketsizlik eşiği tüm soru tiplerinde **5 saniyeye** iner; böylece odak kaybı adımı birkaç saniyede gösterilebilir. Kapalıyken gerçek eşikler (30 sn / 60 sn) geçerlidir.

## Başarı Kriterleri

1. **Kayıt ve roller:** Kullanıcılar ad, soyad, e-posta, şifre ve rol bilgisiyle kayıt olup e-posta + şifre ile giriş yapabilir; öğretmen ve öğrenci farklı ekranlara yönlendirilir.
2. **Sınıf yönetimi:** Öğretmen sınıf oluşturur; sistem benzersiz bir sınıf kodu ve davet linki üretir; öğrenci bu kod/link ile sınıfa katılır.
3. **İçerik yükleme:** Öğretmen kendi ders notunu/slaytını **PDF veya Metin/Markdown** olarak yükler, soruları "Sözel/Görsel" ya da "İşlem" olarak etiketler ve içeriği sınıfla paylaşır.
4. **Öğrenme stili testi:** Öğrenci kısa bir testle Görsel / Dislektik / Metinsel profillerinden birine atanır; sonuç öğretmen panelinde görünür.
5. **Profile göre sunum:** Aynı içerik, öğrencinin profiline göre kural tabanlı olarak farklı biçimde gösterilir:
   - **Dislektik:** okunabilir yazı tipi, geniş satır aralığı, kısa paragraflar.
   - **Görsel:** kart düzeni, ikonlar, renkli vurgular; içerikteki görseller öne çıkarılır.
   - **Metinsel:** klasik, başlıklı ve yoğun okuma düzeni.
6. **Morphing UI:** Odak kaybı tespit edildiğinde arayüz, düz metinden Flashcard/Story formatına pürüzsüz bir geçiş yapar.
7. **Davranışsal telemetri ve erken uyarı:** Öğrenci ekranındaki basit bir hareketsizlik sayacı (sözel/görsel sorularda 30 sn, işlem gerektiren sorularda daha uzun; ayarlanabilir, Sunum Modunda 5 sn) odak kaybını tespit eder ve uyarı **gerçek zamanlı** olarak Öğretmen Paneline düşer. Tıklama sayısı da telemetri olarak kaydedilir ve panelde görünür, ancak bu sürümde karar mantığını etkilemez.
8. **Ölçek gösterimi ve odak seviyeleri:** Sınıf, gerçek kullanıcılara ek olarak önceden hazırlanmış **40+ öğrencilik mock veri setiyle** çalışır. Her öğrencinin üç seviyeli bir odak durumu vardır: **Odakta**, **Dikkat** (hareketsizlik eşiğin yarısını aştı) ve **Kritik** (eşik aşıldı). Mock öğrenciler bu seviyelere dağıtılır; Öğretmen Panelinde yalnızca "Kritik" seviyedeki öğrenciler uyarı olarak listelenir.
9. **Sokratik yaklaşım:** Simüle AI rehberi doğrudan cevap vermez. Her soru için önceden hazırlanmış 2-3 ipucundan oluşan bir **ipucu zinciri** vardır: öğrenci "Bir ipucu daha" isteyebilir veya bir cevap seçip doğru/yanlış geri bildirimi alabilir.
10. **PeerSwarm (hafif sürüm):** Mock öğrencilerin her konu için bir başarı skoru vardır. Uyarıda, o konuda skoru en yüksek olan ve durumu "Odakta" olan akran önerilir. Öğretmen öneriyi tek tıkla onaylayarak eşleştirmeyi başlatabilir.
11. **Öğretmen müdahalesi:** Öğretmen "Acil Müdahale" uyarısından akran eşleştirebilir veya öğrenciye kısa bir mesaj (teşvik notu) gönderebilir.

## Kapsam Dışı

1. **Gerçek LLM API entegrasyonu:** OpenAI, Gemini, Claude vb. API'ler bağlanmaz. Öğretmenin yüklediği içerik, profillere göre **kural tabanlı** olarak uyarlanır (ör. yazı tipi ve satır aralığı değişimi, metni başlık/paragraf bazında kartlara bölme). Sokratik Rehber'in soruları demo konusu için önceden hazırlanmış mock verilerle simüle edilir.
2. **Gerçek davranış analizi:** Göz takibi, klavye ritmi, "rage tap" gibi makine öğrenmesi tabanlı analizler yapılmaz; zamanlayıcı ve basit tıklama sayaçları kullanılır.
3. **PPTX ayrıştırma:** PowerPoint dosyaları doğrudan işlenmez; slaytlar PDF olarak dışa aktarılıp yüklenir.
4. **Bilimsel olarak doğrulanmış öğrenme stili envanterleri:** Uzun, klinik veya akademik olarak doğrulanmış testler uygulanmaz; profil, kısa ve basit bir testle belirlenir. Test bir tanı aracı değildir; sonuç yalnızca içerik sunumunu kişiselleştirmek için kullanılır.
5. **Kurumsal entegrasyonlar:** e-Okul, üniversite bilgi sistemleri veya notlandırma altyapılarına bağlantı kurulmaz.
6. **Gelişmiş hesap özellikleri ve native mobil uygulama:** E-posta doğrulama, şifre sıfırlama, Google/sosyal medya ile giriş ve App Store / Google Play'e yüklenen ayrı bir mobil uygulama geliştirilmez. Platform, telefonda da düzgün görünen (mobil uyumlu) tek bir web uygulamasıdır.

## Riskler

1. **Gerçekçilik algısı (mock veri):** Jüri, arkada gerçek bir LLM çalışmadığını fark edip teknolojik derinliği sorgulayabilir.
   - *Azaltma:* Bunun 24 saatlik bir MVP olduğunu ve asıl değerin "telemetriye dayalı otomatik karar verme" akışında olduğunu vurgulamak; mimarinin gerçek bir LLM'e bağlanmaya hazır olduğunu göstermek; Morphing UI geçişinin kusursuzluğuna odaklanmak.
2. **Kapsamın 24 saate sığmaması:** Kayıt, sınıf, içerik yükleme ve test eklenmesiyle iş yükü arttı.
   - *Azaltma:* Önce Altın Senaryo'yu uçtan uca çalışır hâle getirmek; kayıt ve sınıf ekranlarını en sade hâlde tutmak; demo için önceden kayıtlı hesaplar ve hazır bir ders notu bulundurmak.
3. **Arayüz karmaşası:** Birden fazla modun tek sayfada dinamik değişmesi CSS/state çakışmalarına ve demo sırasında hatalara yol açabilir.
   - *Azaltma:* Geliştirmeyi ve provaları Altın Senaryo etrafında yapmak; diğer modları yalnızca zaman kalırsa eklemek.
4. **Gizlilik endişesi:** Davranış takibi ve öğrenme stili bilgisinin öğretmenle paylaşılması "öğrenciyi aşırı izleme" olarak algılanabilir.
   - *Azaltma:* Kayıt sırasında verinin nasıl kullanılacağını açıklayan kısa bir onay (KVKK aydınlatma) göstermek; verinin not vermek veya cezalandırmak için değil, öğrenciye yardım etmek için kullanıldığını vurgulamak; öğrenme stili ve uyarı bilgisini yalnızca o sınıfın öğretmeninin görebilmesini sağlamak.
