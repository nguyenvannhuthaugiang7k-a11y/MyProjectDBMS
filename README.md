# Library Management System (ProjectDBMS)

A Java Swing application connected to MySQL for basic library management. The repository contains a NetBeans Java project and separate SQL scripts for borrowing/returning books, stock triggers, and overdue-fine calculation.

## Technology Stack

- Java Swing (NetBeans project)
- MySQL
- JDBC using MySQL Connector/J
- Stored procedures, functions, and triggers

## Repository Layout

```text
MyProjectDBMS/
└── ProjectDBMS/
    ├── Function_tinhtienphat.sql
    ├── Procedure_muonsach.sql
    ├── Procedure_trasach.sql
    ├── Trigger_TangSLsaukhitra.sql
    ├── Trigger_ktrGiamsoluongsaukhimuon.sql
    ├── Trigger_ktrSachtrckhimuon.sql
    └── JavaApplication1/
        └── src/
            ├── database/
            │   ├── DBConnection.java
            │   └── TestConnection.java
            └── view/
                ├── LoginForm.java
                ├── MainForm.java
                ├── SachForm.java
                └── PhieuMuonForm.java
```

## Database

The Java connection and SQL scripts use the database name `QuanLyThuVien`.

> **Important:** This repository currently contains SQL scripts for routines and triggers, but does not include a complete database initialization script (such as `CREATE DATABASE`, all `CREATE TABLE` statements, and seed data). Create/import the schema and tables before running the application. The table and column names below are the ones referenced by the checked-in Java and SQL files; they are not a replacement for the complete schema definition.

### Tables and fields referenced by the project

- `TaiKhoan`: `MaTK`, `TenTK`, `MatKhau`, `HoTen`, `VaiTro`
- `Sach`: `MaSach`, `TenSach`, `TacGia`, `TheLoai`, `SoLuong`, `SoLuongCon`
- `PhieuMuon`: `MaPM`, `MaTK`, `MaSach`, `NgayMuon`, `HanTra`, `NgayTra`, `TrangThai`

The SQL and application code indicate that a borrowing record refers to an account and a book. Verify the actual primary keys, foreign keys, data types, defaults, and constraints against your database schema.

### Borrowing status values

The stored procedures and triggers use these status strings:

- `DANG_MUON` — currently borrowed
- `DA_TRA` — returned

## Database Objects

The SQL scripts in `ProjectDBMS/` define the following objects. Run each script in MySQL after the `QuanLyThuVien` schema and required tables have been created.

### 1. Stored procedure: `sp_MuonSach`

File: `Procedure_muonsach.sql`

Parameters:
- `p_MaTK INT` — account ID
- `p_MaSach INT` — book ID
- `p_HanTra DATE` — due date

It checks that the account and book can be found, inserts a row into `PhieuMuon` with today's date and status `DANG_MUON`, and commits the transaction. On SQL exception, it rolls back and rethrows the error. The stock triggers run when the borrowing row is inserted.

Example call:

```sql
CALL sp_MuonSach(1, 1, '2026-12-01');
```

Replace the sample IDs and date with values that exist in your database.

### 2. Stored procedure: `sp_TraSach`

File: `Procedure_trasach.sql`

Parameter: `p_MaPM INT` — borrowing slip ID.

It locks the borrowing row using `FOR UPDATE`, requires the current status to be `DANG_MUON`, then sets `NgayTra = CURDATE()` and `TrangThai = 'DA_TRA'`. Invalid/already-returned slips raise SQLSTATE `45000`. SQL exceptions trigger a rollback.

Example call:

```sql
CALL sp_TraSach(1);
```

### 3. Function: `fn_TinhTienPhat`

File: `Function_tinhtienphat.sql`

Inputs: `p_HanTra DATE`, `p_NgayTra DATE`.

The function calculates overdue days as the non-negative difference between the return date (or today when the return date is NULL) and the due date. The fine is **5,000 per overdue day**.

```sql
SELECT fn_TinhTienPhat('2026-11-01', '2026-11-04') AS TienPhat;
```

For the example above, the result is `15000.00`. The function uses `CURDATE()` when `p_NgayTra` is NULL.

### 4. Triggers

