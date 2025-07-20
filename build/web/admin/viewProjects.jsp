<%@ page import="java.sql.*, utils.DatabaseUtil, java.util.ArrayList, java.util.HashMap, java.util.Map, java.util.List" %>
<%@ page session="true" %>
<%
    if (!"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access");
        return;
    }

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            String deleteProjectId = request.getParameter("projectId");
            String deleteEmployeeId = request.getParameter("employeeId");
            
            if (deleteProjectId != null && deleteEmployeeId != null) {
                Connection conn = null;
                PreparedStatement pst = null;
                
                try {
                    conn = DatabaseUtil.getConnection();
                    pst = conn.prepareStatement(
                        "DELETE FROM projects WHERE id = ? AND employee_id = ?");
                    pst.setString(1, deleteProjectId);
                    pst.setString(2, deleteEmployeeId);
                    int rowsAffected = pst.executeUpdate();
                    
                    if (rowsAffected > 0) {
                        response.sendRedirect("viewProjects.jsp?employeeId=" + deleteEmployeeId);
                        return;
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    if (pst != null) try { pst.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
        }
    }

    String employeeId = request.getParameter("employeeId");
    if (employeeId == null || employeeId.isEmpty()) {
        response.sendRedirect("employees.jsp?error=Invalid employee ID");
        return;
    }

    String employeeName = "";
    List<Map<String, String>> projects = new ArrayList<Map<String, String>>();
    String errorMessage = null;

    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    try {
        conn = DatabaseUtil.getConnection();
        
        pst = conn.prepareStatement("SELECT name FROM employees WHERE id = ?");
        pst.setString(1, employeeId);
        rs = pst.executeQuery();
        
        if (rs.next()) {
            employeeName = rs.getString("name");
        } else {
            errorMessage = "Employee not found";
        }
        
        if (errorMessage == null) {
            if (rs != null) rs.close();
            if (pst != null) pst.close();
            
            pst = conn.prepareStatement(
                "SELECT id, title, description, start_date, end_date, progress_percent, status, priority " +
                "FROM projects " +
                "WHERE employee_id = ? " +
                "ORDER BY end_date");
            pst.setString(1, employeeId);
            rs = pst.executeQuery();
            
            while (rs.next()) {
                Map<String, String> project = new HashMap<String, String>();
                project.put("id", rs.getString("id"));
                project.put("title", rs.getString("title"));
                project.put("description", rs.getString("description"));
                project.put("start_date", rs.getString("start_date"));
                project.put("end_date", rs.getString("end_date"));
                project.put("progress_percent", rs.getString("progress_percent"));
                project.put("status", rs.getString("status"));
                project.put("priority", rs.getString("priority"));
                projects.add(project);
            }
        }
    } catch (SQLException e) {
        errorMessage = "Database error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pst != null) try { pst.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Employee Projects</title>
    <link rel="stylesheet" type="text/css" href="../CSS/admin-project-edit.css">
    <style>
        .status-badge {
            padding: 3px 8px;
            border-radius: 3px;
            font-weight: bold;
            color: white;
        }
        .status-not-started { background-color: #6c757d; }
        .status-in-progress { background-color: #17a2b8; }
        .status-completed { background-color: #28a745; }
        .status-on-hold { background-color: #dc3545; }
        .priority-high { color: #dc3545; font-weight: bold; }
        .priority-medium { color: #ffc107; font-weight: bold; }
        .priority-low { color: #28a745; font-weight: bold; }
        .progress-container {
            width: 100%;
            background-color: #e9ecef;
            border-radius: 4px;
            height: 20px;
            position: relative;
        }
        .progress-bar {
            background-color: #007bff;
            height: 100%;
            border-radius: 4px;
        }
        .progress-container span {
            position: absolute;
            left: 50%;
            top: 50%;
            transform: translate(-50%, -50%);
            color: #fff;
            font-size: 12px;
        }
    </style>
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
        <div class="section">
            <div class="header">
                <h1>Projects for <%= employeeName %></h1>
            </div>

            <a href="addProject.jsp?employeeId=<%= employeeId %>" class="btn btn-primary">+ Add New Project</a>

            <% if (errorMessage != null) { %>
                <div class="error"><%= errorMessage %></div>
            <% } else if (projects.isEmpty()) { %>
                <div class="message warning">No projects assigned to this employee</div>
            <% } else { %>
                <form id="deleteForm" method="POST" action="viewProjects.jsp">
                    <input type="hidden" name="action" value="delete">
                    <input type="hidden" name="projectId" id="deleteProjectId">
                    <input type="hidden" name="employeeId" id="deleteEmployeeId">
                </form>
                
                <table>
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Description</th>
                            <th>Start Date</th>
                            <th>End Date</th>
                            <th>Status</th>
                            <th>Priority</th>
                            <th>Progress</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, String> project : projects) { 
                            int progress = 0;
                            try {
                                progress = Integer.parseInt(project.get("progress_percent"));
                            } catch (NumberFormatException e) {
                                // Default to 0 if progress is not a number
                            }
                        %>
                            <tr>
                                <td><%= project.get("title") %></td>
                                <td><%= project.get("description") %></td>
                                <td><%= project.get("start_date") %></td>
                                <td><%= project.get("end_date") %></td>
                                <td>
                                    <span class="status-badge status-<%= project.get("status").toLowerCase().replace(" ", "-") %>">
                                        <%= project.get("status") %>
                                    </span>
                                </td>
                                <td class="priority-<%= project.get("priority").toLowerCase() %>">
                                    <%= project.get("priority") %>
                                </td>
                                <td>
                                    <div class="progress-container">
                                        <div class="progress-bar" style="width: <%= progress %>%;">
                                            <span><%= progress %>%</span>
                                        </div>
                                    </div>
                                </td>
                                <td class="actions">
                                    <a href="editProject.jsp?projectId=<%= project.get("id") %>&employeeId=<%= employeeId %>" class="btn btn-warning btn-sm">Edit</a>
                                    <a href="#" class="btn btn-danger btn-sm" 
                                       onclick="if(confirm('Are you sure you want to delete this project?')) { 
                                           document.getElementById('deleteProjectId').value = '<%= project.get("id") %>'; 
                                           document.getElementById('deleteEmployeeId').value = '<%= employeeId %>'; 
                                           document.getElementById('deleteForm').submit(); 
                                       }">Delete</a>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
            <a href="allemployees.jsp" class="back-link">Back to Employees</a>
        </div>
    </div>
</body>
</html>