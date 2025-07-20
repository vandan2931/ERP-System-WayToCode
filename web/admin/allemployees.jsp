<%@ page import="java.sql.*, utils.DatabaseUtil" %>
<%@ page session="true" %>
<%
    if (!"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access");
        return;
    }
    if (request.getParameter("employeeId") != null && request.getParameter("action") != null && request.getParameter("action").equals("delete")) {
        String employeeId = request.getParameter("employeeId");
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "DELETE FROM employees WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, employeeId);
            int rowsAffected = ps.executeUpdate();

            if (rowsAffected > 0) {
                out.println("<script>alert('Employee deleted successfully');</script>");
            } else {
                out.println("<script>alert('Employee not found or could not be deleted');</script>");
            }
        } catch (SQLException e) {
            out.println("<script>alert('Error deleting employee: " + e.getMessage() + "');</script>");
            e.printStackTrace();
        } finally {
            if (ps != null) {
                try {
                    ps.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
%>
<html>
    <head>
        <title>All Employees</title>
        <link rel="stylesheet" type="text/css" href="../CSS/admindashboard-allempoyee.css">
        <script>
            function deleteEmployee(employeeId) {
                if (confirm('Are you sure you want to delete this employee?')) {
                    var form = document.createElement('form');
                    form.method = 'post';
                    form.action = 'allemployees.jsp';

                    var inputId = document.createElement('input');
                    inputId.type = 'hidden';
                    inputId.name = 'employeeId';
                    inputId.value = employeeId;
                    form.appendChild(inputId);

                    var inputAction = document.createElement('input');
                    inputAction.type = 'hidden';
                    inputAction.name = 'action';
                    inputAction.value = 'delete';
                    form.appendChild(inputAction);

                    document.body.appendChild(form);
                    form.submit();
                }
            }
        </script>
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
                <li><a href="leaverequests.jsp">Leave Requests</a></li>
            </ul>
        </div>

        <div class="container">
            <h1>Employee Management</h1>

            <div class="section">
                <h2>Administrators</h2>
                <table>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Contact</th>
                        <th>Status</th>
                        <th>Role</th>
                    </tr>
                    <%
                        Connection conn = null;
                        Statement st = null;
                        ResultSet rs = null;

                        try {
                            conn = DatabaseUtil.getConnection();
                            st = conn.createStatement();
                            rs = st.executeQuery("SELECT name, email, contact, status, role FROM employees WHERE role = 'admin'");

                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getString("name")%></td>
                        <td><%= rs.getString("email")%></td>
                        <td><%= rs.getString("contact")%></td>
                        <td><%= rs.getString("status")%></td>
                        <td><%= rs.getString("role")%></td>
                    </tr>
                    <%
                        }
                    } catch (SQLException e) {
                    %>
                    <tr>
                        <td colspan="5" class="error">Database error: <%= e.getMessage()%></td>
                    </tr>
                    <%
                            e.printStackTrace();
                        }
                    %>
                </table>
            </div>

            <div class="section">
                <h2>Employees</h2>
                <table>
                    <tr>
                        <th>Name</th>
                        <th>Email</th>
                        <th>Department</th>
                        <th>Contact</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                    <%
                        try {
                            if (rs != null) {
                                rs.close();
                            }
                            if (st != null) {
                                st.close();
                            }
                            if (conn != null) {
                                conn.close();
                            }

                            // Re-establish connection for the second query
                            conn = DatabaseUtil.getConnection();
                            st = conn.createStatement();
                            rs = st.executeQuery("SELECT id, name, email, department, contact, status, role FROM employees WHERE role != 'admin'");

                            while (rs.next()) {
                                String employeeId = rs.getString("id");

                                // Get leave data for the employee
                                int totalLeaves = 0;
                                int leavesTaken = 0;
                                int leavesRemaining = 0;

                                Connection leaveConn = null;
                                PreparedStatement leaveStmt = null;
                                ResultSet leaveRs = null;

                                try {
                                    leaveConn = DatabaseUtil.getConnection();
                                    // Get current year's leave data
                                    leaveStmt = leaveConn.prepareStatement(
                                            "SELECT SUM(total_leaves) as total, SUM(leaves_taken) as taken, SUM(leaves_remaining) as remaining "
                                            + "FROM leave_policy WHERE employee_id = ? AND year = YEAR(CURDATE())");
                                    leaveStmt.setString(1, employeeId);
                                    leaveRs = leaveStmt.executeQuery();

                                    if (leaveRs.next()) {
                                        totalLeaves = leaveRs.getInt("total");
                                        leavesTaken = leaveRs.getInt("taken");
                                        leavesRemaining = leaveRs.getInt("remaining");
                                    }
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                } finally {
                                    if (leaveRs != null) {
                                        leaveRs.close();
                                    }
                                    if (leaveStmt != null) {
                                        leaveStmt.close();
                                    }
                                    if (leaveConn != null) {
                                        leaveConn.close();
                                    }
                                }
                    %>
                    <tr>
                        <td><%= rs.getString("name")%></td>
                        <td><%= rs.getString("email")%></td>
                        <td><%= rs.getString("department")%></td>
                        <td><%= rs.getString("contact")%></td>
                        <td><%= rs.getString("status")%></td>
                        <td>
                            <a href="../personaldata.jsp?employeeId=<%= employeeId%>" class="btn btn-primary btn-sm">ADD DATA</a>
                            <a href="viewProjects.jsp?employeeId=<%= employeeId%>" class="btn btn-primary btn-sm">View Projects</a>
                            <a href="employeeLeaveDetails.jsp?employeeId=<%= employeeId%>" class="btn btn-primary btn-sm">Leave Details</a>
                            <a href="${pageContext.request.contextPath}/AdminReportServlet?employeeId=<%= employeeId%>" class="btn btn-primary btn-sm">View Report</a>
                            <button onclick="deleteEmployee('<%= employeeId%>')" class="btn btn-danger btn-sm">Delete</button>
                        </td>
                    </tr>
                    <%
                        }
                    } catch (SQLException e) {
                    %>
                    <tr>
                        <td colspan="6" class="error">Database error: <%= e.getMessage()%></td>
                    </tr>
                    <%
                        e.printStackTrace();
                    } catch (Exception e) {
                    %>
                    <tr>
                        <td colspan="6" class="error">Error: <%= e.getMessage()%></td>
                    </tr>
                    <%
                            e.printStackTrace();
                        } finally {
                            if (rs != null) {
                                try {
                                    rs.close();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                            }
                            if (st != null) {
                                try {
                                    st.close();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                            }
                            if (conn != null) {
                                try {
                                    conn.close();
                                } catch (SQLException e) {
                                    e.printStackTrace();
                                }
                            }
                        }
                    %>
                </table>
                <a href="admindashboard.jsp" class="btn btn-primary back">Back to Dashboard</a>   
            </div>
        </div>
    </body>
</html>