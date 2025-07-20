<%@ page import="java.sql.*, utils.DatabaseUtil" %>
<%@ page session="true" %>
<%
    String role = (String) session.getAttribute("userRole");
    if (role == null || !"admin".equals(role)) {
        response.sendRedirect("../login.jsp");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
%>

<html>
    <head>
        <title>Leave Requests</title>
        <link rel="stylesheet" type="text/css" href="../CSS/adminpending-leave.css">
    </head>
    <body>
        <div class="admin-header">
            <h1>Welcome, <%= session.getAttribute("username") != null ? session.getAttribute("username") : "Admin"%></h1>
            <a href="../LogoutServlet">Logout</a>
        </div>

        <div class="admin-nav">
            <ul>
                <li><a href="allemployees.jsp">All Employees</a></li>
                <li><a href="approveusers.jsp">Pending Approvals</a></li>
                <li><a href="leaverequests.jsp" >Leave Requests</a></li>
            </ul>
        </div>

        <div class="container">
            <div class="section">
                <h2>Pending Leave Requests</h2>

                <% if (request.getParameter("success") != null) { %>
                <div class="message success">Leave request processed successfully!</div>
                <% } %>
                <% if (request.getParameter("error") != null) { %>
                <div class="message error">Error processing leave request!</div>
                <% } %>

                <table>
                    <tr>
                        <th>Employee</th>
                        <th>Type</th>
                        <th>Start Date</th>
                        <th>End Date</th>
                        <th>Reason</th>
                        <th>Actions</th>
                    </tr>

                    <%
                        try {
                            conn = DatabaseUtil.getConnection();
                            String sql = "SELECT lr.id, e.name, lr.leave_type, lr.start_date, lr.end_date, lr.reason "
                                    + "FROM leave_requests lr JOIN employees e ON lr.employee_id = e.id WHERE lr.status = 'pending'";
                            ps = conn.prepareStatement(sql);
                            rs = ps.executeQuery();

                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("name")%></td>
                        <td><%= rs.getString("leave_type")%></td>
                        <td><%= rs.getDate("start_date")%></td>
                        <td><%= rs.getDate("end_date")%></td>
                        <td class="reason-cell"><%= rs.getString("reason")%></td>
                        <td>
                            <form class="action-form" action="${pageContext.request.contextPath}/LeaveApprovalServlet" method="post">
                                <input type="hidden" name="requestId" value="<%= rs.getInt("id")%>" />
                                <button type="submit" name="action" value="approve" class="btn btn-success btn-sm">Approve</button>
                                <button type="submit" name="action" value="reject" class="btn btn-danger btn-sm">Reject</button>
                            </form>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (SQLException e) {
                            out.println("<tr><td colspan='6'>Error: " + e.getMessage() + "</td></tr>");
                        } finally {
                            if (rs != null) {
                                try {
                                    rs.close();
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
                </table>


            </div>
            <a href="admindashboard.jsp" class="btn btn-primary back">Back to Dashboard</a>
        </div>
    </body>
</html>