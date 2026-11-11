# Library Management System

A desktop library-management application built with **Java Swing**, **NetBeans**, and **MySQL**. The application includes account login, role-based navigation, book management, account lookup, borrowing and returning books, inventory updates, and overdue-fine calculation.

## Technology Stack

- Java Swing (NetBeans project; project properties specify Java source/target level 26)
- MySQL database: `QuanLyThuVien`
- JDBC with MySQL Connector/J
- MySQL stored procedures, function, triggers, and transactions

## Project Structure

```text
MyProjectDBMS/
├── README.md
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
                ├── TaiKhoanForm.java
                └── PhieuMuonForm.java
```

The repository also contains NetBeans-generated build output and project configuration. Maintain the Java source under `src/`.

## Application Features

### Authentication and roles
- Login checks the username and password against `TaiKhoan`.
- The main screen displays the logged-in user's name and role.
- The application distinguishes `ADMIN` and `DOCGIA`.
- Admin users can access book and account-management screens.
- Readers are restricted to their own borrowing slips; their account ID is filled automatically and made read-only in the borrowing form.

### Book management
The `SachForm` screen supports listing, adding, editing, deleting, searching, and refreshing book records. It displays total quantity and available quantity.

### Account management
The `TaiKhoanForm` screen displays and searches account records. The visible account fields are `MaTK`, `TenTK`, `HoTen`, and `VaiTro`.

### Borrowing and returning
The `PhieuMuonForm` screen supports:
- Creating borrowing slips through `sp_MuonSach`
- Viewing all slips as an admin and only personal slips as a reader
- Selecting a slip and returning it through `sp_TraSach`
- Displaying overdue fines through `fn_TinhTienPhat`
- Displaying borrowing date, due date, return date, and status

The form expects due dates in `yyyy-MM-dd` format and asks for confirmation before returning a selected slip.

## Database

The Java connection and supplied SQL routines use the database name **`QuanLyThuVien`**.

### Tables and fields referenced by the source

| Table | Fields referenced |
|---|---|
| `TaiKhoan` | `MaTK`, `TenTK`, `MatKhau`, `HoTen`, `VaiTro` |
| `Sach` | `MaSach`, `TenSach`, `TacGia`, `TheLoai`, `SoLuong`, `SoLuongCon` |
| `PhieuMuon` | `MaPM`, `MaTK`, `MaSach`, `NgayMuon`, `HanTra`, `NgayTra`, `TrangThai` |

The application logic associates each borrowing slip with an account and a book. **The current repository does not include a complete database initialization script** containing all `CREATE TABLE` statements, primary/foreign-key definitions, data types, constraints, and sample records. The table/column list above documents what the checked-in Java and SQL code references; it is not a complete physical schema.

### Borrowing status values
- `DANG_MUON` — currently borrowed
- `DA_TRA` — returned

## Stored Procedures, Function, and Triggers

Run the SQL scripts after creating the `QuanLyThuVien` database and its required tables.

### 1. Stored procedure: `sp_MuonSach`

File: `Procedure_muonsach.sql`

Parameters:
- `p_MaTK INT` — account ID
- `p_MaSach INT` — book ID
- `p_HanTra DATE` — due date

The procedure starts a transaction, checks that the account and book exist, inserts a row into `PhieuMuon` with `NgayMuon = CURDATE()` and status `DANG_MUON`, then commits. Its SQL exception handler rolls back and rethrows the error. The inventory triggers run as a result of the insert.

```sql
CALL sp_MuonSach(1, 1, '2026-12-01');
```

Use IDs that exist in your own database.

### 2. Stored procedure: `sp_TraSach`

File: `Procedure_trasach.sql`

Parameter: `p_MaPM INT` — borrowing-slip ID.

The procedure starts a transaction, locks and reads the selected slip using `FOR UPDATE`, and requires its status to be `DANG_MUON`. It then sets `NgayTra = CURDATE()` and `TrangThai = 'DA_TRA'` before committing. Invalid or already-returned slips raise SQLSTATE `45000`. SQL exceptions cause a rollback and are rethrown.

```sql
CALL sp_TraSach(1);
```

The Java return button calls this procedure using JDBC `CallableStatement`.

### 3. Function: `fn_TinhTienPhat`

File: `Function_tinhtienphat.sql`

