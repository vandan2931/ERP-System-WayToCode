package servlets;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import utils.DatabaseUtil;

@WebServlet("/MonthlyReportServlet")
public class MonthlyReportServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        int userId = (int) session.getAttribute("userId");
        String monthStr = request.getParameter("month");
        String yearStr = request.getParameter("year");
        String reportType = request.getParameter("reportType"); // "monthly" or "yearly"
        
        int month, year;
        
        try {
            LocalDate currentDate = LocalDate.now();
            if (reportType == null || "monthly".equalsIgnoreCase(reportType)) {
                month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : currentDate.getMonthValue();
            } else {
                month = 1; // Default for yearly reports
            }
            year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : currentDate.getYear();
        } catch (NumberFormatException e) {
            LocalDate currentDate = LocalDate.now();
            month = currentDate.getMonthValue();
            year = currentDate.getYear();
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            
            // Get workdays and leave data
            Map<String, Integer> reportData = new HashMap<>();
            
            if (reportType == null || "monthly".equalsIgnoreCase(reportType)) {
                // Get monthly workdays and leaves taken
                ps = conn.prepareStatement(
                    "SELECT monthly_workdays, leaves_taken, annual_workdays FROM leave_policy " +
                    "WHERE employee_id = ? AND year = ? AND month = ?"
                );
                ps.setInt(1, userId);
                ps.setInt(2, year);
                ps.setInt(3, month);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    int monthlyWorkdays = rs.getInt("monthly_workdays");
                    int leavesTaken = rs.getInt("leaves_taken");
                    int annualWorkdays = rs.getInt("annual_workdays");
                    reportData.put("Workdays", monthlyWorkdays);
                    reportData.put("Leaves Taken", leavesTaken);
                    reportData.put("Annual Workdays", annualWorkdays);
                } else {
                    // Default values if no record exists
                    reportData.put("Workdays", 21); // Default monthly workdays
                    reportData.put("Leaves Taken", 0);
                    reportData.put("Annual Workdays", 252); // Default annual workdays
                }
                rs.close();
                ps.close();
                
                // Get projects data for the month
                ps = conn.prepareStatement(
                    "SELECT COUNT(*) as total_projects, " +
                    "SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed_projects, " +
                    "SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) as in_progress_projects, " +
                    "SUM(CASE WHEN status = 'On Hold' THEN 1 ELSE 0 END) as on_hold_projects " +
                    "FROM projects " +
                    "WHERE employee_id = ? AND " +
                    "YEAR(start_date) = ? AND MONTH(start_date) = ?"
                );
                ps.setInt(1, userId);
                ps.setInt(2, year);
                ps.setInt(3, month);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    int totalProjects = rs.getInt("total_projects");
                    int completedProjects = rs.getInt("completed_projects");
                    int inProgressProjects = rs.getInt("in_progress_projects");
                    int onHoldProjects = rs.getInt("on_hold_projects");
                    
                    reportData.put("Total Projects", totalProjects);
                    reportData.put("Completed Projects", completedProjects);
                    reportData.put("In Progress Projects", inProgressProjects);
                    reportData.put("On Hold Projects", onHoldProjects);
                } else {
                    reportData.put("Total Projects", 0);
                    reportData.put("Completed Projects", 0);
                    reportData.put("In Progress Projects", 0);
                    reportData.put("On Hold Projects", 0);
                }
            } else {
                // Yearly report data
                // Get yearly workdays and leaves taken
                ps = conn.prepareStatement(
                    "SELECT SUM(leaves_taken) as total_leaves, " +
                    "SUM(monthly_workdays) as total_workdays, " +
                    "MIN(annual_workdays) as annual_workdays " + // Should be same for all months
                    "FROM leave_policy " +
                    "WHERE employee_id = ? AND year = ?"
                );
                ps.setInt(1, userId);
                ps.setInt(2, year);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    int totalLeaves = rs.getInt("total_leaves");
                    int totalWorkdays = rs.getInt("total_workdays");
                    int annualWorkdays = rs.getInt("annual_workdays");
                    
                    reportData.put("Total Leaves", totalLeaves);
                    reportData.put("Total Workdays", totalWorkdays);
                    reportData.put("Annual Workdays", annualWorkdays);
                } else {
                    reportData.put("Total Leaves", 0);
                    reportData.put("Total Workdays", 252); // Default annual workdays
                    reportData.put("Annual Workdays", 252);
                }
                rs.close();
                ps.close();
                
                // Get projects data for the year
                ps = conn.prepareStatement(
                    "SELECT COUNT(*) as total_projects, " +
                    "SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) as completed_projects, " +
                    "SUM(CASE WHEN status = 'In Progress' THEN 1 ELSE 0 END) as in_progress_projects, " +
                    "SUM(CASE WHEN status = 'On Hold' THEN 1 ELSE 0 END) as on_hold_projects " +
                    "FROM projects " +
                    "WHERE employee_id = ? AND YEAR(start_date) = ?"
                );
                ps.setInt(1, userId);
                ps.setInt(2, year);
                rs = ps.executeQuery();
                
                if (rs.next()) {
                    int totalProjects = rs.getInt("total_projects");
                    int completedProjects = rs.getInt("completed_projects");
                    int inProgressProjects = rs.getInt("in_progress_projects");
                    int onHoldProjects = rs.getInt("on_hold_projects");
                    
                    reportData.put("Total Projects", totalProjects);
                    reportData.put("Completed Projects", completedProjects);
                    reportData.put("In Progress Projects", inProgressProjects);
                    reportData.put("On Hold Projects", onHoldProjects);
                } else {
                    reportData.put("Total Projects", 0);
                    reportData.put("Completed Projects", 0);
                    reportData.put("In Progress Projects", 0);
                    reportData.put("On Hold Projects", 0);
                }
            }
            
            request.setAttribute("reportData", reportData);
            request.setAttribute("month", month);
            request.setAttribute("year", year);
            request.setAttribute("reportType", reportType != null ? reportType : "monthly");
            request.getRequestDispatcher("monthlyReport.jsp").forward(request, response);
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("dashboard.jsp?error=report_error");
        } finally {
            DatabaseUtil.closeResources(rs, ps, conn);
        }
    }
}