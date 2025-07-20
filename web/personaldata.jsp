<%@ page import="java.sql.*, utils.DatabaseUtil, java.math.BigDecimal, constants.Constants" %>
<%@ page session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%
    // Handle flash messages
    String successMessage = (String) session.getAttribute(Constants.MSG_TYPE_SUCCESS);
    String errorMessage = (String) session.getAttribute(Constants.MSG_TYPE_ERROR);
    session.removeAttribute(Constants.MSG_TYPE_SUCCESS);
    session.removeAttribute(Constants.MSG_TYPE_ERROR);

    // Check authentication
    Integer userId = (Integer) session.getAttribute(Constants.SESSION_USER_ID);
    String userRole = (String) session.getAttribute(Constants.SESSION_USER_ROLE);
    if (userId == null) {
        response.sendRedirect(Constants.JSP_LOGIN);
        return;
    }

    // Handle admin viewing other profiles
    String employeeIdParam = request.getParameter(Constants.PARAM_EMPLOYEE_ID);
    int viewingUserId = userId;

    if (employeeIdParam != null && Constants.ROLE_ADMIN.equals(userRole)) {
        try {
            viewingUserId = Integer.parseInt(employeeIdParam);
        } catch (NumberFormatException e) {
            viewingUserId = userId;
        }
    }

    // Initialize all fields
    String name = "", email = "", department = "", contact = "", status = "", role = "";
    int experience = 0;
    String password = "";
    String age = "", dob = "", currentSalary = "", previousSalary = "", dateOfJoining = "";
    byte[] profilePic = null;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = DatabaseUtil.getConnection();
        ps = conn.prepareStatement("SELECT * FROM " + Constants.TABLE_EMPLOYEES + " WHERE " + Constants.COL_ID + " = ?");
        ps.setInt(1, viewingUserId);
        rs = ps.executeQuery();

        if (rs.next()) {
            // Populate all fields from database
            name = rs.getString(Constants.COL_NAME) != null ? rs.getString(Constants.COL_NAME) : "";
            email = rs.getString(Constants.COL_EMAIL) != null ? rs.getString(Constants.COL_EMAIL) : "";
            department = rs.getString(Constants.COL_DEPARTMENT) != null ? rs.getString(Constants.COL_DEPARTMENT) : "";
            contact = rs.getString(Constants.COL_CONTACT) != null ? rs.getString(Constants.COL_CONTACT) : "";
            status = rs.getString(Constants.COL_STATUS) != null ? rs.getString(Constants.COL_STATUS) : "";
            role = rs.getString(Constants.COL_ROLE) != null ? rs.getString(Constants.COL_ROLE) : "";
            password = rs.getString(Constants.COL_PASSWORD) != null ? rs.getString(Constants.COL_PASSWORD) : "";

            experience = rs.getInt(Constants.COL_EXPERIENCE);
            age = rs.getString(Constants.COL_AGE) != null ? rs.getString(Constants.COL_AGE) : "";

            Date dobDate = rs.getDate(Constants.COL_DOB);
            dob = dobDate != null ? dobDate.toString() : "";

            BigDecimal currentSalaryBD = rs.getBigDecimal(Constants.COL_CURRENT_SALARY);
            currentSalary = currentSalaryBD != null ? currentSalaryBD.toString() : "";

            BigDecimal previousSalaryBD = rs.getBigDecimal(Constants.COL_PREVIOUS_SALARY);
            previousSalary = previousSalaryBD != null ? previousSalaryBD.toString() : "";

            Date dateOfJoiningDate = rs.getDate(Constants.COL_DATE_OF_JOINING);
            dateOfJoining = dateOfJoiningDate != null ? dateOfJoiningDate.toString() : "";

            profilePic = rs.getBytes(Constants.COL_PROFILE_IMAGE);
        }
    } catch (Exception e) {
        errorMessage = Constants.ERR_LOADING_PROFILE + ": " + e.getMessage();
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

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title><%= viewingUserId == userId ? "Your Profile" : "Employee Profile: " + name%></title>
        <link rel="stylesheet" type="text/css" href="CSS/personaldata-projectreport.css">
    </head>
    <body>
        <div class="container">
            <h2><%= viewingUserId == userId ? "Your Profile" : "Employee Profile: " + name%></h2>

            <% if (successMessage != null && !successMessage.isEmpty()) {%>
            <div class="message success">
                <%= successMessage%>
            </div>
            <% } %>

            <% if (errorMessage != null && !errorMessage.isEmpty()) {%>
            <div class="message error">
                <%= errorMessage%>
            </div>
            <% } %>

            <form action="<%= Constants.SERVLET_PERSONAL_DATA %>" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
                <% if (viewingUserId != userId) {%>
                <input type="hidden" name="<%= Constants.PARAM_EMPLOYEE_ID %>" value="<%= viewingUserId%>" />
                <% } %>

                <div class="form-group">
                    <label>Name:</label>
                    <% if (Constants.ROLE_ADMIN.equals(userRole)) {%>
                    <input type="text" name="<%= Constants.COL_NAME %>" value="<%= name%>" required />
                    <% } else {%>
                    <input type="text" value="<%= name%>" readonly />
                    <input type="hidden" name="<%= Constants.COL_NAME %>" value="<%= name%>" />
                    <% }%>
                </div>

                <div class="form-group">
                    <label>Email:</label>
                    <input type="email" name="<%= Constants.COL_EMAIL %>" value="<%= email%>" required />
                </div>

                <div class="form-group">
                    <label>Department:</label>
                    <% if (Constants.ROLE_ADMIN.equals(userRole)) {%>
                    <select name="<%= Constants.COL_DEPARTMENT %>" required>
                        <option value="">-- Select Department --</option>
                        <% for (String dept : Constants.DEPARTMENTS) { %>
                            <option value="<%= dept %>" <%= dept.equals(department) ? "selected" : "" %>><%= dept %></option>
                        <% } %>
                    </select>
                    <% } else {%>
                    <input type="text" value="<%= department%>" readonly />
                    <input type="hidden" name="<%= Constants.COL_DEPARTMENT %>" value="<%= department%>" />
                    <% }%>
                </div>

                <div class="form-group">
                    <label>Contact:</label>
                    <input type="text" name="<%= Constants.COL_CONTACT %>" value="<%= contact%>" 
                           pattern="[0-9]{10}" 
                           title="<%= Constants.ERR_INVALID_CONTACT %>" 
                           required />
                </div>

                <% if (Constants.ROLE_ADMIN.equals(userRole)) {%>
                <div class="form-group">
                    <label>Password:</label>
                    <input type="password" name="<%= Constants.COL_PASSWORD %>" value="<%= password%>" />
                </div>
                <% }%>

                <div class="form-group">
                    <label>Age:</label>
                    <input type="number" name="<%= Constants.COL_AGE %>" value="<%= age%>" min="18" max="100" />
                </div>

                <div class="form-group">
                    <label>Experience (years):</label>
                    <% if (Constants.ROLE_ADMIN.equals(userRole)) {%>
                    <input type="number" name="<%= Constants.COL_EXPERIENCE %>" value="<%= experience%>" min="0" max="50" />
                    <% } else {%>
                    <input type="number" value="<%= experience%>" readonly />
                    <input type="hidden" name="<%= Constants.COL_EXPERIENCE %>" value="<%= experience%>" />
                    <% }%>
                </div>

                <div class="form-group">
                    <label>Date of Birth:</label>
                    <input type="date" name="<%= Constants.COL_DOB %>" value="<%= dob%>" />
                </div>

                <div class="form-group">
                    <label>Current Salary:</label>
                    <% if (Constants.ROLE_ADMIN.equals(userRole)) {%>
                    <input type="number" name="<%= Constants.COL_CURRENT_SALARY %>" value="<%= currentSalary%>" step="0.01" min="0" />
                    <% } else {%>
                    <input type="number" value="<%= currentSalary%>" readonly />
                    <input type="hidden" name="<%= Constants.COL_CURRENT_SALARY %>" value="<%= currentSalary%>" />
                    <% } %>
                </div>

                <div class="form-group">
                    <label>Previous Salary:</label>
                    <% if (Constants.ROLE_ADMIN.equals(userRole)) {%>
                    <input type="number" name="<%= Constants.COL_PREVIOUS_SALARY %>" value="<%= previousSalary%>" step="0.01" min="0" />
                    <% } else {%>
                    <input type="number" value="<%= previousSalary%>" readonly />
                    <input type="hidden" name="<%= Constants.COL_PREVIOUS_SALARY %>" value="<%= previousSalary%>" />
                    <% } %>
                </div>

                <div class="form-group">
                    <label>Date of Joining:</label>
                    <% if (Constants.ROLE_ADMIN.equals(userRole)) {%>
                    <input type="date" name="<%= Constants.COL_DATE_OF_JOINING %>" value="<%= dateOfJoining%>" />
                    <% } else {%>
                    <input type="date" value="<%= dateOfJoining%>" readonly />
                    <input type="hidden" name="<%= Constants.COL_DATE_OF_JOINING %>" value="<%= dateOfJoining%>" />
                    <% }%>
                </div>

                <div class="form-group">
                    <label>Profile Image:</label>
                    <input type="file" name="<%= Constants.COL_PROFILE_IMAGE %>" accept="image/*" />
                </div>

                <div class="form-group">
                    <input type="submit" value="<%= viewingUserId == userId ? "Update Profile" : "Update Employee"%>" class="btn-update">
                </div>
            </form>

            <% if (profilePic != null && profilePic.length > 0) {%>
            <div>
                <h3>Current Profile Picture:</h3>
                <img src="data:image/jpeg;base64,<%= javax.xml.bind.DatatypeConverter.printBase64Binary(profilePic)%>" 
                     class="profile-pic" 
                     alt="Profile Picture" />
            </div>
            <% }%>

            <div class="form-group">
                <button type="button" class="btn-secondary" onclick="location.href = '<%="admin".equals(userRole)
                        ? (viewingUserId != userId ? "admin/allemployees.jsp?employeeId=" + viewingUserId : "../admin/allemployees.jsp")
                        : Constants.JSP_DASHBOARD%>'">
                    <%= "admin".equals(userRole)
                            ? (viewingUserId != userId ? "Back to Employee Profile" : "Back to Employee List")
                            : "Back to Dashboard"%>
                </button>
            </div>
        </div>

        <script>
            function validateForm() {
                const contactInput = document.querySelector('input[name="<%= Constants.COL_CONTACT %>"]');
                if (!/^\d{10}$/.test(contactInput.value)) {
                    alert('<%= Constants.ERR_INVALID_CONTACT %>');
                    contactInput.focus();
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>