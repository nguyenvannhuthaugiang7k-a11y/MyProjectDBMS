import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class HelloWorld {

    public static void main(String[] args) {

        String url = "jdbc:mysql://localhost:3306/test";
        String user = "root";
        String password = "YOUR_PASSWORD";

        try {
            Connection conn = DriverManager.getConnection(
                url, user, password
            );

            System.out.println("Connected!");

            conn.close();

        } catch (SQLException e) {
            System.out.println("Cannot connect!");
            e.printStackTrace();
        }
    }
}