| Trigger | Event | Behavior |
|---|---|---|
| `trg_KiemTraSachTruocKhiMuon` | `BEFORE INSERT ON PhieuMuon` | Rejects a borrowing insert when the book cannot be found or `SoLuongCon <= 0`. |
| `trg_GiamSoLuongSauKhiMuon` | `AFTER INSERT ON PhieuMuon` | Decreases `Sach.SoLuongCon` by one for the borrowed book. |
| `trg_TangSoLuongSauKhiTra` | `AFTER UPDATE ON PhieuMuon` | Increases `Sach.SoLuongCon` by one when status changes from `DANG_MUON` to `DA_TRA`. |

These triggers are defined in:
- `Trigger_ktrSachtrckhimuon.sql`
- `Trigger_ktrGiamsoluongsaukhimuon.sql`
- `Trigger_TangSLsaukhitra.sql`

## Configure and Run

### 1. Prepare MySQL

1. Start your MySQL server.
2. Create or import the `QuanLyThuVien` database, including the required tables and data. The complete table-creation and seed-data scripts are not present in this repository.
3. In MySQL Workbench or another SQL client, execute the three trigger scripts, both procedure scripts, and the function script from `ProjectDBMS/`.
4. Confirm the objects exist:

```sql
SHOW PROCEDURE STATUS WHERE Db = 'QuanLyThuVien';
SHOW FUNCTION STATUS WHERE Db = 'QuanLyThuVien';
SHOW TRIGGERS FROM QuanLyThuVien;
```

If re-running an object script, check whether that object already exists; the current scripts use `CREATE` rather than `CREATE OR REPLACE` or a preceding `DROP`.

### 2. Configure the JDBC connection

The connection settings are in `JavaApplication1/src/database/DBConnection.java`:

```java
private static final String URL =
    "jdbc:mysql://localhost:3306/QuanLyThuVien"
    + "?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh";

private static final String USER = "root";
private static final String PASSWORD = "12345";
```

Update the host, port, database name, username, and password to match your local MySQL installation. **Do not use a real or privileged password in a public repository.** Prefer environment variables or a local configuration file excluded from version control.

The project uses the MySQL JDBC driver class `com.mysql.cj.jdbc.Driver`. The NetBeans project properties reference a local Connector/J JAR path on the original developer's computer; that absolute path will not work on other computers automatically. Add the MySQL Connector/J JAR to the project libraries/classpath on your machine.

### 3. Open and run in NetBeans

1. Open `ProjectDBMS/JavaApplication1` as a NetBeans project.
2. Ensure the JDK and MySQL Connector/J dependency are configured.
3. Update `DBConnection.java` with your local database credentials.
4. Run `database.TestConnection` to test the connection.
5. Run `view.LoginForm` (the configured main class) to open the application.

A valid account must already exist in `TaiKhoan`. The login query checks `TenTK` and `MatKhau` and reads `MaTK`, `HoTen`, and `VaiTro`. The application code expects role strings such as `ADMIN` and `DOCGIA`.

## Application Features Visible in the Source

- Login using a row from `TaiKhoan`
- Book management form (`SachForm`)
- Borrowing-slip form (`PhieuMuonForm`)
- Admin-specific visibility for book/account management controls
- Stored-procedure call from Java for borrowing books

The return-book button handler in the checked-in `PhieuMuonForm.java` is currently a TODO placeholder; the SQL procedure `sp_TraSach` exists, but the UI handler does not yet call it in the checked-in source.

## Security and Implementation Notes

- The checked-in connection class contains a hard-coded database password. Change it and avoid committing credentials.
- The login query compares the stored password directly. For a real deployment, store salted password hashes and verify them in application code.
- Review transaction and trigger behavior against the final schema, especially stock quantity constraints and foreign keys.
- Keep the full schema and sample data in a separate SQL initialization script so a new developer can set up the database consistently.

## SQL Script Index

| File | Purpose |
|---|---|
| `Procedure_muonsach.sql` | Creates `sp_MuonSach` |
| `Procedure_trasach.sql` | Creates `sp_TraSach` |
| `Function_tinhtienphat.sql` | Creates `fn_TinhTienPhat` |
| `Trigger_ktrSachtrckhimuon.sql` | Checks stock before borrowing |
| `Trigger_ktrGiamsoluongsaukhimuon.sql` | Decreases stock after borrowing |
| `Trigger_TangSLsaukhitra.sql` | Increases stock after return |

---
