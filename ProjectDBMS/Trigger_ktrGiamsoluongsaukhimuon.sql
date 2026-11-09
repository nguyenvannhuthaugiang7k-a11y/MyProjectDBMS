USE QuanLyThuVien;

DELIMITER $$

CREATE TRIGGER trg_GiamSoLuongSauKhiMuon
AFTER INSERT ON PhieuMuon
FOR EACH ROW
BEGIN
    UPDATE Sach
    SET SoLuongCon = SoLuongCon - 1
    WHERE MaSach = NEW.MaSach;
END$$

DELIMITER ;

SHOW TRIGGERS FROM QuanLyThuVien;