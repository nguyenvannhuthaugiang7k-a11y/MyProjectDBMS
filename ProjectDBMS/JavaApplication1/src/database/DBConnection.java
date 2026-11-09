package database;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {

    private static final String URL =
        "jdbc:mysql://localhost:3306/QuanLyThuVien"
        + "?useSSL=false&serverTimezone=Asia/Ho_Chi_Minh";

    private static final String USER = "root";

    private static final String PASSWORD = "12345";

    public static Connection getConnection() {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");

            Connection conn = DriverManager.getConnection(
                URL, USER, PASSWORD
            );

            System.out.println("Ket noi MySQL thanh cong!");

            return conn;

        } catch (Exception e) {
            System.out.println("Ket noi MySQL that bai!");
            e.printStackTrace();

            return null;
        }
    }
}