-- Tạo Function fn_TinhTienPhat

USE QuanLyThuVien;

DELIMITER $$

CREATE FUNCTION fn_TinhTienPhat(
    p_HanTra DATE,
    p_NgayTra DATE
)
RETURNS DECIMAL(15,2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE v_SoNgayTre INT;
    DECLARE v_TienPhat DECIMAL(15,2);

    SET v_SoNgayTre = GREATEST(
        DATEDIFF(COALESCE(p_NgayTra, CURDATE()), p_HanTra),
        0
    );

    SET v_TienPhat = v_SoNgayTre * 5000;

    RETURN v_TienPhat;
END$$

DELIMITER ;

SHOW FUNCTION STATUS
WHERE Db = 'QuanLyThuVien';

SELECT fn_TinhTienPhat('2026-11-01', '2026-11-04')
AS TienPhat;