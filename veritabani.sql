CREATE DATABASE diyetisyen_takip;

USE diyetisyen_takip;

CREATE TABLE Diyetisyenler (
    dyt_id INT PRIMARY KEY AUTO_INCREMENT,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    uzmanlik_alani VARCHAR(100)
);

CREATE TABLE Danisanlar (
    dns_id INT PRIMARY KEY AUTO_INCREMENT,
    tc_kimlik VARCHAR(11) UNIQUE,
    ad VARCHAR(50) NOT NULL,
    soyad VARCHAR(50) NOT NULL,
    telefon VARCHAR(15)
);

CREATE TABLE Olcumler (
    olcum_id INT PRIMARY KEY AUTO_INCREMENT,
    dns_id INT,
    boy DECIMAL(5,2) CHECK (boy > 0),
    kilo DECIMAL(5,2) CHECK (kilo > 0),
    olcum_tarihi DATE,
    FOREIGN KEY (dns_id) REFERENCES Danisanlar(dns_id) ON DELETE CASCADE
);

CREATE TABLE Randevular (
    randevu_id INT PRIMARY KEY AUTO_INCREMENT,
    dyt_id INT,
    dns_id INT,
    tarih DATETIME,
    FOREIGN KEY (dyt_id) REFERENCES Diyetisyenler(dyt_id),
    FOREIGN KEY (dns_id) REFERENCES Danisanlar(dns_id)
);

DELIMITER $$
CREATE TRIGGER trg_gunluk_kota_kontrol
BEFORE INSERT ON Randevular
FOR EACH ROW
BEGIN
    DECLARE gunluk_randevu_sayisi INT;
    
    SELECT COUNT(*) INTO gunluk_randevu_sayisi 
    FROM Randevular 
    WHERE dyt_id = NEW.dyt_id AND DATE(tarih) = DATE(NEW.tarih);
    
    IF gunluk_randevu_sayisi >= 8 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Günlük 8 randevu kotası dolmuştur!';
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER trg_gecmis_tarih_engelle
BEFORE INSERT ON Randevular
FOR EACH ROW
BEGIN
    IF NEW.tarih < NOW() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Geçmiş bir tarihe randevu oluşturulamaz!';
    END IF;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_RandevuEkle (IN p_dyt_id INT, IN p_dns_id INT, IN p_tarih DATETIME)
BEGIN
    INSERT INTO Randevular (dyt_id, dns_id, tarih) 
    VALUES (p_dyt_id, p_dns_id, p_tarih);
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_RandevuListe ()
BEGIN
    SELECT r.randevu_id, dyt.ad AS Diyetisyen, dns.ad AS Danisan, r.tarih 
    FROM Randevular r
    INNER JOIN Diyetisyenler dyt ON r.dyt_id = dyt.dyt_id
    INNER JOIN Danisanlar dns ON r.dns_id = dns.dns_id
    ORDER BY r.tarih DESC;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_RandevuGuncelle (IN p_randevu_id INT, IN p_dyt_id INT, IN p_dns_id INT, IN p_tarih DATETIME)
BEGIN
    UPDATE Randevular 
    SET dyt_id = p_dyt_id, dns_id = p_dns_id, tarih = p_tarih
    WHERE randevu_id = p_randevu_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE sp_RandevuSil (IN p_randevu_id INT)
BEGIN
    DELETE FROM Randevular 
    WHERE randevu_id = p_randevu_id;
END $$
DELIMITER ;
