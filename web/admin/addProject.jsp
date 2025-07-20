<%@ page import="java.sql.*, utils.DatabaseUtil" %>
<%@ page session="true" %>
<%
    if (!"admin".equals(session.getAttribute("userRole"))) {
        response.sendRedirect("../login.jsp?error=Unauthorized access");
        return;
    }

    String employeeId = request.getParameter("employeeId");
    if (employeeId == null || employeeId.isEmpty()) {
        response.sendRedirect("employees.jsp?error=Invalid employee ID");
        return;
    }

    String employeeName = "";
    String errorMessage = null;
    boolean showSuccessAlert = false;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startDate = request.getParameter("start_date");
        String endDate = request.getParameter("end_date");
        String progress = request.getParameter("progress_percent");
        String status = request.getParameter("status");
        String priority = request.getParameter("priority");

        Connection conn = null;
        PreparedStatement pst = null;

        try {
            conn = DatabaseUtil.getConnection();
            String sql = "INSERT INTO projects (employee_id, title, description, start_date, end_date, progress_percent, status, priority) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pst = conn.prepareStatement(sql);
            pst.setString(1, employeeId);
            pst.setString(2, title);
            pst.setString(3, description);
            pst.setString(4, startDate);
            pst.setString(5, endDate);
            pst.setInt(6, Integer.parseInt(progress));
            pst.setString(7, status);
            pst.setString(8, priority);

            int rowsAffected = pst.executeUpdate();
            if (rowsAffected > 0) {
                showSuccessAlert = true;
            } else {
                errorMessage = "Failed to add project";
            }
        } catch (SQLException e) {
            errorMessage = "Database error: " + e.getMessage();
            e.printStackTrace();
        } catch (NumberFormatException e) {
            errorMessage = "Invalid progress value";
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
        <title>Add New Project</title>
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
            .error-message {
                color: red;
                font-size: 12px;
                margin-top: 5px;
                display: none;
            }
            .form-group.required label:after {
                content: " *";
                color: red;
            }
        </style>
        <script>
            function validateForm() {

                document.querySelectorAll('.error-message').forEach(el => el.style.display = 'none');

                const title = document.getElementById("title").value.trim();
                const description = document.getElementById("description").value.trim();
                const startDate = document.getElementById("start_date").value.trim();
                const endDate = document.getElementById("end_date").value.trim();
                const progress = document.getElementById("progress_percent").value.trim();
                const status = document.getElementById("status").value;
                const priority = document.getElementById("priority").value;

                let isValid = true;

                if (title === "") {
                    showError("title-error", "Project title is required");
                    isValid = false;
                } else if (title.length < 3) {
                    showError("title-error", "Title must be at least 3 characters");
                    isValid = false;
                }


                if (description === "") {
                    showError("description-error", "Description is required");
                    isValid = false;
                }

                if (startDate === "") {
                    showError("start-date-error", "Start date is required");
                    isValid = false;
                } else if (new Date(startDate) < new Date()) {
                    if (!confirm("Start date is in the past. Are you sure?")) {
                        showError("start-date-error", "Please select a valid start date");
                        isValid = false;
                    }
                }

                if (endDate !== "") {
                    if (new Date(endDate) <= new Date(startDate)) {
                        showError("end-date-error", "End date must be after start date");
                        isValid = false;
                    }
                }

                if (progress === "" || isNaN(progress) || progress < 0 || progress > 100) {
                    showError("progress-error", "Progress must be between 0 and 100");
                    isValid = false;
                }

                if (isValid) {
                    return confirm('Are you sure you want to add this project?');
                }

                return false;
            }

            function showError(elementId, message) {
                const errorElement = document.getElementById(elementId);
                errorElement.textContent = message;
                errorElement.style.display = 'block';
            }

            <% if (showSuccessAlert) {%>
            document.addEventListener('DOMContentLoaded', function () {
                alert("Project added successfully!");
            window.location.href = 'viewProjects.jsp?employeeId=<%= employeeId%>';
            });
            <% }%>
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
                    <h1>Add New Project for <%= employeeName%></h1>
                </div>

                <% if (errorMessage != null) {%>
                <div class="error"><%= errorMessage%></div>
                <% }%>

                <form method="POST" onsubmit="return validateForm()">
                    <input type="hidden" name="employeeId" value="<%= employeeId%>">

                    <div class="form-group required">
                        <label for="title">Project Title:</label>
                        <input type="text" id="title" name="title" required>
                        <div id="title-error" class="error-message"></div>
                    </div>

                    <div class="form-group required">
                        <label for="description">Description:</label>
                        <textarea id="description" name="description" rows="3" required></textarea>
                        <div id="description-error" class="error-message"></div>
                    </div>

                    <div class="form-row">
                        <div class="form-group required">
                            <label for="start_date">Start Date:</label>
                            <input type="date" id="start_date" name="start_date" required>
                            <div id="start-date-error" class="error-message"></div>
                        </div>

                        <div class="form-group">
                            <label for="end_date">End Date:</label>
                            <input type="date" id="end_date" name="end_date">
                            <div id="end-date-error" class="error-message"></div>
                        </div>

                        <div class="form-group required">
                            <label for="progress_percent">Progress (%):</label>
                            <input type="number" id="progress_percent" name="progress_percent" min="0" max="100" value="0" required>
                            <div id="progress-error" class="error-message"></div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group required">
                            <label for="status">Status:</label>
                            <select id="status" name="status" class="form-control" required>
                                <option value="Not Started">Not Started</option>
                                <option value="In Progress">In Progress</option>
                                <option value="Completed">Completed</option>
                                <option value="On Hold">On Hold</option>
                            </select>
                        </div>

                        <div class="form-group required">
                            <label for="priority">Priority:</label>
                            <select id="priority" name="priority" class="form-control" required>
                                <option value="High">High</option>
                                <option value="Medium" selected>Medium</option>
                                <option value="Low">Low</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Add Project</button>
                        <button type="button" class="btn-secondary" onclick="location.href = 'viewProjects.jsp?employeeId=<%= employeeId%>'">
                            Cancel
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>