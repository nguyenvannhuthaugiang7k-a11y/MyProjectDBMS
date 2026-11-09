-- Tạo Stored Procedure tra sach

USE QuanLyThuVien;

DELIMITER $$

CREATE PROCEDURE sp_TraSach(
    IN p_MaPM INT
)
BEGIN
    DECLARE v_TrangThai VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    -- Kiem tra phieu muon
    SELECT TrangThai INTO v_TrangThai
    FROM PhieuMuon
    WHERE MaPM = p_MaPM
    FOR UPDATE;

    -- Kiem tra phieu muon chua duoc tra
    IF v_TrangThai <> 'DANG_MUON' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Phieu muon khong hop le hoac da duoc tra!';
    END IF;

    -- Cap nhat trang thai tra sach
    UPDATE PhieuMuon
    SET NgayTra = CURDATE(),
        TrangThai = 'DA_TRA'
    WHERE MaPM = p_MaPM;

    COMMIT;
END$$

DELIMITER ;

SHOW PROCEDURE STATUS
WHERE Db = 'QuanLyThuVien';