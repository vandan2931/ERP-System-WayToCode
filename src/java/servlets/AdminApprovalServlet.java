package servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import utils.DatabaseUtil;

public class AdminApprovalServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String id = request.getParameter("id");
        String action = request.getParameter("action");
        
        if (id == null || action == null) {
            response.sendRedirect("../admin/approveusers.jsp?error=Invalid+request");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            
            if ("approve".equals(action)) {
                // Approve the user
                ps = conn.prepareStatement("UPDATE employees SET status = 'approved' WHERE id = ?");
                ps.setString(1, id);
                int rowsAffected = ps.executeUpdate();
                
                if (rowsAffected > 0) {
                    response.sendRedirect("../admin/approveusers.jsp?success=User+approved+successfully");
                } else {
                    response.sendRedirect("../admin/approveusers.jsp?error=Failed+to+approve+user");
                }
            } else if ("reject".equals(action)) {
                // Reject and delete the user
                ps = conn.prepareStatement("DELETE FROM employees WHERE id = ?");
                ps.setString(1, id);
                int rowsAffected = ps.executeUpdate();
                
                if (rowsAffected > 0) {
                    response.sendRedirect("../admin/approveusers.jsp?success=User+rejected+and+deleted+successfully");
                } else {
                    response.sendRedirect("../admin/approveusers.jsp?error=Failed+to+reject+user");
                }
            } else {
                response.sendRedirect("../admin/approveusers.jsp?error=Invalid+action");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("../admin/approveusers.jsp?error=Database+error%3A+" + e.getMessage());
        } finally {
            // Close resources in reverse order
            if (ps != null) try { ps.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    }
}