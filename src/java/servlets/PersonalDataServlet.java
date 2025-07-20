package servlets;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import java.math.BigDecimal;
import java.sql.Date;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.*;
import utils.DatabaseUtil;
import javax.servlet.annotation.MultipartConfig;
import constants.Constants;

@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 5,
        maxRequestSize = 1024 * 1024 * 10
)
public class PersonalDataServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute(Constants.SESSION_USER_ID) == null
                || session.getAttribute(Constants.SESSION_USER_ROLE) == null) {
            response.sendRedirect(Constants.JSP_LOGIN);
            return;
        }

        int userId = (int) session.getAttribute(Constants.SESSION_USER_ID);
        String userRole = (String) session.getAttribute(Constants.SESSION_USER_ROLE);

        String employeeIdParam = request.getParameter(Constants.PARAM_EMPLOYEE_ID);
        int targetUserId = userId;

        if (employeeIdParam != null && Constants.ROLE_ADMIN.equals(userRole)) {
            try {
                targetUserId = Integer.parseInt(employeeIdParam);
            } catch (NumberFormatException e) {
                targetUserId = userId;
            }
        }

        String name = request.getParameter(Constants.COL_NAME);
        String email = request.getParameter(Constants.COL_EMAIL);
        String department = request.getParameter(Constants.COL_DEPARTMENT);
        String contact = request.getParameter(Constants.COL_CONTACT);
        String password = request.getParameter(Constants.COL_PASSWORD);
        String status = request.getParameter(Constants.COL_STATUS);
        String role = request.getParameter(Constants.COL_ROLE);
        String ageStr = request.getParameter(Constants.COL_AGE);
        String dobStr = request.getParameter(Constants.COL_DOB);
        String currentSalaryStr = request.getParameter(Constants.COL_CURRENT_SALARY);
        String previousSalaryStr = request.getParameter(Constants.COL_PREVIOUS_SALARY);
        String dateOfJoiningStr = request.getParameter(Constants.COL_DATE_OF_JOINING);
        String experienceStr = request.getParameter(Constants.COL_EXPERIENCE);
        Part filePart = request.getPart(Constants.COL_PROFILE_IMAGE);

        if (name == null || name.trim().isEmpty() || email == null || email.trim().isEmpty()
                || department == null || department.trim().isEmpty() || contact == null || contact.trim().isEmpty()) {
            session.setAttribute(Constants.MSG_TYPE_ERROR, Constants.ERR_REQUIRED_FIELDS_EMPTY);
            response.sendRedirect(Constants.JSP_PERSONAL_DATA + (targetUserId != userId ? "?"
                    + Constants.PARAM_EMPLOYEE_ID + "=" + targetUserId : ""));
            return;
        }

        if (!contact.matches("\\d{10}")) {
            session.setAttribute(Constants.MSG_TYPE_ERROR, Constants.ERR_INVALID_CONTACT);
            response.sendRedirect(Constants.JSP_PERSONAL_DATA + (targetUserId != userId ? "?"
                    + Constants.PARAM_EMPLOYEE_ID + "=" + targetUserId : ""));
            return;
        }

        if (!Arrays.asList(Constants.DEPARTMENTS).contains(department)) {
            session.setAttribute(Constants.MSG_TYPE_ERROR, Constants.ERR_INVALID_DEPARTMENT);
            response.sendRedirect(Constants.JSP_PERSONAL_DATA + (targetUserId != userId ? "?"
                    + Constants.PARAM_EMPLOYEE_ID + "=" + targetUserId : ""));
            return;
        }

        if (!Constants.ROLE_ADMIN.equals(userRole)) {
            Connection connCheck = null;
            PreparedStatement psCheck = null;
            ResultSet rsCheck = null;

            try {
                connCheck = DatabaseUtil.getConnection();
                psCheck = connCheck.prepareStatement(
                        "SELECT " + Constants.COL_NAME + ", " + Constants.COL_EXPERIENCE + ", "
                        + Constants.COL_CURRENT_SALARY + ", " + Constants.COL_PREVIOUS_SALARY + ", "
                        + Constants.COL_DATE_OF_JOINING + ", " + Constants.COL_DEPARTMENT
                        + " FROM " + Constants.TABLE_EMPLOYEES + " WHERE " + Constants.COL_ID + " = ?");
                psCheck.setInt(1, userId);
                rsCheck = psCheck.executeQuery();

                if (rsCheck.next()) {
                    name = rsCheck.getString(Constants.COL_NAME);
                    experienceStr = String.valueOf(rsCheck.getInt(Constants.COL_EXPERIENCE));
                    currentSalaryStr = rsCheck.getBigDecimal(Constants.COL_CURRENT_SALARY).toString();
                    previousSalaryStr = rsCheck.getBigDecimal(Constants.COL_PREVIOUS_SALARY).toString();
                    dateOfJoiningStr = rsCheck.getDate(Constants.COL_DATE_OF_JOINING).toString();
                    department = rsCheck.getString(Constants.COL_DEPARTMENT);
                }
            } catch (SQLException e) {
                Logger.getLogger(PersonalDataServlet.class.getName()).log(Level.SEVERE, "Error fetching original values", e);
            } finally {
                DatabaseUtil.closeResources(connCheck, psCheck, rsCheck);
            }
        }

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);

            StringBuilder query = new StringBuilder(
                    "UPDATE " + Constants.TABLE_EMPLOYEES + " SET " + Constants.COL_NAME + "=?, "
                    + Constants.COL_EMAIL + "=?, " + Constants.COL_DEPARTMENT + "=?, "
                    + Constants.COL_CONTACT + "=?");

            List<Object> params = new ArrayList<>();
            params.add(name);
            params.add(email);
            params.add(department);
            params.add(contact);

            if (filePart != null && filePart.getSize() > 0) {
                try (InputStream fileContent = filePart.getInputStream()) {
                    ByteArrayOutputStream buffer = new ByteArrayOutputStream();
                    byte[] data = new byte[16384];
                    int nRead;
                    while ((nRead = fileContent.read(data, 0, data.length)) != -1) {
                        buffer.write(data, 0, nRead);
                    }
                    buffer.flush();
                    byte[] imageBytes = buffer.toByteArray();
                    query.append(", " + Constants.COL_PROFILE_IMAGE + "=?");
                    params.add(imageBytes);
                }
            }

            if (Constants.ROLE_ADMIN.equals(userRole)) {
                if (password != null && !password.isEmpty()) {
                    query.append(", " + Constants.COL_PASSWORD + "=?");
                    params.add(password);
                }

                if (status != null && !status.isEmpty()) {
                    query.append(", " + Constants.COL_STATUS + "=?");
                    params.add(status);
                }

                if (role != null && !role.isEmpty()) {
                    query.append(", " + Constants.COL_ROLE + "=?");
                    params.add(role);
                }
            }

            if (ageStr != null && !ageStr.isEmpty()) {
                query.append(", " + Constants.COL_AGE + "=?");
                params.add(Integer.parseInt(ageStr));
            }

            if (experienceStr != null && !experienceStr.isEmpty()) {
                query.append(", " + Constants.COL_EXPERIENCE + "=?");
                params.add(Integer.parseInt(experienceStr));
            }

            if (dobStr != null && !dobStr.isEmpty()) {
                query.append(", " + Constants.COL_DOB + "=?");
                params.add(Date.valueOf(dobStr));
            }

            if (currentSalaryStr != null && !currentSalaryStr.isEmpty()) {
                query.append(", " + Constants.COL_CURRENT_SALARY + "=?");
                params.add(new BigDecimal(currentSalaryStr));
            }

            if (previousSalaryStr != null && !previousSalaryStr.isEmpty()) {
                query.append(", " + Constants.COL_PREVIOUS_SALARY + "=?");
                params.add(new BigDecimal(previousSalaryStr));
            }

            if (dateOfJoiningStr != null && !dateOfJoiningStr.isEmpty()) {
                query.append(", " + Constants.COL_DATE_OF_JOINING + "=?");
                params.add(Date.valueOf(dateOfJoiningStr));
            }

            query.append(" WHERE " + Constants.COL_ID + "=?");
            params.add(targetUserId);

            ps = conn.prepareStatement(query.toString());

            for (int i = 0; i < params.size(); i++) {
                Object param = params.get(i);
                if (param instanceof Date) {
                    ps.setDate(i + 1, (Date) param);
                } else if (param instanceof BigDecimal) {
                    ps.setBigDecimal(i + 1, (BigDecimal) param);
                } else if (param instanceof byte[]) {
                    ps.setBytes(i + 1, (byte[]) param);
                } else {
                    ps.setObject(i + 1, param);
                }
            }

            int rowsAffected = ps.executeUpdate();
            conn.commit();

            if (rowsAffected > 0) {
                session.setAttribute(Constants.MSG_TYPE_SUCCESS, Constants.MSG_PROFILE_UPDATED);
            } else {
                session.setAttribute(Constants.MSG_TYPE_ERROR, Constants.ERR_NO_CHANGES_MADE);
            }

        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                Logger.getLogger(PersonalDataServlet.class.getName()).log(Level.SEVERE, "Error rolling back transaction", ex);
            }
            session.setAttribute(Constants.MSG_TYPE_ERROR, Constants.ERR_DATABASE_ERROR + ": " + e.getMessage());
            Logger.getLogger(PersonalDataServlet.class.getName()).log(Level.SEVERE, "Database error", e);
        } catch (NumberFormatException e) {
            session.setAttribute(Constants.MSG_TYPE_ERROR, Constants.ERR_INVALID_NUMBER_FORMAT + ": " + e.getMessage());
        } catch (IllegalArgumentException e) {
            session.setAttribute(Constants.MSG_TYPE_ERROR, Constants.ERR_INVALID_DATE_FORMAT);
        } catch (Exception ex) {
            session.setAttribute(Constants.MSG_TYPE_ERROR, Constants.ERR_UNEXPECTED_ERROR);
            Logger.getLogger(PersonalDataServlet.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            DatabaseUtil.closeResources(conn, ps, null);
        }

        response.sendRedirect(Constants.JSP_PERSONAL_DATA + (targetUserId != userId ? "?"
                + Constants.PARAM_EMPLOYEE_ID + "=" + targetUserId : ""));
    }
}
