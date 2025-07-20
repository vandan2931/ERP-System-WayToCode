<%@ page session="true" %>
<%@ page import="java.io.*,java.util.*" %>
<%
    String userName = (String) session.getAttribute("userName");
    if (userName == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome - Employee Portal</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Rajdhani:wght@500;600&family=Orbitron:wght@500&display=swap" rel="stylesheet">
        <link rel="stylesheet" type="text/css" href="CSS/dashboard.css">


    </head>
    <body>
        <div class="dashboard-container">
            <div class="dashboard-header">
                <h1>Welcome, <%= userName%>!</h1>
                <p>Employee Dashboard</p>
            </div>

            <div class="button-grid">
                <form action="personaldata.jsp" method="post">
                    <button type="submit" class="dashboard-btn btn-personal">
                        <i class="fas fa-user"></i> Personal Data
                    </button>
                </form>

                <form action="leaveform.jsp" method="post">
                    <button type="submit" class="dashboard-btn btn-leave">
                        <i class="fas fa-calendar-alt"></i> Leave Form
                    </button>
                </form>

                <form action="projectreport.jsp" method="post">
                    <button type="submit" class="dashboard-btn btn-projects">
                        <i class="fas fa-project-diagram"></i> Project Report
                    </button>
                </form>

                <form action="monthlyReport.jsp" method="post">
                    <button type="submit" class="dashboard-btn btn-reports">
                        <i class="fas fa-chart-bar"></i>Monthly/Yearly Report
                    </button>
                </form>

                <form action="LogoutServlet" method="post">
                    <button type="submit" class="dashboard-btn logout-btn">
                        <i class="fas fa-sign-out-alt"></i>  Logout
                    </button>
                </form>
            </div>
        </div>

    </body>
</html>