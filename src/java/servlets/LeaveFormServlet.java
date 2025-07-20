package servlets;

import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import utils.DatabaseUtil;
import constants.Constants;

public class LeaveFormServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(Constants.SESSION_USER_ID) == null) {
            response.sendRedirect(Constants.JSP_LOGIN);
            return;
        }

        int employeeId = (int) session.getAttribute(Constants.SESSION_USER_ID);
        String type = request.getParameter(Constants.PARAM_TYPE);
        String startStr = request.getParameter(Constants.PARAM_START);
        String endStr = request.getParameter(Constants.PARAM_END);
        String reason = request.getParameter(Constants.PARAM_REASON);

        if (type == null || startStr == null || endStr == null
                || type.isEmpty() || startStr.isEmpty() || endStr.isEmpty()) {
            response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_REQUIRED_FIELDS_EMPTY);
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            LocalDate startDate;
            LocalDate endDate;
            LocalDate today = LocalDate.now();

            try {
                startDate = LocalDate.parse(startStr);
                endDate = LocalDate.parse(endStr);
            } catch (Exception e) {
                response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_INVALID_DATE_FORMAT);
                return;
            }

            if (startDate.isBefore(today)) {
                response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_PAST_DATE_NOT_ALLOWED);
                return;
            }

            if (endDate.isBefore(startDate)) {
                response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_INVALID_DATE_RANGE);
                return;
            }

            int daysRequested = (int) ChronoUnit.DAYS.between(startDate, endDate) + 1;
            int year = startDate.getYear();
            int month = startDate.getMonthValue();

            ps = conn.prepareStatement(
                    "SELECT SUM(" + Constants.COL_LEAVES_TAKEN + ") AS total_taken "
                    + "FROM " + Constants.TABLE_LEAVE_POLICY + " WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND " + Constants.COL_YEAR + " = ?");
            ps.setInt(1, employeeId);
            ps.setInt(2, year);
            rs = ps.executeQuery();

            int annualTaken = 0;
            if (rs.next()) {
                annualTaken = rs.getInt("total_taken");
            }
            rs.close();
            ps.close();

            int remainingAnnualLeaves = Constants.MAX_ANNUAL_LEAVES - annualTaken;
            int totalTaken = annualTaken + daysRequested;
            int annualWorkdaysRemaining = Constants.ANNUAL_WORKDAYS - totalTaken;

            if (daysRequested > remainingAnnualLeaves) {
                response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_NOT_ENOUGH_LEAVES);
                return;
            }

            if (annualWorkdaysRemaining < 0) {
                response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_UNEXPECTED_ERROR);
                return;
            }

            ps = conn.prepareStatement(
                    "SELECT " + Constants.COL_MONTHLY_WORKDAYS + " FROM " + Constants.TABLE_LEAVE_POLICY + " "
                    + "WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND " + Constants.COL_YEAR + " = ? AND " + Constants.COL_MONTH + " = ?");
            ps.setInt(1, employeeId);
            ps.setInt(2, year);
            ps.setInt(3, month);
            rs = ps.executeQuery();

            int monthlyWorkdaysRemaining = Constants.MONTHLY_WORKDAYS;
            if (rs.next()) {
                monthlyWorkdaysRemaining = rs.getInt(Constants.COL_MONTHLY_WORKDAYS);
                if (rs.wasNull()) {
                    monthlyWorkdaysRemaining = Constants.MONTHLY_WORKDAYS;
                }
            }
            rs.close();
            ps.close();

            if (daysRequested > monthlyWorkdaysRemaining) {
                response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_UNEXPECTED_ERROR);
                return;
            }

            ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM " + Constants.TABLE_LEAVE_REQUESTS + " "
                    + "WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND " + Constants.COL_STATUS + " = ? "
                    + "AND ((" + Constants.COL_START_DATE + " BETWEEN ? AND ?) OR (" + Constants.COL_END_DATE + " BETWEEN ? AND ?) "
                    + "OR (? BETWEEN " + Constants.COL_START_DATE + " AND " + Constants.COL_END_DATE + ") OR (? BETWEEN " + Constants.COL_START_DATE + " AND " + Constants.COL_END_DATE + "))"
            );
            ps.setInt(1, employeeId);
            ps.setString(2, Constants.STATUS_APPROVED);
            ps.setDate(3, Date.valueOf(startDate));
            ps.setDate(4, Date.valueOf(endDate));
            ps.setDate(5, Date.valueOf(startDate));
            ps.setDate(6, Date.valueOf(endDate));
            ps.setDate(7, Date.valueOf(startDate));
            ps.setDate(8, Date.valueOf(endDate));
            rs = ps.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_OVERLAPPING_LEAVE);
                return;
            }
            rs.close();
            ps.close();

            ps = conn.prepareStatement(
                    "INSERT INTO " + Constants.TABLE_LEAVE_REQUESTS + " ("
                    + Constants.COL_EMPLOYEE_ID + ", " + Constants.COL_LEAVE_TYPE + ", "
                    + Constants.COL_START_DATE + ", " + Constants.COL_END_DATE + ", "
                    + Constants.COL_REASON + ", " + Constants.COL_STATUS + ", " + Constants.COL_APPLIED_ON + ") "
                    + "VALUES (?, ?, ?, ?, ?, ?, CURDATE())"
            );
            ps.setInt(1, employeeId);
            ps.setString(2, type);
            ps.setDate(3, Date.valueOf(startDate));
            ps.setDate(4, Date.valueOf(endDate));
            ps.setString(5, reason);
            ps.setString(6, Constants.STATUS_PENDING);

            int affectedRows = ps.executeUpdate();
            if (affectedRows == 0) {
                throw new SQLException("Creating leave request failed, no rows affected.");
            }

            conn.commit();
            response.sendRedirect(Constants.JSP_LEAVE_FORM + "?success=true");

        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.sendRedirect(Constants.JSP_LEAVE_FORM + "?error=" + Constants.ERR_DATABASE_ERROR);
        } finally {
            DatabaseUtil.closeResources(rs, ps, conn);
        }
    }
}
