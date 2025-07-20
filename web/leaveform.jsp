<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.Date"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.Connection"%>
<%@ page import="constants.Constants, utils.DatabaseUtil, java.text.SimpleDateFormat" %>
<%@ page session="true" %>
<%
    // Authentication
    Integer employeeId = (Integer) session.getAttribute(Constants.SESSION_USER_ID);
    if (employeeId == null) {
        response.sendRedirect(Constants.JSP_LOGIN);
        return;
    }

    // Use constants
    final int MAX_ANNUAL_LEAVES = Constants.MAX_ANNUAL_LEAVES;
    final int MAX_WORKDAYS = Constants.ANNUAL_WORKDAYS;
    int leavesTaken = 0;
    int workdaysUsed = 0;
    int leavesPending = 0;
    SimpleDateFormat formatter = new SimpleDateFormat(Constants.DATE_FORMAT_DISPLAY);

    String messageSuccess = request.getParameter(Constants.MSG_TYPE_SUCCESS);
    String messageError = request.getParameter(Constants.MSG_TYPE_ERROR);
    String errorType = request.getParameter("errorType");

    Connection dbConnection = null;
    PreparedStatement statement = null;
    ResultSet result = null;

    try {
        dbConnection = DatabaseUtil.getConnection();

        // data approved leaves
        statement = dbConnection.prepareStatement(
                "SELECT SUM(DATEDIFF(end_date, start_date) + 1) AS total FROM leave_requests WHERE employee_id = ? AND status = ?"
        );
        statement.setInt(1, employeeId);
        statement.setString(2, Constants.STATUS_APPROVED);
        result = statement.executeQuery();
        if (result.next()) {
            leavesTaken = result.getInt("total");
            if (result.wasNull()) {
                leavesTaken = 0;
            }
        }
        result.close();
        statement.close();

        // get workdays used (same as leaves taken)
        workdaysUsed = leavesTaken;

        //pending leaves
        statement = dbConnection.prepareStatement(
                "SELECT SUM(DATEDIFF(end_date, start_date) + 1) AS total FROM leave_requests WHERE employee_id = ? AND status = ?"
        );
        statement.setInt(1, employeeId);
        statement.setString(2, Constants.STATUS_PENDING);
        result = statement.executeQuery();
        if (result.next()) {
            leavesPending = result.getInt("total");
            if (result.wasNull()) {
                leavesPending = 0;
            }
        }

    } catch (Exception exception) {
        exception.printStackTrace();
        messageError = "true";
    } finally {
        if (result != null) {
            try {
                result.close();
            } catch (SQLException ignore) {
            }
        }
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException ignore) {
            }
        }
        if (dbConnection != null) {
            try {
                dbConnection.close();
            } catch (SQLException ignore) {
            }
        }
    }

    int leavesRemaining = MAX_ANNUAL_LEAVES - leavesTaken;
    int workdaysRemaining = MAX_WORKDAYS - workdaysUsed;
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Leave Management</title>
        <link rel="stylesheet" type="text/css" href="CSS/leaveform.css">
        <style>
            .reason-cell {
                max-width: 300px;
                word-wrap: break-word;
                white-space: normal;
            }

            .alert-danger {
                color: #721c24;
                background-color: #f8d7da;
                border-color: #f5c6cb;
                padding: 10px;
                margin-bottom: 15px;
                border-radius: 4px;
            }

            .low-balance {
                color: #ff9800;
                font-weight: bold;
            }

            .critical-balance {
                color: #f44336;
                font-weight: bold;
            }

            @media (max-width: 768px) {
                .reason-cell {
                    max-width: 150px;
                }
                .summary-cards {
                    flex-direction: column;
                }
                .card-item {
                    margin-bottom: 10px;
                }
                table {
                    font-size: 0.8rem;
                }
                th, td {
                    padding: 5px;
                }
            }
        </style>
    </head>
    <body>
        <div class="container py-5">
            <% if (messageSuccess != null) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <%= Constants.MSG_LEAVE_SUBMITTED %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
            <% } %>

            <% if (messageError != null) { %>
            <div class="alert-danger" role="alert">
                <%
                    String errorMessage = Constants.ERR_UNEXPECTED_ERROR;
                    if (errorType != null) {
                        switch (errorType) {
                            case "invalid_date_format":
                                errorMessage = Constants.ERR_INVALID_DATE_FORMAT;
                                break;
                            case "past_date_not_allowed":
                                errorMessage = Constants.ERR_PAST_DATE_NOT_ALLOWED;
                                break;
                            case "invalid_date_range":
                                errorMessage = Constants.ERR_INVALID_DATE_RANGE;
                                break;
                            case "not_enough_leaves":
                                errorMessage = Constants.ERR_NOT_ENOUGH_LEAVES;
                                break;
                            case "exceeds_workdays":
                                errorMessage = Constants.ERR_NOT_ENOUGH_LEAVES;
                                break;
                            case "exceeds_monthly_workdays":
                                errorMessage = Constants.ERR_NOT_ENOUGH_LEAVES;
                                break;
                            case "overlapping_leave":
                                errorMessage = Constants.ERR_OVERLAPPING_LEAVE;
                                break;
                            case "database_error":
                                errorMessage = Constants.ERR_DATABASE_ERROR;
                                break;
                        }
                    }
                %>
                <%= errorMessage%>
            </div>
            <% }%>

            <h2 class="mb-4">Leave Dashboard</h2>

            <section class="leave-balance">
                <h3>Leave Summary</h3>
                <div class="summary-cards">
                    <div class="card-item"><strong>Total Leaves:</strong> <%= MAX_ANNUAL_LEAVES%></div>
                    <div class="card-item"><strong>Taken Leaves:</strong> <%= leavesTaken%></div>
                    <div class="card-item"><strong>Pending Leaves:</strong> <%= leavesPending%></div>
                    <div class="card-item highlight <%= leavesRemaining <= 5 ? (leavesRemaining <= 2 ? "critical-balance" : "low-balance") : ""%>">
                        <strong>Remaining Leaves:</strong> <%= leavesRemaining%>
                    </div>
                </div>
                <% if (leavesRemaining <= 5) {%>
                <div class="balance-warning <%= leavesRemaining <= 2 ? "critical-balance" : "low-balance"%>">
                    <% if (leavesRemaining <= 2) { %>
                    Warning: Very low leave balance!
                    <% } else { %>
                    Notice: Low leave balance remaining
                    <% } %>
                </div>
                <% }%>
            </section>

            <section class="leave-application">
                <h3>Apply for Leave</h3>
                <form action="<%= Constants.SERVLET_LEAVE_FORM %>" method="post" onsubmit="return validateLeaveForm()">
                    <div class="form-group">
                        <label for="type">Leave Type</label>
                        <select name="type" id="type" required>
                            <option value="">Select</option>
                            <option value="<%= Constants.LEAVE_TYPE_ANNUAL %>">Annual</option>
                            <option value="<%= Constants.LEAVE_TYPE_SICK %>">Sick</option>
                            <option value="<%= Constants.LEAVE_TYPE_CASUAL %>">Casual</option>
                            <option value="<%= Constants.LEAVE_TYPE_MATERNITY_PATERNITY %>">Maternity/Paternity</option>
                            <option value="<%= Constants.LEAVE_TYPE_BEREAVEMENT %>">Bereavement</option>
                        </select>
                    </div>
                    <div class="form-row">
                        <input type="date" name="start" id="start" required min="<%= new java.text.SimpleDateFormat(Constants.DATE_FORMAT_HTML).format(new java.util.Date())%>">
                        <input type="date" name="end" id="end" required>
                        <input type="text" id="days" readonly placeholder="Days">
                    </div>
                    <div class="form-group">
                        <textarea name="reason" id="reason" placeholder="Reason (required)" required></textarea>
                    </div>
                    <button type="submit">Submit</button>
                </form>
            </section>

            <section class="leave-history">
                <h3>Leave History</h3>
                <div class="table-responsive">
                    <table>
                        <thead>
                            <tr>
                                <th>Type</th>
                                <th>Start</th>
                                <th>End</th>
                                <th>Days</th>
                                <th>Reason</th>
                                <th>Status</th>
                                <th>Applied</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection historyConn = null;
                                PreparedStatement historyStmt = null;
                                ResultSet historyRs = null;

                                try {
                                    historyConn = DatabaseUtil.getConnection();
                                    historyStmt = historyConn.prepareStatement(
                                            "SELECT leave_type, start_date, end_date, status, reason, applied_on FROM leave_requests WHERE employee_id = ? ORDER BY applied_on DESC"
                                    );
                                    historyStmt.setInt(1, employeeId);
                                    historyRs = historyStmt.executeQuery();

                                    while (historyRs.next()) {
                                        Date start = historyRs.getDate("start_date");
                                        Date end = historyRs.getDate("end_date");
                                        long dayCount = (end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24) + 1;
                                        String status = historyRs.getString("status");
                                        String cssClass = "";

                                        if (Constants.STATUS_APPROVED.equalsIgnoreCase(status)) {
                                            cssClass = "approved";
                                        } else if (Constants.STATUS_PENDING.equalsIgnoreCase(status)) {
                                            cssClass = "pending";
                                        } else if (Constants.STATUS_REJECTED.equalsIgnoreCase(status)) {
                                            cssClass = "rejected";
                                        }
                            %>
                            <tr class="<%= cssClass%>">
                                <td><%= historyRs.getString("leave_type")%></td>
                                <td><%= formatter.format(start)%></td>
                                <td><%= formatter.format(end)%></td>
                                <td><%= dayCount%></td>
                                <td class="reason-cell"><%= historyRs.getString("reason")%></td>
                                <td><%= status%></td>
                                <td><%= formatter.format(historyRs.getDate("applied_on"))%></td>
                            </tr>
                            <%
                                }
                            } catch (Exception ex) {
                                ex.printStackTrace();
                            %>
                            <tr><td colspan="7"><%= Constants.ERR_LEAVE_HISTORY %></td></tr>
                            <%
                                } finally {
                                    if (historyRs != null) {
                                        try {
                                            historyRs.close();
                                        } catch (SQLException ignore) {
                                        }
                                    }
                                    if (historyStmt != null) {
                                        try {
                                            historyStmt.close();
                                        } catch (SQLException ignore) {
                                        }
                                    }
                                    if (historyConn != null) {
                                        try {
                                            historyConn.close();
                                        } catch (SQLException ignore) {
                                        }
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
                <div class="back-dashboard">
                    <button type="button" class="btn-secondary" onclick="location.href = '<%= Constants.JSP_DASHBOARD %>'">
                        Back to Dashboard
                    </button>
                </div>
            </section>
        </div>

        <script>
            document.getElementById('start').addEventListener('change', calculateDays);
            document.getElementById('end').addEventListener('change', calculateDays);

            function calculateDays() {
                const start = new Date(document.getElementById('start').value);
                const end = new Date(document.getElementById('end').value);

                if (start && end && start <= end) {
                    const duration = Math.ceil((end - start) / (1000 * 60 * 60 * 24)) + 1;
                    document.getElementById('days').value = duration;

                    // Check for weekends (optional)
                    let weekends = 0;
                    let current = new Date(start);
                    while (current <= end) {
                        const day = current.getDay();
                        if (day === 0 || day === 6) {
                            weekends++;
                        }
                        current.setDate(current.getDate() + 1);
                    }

                    if (weekends > 0) {
                        alert('Note: Your leave includes ' + weekends + ' weekend day(s)');
                    }
                } else {
                    document.getElementById('days').value = '';
                }
            }

            function validateLeaveForm() {
                const start = new Date(document.getElementById('start').value);
                const end = new Date(document.getElementById('end').value);
                const today = new Date();
                today.setHours(0, 0, 0, 0);

                if (start < today) {
                    alert('<%= Constants.ERR_PAST_DATE_NOT_ALLOWED %>');
                    return false;
                }
                if (end < start) {
                    alert('<%= Constants.ERR_INVALID_DATE_RANGE %>');
                    return false;
                }

                // Check if remaining leaves are sufficient (client-side estimation)
                const daysRequested = Math.ceil((end - start) / (1000 * 60 * 60 * 24)) + 1;
                const remainingElement = document.querySelector('.highlight');
                const remainingText = remainingElement ? remainingElement.textContent.match(/\d+/) : null;
                const remainingLeaves = remainingText ? parseInt(remainingText[0]) : 0;

                if (daysRequested > remainingLeaves) {
                    return confirm('<%= Constants.ERR_NOT_ENOUGH_LEAVES %> Do you want to proceed?');
                }

                return true;
            }
        </script>
    </body>
</html>