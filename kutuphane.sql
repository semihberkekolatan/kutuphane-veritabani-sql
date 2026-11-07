-- ============================================================
-- VERİTABANINA GİRİŞ DERSİ - PROJE ÖDEVİ
-- Üniversite Kütüphane Yönetim Sistemi
-- ============================================================

-- ============================================================
-- VERİTABANI OLUŞTURMA
-- ============================================================
CREATE DATABASE IF NOT EXISTS uni_kutuphane;
USE uni_kutuphane;

-- ============================================================
-- TABLO OLUŞTURMA (CREATE TABLE)
-- ============================================================

-- 1. Fakülte/Bölüm tablosu (ogrenciler tablosuna bağlı - 3NF gereği ayrıldı)
CREATE TABLE bolumler (
    bolum_id   INT AUTO_INCREMENT PRIMARY KEY,
    bolum_adi  VARCHAR(100) NOT NULL,
    fakulte    VARCHAR(100) NOT NULL
);

-- 2. Yazarlar tablosu
CREATE TABLE yazarlar (
    yazar_id  INT AUTO_INCREMENT PRIMARY KEY,
    ad        VARCHAR(50) NOT NULL,
    soyad     VARCHAR(50) NOT NULL,
    ulke      VARCHAR(50) DEFAULT 'Türkiye'
);

-- 3. Yayınevleri tablosu
CREATE TABLE yayinevleri (
    yayinevi_id  INT AUTO_INCREMENT PRIMARY KEY,
    yayinevi_adi VARCHAR(100) NOT NULL UNIQUE,
    sehir        VARCHAR(50)
);

-- 4. Kategoriler tablosu
CREATE TABLE kategoriler (
    kategori_id  INT AUTO_INCREMENT PRIMARY KEY,
    kategori_adi VARCHAR(80) NOT NULL UNIQUE
);

-- 5. Kitaplar tablosu (yayinevleri ve kategoriler ile ilişkili)
CREATE TABLE kitaplar (
    kitap_id    INT AUTO_INCREMENT PRIMARY KEY,
    kitap_adi   VARCHAR(200) NOT NULL,
    yayin_yili  YEAR NOT NULL,
    isbn        VARCHAR(20) UNIQUE,
    yayinevi_id INT NOT NULL,
    kategori_id INT NOT NULL,
    CONSTRAINT fk_kitap_yayinevi FOREIGN KEY (yayinevi_id) REFERENCES yayinevleri(yayinevi_id),
    CONSTRAINT fk_kitap_kategori FOREIGN KEY (kategori_id) REFERENCES kategoriler(kategori_id)
);

-- 6. Kitap-Yazar ara tablosu (çok-çok ilişki, bileşik anahtar)
CREATE TABLE kitap_yazar (
    kitap_id  INT NOT NULL,
    yazar_id  INT NOT NULL,
    PRIMARY KEY (kitap_id, yazar_id),
    CONSTRAINT fk_ky_kitap FOREIGN KEY (kitap_id) REFERENCES kitaplar(kitap_id),
    CONSTRAINT fk_ky_yazar FOREIGN KEY (yazar_id) REFERENCES yazarlar(yazar_id)
);

-- 7. Kitap fiziksel kopyaları tablosu
CREATE TABLE kitap_kopyalari (
    kopya_id     INT AUTO_INCREMENT PRIMARY KEY,
    kitap_id     INT NOT NULL,
    demirbas_no  VARCHAR(30) NOT NULL UNIQUE,
    raf_kodu     VARCHAR(20),
    durum        ENUM('RAFTA','ODUNCTE','KAYIP','BAKIM') NOT NULL DEFAULT 'RAFTA',
    CONSTRAINT fk_kopya_kitap FOREIGN KEY (kitap_id) REFERENCES kitaplar(kitap_id)
);

