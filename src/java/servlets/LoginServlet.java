package servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import utils.DatabaseUtil;
import constants.Constants;
import java.net.URLEncoder;

public class LoginServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter(Constants.COL_EMAIL);
        String password = request.getParameter(Constants.COL_PASSWORD);

        try (Connection conn = DatabaseUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(Constants.QUERY_GET_EMPLOYEE_BY_CREDENTIALS);
            ps.setString(1, email);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                String status = rs.getString(Constants.COL_STATUS);
                String role = rs.getString(Constants.COL_ROLE);

                if (!Constants.STATUS_APPROVED.equalsIgnoreCase(status)) {
                    response.sendRedirect(Constants.JSP_LOGIN + "?error="
                            + URLEncoder.encode(Constants.ERR_ACCOUNT_PENDING, "UTF-8"));
                    return;
                }

                HttpSession session = request.getSession();
                session.setAttribute(Constants.SESSION_USER_ID, rs.getInt(Constants.COL_ID));
                session.setAttribute(Constants.SESSION_USER_NAME, rs.getString(Constants.COL_NAME));
                session.setAttribute(Constants.SESSION_USER_ROLE, role);

                if (Constants.ROLE_ADMIN.equals(role)) {
                    response.sendRedirect(Constants.JSP_ADMIN_DASHBOARD);
                } else {
                    response.sendRedirect(Constants.JSP_DASHBOARD);
                }
            } else {
                response.sendRedirect(Constants.JSP_LOGIN + "?error="
                        + URLEncoder.encode(Constants.ERR_INVALID_CREDENTIALS, "UTF-8"));
            }
        } catch (Exception e) {
            response.sendRedirect(Constants.JSP_LOGIN + "?error="
                    + URLEncoder.encode(Constants.ERR_SERVER_ERROR, "UTF-8"));
            e.printStackTrace();
        }
    }
}
