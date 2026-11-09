USE QuanLyThuVien;

DELIMITER $$

CREATE TRIGGER trg_TangSoLuongSauKhiTra
AFTER UPDATE ON PhieuMuon
FOR EACH ROW
BEGIN
    IF OLD.TrangThai = 'DANG_MUON'
       AND NEW.TrangThai = 'DA_TRA' THEN

        UPDATE Sach
        SET SoLuongCon = SoLuongCon + 1
        WHERE MaSach = NEW.MaSach;

    END IF;
END$$

DELIMITER ;

SHOW TRIGGERS FROM QuanLyThuVien;