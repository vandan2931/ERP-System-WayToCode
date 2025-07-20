package servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import utils.DatabaseUtil;
import constants.Constants;
import java.net.URLEncoder;

public class SignupServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get form parameters
        String name = request.getParameter(Constants.COL_NAME);
        String email = request.getParameter(Constants.COL_EMAIL);
        String password = request.getParameter(Constants.COL_PASSWORD);
        String confirm = request.getParameter("confirm");
        String role = request.getParameter(Constants.COL_ROLE);
        String department = request.getParameter(Constants.COL_DEPARTMENT);

        // Validate password match
        if (!password.equals(confirm)) {
            response.sendRedirect(Constants.JSP_LOGIN + "?error=" + 
                URLEncoder.encode(Constants.ERR_PASSWORD_MISMATCH, "UTF-8"));
            return;
        }

        try (Connection conn = DatabaseUtil.getConnection()) {
            // Check if email already exists
            String checkQuery = "SELECT " + Constants.COL_ID + " FROM " + Constants.TABLE_EMPLOYEES + 
                               " WHERE " + Constants.COL_EMAIL + " = ?";
            PreparedStatement ps = conn.prepareStatement(checkQuery);
            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                response.sendRedirect(Constants.JSP_LOGIN + "?error=" + 
                    URLEncoder.encode(Constants.ERR_EMAIL_EXISTS, "UTF-8"));
                return;
            }

            // Insert new user
            String insertQuery = "INSERT INTO " + Constants.TABLE_EMPLOYEES + " (" + 
                               Constants.COL_NAME + ", " + Constants.COL_EMAIL + ", " + 
                               Constants.COL_PASSWORD + ", " + Constants.COL_STATUS + ", " + 
                               Constants.COL_ROLE + ", " + Constants.COL_DEPARTMENT + ") " +
                               "VALUES (?, ?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(insertQuery);
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, Constants.ROLE_ADMIN.equals(role) ? Constants.STATUS_PENDING_ADMIN : Constants.STATUS_PENDING);
            ps.setString(5, Constants.ROLE_ADMIN.equals(role) ? Constants.ROLE_ADMIN : Constants.ROLE_EMPLOYEE);
            ps.setString(6, department);

            if (ps.executeUpdate() > 0) {
                String msg = Constants.ROLE_ADMIN.equals(role) ? 
                    Constants.MSG_ADMIN_REQUEST_SUBMITTED : Constants.MSG_REGISTRATION_SUCCESS;
                response.sendRedirect(Constants.JSP_LOGIN + "?success=" + URLEncoder.encode(msg, "UTF-8"));
            } else {
                response.sendRedirect(Constants.JSP_LOGIN + "?error=" + 
                    URLEncoder.encode(Constants.ERR_SERVER_ERROR, "UTF-8"));
            }
        } catch (SQLException e) {
            // Handle unique constraint violation
            if (e.getSQLState().equals("23505")) {
                response.sendRedirect(Constants.JSP_LOGIN + "?error=" + 
                    URLEncoder.encode(Constants.ERR_EMAIL_EXISTS, "UTF-8"));
            } else {
                response.sendRedirect(Constants.JSP_LOGIN + "?error=" + 
                    URLEncoder.encode(Constants.ERR_SERVER_ERROR, "UTF-8"));
                e.printStackTrace();
            }
        } catch (Exception e) {
            response.sendRedirect(Constants.JSP_LOGIN + "?error=" + 
                URLEncoder.encode(Constants.ERR_SERVER_ERROR, "UTF-8"));
            e.printStackTrace();
        }
    }
}