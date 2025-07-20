package servlets;

import model.Project;
import utils.DatabaseUtil;
import constants.Constants;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "ProjectServlet", urlPatterns = {"/Project"})
public class ProjectServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(ProjectServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String idParam = request.getParameter("id");
        String reportType = request.getParameter("reportType");

        try {
            if ("edit".equalsIgnoreCase(action) && idParam != null) {
                int projectId = Integer.parseInt(idParam);
                Project editProject = getProjectById(projectId, userId);
                request.setAttribute("editProject", editProject);
                request.getRequestDispatcher("projectreport.jsp").forward(request, response);
                return;
            } else if ("delete".equalsIgnoreCase(action) && idParam != null) {
                int projectId = Integer.parseInt(idParam);
                boolean deleted = deleteProjectById(projectId, userId);
                if (deleted) {
                    session.setAttribute("message", "Project deleted successfully!");
                    session.setAttribute("messageType", "success");
                } else {
                    session.setAttribute("message", "Failed to delete project");
                    session.setAttribute("messageType", "error");
                }
                response.sendRedirect("Project?action=list");
                return;
            } else if ("list".equalsIgnoreCase(action)) {
                List<Project> projects = getProjectsByUser(userId);
                request.setAttribute("projects", projects);
                
                // Check for messages from session
                if (session.getAttribute("message") != null) {
                    request.setAttribute("message", session.getAttribute("message"));
                    request.setAttribute("messageType", session.getAttribute("messageType"));
                    session.removeAttribute("message");
                    session.removeAttribute("messageType");
                }
                
                request.getRequestDispatcher("Project.jsp").forward(request, response);
                return;
            } else if ("generateReport".equalsIgnoreCase(action) && reportType != null) {
                generateProjectReport(request, response, userId, reportType);
                return;
            }
        } catch (NumberFormatException e) {
            LOGGER.log(Level.WARNING, "Invalid project ID: " + idParam, e);
            session.setAttribute("message", "Invalid project ID");
            session.setAttribute("messageType", "error");
            response.sendRedirect("Project?action=list");
            return;
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error processing request", ex);
            session.setAttribute("message", "Server error occurred");
            session.setAttribute("messageType", "error");
            response.sendRedirect("Project?action=list");
            return;
        }

        // Default action if none specified
        response.sendRedirect("Project?action=list");
    }

    private void generateProjectReport(HttpServletRequest request, HttpServletResponse response, 
                                     int userId, String reportType) throws Exception {
        List<Project> projects = getProjectsByUser(userId);
        
        switch(reportType) {
            case "status":
                request.setAttribute("reportTitle", "Projects by Status");
                break;
            case "priority":
                request.setAttribute("reportTitle", "Projects by Priority");
                break;
            case "timeline":
                request.setAttribute("reportTitle", "Projects Timeline");
                break;
            default:
                request.setAttribute("reportTitle", "All Projects");
        }
        
        request.setAttribute("projects", projects);
        request.setAttribute("reportType", reportType);
        request.getRequestDispatcher("/WEB-INF/views/projectReport.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String id = request.getParameter("id");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String progressStr = request.getParameter("progressPercent");
        String status = request.getParameter("status");
        String priority = request.getParameter("priority");

        List<String> errors = new ArrayList<>();
        
        if (title == null || title.trim().isEmpty()) {
            errors.add("Project title is required");
        }
        
        if (startDate == null || startDate.trim().isEmpty()) {
            errors.add("Start date is required");
        }
        
        if (progressStr == null || progressStr.trim().isEmpty()) {
            errors.add("Progress percentage is required");
        } else {
            try {
                int progress = Integer.parseInt(progressStr);
                if (progress < 0 || progress > 100) {
                    errors.add("Progress must be between 0 and 100");
                }
            } catch (NumberFormatException e) {
                errors.add("Invalid progress value");
            }
        }
        
        if (endDate != null && !endDate.isEmpty() && startDate != null && !startDate.isEmpty()) {
            try {
                Date start = Date.valueOf(startDate);
                Date end = Date.valueOf(endDate);
                if (end.before(start)) {
                    errors.add("End date cannot be before start date");
                }
            } catch (IllegalArgumentException e) {
                errors.add("Invalid date format");
            }
        }
        
        if (!errors.isEmpty()) {
            session.setAttribute("message", String.join("<br>", errors));
            session.setAttribute("messageType", "error");
            
            // Preserve the form data for re-display
            Project project = new Project();
            try {
                if (id != null && !id.isEmpty()) {
                    project.setId(Integer.parseInt(id));
                }
            } catch (NumberFormatException e) {
                LOGGER.log(Level.WARNING, "Invalid project ID during error handling", e);
            }
            project.setTitle(title);
            project.setDescription(description);
            project.setStartDate(startDate != null ? Date.valueOf(startDate) : null);
            project.setEndDate(endDate != null && !endDate.isEmpty() ? Date.valueOf(endDate) : null);
            project.setProgressPercent(progressStr != null ? Integer.parseInt(progressStr) : 0);
            project.setStatus(status);
            project.setPriority(priority);
            
            request.setAttribute("editProject", project);
            request.getRequestDispatcher("projectreport.jsp").forward(request, response);
            return;
        }

        int progress = Integer.parseInt(progressStr);

        boolean success = false;
        String message = "";
        String messageType = "error";

        try {
            int projectId = (id != null && !id.trim().isEmpty()) ? Integer.parseInt(id.trim()) : -1;
            
            if (projectId > 0) {
                success = updateProject(
                    projectId, userId, title, description, 
                    startDate, endDate, progress, status, 
                    priority
                );
                message = success ? "Project updated successfully!" : "Failed to update project";
            } else {
                success = addProject(
                    userId, title, description, startDate, 
                    endDate, progress, status, priority
                );
                message = success ? "Project added successfully!" : "Failed to add project";
            }
            messageType = success ? "success" : "error";
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Error processing project", ex);
            message = "An error occurred while processing your request";
        }

        session.setAttribute("message", message);
        session.setAttribute("messageType", messageType);
        response.sendRedirect("Project?action=list");
    }

    private boolean addProject(int userId, String title, String description,
                             String startDate, String endDate, int progress,
                             String status, String priority) throws Exception {
        String sql = "INSERT INTO projects (employee_id, title, description, start_date, " +
                     "end_date, progress_percent, status, priority) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
   
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, userId);
            ps.setString(2, title);
            ps.setString(3, description);
            ps.setDate(4, Date.valueOf(startDate));
            ps.setDate(5, endDate != null && !endDate.isEmpty() ? Date.valueOf(endDate) : null);
            ps.setInt(6, progress);
            ps.setString(7, status);
            ps.setString(8, priority);
            
            int affectedRows = ps.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding project", e);
            throw e;
        }
    }

    private boolean updateProject(int projectId, int userId, String title, String description,
                                String startDate, String endDate, int progress, String status,
                                String priority) throws Exception {
        String sql = "UPDATE projects SET title = ?, description = ?, start_date = ?, " +
                     "end_date = ?, progress_percent = ?, status = ?, priority = ? " +
                     "WHERE id = ? AND employee_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, title);
            ps.setString(2, description);
            ps.setDate(3, Date.valueOf(startDate));
            ps.setDate(4, endDate != null && !endDate.isEmpty() ? Date.valueOf(endDate) : null);
            ps.setInt(5, progress);
            ps.setString(6, status);
            ps.setString(7, priority);
            ps.setInt(8, projectId);
            ps.setInt(9, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating project", e);
            throw e;
        }
    }

    private boolean deleteProjectById(int projectId, int userId) throws Exception {
        String sql = "DELETE FROM projects WHERE id = ? AND employee_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, projectId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting project", e);
            throw e;
        }
    }

    private Project getProjectById(int id, int userId) throws Exception {
        String sql = "SELECT * FROM projects WHERE id = ? AND employee_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, id);
            ps.setInt(2, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Project project = new Project();
                project.setId(rs.getInt("id"));
                project.setEmployeeId(rs.getInt("employee_id"));
                project.setTitle(rs.getString("title"));
                project.setDescription(rs.getString("description"));
                project.setStartDate(rs.getDate("start_date"));
                project.setEndDate(rs.getDate("end_date"));
                project.setProgressPercent(rs.getInt("progress_percent"));
                project.setStatus(rs.getString("status"));
                project.setPriority(rs.getString("priority"));
                return project;
            }
            return null;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching project by ID", e);
            throw e;
        }
    }

    private List<Project> getProjectsByUser(int userId) throws Exception {
        List<Project> projects = new ArrayList<>();
        String sql = "SELECT * FROM projects WHERE employee_id = ? ORDER BY start_date DESC";

        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Project project = new Project();
                project.setId(rs.getInt("id"));
                project.setEmployeeId(rs.getInt("employee_id"));
                project.setTitle(rs.getString("title"));
                project.setDescription(rs.getString("description"));
                project.setStartDate(rs.getDate("start_date"));
                project.setEndDate(rs.getDate("end_date"));
                project.setProgressPercent(rs.getInt("progress_percent"));
                project.setStatus(rs.getString("status"));
                project.setPriority(rs.getString("priority"));
                projects.add(project);
            }
            return projects;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching projects list", e);
            throw e;
        }
    }
}