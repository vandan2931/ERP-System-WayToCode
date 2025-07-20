<%@ page import="java.sql.*, utils.DatabaseUtil" %>
<%@ page session="true" %>
<%
    if (!"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../admin/adminlogin.jsp?error=Unauthorized access");
        return;
    }
%>
<html>
<head>
    <title>Admin Dashboard</title>
    <link rel="stylesheet" type="text/css" href="../CSS/admindashboard-allempoyee.css">
</head>
<body>
    <div class="admin-header">
        <h1>Welcome, <%= session.getAttribute("username") != null ? session.getAttribute("username") : "Admin" %></h1>
        <a href="../LogoutServlet">Logout</a>
    </div>
    
    <div class="admin-nav">
        <ul>
            <li><a href="allemployees.jsp">All Employees</a></li>
            <li><a href="approveusers.jsp">Pending Approvals</a></li>
            <li><a href="leaverequests.jsp">Leave Requests</a></li>
        </ul>
    </div>
    
    <div class="container">
        <div class="admin-stats">
            <div class="stat-card">
                <h3>Total Employees</h3>
                <p>
                    <%
                        Connection conn1 = null;
                        Statement st1 = null;
                        ResultSet rs1 = null;
                        try {
                            conn1 = DatabaseUtil.getConnection();
                            st1 = conn1.createStatement();
                            rs1 = st1.executeQuery("SELECT COUNT(*) FROM employees");
                            if (rs1.next()) out.print(rs1.getInt(1));
                        } catch (Exception e) { 
                            out.print("Error"); 
                            e.printStackTrace();
                        } finally {
                            if (rs1 != null) try { rs1.close(); } catch (SQLException e) {}
                            if (st1 != null) try { st1.close(); } catch (SQLException e) {}
                            if (conn1 != null) try { conn1.close(); } catch (SQLException e) {}
                        }
                    %>
                </p>
            </div>
            <div class="stat-card">
                <h3>Pending Approvals</h3>
                <p>
                    <%
                        Connection conn2 = null;
                        Statement st2 = null;
                        ResultSet rs2 = null;
                        try {
                            conn2 = DatabaseUtil.getConnection();
                            st2 = conn2.createStatement();
                            rs2 = st2.executeQuery("SELECT COUNT(*) FROM employees WHERE status = 'pending'");
                            if (rs2.next()) out.print(rs2.getInt(1));
                        } catch (Exception e) { 
                            out.print("Error"); 
                            e.printStackTrace();
                        } finally {
                            if (rs2 != null) try { rs2.close(); } catch (SQLException e) {}
                            if (st2 != null) try { st2.close(); } catch (SQLException e) {}
                            if (conn2 != null) try { conn2.close(); } catch (SQLException e) {}
                        }
                    %>
                </p>
            </div>
            <div class="stat-card">
                <h3>Pending Leave Requests</h3>
                <p>
                    <%
                        Connection conn3 = null;
                        Statement st3 = null;
                        ResultSet rs3 = null;
                        try {
                            conn3 = DatabaseUtil.getConnection();
                            st3 = conn3.createStatement();
                            rs3 = st3.executeQuery("SELECT COUNT(*) FROM leave_requests WHERE status = 'pending'");
                            if (rs3.next()) out.print(rs3.getInt(1));
                        } catch (Exception e) { 
                            out.print("Error"); 
                            e.printStackTrace();
                        } finally {
                            if (rs3 != null) try { rs3.close(); } catch (SQLException e) {}
                            if (st3 != null) try { st3.close(); } catch (SQLException e) {}
                            if (conn3 != null) try { conn3.close(); } catch (SQLException e) {}
                        }
                    %>
                </p>
            </div>
        </div>
    </div>
</body>
</html>