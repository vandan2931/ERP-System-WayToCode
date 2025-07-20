package servlets;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import utils.DatabaseUtil;
import constants.Constants;

public class AdminReportServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("AdminReportServlet accessed");

        HttpSession session = request.getSession(false);
        if (session == null || !Constants.ROLE_ADMIN.equals(session.getAttribute(Constants.SESSION_USER_ROLE))) {
            System.out.println("Unauthorized access attempt");
            response.sendRedirect(request.getContextPath() + Constants.JSP_LOGIN);
            return;
        }

        String employeeIdStr = request.getParameter(Constants.PARAM_EMPLOYEE_ID);
        System.out.println("Employee ID parameter: " + employeeIdStr);

        if (employeeIdStr == null || employeeIdStr.isEmpty()) {
            response.sendRedirect(Constants.JSP_ALL_EMPLOYEES);
            return;
        }

        int employeeId;
        try {
            employeeId = Integer.parseInt(employeeIdStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(Constants.JSP_ALL_EMPLOYEES);
            return;
        }

        String employeeName = "";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            ps = conn.prepareStatement("SELECT " + Constants.COL_NAME + " FROM " + Constants.TABLE_EMPLOYEES + " WHERE " + Constants.COL_ID + " = ?");
            ps.setInt(1, employeeId);
            rs = ps.executeQuery();

            if (rs.next()) {
                employeeName = rs.getString(Constants.COL_NAME);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(Constants.JSP_ALL_EMPLOYEES + "?error=" + Constants.ERR_DATABASE_ERROR);
            return;
        } finally {
            DatabaseUtil.closeResources(rs, ps, null);
        }

        String monthStr = request.getParameter(Constants.PARAM_MONTH);
        String yearStr = request.getParameter(Constants.PARAM_YEAR);
        String reportType = request.getParameter(Constants.PARAM_REPORT_TYPE);

        int month, year;

        try {
            month = (monthStr != null && !monthStr.isEmpty()) ? Integer.parseInt(monthStr) : LocalDate.now().getMonthValue();
            year = (yearStr != null && !yearStr.isEmpty()) ? Integer.parseInt(yearStr) : LocalDate.now().getYear();
        } catch (NumberFormatException e) {
            month = LocalDate.now().getMonthValue();
            year = LocalDate.now().getYear();
        }

        Map<String, Integer> reportData = new HashMap<>();

        try {
            conn = DatabaseUtil.getConnection();

            if (reportType == null || Constants.REPORT_TYPE_MONTHLY.equalsIgnoreCase(reportType)) {
                ps = conn.prepareStatement(
                        "SELECT " + Constants.COL_MONTHLY_WORKDAYS + ", " + Constants.COL_LEAVES_TAKEN + ", " + Constants.COL_ANNUAL_WORKDAYS + " FROM " + Constants.TABLE_LEAVE_POLICY + " "
                        + "WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND " + Constants.COL_YEAR + " = ? AND " + Constants.COL_MONTH + " = ?"
                );
                ps.setInt(1, employeeId);
                ps.setInt(2, year);
                ps.setInt(3, month);
                rs = ps.executeQuery();

                if (rs.next()) {
                    reportData.put("Workdays", rs.getInt(Constants.COL_MONTHLY_WORKDAYS));
                    reportData.put("Leaves Taken", rs.getInt(Constants.COL_LEAVES_TAKEN));
                    reportData.put("Annual Workdays", rs.getInt(Constants.COL_ANNUAL_WORKDAYS));
                } else {
                    reportData.put("Workdays", Constants.DEFAULT_MONTHLY_WORKDAYS);
                    reportData.put("Leaves Taken", 0);
                    reportData.put("Annual Workdays", Constants.DEFAULT_ANNUAL_WORKDAYS);
                }
                DatabaseUtil.closeResources(rs, ps, null);

                ps = conn.prepareStatement(
                        "SELECT COUNT(*) as total_projects, "
                        + "SUM(CASE WHEN " + Constants.COL_PROJECT_STATUS + " = 'Completed' THEN 1 ELSE 0 END) as completed_projects, "
                        + "SUM(CASE WHEN " + Constants.COL_PROJECT_STATUS + " = 'In Progress' THEN 1 ELSE 0 END) as in_progress_projects, "
                        + "SUM(CASE WHEN " + Constants.COL_PROJECT_STATUS + " = 'On Hold' THEN 1 ELSE 0 END) as on_hold_projects "
                        + "FROM " + Constants.TABLE_PROJECTS + " "
                        + "WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND "
                        + "YEAR(" + Constants.COL_START_DATE + ") = ? AND MONTH(" + Constants.COL_START_DATE + ") = ?"
                );
                ps.setInt(1, employeeId);
                ps.setInt(2, year);
                ps.setInt(3, month);
                rs = ps.executeQuery();

                if (rs.next()) {
                    reportData.put("Total Projects", rs.getInt("total_projects"));
                    reportData.put("Completed Projects", rs.getInt("completed_projects"));
                    reportData.put("In Progress Projects", rs.getInt("in_progress_projects"));
                    reportData.put("On Hold Projects", rs.getInt("on_hold_projects"));
                } else {
                    reportData.put("Total Projects", 0);
                    reportData.put("Completed Projects", 0);
                    reportData.put("In Progress Projects", 0);
                    reportData.put("On Hold Projects", 0);
                }
            } else {
                ps = conn.prepareStatement(
                        "SELECT SUM(" + Constants.COL_LEAVES_TAKEN + ") as total_leaves, "
                        + "SUM(" + Constants.COL_MONTHLY_WORKDAYS + ") as total_workdays, "
                        + "MIN(" + Constants.COL_ANNUAL_WORKDAYS + ") as annual_workdays "
                        + "FROM " + Constants.TABLE_LEAVE_POLICY + " "
                        + "WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND " + Constants.COL_YEAR + " = ?"
                );
                ps.setInt(1, employeeId);
                ps.setInt(2, year);
                rs = ps.executeQuery();

                if (rs.next()) {
                    reportData.put("Total Leaves", rs.getInt("total_leaves"));
                    reportData.put("Total Workdays", rs.getInt("total_workdays"));
                    reportData.put("Annual Workdays", rs.getInt("annual_workdays"));
                } else {
                    reportData.put("Total Leaves", 0);
                    reportData.put("Total Workdays", Constants.DEFAULT_ANNUAL_WORKDAYS);
                    reportData.put("Annual Workdays", Constants.DEFAULT_ANNUAL_WORKDAYS);
                }
                DatabaseUtil.closeResources(rs, ps, null);

                ps = conn.prepareStatement(
                        "SELECT COUNT(*) as total_projects, "
                        + "SUM(CASE WHEN " + Constants.COL_PROJECT_STATUS + " = 'Completed' THEN 1 ELSE 0 END) as completed_projects, "
                        + "SUM(CASE WHEN " + Constants.COL_PROJECT_STATUS + " = 'In Progress' THEN 1 ELSE 0 END) as in_progress_projects, "
                        + "SUM(CASE WHEN " + Constants.COL_PROJECT_STATUS + " = 'On Hold' THEN 1 ELSE 0 END) as on_hold_projects "
                        + "FROM " + Constants.TABLE_PROJECTS + " "
                        + "WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND YEAR(" + Constants.COL_START_DATE + ") = ?"
                );
                ps.setInt(1, employeeId);
                ps.setInt(2, year);
                rs = ps.executeQuery();

                if (rs.next()) {
                    reportData.put("Total Projects", rs.getInt("total_projects"));
                    reportData.put("Completed Projects", rs.getInt("completed_projects"));
                    reportData.put("In Progress Projects", rs.getInt("in_progress_projects"));
                    reportData.put("On Hold Projects", rs.getInt("on_hold_projects"));
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
            request.setAttribute("reportType", reportType != null ? reportType : Constants.REPORT_TYPE_MONTHLY);
            request.setAttribute("employeeName", employeeName);
            request.getRequestDispatcher(Constants.JSP_VIEW_REPORT).forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect(Constants.JSP_ALL_EMPLOYEES + "?error=" + Constants.ERR_REPORT_ERROR);
        } finally {
            DatabaseUtil.closeResources(rs, ps, conn);
        }
    }
}
