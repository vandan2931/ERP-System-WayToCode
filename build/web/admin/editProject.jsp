<%@ page import="java.sql.*, utils.DatabaseUtil" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page session="true" %>
<%
    if (!"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access");
        return;
    }

    String projectId = request.getParameter("projectId");
    String employeeId = request.getParameter("employeeId");

    if (projectId == null || projectId.isEmpty() || employeeId == null || employeeId.isEmpty()) {
        response.sendRedirect("employees.jsp?error=Invalid parameters");
        return;
    }

    Map<String, String> project = new HashMap<String, String>();
    String errorMessage = null;
    String successMessage = null;

    // Handle form submission
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Connection conn = null;
        PreparedStatement pst = null;

        try {
            conn = DatabaseUtil.getConnection();
            pst = conn.prepareStatement(
                    "UPDATE projects SET title=?, description=?, start_date=?, end_date=?, progress_percent=?, status=?, priority=? "
                    + "WHERE id=? AND employee_id=?");

            pst.setString(1, request.getParameter("title"));
            pst.setString(2, request.getParameter("description"));
            pst.setString(3, request.getParameter("start_date"));
            pst.setString(4, request.getParameter("end_date"));

            int progress = 0;
            try {
                progress = Integer.parseInt(request.getParameter("progress"));
            } catch (NumberFormatException e) {
                errorMessage = "Invalid progress percentage";
            }

            pst.setInt(5, progress);
            pst.setString(6, request.getParameter("status"));
            pst.setString(7, request.getParameter("priority"));
            pst.setString(8, projectId);
            pst.setString(9, employeeId);

            if (errorMessage == null) {
                int rowsAffected = pst.executeUpdate();
                if (rowsAffected > 0) {
                    // Set success message that will be displayed after redirect
                    session.setAttribute("successMessage", "Project updated successfully!");
                    response.sendRedirect("editProject.jsp?projectId=" + projectId + "&employeeId=" + employeeId);
                    return;
                } else {
                    errorMessage = "No changes made or project not found";
                }
            }
        } catch (SQLException e) {
            errorMessage = "Database error: " + e.getMessage();
            e.printStackTrace();
        } finally {
            if (pst != null) {
                try {
                    pst.close();
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

    // Check for success message from session
    successMessage = (String) session.getAttribute("successMessage");
    if (successMessage != null) {
        session.removeAttribute("successMessage"); // Clear the message after displaying
    }

    // Load project data
    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;

    try {
        conn = DatabaseUtil.getConnection();
        pst = conn.prepareStatement(
                "SELECT id, title, description, start_date, end_date, progress_percent, status, priority "
                + "FROM projects WHERE id=? AND employee_id=?");
        pst.setString(1, projectId);
        pst.setString(2, employeeId);
        rs = pst.executeQuery();

        if (rs.next()) {
            project.put("id", rs.getString("id"));
            project.put("title", rs.getString("title"));
            project.put("description", rs.getString("description"));
            project.put("start_date", rs.getString("start_date"));
            project.put("end_date", rs.getString("end_date"));
            project.put("progress_percent", rs.getString("progress_percent"));
            project.put("status", rs.getString("status"));
            project.put("priority", rs.getString("priority"));
        } else {
            errorMessage = "Project not found";
        }
    } catch (SQLException e) {
        errorMessage = "Database error: " + e.getMessage();
        e.printStackTrace();
    } finally {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        if (pst != null) {
            try {
                pst.close();
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
<!DOCTYPE html>
<html>
    <head>
        <title>Edit Project</title>
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
            .alert-success {
                background-color: #d4edda;
                color: #155724;
                padding: 10px;
                margin-bottom: 15px;
                border: 1px solid #c3e6cb;
                border-radius: 4px;
            }
            .alert-error {
                background-color: #f8d7da;
                color: #721c24;
                padding: 10px;
                margin-bottom: 15px;
                border: 1px solid #f5c6cb;
                border-radius: 4px;
            }
        </style>
        <script>
            function validateForm() {
                var title = document.getElementById("title").value;
                var startDate = document.getElementById("start_date").value;
                var progress = document.getElementById("progress").value;

                if (title.trim() === "") {
                    alert("Project title is required");
                    return false;
                }

                if (startDate.trim() === "") {
                    alert("Start date is required");
                    return false;
                }

                if (progress < 0 || progress > 100) {
                    alert("Progress must be between 0 and 100");
                    return false;
                }

                return true;
            }

            // Auto-hide success message after 5 seconds
            window.onload = function () {
                var successMessage = document.getElementById("successMessage");
                if (successMessage) {
                    setTimeout(function () {
                        successMessage.style.display = 'none';
                    }, 5000);
                }
            };
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
            <div class="section">
                <div class="header">
                    <h1>Edit Project</h1>
                </div>

                <% if (errorMessage != null) {%>
                <div class="alert-error"><%= errorMessage%></div>
                <% } %>

                <% if (successMessage != null) {%>
                <div id="successMessage" class="alert-success"><%= successMessage%></div>
                <% } %>

                <% if (project.containsKey("id")) {%>
                <form method="POST" onsubmit="return validateForm()">
                    <input type="hidden" name="projectId" value="<%= project.get("id")%>">
                    <input type="hidden" name="employeeId" value="<%= employeeId%>">

                    <div class="form-group">
                        <label for="title">Project Title:</label>
                        <input type="text" id="title" name="title" value="<%= project.get("title")%>" required>
                    </div>

                    <div class="form-group">
                        <label for="description">Description:</label>
                        <textarea id="description" name="description" rows="3" required><%= project.get("description")%></textarea>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="start_date">Start Date:</label>
                            <input type="date" id="start_date" name="start_date" value="<%= project.get("start_date")%>" required>
                        </div>

                        <div class="form-group">
                            <label for="end_date">End Date:</label>
                            <input type="date" id="end_date" name="end_date" value="<%= project.get("end_date")%>">
                        </div>

                        <div class="form-group">
                            <label for="progress">Progress (%):</label>
                            <input type="number" id="progress" name="progress" min="0" max="100" 
                                   value="<%= project.get("progress_percent")%>" required>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="status">Status:</label>
                            <select id="status" name="status" class="form-control" required>
                                <option value="Not Started" <%= "Not Started".equals(project.get("status")) ? "selected" : ""%>>Not Started</option>
                                <option value="In Progress" <%= "In Progress".equals(project.get("status")) ? "selected" : ""%>>In Progress</option>
                                <option value="Completed" <%= "Completed".equals(project.get("status")) ? "selected" : ""%>>Completed</option>
                                <option value="On Hold" <%= "On Hold".equals(project.get("status")) ? "selected" : ""%>>On Hold</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="priority">Priority:</label>
                            <select id="priority" name="priority" class="form-control" required>
                                <option value="High" <%= "High".equals(project.get("priority")) ? "selected" : ""%>>High</option>
                                <option value="Medium" <%= "Medium".equals(project.get("priority")) || project.get("priority") == null ? "selected" : ""%>>Medium</option>
                                <option value="Low" <%= "Low".equals(project.get("priority")) ? "selected" : ""%>>Low</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Update Project</button>
                        <a href="viewProjects.jsp?employeeId=<%= employeeId%>" class="back-link">Back to View Project</a>
                    </div>


                </form>
                <% }%>
            </div>
        </div>
    </body>
</html>