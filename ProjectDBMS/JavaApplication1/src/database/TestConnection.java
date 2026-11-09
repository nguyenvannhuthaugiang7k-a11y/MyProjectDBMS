package database;

import java.sql.Connection;
import java.sql.SQLException;

public class TestConnection {

    public static void main(String[] args) {

        Connection conn = DBConnection.getConnection();

        if (conn != null) {
            System.out.println("Da ket noi den database QuanLyThuVien!");

            try {
                conn.close();
                System.out.println("Da dong ket noi.");
            } catch (SQLException e) {
                e.printStackTrace();
            }

        } else {
            System.out.println("Khong the ket noi database!");
        }
    }
}