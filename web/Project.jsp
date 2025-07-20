<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, model.Project" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>All Projects</title>
    <link rel="stylesheet" type="text/css" href="CSS/project.css">
    <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>
<body>
    <div class="container">
        <h2>All Projects</h2>

        <% 
            String message = (String) request.getAttribute("message");
            String type = (String) request.getAttribute("messageType");
            if (message != null) { 
        %>
            <div class="message <%= type %>"><%= message %></div>
        <% } %>

        <table>
            <thead>
                <tr>
                    <th>Title</th>
                    <th>Description</th>
                    <th>Start Date</th>
                    <th>End Date</th>
                    <th>Progress</th>
                    <th>Status</th>
                    <th>Priority</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% 
                    List<Project> projects = (List<Project>) request.getAttribute("projects"); 
                    if (projects != null && !projects.isEmpty()) {
                        for (Project p : projects) { 
                %>
                <tr>
                    <td title="<%= p.getTitle() %>"><%= p.getTitle() %></td>
                    <td title="<%= p.getDescription() %>"><%= p.getDescription() %></td>
                    <td><fmt:formatDate value="<%= p.getStartDate() %>" pattern="yyyy-MM-dd" /></td>
                    <td><%= p.getEndDate() != null ? new java.text.SimpleDateFormat("yyyy-MM-dd").format(p.getEndDate()) : "" %></td>
                    <td><%= p.getProgressPercent() %>%</td>
                    <td class="status-<%= p.getStatus().toLowerCase().replace(" ", "-") %>"><%= p.getStatus() %></td>
                    <td class="priority-<%= p.getPriority().toLowerCase() %>"><%= p.getPriority() %></td>
                    <td class="action-links">
                        <a href="Project?action=edit&id=<%= p.getId() %>">Edit</a>
                        <a href="Project?action=delete&id=<%= p.getId() %>" 
                           onclick="return confirm('Are you sure you want to delete this project?');">Delete</a>
                    </td>
                </tr>
                <% 
                        }
                    } else { 
                %>
                <tr>
                    <td colspan="8" class="empty-state">No projects found.</td>
                </tr>
                <% } %>
            </tbody>
        </table>

        <div class="btn-container">
            <button type="button" class="btn-secondary" onclick="location.href = 'projectreport.jsp'">
                Add New Project
            </button>
            <button type="button" class="btn-secondary" onclick="location.href = 'dashboard.jsp'">
                Back to Dashboard
            </button>
        </div>
    </div>
</body>
</html>