Inputs: `p_HanTra DATE` and `p_NgayTra DATE`. If the return date is NULL, the function uses `CURDATE()`. It calculates non-negative overdue days and charges **5,000 VND per overdue day**.

```sql
SELECT fn_TinhTienPhat('2026-11-01', '2026-11-04') AS TienPhat;
```

The example result is `15000.00`. The borrowing-slip screen calls this function to display the fine for the selected record.

### 4. Triggers

| Trigger | Event | Behavior |
|---|---|---|
| `trg_KiemTraSachTruocKhiMuon` | `BEFORE INSERT ON PhieuMuon` | Rejects borrowing if the book is missing or `SoLuongCon <= 0`. |
| `trg_GiamSoLuongSauKhiMuon` | `AFTER INSERT ON PhieuMuon` | Decreases `Sach.SoLuongCon` by one. |
| `trg_TangSoLuongSauKhiTra` | `AFTER UPDATE ON PhieuMuon` | Increases `Sach.SoLuongCon` when status changes from `DANG_MUON` to `DA_TRA`. |

SQL files:
- `Trigger_ktrSachtrckhimuon.sql`
- `Trigger_ktrGiamsoluongsaukhimuon.sql`
- `Trigger_TangSLsaukhitra.sql`

## Setup and Run

### Prerequisites
- MySQL Server and MySQL Workbench (or another MySQL client)
- NetBeans IDE
- A JDK compatible with the project's configured Java level
- MySQL Connector/J

### 1. Prepare MySQL
1. Start MySQL Server.
2. Create/import the `QuanLyThuVien` database, including the tables and required data.
3. Execute the three trigger scripts, two procedure scripts, and function script from `ProjectDBMS/`.
4. Ensure at least one valid account exists in `TaiKhoan`.

The repository does not currently provide the complete schema or seed-data SQL, so these must be supplied separately before the application can run.

Verify the routines and triggers:

```sql
SHOW PROCEDURE STATUS WHERE Db = 'QuanLyThuVien';
SHOW FUNCTION STATUS WHERE Db = 'QuanLyThuVien';
SHOW TRIGGERS FROM QuanLyThuVien;
```

The scripts use `CREATE`; if an object already exists, remove or rename it before executing the corresponding script again.

### 2. Configure JDBC

Connection settings are in `ProjectDBMS/JavaApplication1/src/database/DBConnection.java`:

```java
private static final String URL =
    "jdbc:mysql://localhost:3306/QuanLyThuVien"
    + "?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh";

private static final String USER = "root";
private static final String PASSWORD = "12345";
```

Change the host, port, database name, username, and password for your local MySQL setup. The project loads the driver `com.mysql.cj.jdbc.Driver`.

Add MySQL Connector/J to the NetBeans project libraries/classpath. The current project properties refer to a Connector/J JAR at an absolute path on the original developer's computer; update that path on another machine.

> **Security:** The source currently contains a hard-coded database password. Replace it and do not publish real credentials. Prefer environment variables or a local configuration file excluded from version control.

### 3. Run in NetBeans
1. Open `ProjectDBMS/JavaApplication1` in NetBeans.
2. Configure the JDK and MySQL Connector/J library.
3. Update the connection settings in `DBConnection.java`.
4. Run `database.TestConnection` to test the connection.
5. Run `view.LoginForm` to start the application.

Create valid test accounts in `TaiKhoan` with role values expected by the application, such as `ADMIN` and `DOCGIA`.

## SQL Script Index

| File | Purpose |
|---|---|
| `Procedure_muonsach.sql` | Creates `sp_MuonSach` |
| `Procedure_trasach.sql` | Creates `sp_TraSach` |
| `Function_tinhtienphat.sql` | Creates `fn_TinhTienPhat` |
| `Trigger_ktrSachtrckhimuon.sql` | Checks stock before borrowing |
| `Trigger_ktrGiamsoluongsaukhimuon.sql` | Decreases stock after borrowing |
| `Trigger_TangSLsaukhitra.sql` | Restores stock after returning |

## Notes and Limitations

- A full database schema and sample-data script are not included in the current repository.
- The connection class hard-codes credentials; change this before sharing or deploying the application.
- The login code compares the supplied password directly with `TaiKhoan.MatKhau`. For production use, store salted password hashes and verify them securely.
- Confirm the final schema's keys, constraints, and data types before deployment.
