package servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import utils.DatabaseUtil;
import constants.Constants;

public class AdminLoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter(Constants.COL_EMAIL);
        String password = request.getParameter(Constants.COL_PASSWORD);

        try (Connection conn = DatabaseUtil.getConnection()) {
            String query = "SELECT " + Constants.COL_ID + ", " + Constants.COL_NAME + " FROM "
                    + Constants.TABLE_EMPLOYEES + " WHERE " + Constants.COL_EMAIL + " = ? AND "
                    + Constants.COL_PASSWORD + " = ? AND " + Constants.COL_ROLE + " = '"
                    + Constants.ROLE_ADMIN + "' AND " + Constants.COL_STATUS + " = '"
                    + Constants.STATUS_APPROVED + "'";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute(Constants.SESSION_ADMIN_ID, rs.getInt(Constants.COL_ID));
                session.setAttribute(Constants.SESSION_ADMIN_NAME, rs.getString(Constants.COL_NAME));
                response.sendRedirect(Constants.JSP_ADMIN_DASHBOARD);
            } else {
                response.sendRedirect(Constants.JSP_ADMIN_LOGIN + "?error=" + Constants.ERR_INVALID_CREDENTIALS);
            }
        } catch (Exception e) {
            response.sendRedirect(Constants.JSP_ADMIN_LOGIN + "?error=" + Constants.ERR_LOGIN_ERROR);
            e.printStackTrace();
        }
    }
}
