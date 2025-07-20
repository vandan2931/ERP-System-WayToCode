package servlets;

import java.io.*;
import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import utils.DatabaseUtil;
import constants.Constants;

@WebServlet("/" + Constants.SERVLET_LEAVE_APPROVAL)
public class LeaveApprovalServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !Constants.ROLE_ADMIN.equals(session.getAttribute(Constants.SESSION_USER_ROLE))) {
            response.sendRedirect(Constants.JSP_LOGIN);
            return;
        }

        String requestId = request.getParameter(Constants.PARAM_LEAVE_REQUEST_ID);
        String action = request.getParameter(Constants.PARAM_ACTION);

        if (requestId == null || action == null) {
            response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=true");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            String newStatus = Constants.ACTION_APPROVE.equalsIgnoreCase(action)
                    ? Constants.STATUS_APPROVED : Constants.STATUS_REJECTED;

            ps = conn.prepareStatement("SELECT * FROM " + Constants.TABLE_LEAVE_REQUESTS
                    + " WHERE " + Constants.COL_ID + " = ?");
            ps.setInt(1, Integer.parseInt(requestId));
            rs = ps.executeQuery();

            if (!rs.next()) {
                response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=request_not_found");
                return;
            }

            int empId = rs.getInt(Constants.COL_EMPLOYEE_ID);
            Date start = rs.getDate(Constants.COL_START_DATE);
            Date end = rs.getDate(Constants.COL_END_DATE);

            rs.close();
            ps.close();

            ps = conn.prepareStatement("UPDATE " + Constants.TABLE_LEAVE_REQUESTS
                    + " SET " + Constants.COL_STATUS + " = ? WHERE " + Constants.COL_ID + " = ?");
            ps.setString(1, newStatus);
            ps.setInt(2, Integer.parseInt(requestId));
            ps.executeUpdate();
            ps.close();

            if (Constants.STATUS_APPROVED.equalsIgnoreCase(newStatus)) {
                LocalDate startDate = start.toLocalDate();
                LocalDate endDate = end.toLocalDate();
                int daysTaken = (int) ChronoUnit.DAYS.between(startDate, endDate) + 1;

                int year = startDate.getYear();
                int month = startDate.getMonthValue();

                ps = conn.prepareStatement(
                        "SELECT " + Constants.COL_TOTAL_LEAVES + ", " + Constants.COL_LEAVES_TAKEN + ", "
                        + Constants.COL_LEAVES_REMAINING + ", " + Constants.COL_ANNUAL_WORKDAYS + ", "
                        + Constants.COL_MONTHLY_WORKDAYS + " FROM " + Constants.TABLE_LEAVE_POLICY
                        + " WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND " + Constants.COL_YEAR + " = ? AND "
                        + Constants.COL_MONTH + " = ?");
                ps.setInt(1, empId);
                ps.setInt(2, year);
                ps.setInt(3, month);
                rs = ps.executeQuery();

                if (rs.next()) {
                    int total = rs.getInt(Constants.COL_TOTAL_LEAVES);
                    int taken = rs.getInt(Constants.COL_LEAVES_TAKEN);
                    int remaining = rs.getInt(Constants.COL_LEAVES_REMAINING);
                    int annualWorkdays = rs.getInt(Constants.COL_ANNUAL_WORKDAYS);
                    int monthlyWorkdays = rs.getInt(Constants.COL_MONTHLY_WORKDAYS);

                    int newTaken = taken + daysTaken;
                    int newRemaining = total - newTaken;
                    int newAnnualWorkdays = annualWorkdays - daysTaken;
                    int newMonthlyWorkdays = monthlyWorkdays - daysTaken;

                    if (newRemaining < 0) {
                        conn.rollback();
                        response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=" + Constants.ERR_NOT_ENOUGH_LEAVES);
                        return;
                    }

                    if (newAnnualWorkdays < 0) {
                        conn.rollback();
                        response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=exceeds_workdays");
                        return;
                    }

                    if (newMonthlyWorkdays < 0) {
                        conn.rollback();
                        response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=exceeds_monthly_workdays");
                        return;
                    }

                    rs.close();
                    ps.close();

                    ps = conn.prepareStatement(
                            "UPDATE " + Constants.TABLE_LEAVE_POLICY + " SET " + Constants.COL_LEAVES_TAKEN + " = ?, "
                            + Constants.COL_LEAVES_REMAINING + " = ?, " + Constants.COL_ANNUAL_WORKDAYS + " = ?, "
                            + Constants.COL_MONTHLY_WORKDAYS + " = ? "
                            + "WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND " + Constants.COL_YEAR + " = ? AND "
                            + Constants.COL_MONTH + " = ?");
                    ps.setInt(1, newTaken);
                    ps.setInt(2, newRemaining);
                    ps.setInt(3, newAnnualWorkdays);
                    ps.setInt(4, newMonthlyWorkdays);
                    ps.setInt(5, empId);
                    ps.setInt(6, year);
                    ps.setInt(7, month);
                    ps.executeUpdate();
                } else {
                    rs.close();
                    ps.close();

                    ps = conn.prepareStatement(
                            "SELECT SUM(" + Constants.COL_LEAVES_TAKEN + ") AS total_taken "
                            + "FROM " + Constants.TABLE_LEAVE_POLICY + " WHERE " + Constants.COL_EMPLOYEE_ID + " = ? AND "
                            + Constants.COL_YEAR + " = ?");
                    ps.setInt(1, empId);
                    ps.setInt(2, year);
                    rs = ps.executeQuery();

                    int annualTaken = 0;
                    if (rs.next()) {
                        annualTaken = rs.getInt("total_taken");
                    }
                    rs.close();
                    ps.close();

                    int remainingAnnualLeaves = Constants.MAX_ANNUAL_LEAVES - annualTaken;
                    int totalTaken = annualTaken + daysTaken;
                    int annualWorkdaysRemaining = Constants.ANNUAL_WORKDAYS - totalTaken;
                    int monthlyWorkdaysRemaining = Constants.MONTHLY_WORKDAYS - daysTaken;

                    if (remainingAnnualLeaves < daysTaken) {
                        conn.rollback();
                        response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=" + Constants.ERR_NOT_ENOUGH_LEAVES);
                        return;
                    }

                    if (annualWorkdaysRemaining < 0) {
                        conn.rollback();
                        response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=exceeds_workdays");
                        return;
                    }

                    if (monthlyWorkdaysRemaining < 0) {
                        conn.rollback();
                        response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=exceeds_monthly_workdays");
                        return;
                    }

                    ps = conn.prepareStatement(
                            "INSERT INTO " + Constants.TABLE_LEAVE_POLICY + " (" + Constants.COL_EMPLOYEE_ID + ", "
                            + Constants.COL_YEAR + ", " + Constants.COL_MONTH + ", " + Constants.COL_TOTAL_LEAVES + ", "
                            + Constants.COL_LEAVES_TAKEN + ", " + Constants.COL_LEAVES_REMAINING + ", "
                            + Constants.COL_ANNUAL_WORKDAYS + ", " + Constants.COL_MONTHLY_WORKDAYS + ") "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
                    ps.setInt(1, empId);
                    ps.setInt(2, year);
                    ps.setInt(3, month);
                    ps.setInt(4, Constants.MAX_ANNUAL_LEAVES);
                    ps.setInt(5, daysTaken);
                    ps.setInt(6, remainingAnnualLeaves - daysTaken);
                    ps.setInt(7, annualWorkdaysRemaining);
                    ps.setInt(8, monthlyWorkdaysRemaining);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?success=true");

        } catch (Exception e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            e.printStackTrace();
            response.sendRedirect(Constants.JSP_LEAVE_REQUESTS + "?error=true");
        } finally {
            DatabaseUtil.closeResources(rs, ps, conn);
        }
    }
}
