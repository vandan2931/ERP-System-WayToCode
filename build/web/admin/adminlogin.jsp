<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Login</title>
    <link rel="stylesheet" type="text/css" href="CSS/style.css">
</head>
<body>
    <div class="admin-login-container">
        <div class="admin-form">
            <h2>Admin Login</h2>
            <form action="AdminLoginServlet" method="post">
                <input type="email" name="email" placeholder="Admin Email" required />
                <input type="password" name="password" placeholder="Password" required />
                <button type="submit">Login</button>
            </form>
            <% String error = request.getParameter("error"); %>
            <% if (error != null) { %>
                <p class="error-message"><%= error %></p>
            <% } %>
            <div class="back-to-main">
                <a href="login.jsp">? Back to main login</a>
            </div>
        </div>
    </div>
</body>
</html>