-- 8. Öğrenciler tablosu (bolumler ile ilişkili - 3NF gereği)
CREATE TABLE ogrenciler (
    ogrenci_id INT AUTO_INCREMENT PRIMARY KEY,
    ad         VARCHAR(50) NOT NULL,
    soyad      VARCHAR(50) NOT NULL,
    eposta     VARCHAR(100) NOT NULL UNIQUE,
    sinif      TINYINT NOT NULL CHECK (sinif BETWEEN 1 AND 4),
    yas        TINYINT NOT NULL CHECK (yas BETWEEN 17 AND 60),
    bolum_id   INT NOT NULL,
    CONSTRAINT fk_ogr_bolum FOREIGN KEY (bolum_id) REFERENCES bolumler(bolum_id)
);

-- 9. Ödünç işlemleri tablosu
CREATE TABLE odunc_islemleri (
    odunc_id              INT AUTO_INCREMENT PRIMARY KEY,
    ogrenci_id            INT NOT NULL,
    kopya_id              INT NOT NULL,
    odunc_tarihi          DATE NOT NULL,
    beklenen_iade_tarihi  DATE NOT NULL,
    gercek_iade_tarihi    DATE DEFAULT NULL,          -- NULL ise henüz iade edilmemiş
    durum                 ENUM('ODUNCTE','IADE','GECIKTI','KAYIP') NOT NULL DEFAULT 'ODUNCTE',
    gecikme_cezasi        DECIMAL(6,2) DEFAULT 0.00,
    CONSTRAINT fk_odunc_ogr   FOREIGN KEY (ogrenci_id) REFERENCES ogrenciler(ogrenci_id),
    CONSTRAINT fk_odunc_kopya FOREIGN KEY (kopya_id)   REFERENCES kitap_kopyalari(kopya_id)
);

-- ============================================================
-- VERİ EKLEME (INSERT)
-- ============================================================

-- Bölümler
INSERT INTO bolumler (bolum_adi, fakulte) VALUES
('Bilgisayar Mühendisliği',     'Mühendislik Fakültesi'),
('Elektrik-Elektronik Müh.',    'Mühendislik Fakültesi'),
('Yönetim Bilişim Sistemleri',  'İşletme Fakültesi'),
('Yapay Zeka Mühendisliği',     'Mühendislik Fakültesi'),
('Matematik',                   'Fen Edebiyat Fakültesi');

-- Yazarlar
INSERT INTO yazarlar (ad, soyad, ulke) VALUES
('Ali',    'Yılmaz',  'Türkiye'),
('Zeynep', 'Kaya',    'Türkiye'),
('Burak',  'Arslan',  'Türkiye'),
('Ahmet',  'Çelik',   'Türkiye'),
('Hasan',  'Demir',   'Türkiye'),
('Martin', 'Kleppmann','Almanya'),
('Andrew', 'Tanenbaum','ABD');

-- Yayınevleri
INSERT INTO yayinevleri (yayinevi_adi, sehir) VALUES
('Akademi Yayınları',    'Ankara'),
('Bilim Kitap',          'İstanbul'),
('Seçkin Yayıncılık',    'Ankara'),
('Nobel Akademik',       'Ankara'),
('O''Reilly Media',      'Sebastopol');

-- Kategoriler
INSERT INTO kategoriler (kategori_adi) VALUES
('Veri Tabanı'),
('Yapay Zeka'),
('Algoritma'),
('Ağ ve Sistem'),
('Yazılım Mühendisliği'),
('Matematik');

-- Kitaplar (en az 8)
INSERT INTO kitaplar (kitap_adi, yayin_yili, isbn, yayinevi_id, kategori_id) VALUES
('Veri Tabanına Giriş',                      2021, '978-605-001-001-1', 1, 1),
('SQL Temelleri',                            2022, '978-605-001-002-2', 2, 1),
('Makine Öğrenmesi',                         2023, '978-605-001-003-3', 3, 2),
('Derin Öğrenme ile Yapay Zeka',             2024, '978-605-001-004-4', 4, 2),
('Veri Yapıları ve Algoritmalar',            2020, '978-605-001-005-5', 1, 3),
('Bilgisayar Ağları',                        2019, '978-605-001-006-6', 2, 4),
('Designing Data-Intensive Applications',    2017, '978-1-491-90342-6', 5, 1),
('Modern Operating Systems',                 2014, '978-0-13-359162-0', 5, 4),
('Yazılım Mimarisi Desenleri',               2022, '978-605-001-009-9', 3, 5),
('Ayrık Matematik',                          2018, '978-605-001-010-0', 4, 6);

