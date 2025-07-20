<%@ page import="java.sql.*, utils.DatabaseUtil" %>
<%@ page session="true" %>

<%
    // Authentication check
    if (!"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized+access");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Approve Users</title>
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
                <li><a href="approveusers.jsp" class="active">Pending Approvals</a></li>
                <li><a href="leaverequests.jsp">Leave Requests</a></li>
            </ul>
        </div>

        <div class="container">
            <div class="section">
                <h2>Pending User Approvals</h2>

                <%-- Success and Error Messages --%>
                <% if (request.getParameter("success") != null) { %>
                    <div class="success-message"><%= request.getParameter("success") %></div>
                <% } %>
                
                <% if (request.getParameter("error") != null) { %>
                    <div class="error-message"><%= request.getParameter("error") %></div>
                <% } %>

                <table>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Department</th>
                        <th>Action</th>
                    </tr>

                    <%
                        Connection conn = null;
                        PreparedStatement ps = null;
                        ResultSet rs = null;

                        try {
                            conn = DatabaseUtil.getConnection();
                            ps = conn.prepareStatement(
                                    "SELECT id, name, email, department FROM employees WHERE status IN ('pending', 'pending_admin')");
                            rs = ps.executeQuery();

                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("name")%></td>
                        <td><%= rs.getString("email")%></td>
                        <td><%= rs.getString("department")%></td>
                        <td>
                            <div class="action-form">
                                <form action="../servlets/AdminApprovalServlet" method="post">
                                    <input type="hidden" name="id" value="<%= rs.getInt("id")%>">
                                    <input type="hidden" name="action" value="approve">
                                    <button type="submit" class="btn btn-success">Approve</button>
                                </form>
                                <form action="../servlets/AdminApprovalServlet" method="post" 
                                      onsubmit="return confirm('Are you sure you want to reject and delete this user?');">
                                    <input type="hidden" name="id" value="<%= rs.getInt("id")%>">
                                    <input type="hidden" name="action" value="reject">
                                    <button type="submit" class="btn btn-danger">Reject</button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    <%
                            }
                        } catch (SQLException e) {
                            out.println("<tr><td colspan='4' class='error-message'>Database error: " + e.getMessage() + "</td></tr>");
                        } finally {
                            // Close resources in reverse order
                            if (rs != null) rs.close();
                            if (ps != null) ps.close();
                            if (conn != null) conn.close();
                        }
                    %>
                </table>
            </div>
            <a href="admindashboard.jsp" class="btn btn-primary back">Back to Dashboard</a>
        </div>
    </body>
</html>