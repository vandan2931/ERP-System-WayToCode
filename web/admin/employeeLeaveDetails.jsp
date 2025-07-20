<%@ page import="java.sql.*, utils.DatabaseUtil, java.text.SimpleDateFormat" %>
<%@ page session="true" %>
<%
    if (!"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access");
        return;
    }

    String employeeId = request.getParameter("employeeId");
    if (employeeId == null || employeeId.isEmpty()) {
        response.sendRedirect("allemployees.jsp?error=Invalid employee ID");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    ResultSet leaveRs = null;

    String employeeName = "";
    String department = "";
    int totalLeaves = 20; // Fixed annual leave count
    int leavesTaken = 0;
    int leavesRemaining = 20;
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy");
%>

<html>
    <head>
        <title>Employee Leave Details</title>
        <link rel="stylesheet" href="../CSS/employee-leave.css">
       
    </head>
    <body>
        <div class="admin-header">
            <h1>Employee Leave Details</h1>
            <a href="../LogoutServlet">Logout</a>
        </div>

        <div class="container">
            <%
                try {
                    conn = DatabaseUtil.getConnection();

                    // Get employee basic info
                    ps = conn.prepareStatement("SELECT name, department FROM employees WHERE id = ?");
                    ps.setString(1, employeeId);
                    rs = ps.executeQuery();

                    if (rs.next()) {
                        employeeName = rs.getString("name");
                        department = rs.getString("department");
                    }
            %>
            
            <div class="employee-info">
                <h2><%= employeeName %></h2>
                <p class="department"><%= department %></p>
            </div>

            <%
                    // Calculate leaves taken in current year
                    ps = conn.prepareStatement(
                        "SELECT SUM(DATEDIFF(end_date, start_date) + 1) AS days_taken " +
                        "FROM leave_requests " +
                        "WHERE employee_id = ? AND status = 'approved' " +
                        "AND YEAR(start_date) = YEAR(CURDATE())");
                    ps.setString(1, employeeId);
                    rs = ps.executeQuery();

                    if (rs.next()) {
                        leavesTaken = rs.getInt("days_taken");
                        if (rs.wasNull()) {
                            leavesTaken = 0;
                        }
                    }
                    
                    // Calculate remaining leaves (never less than 0)
                    leavesRemaining = Math.max(0, totalLeaves - leavesTaken);
            %>

            <div class="leave-summary">
                <h3>Leave Summary (Current Year)</h3>
                <div class="summary-cards">
                    <div class="summary-card total">
                        <h3>Total Leaves</h3>
                        <div class="value"><%= totalLeaves %></div>
                    </div>
                    <div class="summary-card taken">
                        <h3>Leaves Taken</h3>
                        <div class="value"><%= leavesTaken %></div>
                    </div>
                    <div class="summary-card remaining">
                        <h3>Leaves Remaining</h3>
                        <div class="value"><%= leavesRemaining %></div>
                    </div>
                </div>
            </div>

            <div class="leave-history">
                <h3>Leave History</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Type</th>
                            <th>Start Date</th>
                            <th>End Date</th>
                            <th>Days</th>
                            <th>Reason</th>
                            <th>Status</th>
                            <th>Applied On</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            // Get all leave history
                            ps = conn.prepareStatement(
                                    "SELECT leave_type, start_date, end_date, status, reason, applied_on "
                                    + "FROM leave_requests WHERE employee_id = ? ORDER BY applied_on DESC");
                            ps.setString(1, employeeId);
                            leaveRs = ps.executeQuery();

                            while (leaveRs.next()) {
                                Date start = leaveRs.getDate("start_date");
                                Date end = leaveRs.getDate("end_date");
                                long dayCount = (end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24) + 1;
                                String status = leaveRs.getString("status");
                                String cssClass = status.toLowerCase();
                        %>
                        <tr class="<%= cssClass %>">
                            <td><%= leaveRs.getString("leave_type") %></td>
                            <td><%= dateFormat.format(start) %></td>
                            <td><%= dateFormat.format(end) %></td>
                            <td><%= dayCount %></td>
                            <td class="reason-cell"><%= leaveRs.getString("reason") %></td>
                            <td class="<%= cssClass %>"><%= status %></td>
                            <td><%= dateFormat.format(leaveRs.getDate("applied_on")) %></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </div>

            <a href="allemployees.jsp" class="back-btn">Back to Employee List</a>

            <%
                } catch (SQLException e) {
                    out.println("<div class='error'>Database error: " + e.getMessage() + "</div>");
                    e.printStackTrace();
                } finally {
                    if (rs != null) {
                        try {
                            rs.close();
                        } catch (SQLException e) {
                        }
                    }
                    if (leaveRs != null) {
                        try {
                            leaveRs.close();
                        } catch (SQLException e) {
                        }
                    }
                    if (ps != null) {
                        try {
                            ps.close();
                        } catch (SQLException e) {
                        }
                    }
                    if (conn != null) {
                        try {
                            conn.close();
                        } catch (SQLException e) {
                        }
                    }
                }
            %>
        </div>
    </body>
</html>