-- Kitap-Yazar ilişkileri
INSERT INTO kitap_yazar (kitap_id, yazar_id) VALUES
(1, 1), (1, 2),   -- Veri Tabanına Giriş: Ali Yılmaz, Zeynep Kaya
(2, 1),           -- SQL Temelleri: Ali Yılmaz
(3, 3),           -- Makine Öğrenmesi: Burak Arslan
(4, 3), (4, 4),   -- Derin Öğrenme: Burak Arslan, Ahmet Çelik
(5, 4),           -- Veri Yapıları: Ahmet Çelik
(6, 5),           -- Bilgisayar Ağları: Hasan Demir
(7, 6),           -- DDIA: Martin Kleppmann
(8, 7),           -- Modern OS: Andrew Tanenbaum
(9, 5),           -- Yazılım Mimarisi: Hasan Demir
(10, 4);          -- Ayrık Matematik: Ahmet Çelik

-- Fiziksel kopyalar (en az 8)
INSERT INTO kitap_kopyalari (kitap_id, demirbas_no, raf_kodu, durum) VALUES
(1, 'KTP-2024-001', 'A-01', 'ODUNCTE'),
(1, 'KTP-2024-002', 'A-01', 'RAFTA'),
(2, 'KTP-2024-003', 'A-02', 'ODUNCTE'),
(3, 'KTP-2024-004', 'B-01', 'RAFTA'),
(4, 'KTP-2024-005', 'B-02', 'ODUNCTE'),
(5, 'KTP-2024-006', 'C-01', 'RAFTA'),
(6, 'KTP-2024-007', 'C-02', 'GECIKTI'),
(7, 'KTP-2024-008', 'D-01', 'ODUNCTE'),
(8, 'KTP-2024-009', 'D-02', 'RAFTA'),
(9, 'KTP-2024-010', 'E-01', 'RAFTA'),
(10,'KTP-2024-011', 'E-02', 'KAYIP');

-- Öğrenciler (en az 8)
INSERT INTO ogrenciler (ad, soyad, eposta, sinif, yas, bolum_id) VALUES
('Ayse',    'Demir',    'ayse.demir@uni.edu.tr',    3, 21, 1),
('Mehmet',  'Can',      'mehmet.can@uni.edu.tr',    2, 20, 3),
('Fatma',   'Yildiz',   'fatma.yildiz@uni.edu.tr',  4, 22, 1),
('Emre',    'Sahin',    'emre.sahin@uni.edu.tr',    1, 19, 4),
('Busra',   'Arslan',   'busra.arslan@uni.edu.tr',  3, 21, 2),
('Kerem',   'Koc',      'kerem.koc@uni.edu.tr',     2, 20, 1),
('Selin',   'Ozturk',   'selin.ozturk@uni.edu.tr',  4, 23, 5),
('Onur',    'Yilmaz',   'onur.yilmaz@uni.edu.tr',   1, 18, 4),
('Merve',   'Celik',    'merve.celik@uni.edu.tr',   3, 22, 3),
('Baris',   'Aktas',    'baris.aktas@uni.edu.tr',   2, 20, 2);

-- Ödünç işlemleri (en az 10)
-- Gecikme cezası: her gecikme günü için 1.50 TL
INSERT INTO odunc_islemleri
    (ogrenci_id, kopya_id, odunc_tarihi, beklenen_iade_tarihi, gercek_iade_tarihi, durum, gecikme_cezasi) VALUES
