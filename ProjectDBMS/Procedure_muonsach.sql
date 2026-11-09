-- Tạo Stored Procedure mượn sách
USE QuanLyThuVien;

DELIMITER $$

CREATE PROCEDURE sp_MuonSach(
    IN p_MaTK INT,
    IN p_MaSach INT,
    IN p_HanTra DATE
)
BEGIN
    DECLARE v_MaTK INT;
    DECLARE v_MaSach INT;

    -- Neu co loi, huy giao dich va bao loi
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Kiem tra tai khoan ton tai
    SELECT MaTK INTO v_MaTK
    FROM TaiKhoan
    WHERE MaTK = p_MaTK;

    -- Kiem tra sach ton tai
    SELECT MaSach INTO v_MaSach
    FROM Sach
    WHERE MaSach = p_MaSach;

    -- Tao phieu muon
    INSERT INTO PhieuMuon (
        MaTK,
        MaSach,
        NgayMuon,
        HanTra,
        TrangThai
    )
    VALUES (
        p_MaTK,
        p_MaSach,
        CURDATE(),
        p_HanTra,
        'DANG_MUON'
    );

    COMMIT;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS
WHERE Db = 'QuanLyThuVien';