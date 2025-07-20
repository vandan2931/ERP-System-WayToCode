package servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import utils.DatabaseUtil;
import constants.Constants;

public class AdminSignupServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter(Constants.COL_NAME);
        String email = request.getParameter(Constants.COL_EMAIL);
        String contact = request.getParameter(Constants.COL_CONTACT);
        String password = request.getParameter(Constants.COL_PASSWORD);

        try (Connection conn = DatabaseUtil.getConnection()) {
            String query = "INSERT INTO " + Constants.TABLE_EMPLOYEES + " ("
                    + Constants.COL_NAME + ", " + Constants.COL_EMAIL + ", "
                    + Constants.COL_CONTACT + ", " + Constants.COL_PASSWORD + ", "
                    + Constants.COL_STATUS + ", " + Constants.COL_ROLE + ") VALUES (?, ?, ?, ?, '"
                    + Constants.STATUS_APPROVED + "', '" + Constants.ROLE_ADMIN + "')";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, contact);
            ps.setString(4, password);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                response.sendRedirect(Constants.JSP_ADMIN_LOGIN);
            } else {
                response.getWriter().println(Constants.ERR_REGISTRATION_FAILED);
            }
        } catch (Exception e) {
            e.printStackTrace(response.getWriter());
        }
    }
}