(1, 1,  '2026-04-01', '2026-04-15', NULL,         'ODUNCTE',  0.00),
(2, 3,  '2026-03-10', '2026-03-24', '2026-03-24', 'IADE',     0.00),
(3, 7,  '2026-02-15', '2026-03-01', '2026-03-10', 'IADE',     13.50),  -- 9 gün geç iade
(4, 5,  '2026-04-05', '2026-04-19', NULL,         'ODUNCTE',  0.00),
(5, 8,  '2026-03-20', '2026-04-03', NULL,         'GECIKTI',  25.50),  -- beklenen tarihi geçti
(6, 2,  '2026-04-10', '2026-04-24', NULL,         'ODUNCTE',  0.00),
(7, 6,  '2026-01-05', '2026-01-19', '2026-01-19', 'IADE',     0.00),
(8, 4,  '2026-04-12', '2026-04-26', NULL,         'ODUNCTE',  0.00),
(1, 9,  '2026-02-01', '2026-02-15', '2026-02-20', 'IADE',     7.50),   -- 5 gün geç
(9, 10, '2026-03-15', '2026-03-29', '2026-03-29', 'IADE',     0.00),
(10,3,  '2026-03-01', '2026-03-15', '2026-03-14', 'IADE',     0.00),
(2, 5,  '2026-01-10', '2026-01-24', '2026-01-24', 'IADE',     0.00);

-- ============================================================
-- VERİ GÜNCELLEME (UPDATE)
-- ============================================================

-- Güncelleme 1: Ayse Demir'in sınıf bilgisi güncelleniyor (1. sınıftan 3. sınıfa geçiş düzeltmesi)
UPDATE ogrenciler
SET sinif = 3
WHERE eposta = 'ayse.demir@uni.edu.tr';

-- Güncelleme 2: İade edilen kopyanın durumu RAFTA yapılıyor (iade işlemi onaylandı)
UPDATE kitap_kopyalari
SET durum = 'RAFTA'
WHERE demirbas_no = 'KTP-2024-007';

-- Güncelleme 3: Geciken ödünç işleminin durumu ve cezası güncelleniyor
UPDATE odunc_islemleri
SET durum = 'GECIKTI', gecikme_cezasi = 30.00
WHERE ogrenci_id = 5 AND kopya_id = 8;

-- Güncelleme 4: Veri bütünlüğü örneği - yanlış e-posta düzeltmesi (UNIQUE kısıtına uygun)
-- Önce yanlış kaydı düzeltiyoruz:
UPDATE ogrenciler
SET eposta = 'merve.celik2023@uni.edu.tr'
WHERE ogrenci_id = 9 AND eposta = 'merve.celik@uni.edu.tr';

-- ============================================================
-- VERİ SİLME (DELETE)
-- ============================================================

-- Silme 1: Yanlış eklenen test kaydı siliniyor
-- Önce test kaydı ekleyelim, sonra silelim
INSERT INTO kategoriler (kategori_adi) VALUES ('TEST_KATEGORI');
DELETE FROM kategoriler WHERE kategori_adi = 'TEST_KATEGORI';

-- Silme 2: Kayıp kopyanın ödünç kaydı siliniyor (kayıp olarak işaretlenen fiziksel kopya)
-- Not: FK kısıtı nedeniyle önce ödünç kaydı silinmeli, ardından kopya silinebilir.
-- Kopya 11 (KTP-2024-011, KAYIP) ile ilgili ödünç kaydı yoktur, doğrudan silinebilir.
-- Eğer ödünç kaydı olsaydı FK hatası alırdık; bu durum veri bütünlüğünü korur.
DELETE FROM kitap_kopyalari WHERE demirbas_no = 'KTP-2024-011' AND durum = 'KAYIP';

-- ============================================================
-- E) FİLTRELEME, SIRALAMA VE KOŞULLU SORGULAR
-- ============================================================

-- E1: BETWEEN - Yaşı 19 ile 21 arasında olan öğrencileri listeler
SELECT ad, soyad, yas, eposta
FROM ogrenciler
WHERE yas BETWEEN 19 AND 21
ORDER BY yas;

