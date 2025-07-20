<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="java.time.LocalDate" %>

<!DOCTYPE html>
<html>
    <head>
        <title>
            <c:choose>
                <c:when test="${reportType eq 'yearly'}">Yearly Productivity Report</c:when>
                <c:otherwise>Monthly Productivity Report</c:otherwise>
            </c:choose>
        </title>
        <link rel="stylesheet" type="text/css" href="CSS/monthly-report.css">

        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;700&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    </head>
    <body>
        <div class="report-container">
            <div class="report-header">
                <h2 class="report-title">
                    <c:choose>
                        <c:when test="${reportType eq 'yearly'}">Yearly Productivity Report - ${year}</c:when>
                        <c:otherwise>
                            Monthly Productivity Report - 
                            <c:if test="${not empty year and not empty month}">
                                <fmt:parseDate value="${year}-${month}-01" pattern="yyyy-MM-dd" var="parsedDate" />
                                <fmt:formatDate value="${parsedDate}" pattern="MMMM yyyy" />
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </h2>
                <div class="glow-effect"></div>
            </div>

            <div class="report-controls">
                <div class="report-type-toggle">
                    <a href="MonthlyReportServlet?reportType=monthly&month=${not empty month ? month : LocalDate.now().monthValue}&year=${not empty year ? year : LocalDate.now().year}" 
                       class="toggle-btn ${reportType ne 'yearly' ? 'active' : ''}">Monthly</a>
                    <a href="MonthlyReportServlet?reportType=yearly&year=${not empty year ? year : LocalDate.now().year}" 
                       class="toggle-btn ${reportType eq 'yearly' ? 'active' : ''}">Yearly</a>
                </div>

                <form method="get" action="MonthlyReportServlet" class="date-selector">
                    <input type="hidden" name="reportType" value="${not empty reportType ? reportType : 'monthly'}">
                    
                    <c:if test="${empty reportType or reportType ne 'yearly'}">
                        <div class="form-group">
                            <label for="month">Month</label>
                            <select id="month" name="month" class="futuristic-select">
                                <c:forEach var="m" begin="1" end="12">
                                    <option value="${m}" ${m == (not empty month ? month : LocalDate.now().monthValue) ? 'selected' : ''}>
                                        <fmt:parseDate value="2000-${m}-01" pattern="yyyy-MM-dd" var="parsedMonth" />
                                        <fmt:formatDate value="${parsedMonth}" pattern="MMMM" />
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </c:if>

                    <div class="form-group">
                        <label for="year">Year</label>
                        <select id="year" name="year" class="futuristic-select">
                            <c:set var="currentYear" value="<%=LocalDate.now().getYear()%>" />
                            <c:forEach var="y" begin="${currentYear - 1}" end="${currentYear + 10}">
                                <option value="${y}" ${y == (not empty year ? year : currentYear) ? 'selected' : ''}>${y}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <button type="submit" class="generate-btn">Generate</button>
                </form>
            </div>

            <c:if test="${not empty reportData}">
                <div class="chart-section">
                    <div class="chart-container">
                        <canvas id="productivityChart"></canvas>
                    </div>

                    <div class="data-grid">
                        <div class="data-panel workdays-panel">
                            <h3 class="panel-title">Workdays Summary</h3>
                            <div class="panel-content">
                                <c:choose>
                                    <c:when test="${reportType eq 'yearly'}">
                                        <div class="data-item">
                                            <span class="data-label">Annual Workdays:</span>
                                            <span class="data-value">${reportData.get("Annual Workdays")}</span>
                                        </div>
                                        <div class="data-item">
                                            <span class="data-label">Total Workdays Used:</span>
                                            <span class="data-value">${reportData.get("Total Workdays")}</span>
                                        </div>
                                        <div class="data-item">
                                            <span class="data-label">Total Leaves Taken:</span>
                                            <span class="data-value">${reportData.get("Total Leaves")}</span>
                                        </div>
                                        <div class="data-item highlight">
                                            <span class="data-label">Productivity Ratio:</span>
                                            <span class="data-value">
                                                <fmt:formatNumber value="${(reportData.get('Total Workdays') / reportData.get('Annual Workdays')) * 100}" maxFractionDigits="1" />%
                                            </span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="data-item">
                                            <span class="data-label">Available Workdays:</span>
                                            <span class="data-value">${reportData.get("Workdays")}</span>
                                        </div>
                                        <div class="data-item">
                                            <span class="data-label">Leaves Taken:</span>
                                            <span class="data-value">${reportData.get("Leaves Taken")}</span>
                                        </div>
                                        <div class="data-item">
                                            <span class="data-label">Annual Workdays Remaining:</span>
                                            <span class="data-value">${reportData.get("Annual Workdays")}</span>
                                        </div>
                                        <div class="data-item highlight">
                                            <span class="data-label">Productivity Ratio:</span>
                                            <span class="data-value">
                                                <fmt:formatNumber value="${(reportData.get('Workdays') / 21) * 100}" maxFractionDigits="1" />%
                                            </span>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="data-panel projects-panel">
                            <h3 class="panel-title">Projects Summary</h3>
                            <div class="panel-content">
                                <div class="data-item">
                                    <span class="data-label">Total Projects:</span>
                                    <span class="data-value">${reportData.get("Total Projects")}</span>
                                </div>
                                <div class="data-item">
                                    <span class="data-label">Completed:</span>
                                    <span class="data-value">${reportData.get("Completed Projects")}</span>
                                </div>
                                <div class="data-item">
                                    <span class="data-label">In Progress:</span>
                                    <span class="data-value">${reportData.get("In Progress Projects")}</span>
                                </div>
                                <div class="data-item">
                                    <span class="data-label">On Hold:</span>
                                    <span class="data-value">${reportData.get("On Hold Projects")}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <script>
                    // Prepare data for the chart with default values if null
                    <c:choose>
                        <c:when test="${reportType eq 'yearly'}">
                            const workdays = ${not empty reportData.get("Total Workdays") ? reportData.get("Total Workdays") : 0};
                            const leavesTaken = ${not empty reportData.get("Total Leaves") ? reportData.get("Total Leaves") : 0};
                        </c:when>
                        <c:otherwise>
                            const workdays = ${not empty reportData.get("Workdays") ? reportData.get("Workdays") : 0};
                            const leavesTaken = ${not empty reportData.get("Leaves Taken") ? reportData.get("Leaves Taken") : 0};
                        </c:otherwise>
                    </c:choose>
                    const completedProjects = ${not empty reportData.get("Completed Projects") ? reportData.get("Completed Projects") : 0};
                    const inProgressProjects = ${not empty reportData.get("In Progress Projects") ? reportData.get("In Progress Projects") : 0};
                    const onHoldProjects = ${not empty reportData.get("On Hold Projects") ? reportData.get("On Hold Projects") : 0};

                    const ctx = document.getElementById('productivityChart').getContext('2d');
                    const productivityChart = new Chart(ctx, {
                        type: 'pie',
                        data: {
                            labels: [
                                'Workdays (' + workdays + ')',
                                'Leaves Taken (' + leavesTaken + ')',
                                'Completed Projects (' + completedProjects + ')',
                                'In Progress Projects (' + inProgressProjects + ')',
                                'On Hold Projects (' + onHoldProjects + ')'
                            ],
                            datasets: [{
                                    data: [workdays, leavesTaken, completedProjects, inProgressProjects, onHoldProjects],
                                    backgroundColor: [
                                        'rgba(0, 231, 255, 0.7)', // Cyan for workdays
                                        'rgba(255, 71, 87, 0.7)', // Pink for leaves
                                        'rgba(46, 213, 115, 0.7)', // Green for completed
                                        'rgba(255, 165, 2, 0.7)', // Orange for in progress
                                        'rgba(162, 155, 254, 0.7)' // Purple for on hold
                                    ],
                                    borderColor: [
                                        'rgba(0, 231, 255, 1)',
                                        'rgba(255, 71, 87, 1)',
                                        'rgba(46, 213, 115, 1)',
                                        'rgba(255, 165, 2, 1)',
                                        'rgba(162, 155, 254, 1)'
                                    ],
                                    borderWidth: 2
                                }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                title: {
                                    display: true,
                                    text: '${reportType eq "yearly" ? "Yearly" : "Monthly"} Productivity Overview',
                                    font: {
                                        family: 'Orbitron',
                                        size: 18,
                                        weight: 'bold'
                                    },
                                    color: '#ffffff'
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function (context) {
                                            const label = context.label || '';
                                            const value = context.raw || 0;
                                            const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                            const percentage = Math.round((value / total) * 100);
                                            return `${label}: ${value} (${percentage}%)`;
                                        }
                                    },
                                    bodyFont: {
                                        family: 'Roboto',
                                        size: 12
                                    }
                                },
                                legend: {
                                    position: 'bottom',
                                    labels: {
                                        font: {
                                            family: 'Roboto',
                                            size: 12
                                        },
                                        color: '#ffffff'
                                    }
                                }
                            }
                        }
                    });
                </script>
            </c:if>

            <div class="navigation">
                <a href="dashboard.jsp" class="back-btn">Back to Dashboard</a>
            </div>
        </div>
    </body>
</html>