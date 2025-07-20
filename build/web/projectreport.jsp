<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Project Management</title>
        <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Rajdhani">
        <link rel="stylesheet" type="text/css" href="CSS/projectreport.css">
        <style>
            .error-message {
                color: red;
                font-size: 12px;
                margin-top: 5px;
                display: none;
            }
            .required-field:after {
                content: " *";
                color: red;
            }
        </style>
        <script>
            function validateForm() {
                // Hide all error messages first
                document.querySelectorAll('.error-message').forEach(el => el.style.display = 'none');

                const title = document.getElementById("title").value.trim();
                const description = document.getElementById("description").value.trim();
                const startDate = document.getElementById("startDate").value.trim();
                const endDate = document.getElementById("endDate").value.trim();
                const progress = document.getElementById("progressPercent").value.trim();
                const status = document.getElementById("status").value;
                const priority = document.getElementById("priority").value;
                
                let isValid = true;

                // Title validation
                if (title === "") {
                    showError("title-error", "Project title is required");
                    isValid = false;
                } else if (title.length < 3) {
                    showError("title-error", "Title must be at least 3 characters");
                    isValid = false;
                }

                // Description validation
                if (description === "") {
                    showError("description-error", "Description is required");
                    isValid = false;
                }

                // Start date validation
                if (startDate === "") {
                    showError("startDate-error", "Start date is required");
                    isValid = false;
                } else if (new Date(startDate) < new Date()) {
                    if (!confirm("Start date is in the past. Are you sure?")) {
                        showError("startDate-error", "Please select a valid start date");
                        isValid = false;
                    }
                }

                if (endDate !== "") {
                    if (new Date(endDate) <= new Date(startDate)) {
                        showError("endDate-error", "End date must be after start date");
                        isValid = false;
                    }
                }

                if (status === "") {
                    showError("status-error", "Status is required");
                    isValid = false;
                }

                if (priority === "") {
                    showError("priority-error", "Priority is required");
                    isValid = false;
                }

                if (progress === "" || isNaN(progress) || progress < 0 || progress > 100) {
                    showError("progressPercent-error", "Progress must be between 0 and 100");
                    isValid = false;
                }

                if (isValid) {
                    return confirm('Are you sure you want to ${empty editProject ? "add" : "update"} this project?');
                }

                return false;
            }

            function showError(elementId, message) {
                const errorElement = document.getElementById(elementId);
                errorElement.textContent = message;
                errorElement.style.display = 'block';
            }
        </script>
    </head>
    <body>
        <div class="container">
            <h2>
                <c:choose>
                    <c:when test="${empty editProject}">Add New Project</c:when>
                    <c:otherwise>Edit Project</c:otherwise>
                </c:choose>
            </h2>

            <c:if test="${not empty message}">
                <div class="message ${messageType}">${message}</div>
            </c:if>

            <div class="project-form">
                <form method="POST" action="Project" onsubmit="return validateForm()">
                    <input type="hidden" name="id" value="${editProject.id}">

                    <div class="form-group">
                        <label for="title" class="required-field">Project Title</label>
                        <input type="text" id="title" name="title" required 
                               value="${not empty editProject ? editProject.title : ''}">
                        <div id="title-error" class="error-message"></div>
                    </div>

                    <div class="form-group">
                        <label for="description" class="required-field">Description</label>
                        <textarea id="description" name="description" rows="3" required>${not empty editProject ? editProject.description : ''}</textarea>
                        <div id="description-error" class="error-message"></div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="startDate" class="required-field">Start Date</label>
                            <input type="date" id="startDate" name="startDate" required
                                   value="<fmt:formatDate value='${editProject.startDate}' pattern='yyyy-MM-dd' />">
                            <div id="startDate-error" class="error-message"></div>
                        </div>

                        <div class="form-group">
                            <label for="endDate">End Date</label>
                            <input type="date" id="endDate" name="endDate"
                                   value="<fmt:formatDate value='${editProject.endDate}' pattern='yyyy-MM-dd' />">
                            <div id="endDate-error" class="error-message"></div>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-group">
                            <label for="status" class="required-field">Status</label>
                            <select id="status" name="status" required>
                                <option value="">Select Status</option>
                                <option value="Not Started" ${editProject.status eq 'Not Started' ? 'selected' : ''}>Not Started</option>
                                <option value="In Progress" ${editProject.status eq 'In Progress' ? 'selected' : ''}>In Progress</option>
                                <option value="Completed" ${editProject.status eq 'Completed' ? 'selected' : ''}>Completed</option>
                                <option value="On Hold" ${editProject.status eq 'On Hold' ? 'selected' : ''}>On Hold</option>
                            </select>
                            <div id="status-error" class="error-message"></div>
                        </div>

                        <div class="form-group">
                            <label for="priority" class="required-field">Priority</label>
                            <select id="priority" name="priority" required>
                                <option value="">Select Priority</option>
                                <option value="High" ${editProject.priority eq 'High' ? 'selected' : ''}>High</option>
                                <option value="Medium" ${editProject.priority eq 'Medium' ? 'selected' : ''}>Medium</option>
                                <option value="Low" ${editProject.priority eq 'Low' ? 'selected' : ''}>Low</option>
                            </select>
                            <div id="priority-error" class="error-message"></div>
                        </div>

                        <div class="form-group">
                            <label for="progressPercent" class="required-field">Progress (%)</label>
                            <input type="number" id="progressPercent" name="progressPercent" 
                                   min="0" max="100" required
                                   value="${not empty editProject ? editProject.progressPercent : 0}">
                            <div id="progressPercent-error" class="error-message"></div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">
                            <c:choose>
                                <c:when test="${empty editProject}">Add Project</c:when>
                                <c:otherwise>Update Project</c:otherwise>
                            </c:choose>
                        </button>

                        <c:if test="${not empty editProject}">
                            <button type="button" onclick="window.location.href = 'Project?action=list'" 
                                    class="btn btn-secondary">Cancel</button>
                        </c:if>
                    </div>
                </form>
            </div>

            <div class="action-buttons">
                <a href="Project?action=list" class="btn btn-primary ">View All Projects</a>
               
                <a href="dashboard.jsp" class="btn btn-secondary">Back to Dashboard</a>
            </div>
        </div>
    </body>
</html>