-- E2: LIKE - Adı 'A' veya 'a' ile başlayan öğrenciler (büyük/küçük harf duyarsız)
SELECT ad, soyad, eposta
FROM ogrenciler
WHERE ad LIKE 'A%' OR ad LIKE 'a%';

-- E3: AND/OR - 3. veya 4. sınıfta olan ve yaşı 21 ve üzeri öğrenciler
SELECT ad, soyad, sinif, yas
FROM ogrenciler
WHERE (sinif = 3 OR sinif = 4) AND yas >= 21
ORDER BY sinif, yas;

-- E4: ORDER BY - Kitapları yayın yılına göre en yeniden en eskiye sıralar
SELECT kitap_adi, yayin_yili, isbn
FROM kitaplar
ORDER BY yayin_yili DESC;

-- E5: IN - Veri Tabanı veya Yapay Zeka kategorisindeki kitapları listeler
SELECT k.kitap_adi, k.yayin_yili, kat.kategori_adi
FROM kitaplar k
JOIN kategoriler kat ON k.kategori_id = kat.kategori_id
WHERE kat.kategori_adi IN ('Veri Tabanı', 'Yapay Zeka');

-- E5b: NOT IN - Algoritma ve Matematik kategorisi dışındaki kitapları listeler
SELECT k.kitap_adi, kat.kategori_adi
FROM kitaplar k
JOIN kategoriler kat ON k.kategori_id = kat.kategori_id
WHERE kat.kategori_adi NOT IN ('Algoritma', 'Matematik');

-- E6: NULL kontrolü - Henüz iade edilmemiş (gercek_iade_tarihi NULL) ödünç işlemleri
SELECT oi.odunc_id, o.ad, o.soyad,
       oi.odunc_tarihi, oi.beklenen_iade_tarihi, oi.durum
FROM odunc_islemleri oi
JOIN ogrenciler o ON oi.ogrenci_id = o.ogrenci_id
WHERE oi.gercek_iade_tarihi IS NULL;

-- ============================================================
-- F) JOIN, GROUP BY, HAVING VE ALT SORGULARLA RAPORLAMA
-- ============================================================

-- F1: Her kitabın yazar(ları), yayınevi ve kategori bilgisi
SELECT
    k.kitap_id,
    k.kitap_adi,
    CONCAT(y.ad, ' ', y.soyad) AS yazar,
    yev.yayinevi_adi,
    kat.kategori_adi
FROM kitaplar k
JOIN kitap_yazar ky   ON k.kitap_id   = ky.kitap_id
JOIN yazarlar y       ON ky.yazar_id  = y.yazar_id
JOIN yayinevleri yev  ON k.yayinevi_id = yev.yayinevi_id
JOIN kategoriler kat  ON k.kategori_id = kat.kategori_id
ORDER BY k.kitap_id;

-- F2: Öğrenci, bölüm, kitap, demirbaş no, ödünç tarihi ve durum bilgisi
SELECT
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci,
    b.bolum_adi,
    k.kitap_adi,
    kk.demirbas_no,
    oi.odunc_tarihi,
    oi.durum
FROM odunc_islemleri oi
JOIN ogrenciler o      ON oi.ogrenci_id = o.ogrenci_id
JOIN bolumler b        ON o.bolum_id    = b.bolum_id
JOIN kitap_kopyalari kk ON oi.kopya_id = kk.kopya_id
JOIN kitaplar k        ON kk.kitap_id  = k.kitap_id
ORDER BY oi.odunc_tarihi DESC;

-- F3: Şu anda ödünçte olan veya geciken kitap kopyaları
SELECT
    kk.demirbas_no,
    kk.raf_kodu,
    kk.durum AS kopya_durumu,
    k.kitap_adi,
    CONCAT(o.ad, ' ', o.soyad) AS odunc_eden,
    oi.beklenen_iade_tarihi
