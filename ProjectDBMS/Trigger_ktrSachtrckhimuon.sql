USE QuanLyThuVien;

DELIMITER $$

CREATE TRIGGER trg_KiemTraSachTruocKhiMuon
BEFORE INSERT ON PhieuMuon
FOR EACH ROW
BEGIN
    DECLARE v_SoLuongCon INT;

    SELECT SoLuongCon
    INTO v_SoLuongCon
    FROM Sach
    WHERE MaSach = NEW.MaSach;

    IF v_SoLuongCon IS NULL OR v_SoLuongCon <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sach da het, khong the muon!';
    END IF;
END$$

DELIMITER ;

SHOW TRIGGERS FROM QuanLyThuVien;