FROM kitap_kopyalari kk
JOIN kitaplar k          ON kk.kitap_id   = k.kitap_id
JOIN odunc_islemleri oi  ON kk.kopya_id   = oi.kopya_id
JOIN ogrenciler o        ON oi.ogrenci_id = o.ogrenci_id
WHERE kk.durum IN ('ODUNCTE', 'GECIKTI')
  AND oi.gercek_iade_tarihi IS NULL;

-- F4: En çok kitap ödünç alan ilk 3 öğrenci
SELECT
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci,
    b.bolum_adi,
    COUNT(oi.odunc_id) AS toplam_odunc
FROM odunc_islemleri oi
JOIN ogrenciler o ON oi.ogrenci_id = o.ogrenci_id
JOIN bolumler b   ON o.bolum_id    = b.bolum_id
GROUP BY o.ogrenci_id, o.ad, o.soyad, b.bolum_adi
ORDER BY toplam_odunc DESC
LIMIT 3;

-- F5: 2020 ve sonrası basılan kitapları ödünç alan öğrenciler
SELECT DISTINCT
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci,
    k.kitap_adi,
    k.yayin_yili
FROM odunc_islemleri oi
JOIN ogrenciler o       ON oi.ogrenci_id = o.ogrenci_id
JOIN kitap_kopyalari kk ON oi.kopya_id   = kk.kopya_id
JOIN kitaplar k         ON kk.kitap_id   = k.kitap_id
WHERE k.yayin_yili >= 2020
ORDER BY k.yayin_yili DESC;

-- F6: Her kategoriye göre toplam kitap sayısı (GROUP BY)
SELECT
    kat.kategori_adi,
    COUNT(k.kitap_id) AS kitap_sayisi
FROM kategoriler kat
LEFT JOIN kitaplar k ON kat.kategori_id = k.kategori_id
GROUP BY kat.kategori_id, kat.kategori_adi
ORDER BY kitap_sayisi DESC;

-- F7: En az 2 kez ödünç alınmış kitaplar (HAVING)
SELECT
    k.kitap_adi,
    COUNT(oi.odunc_id) AS odunc_sayisi
FROM kitaplar k
JOIN kitap_kopyalari kk ON k.kitap_id  = kk.kitap_id
JOIN odunc_islemleri oi ON kk.kopya_id = oi.kopya_id
GROUP BY k.kitap_id, k.kitap_adi
HAVING COUNT(oi.odunc_id) >= 2
ORDER BY odunc_sayisi DESC;

-- F8: Hiç ödünç alınmamış kitap kopyaları (LEFT JOIN)
SELECT
    kk.demirbas_no,
    kk.raf_kodu,
    k.kitap_adi,
    kk.durum
FROM kitap_kopyalari kk
JOIN kitaplar k ON kk.kitap_id = k.kitap_id
LEFT JOIN odunc_islemleri oi ON kk.kopya_id = oi.kopya_id
WHERE oi.odunc_id IS NULL;

-- F9: Alt sorgu - Ortalamanın üzerinde ödünç alma yapan öğrenciler
SELECT
    CONCAT(o.ad, ' ', o.soyad) AS ogrenci,
    b.bolum_adi,
    COUNT(oi.odunc_id) AS toplam_odunc
FROM odunc_islemleri oi
JOIN ogrenciler o ON oi.ogrenci_id = o.ogrenci_id
JOIN bolumler b   ON o.bolum_id    = b.bolum_id
GROUP BY o.ogrenci_id, o.ad, o.soyad, b.bolum_adi
HAVING COUNT(oi.odunc_id) > (
    SELECT AVG(odunc_sayisi)
    FROM (
        SELECT COUNT(odunc_id) AS odunc_sayisi
        FROM odunc_islemleri
        GROUP BY ogrenci_id
    ) AS alt
)
ORDER BY toplam_odunc DESC;

-- F10: Gecikme cezası oluşan işlemler - öğrenci ve kitap bilgileriyle
SELECT
    CONCAT(o.ad, ' ', o.soyad)  AS ogrenci,
    b.bolum_adi,
    k.kitap_adi,
    kk.demirbas_no,
    oi.odunc_tarihi,
    oi.beklenen_iade_tarihi,
    oi.gercek_iade_tarihi,
    oi.gecikme_cezasi
FROM odunc_islemleri oi
JOIN ogrenciler o       ON oi.ogrenci_id = o.ogrenci_id
JOIN bolumler b         ON o.bolum_id    = b.bolum_id
JOIN kitap_kopyalari kk ON oi.kopya_id   = kk.kopya_id
JOIN kitaplar k         ON kk.kitap_id   = k.kitap_id
WHERE oi.gecikme_cezasi > 0
ORDER BY oi.gecikme_cezasi DESC;

-- ============================================================
-- G) GÖRÜNÜM (VIEW)
-- ============================================================

-- Kapsamlı kütüphane görünümü oluşturuluyor
CREATE OR REPLACE VIEW v_odunc_detay AS
SELECT
    oi.odunc_id,
    CONCAT(o.ad, ' ', o.soyad)     AS ogrenci_ad_soyad,
    b.bolum_adi,
    k.kitap_adi,
    CONCAT(y.ad, ' ', y.soyad)     AS yazar_ad_soyad,
    yev.yayinevi_adi,
    kat.kategori_adi,
    kk.demirbas_no,
    oi.odunc_tarihi,
    oi.beklenen_iade_tarihi,
    oi.gercek_iade_tarihi,
    oi.durum,
    oi.gecikme_cezasi
FROM odunc_islemleri oi
JOIN ogrenciler o       ON oi.ogrenci_id  = o.ogrenci_id
JOIN bolumler b         ON o.bolum_id     = b.bolum_id
JOIN kitap_kopyalari kk ON oi.kopya_id    = kk.kopya_id
JOIN kitaplar k         ON kk.kitap_id    = k.kitap_id
JOIN kitap_yazar ky     ON k.kitap_id     = ky.kitap_id
JOIN yazarlar y         ON ky.yazar_id    = y.yazar_id
JOIN yayinevleri yev    ON k.yayinevi_id  = yev.yayinevi_id
JOIN kategoriler kat    ON k.kategori_id  = kat.kategori_id;

-- VIEW'i çağırma - tüm kayıtları göster
SELECT * FROM v_odunc_detay;

-- VIEW üzerinde WHERE koşulu - sadece geciken veya ödünçte olanlar
SELECT *
FROM v_odunc_detay
WHERE durum IN ('GECIKTI', 'ODUNCTE')
ORDER BY beklenen_iade_tarihi;

-- ============================================================
-- BONUS: TRIGGER
-- ============================================================

DELIMITER $$

-- Trigger 1: Yeni ödünç işlemi eklendiğinde kopyanın durumunu ODUNCTE yap
CREATE TRIGGER trg_odunc_sonrasi_kopya_guncelle
AFTER INSERT ON odunc_islemleri
FOR EACH ROW
BEGIN
    UPDATE kitap_kopyalari
    SET durum = 'ODUNCTE'
    WHERE kopya_id = NEW.kopya_id;
END$$

-- Trigger 2: Ödünç işlemi iade edildiğinde (gercek_iade_tarihi güncellendi) kopyayı RAFTA yap
CREATE TRIGGER trg_iade_sonrasi_kopya_guncelle
AFTER UPDATE ON odunc_islemleri
FOR EACH ROW
BEGIN
    IF NEW.gercek_iade_tarihi IS NOT NULL AND OLD.gercek_iade_tarihi IS NULL THEN
        UPDATE kitap_kopyalari
        SET durum = 'RAFTA'
        WHERE kopya_id = NEW.kopya_id;
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- BONUS: STORED PROCEDURE
-- ============================================================

DELIMITER $$

-- Procedure 1: Yeni ödünç işlemi ekleme
CREATE PROCEDURE sp_odunc_ver(
    IN p_ogrenci_id INT,
    IN p_kopya_id   INT,
    IN p_sure_gun   INT  -- kaç gün ödünç verilecek
)
BEGIN
    DECLARE v_durum VARCHAR(20);
    -- Kopyanın müsait olup olmadığını kontrol et
    SELECT durum INTO v_durum FROM kitap_kopyalari WHERE kopya_id = p_kopya_id;
    IF v_durum = 'RAFTA' THEN
        INSERT INTO odunc_islemleri
            (ogrenci_id, kopya_id, odunc_tarihi, beklenen_iade_tarihi, durum)
        VALUES
            (p_ogrenci_id, p_kopya_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_sure_gun DAY), 'ODUNCTE');
        SELECT 'Ödünç işlemi başarıyla kaydedildi.' AS mesaj;
    ELSE
        SELECT CONCAT('Kopya müsait değil. Mevcut durum: ', v_durum) AS mesaj;
    END IF;
END$$

-- Procedure 2: İade işlemi gerçekleştirme
CREATE PROCEDURE sp_iade_al(
    IN p_odunc_id       INT,
    IN p_ceza_per_gun   DECIMAL(5,2)   -- günlük gecikme ücreti
)
BEGIN
    DECLARE v_beklenen DATE;
    DECLARE v_gecikme_gun INT DEFAULT 0;
    DECLARE v_ceza DECIMAL(6,2) DEFAULT 0.00;

    SELECT beklenen_iade_tarihi INTO v_beklenen
    FROM odunc_islemleri WHERE odunc_id = p_odunc_id;

    IF CURDATE() > v_beklenen THEN
        SET v_gecikme_gun = DATEDIFF(CURDATE(), v_beklenen);
        SET v_ceza        = v_gecikme_gun * p_ceza_per_gun;
    END IF;

    UPDATE odunc_islemleri
    SET gercek_iade_tarihi = CURDATE(),
        durum              = IF(v_gecikme_gun > 0, 'IADE', 'IADE'),
        gecikme_cezasi     = v_ceza
    WHERE odunc_id = p_odunc_id;

    SELECT CONCAT('İade tamamlandı. Gecikme: ', v_gecikme_gun,
                  ' gün, Ceza: ', v_ceza, ' TL') AS sonuc;
END$$

DELIMITER ;

-- ============================================================
-- BONUS: INDEX
-- ============================================================

-- Sık kullanılan JOIN ve WHERE sorgularını hızlandırmak için index oluşturma
-- odunc_islemleri tablosunda ogrenci_id ve durum üzerinde arama hızlanır
CREATE INDEX idx_odunc_ogrenci ON odunc_islemleri(ogrenci_id);
CREATE INDEX idx_odunc_durum   ON odunc_islemleri(durum);
-- kitap_kopyalari tablosunda kitap bazlı sorguları hızlandırır
CREATE INDEX idx_kopya_kitap   ON kitap_kopyalari(kitap_id);

-- ============================================================
-- BONUS: DATEDIFF ile gecikme gün sayısı raporu
-- ============================================================

-- Geciken veya iade edilen işlemlerde kaç gün gecikme oluştuğunu hesaplar
SELECT
    CONCAT(o.ad, ' ', o.soyad)  AS ogrenci,
    k.kitap_adi,
    oi.beklenen_iade_tarihi,
    COALESCE(oi.gercek_iade_tarihi, CURDATE()) AS kontrol_tarihi,
    GREATEST(0, DATEDIFF(
        COALESCE(oi.gercek_iade_tarihi, CURDATE()),
        oi.beklenen_iade_tarihi
    )) AS gecikme_gun_sayisi,
    oi.gecikme_cezasi
FROM odunc_islemleri oi
JOIN ogrenciler o       ON oi.ogrenci_id = o.ogrenci_id
JOIN kitap_kopyalari kk ON oi.kopya_id   = kk.kopya_id
JOIN kitaplar k         ON kk.kitap_id   = k.kitap_id
WHERE oi.gecikme_cezasi > 0 OR oi.durum = 'GECIKTI'
ORDER BY gecikme_gun_sayisi DESC;

-- ============================================================
-- SQL DOSYASI SONU
-- ============================================================
