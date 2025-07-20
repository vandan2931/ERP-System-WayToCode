<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html>
    <head>
        <title>
            <c:choose>
                <c:when test="${reportType eq 'yearly'}">Yearly Productivity Report</c:when>
                <c:otherwise>Monthly Productivity Report</c:otherwise>
            </c:choose>
        </title>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/CSS/monthly-report.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;500;700&family=Roboto:wght@300;400;500&display=swap" rel="stylesheet">
    </head>
    <body>
        <div class="report-container">
            <div class="report-header">
                <h2 class="report-title">
                    <c:choose>
                        <c:when test="${reportType eq 'yearly'}">
                            Yearly Productivity Report - ${year} 
                            <span class="employee-name">for ${employeeName}</span>
                        </c:when>
                        <c:otherwise>
                            Monthly Productivity Report - 
                            <c:if test="${not empty year and not empty month}">
                                <fmt:parseDate value="${year}-${month}-01" pattern="yyyy-MM-dd" var="parsedDate" />
                                <fmt:formatDate value="${parsedDate}" pattern="MMMM yyyy" />
                            </c:if>
                            <span class="employee-name">for ${employeeName}</span>
                        </c:otherwise>
                    </c:choose>
                </h2>
                <div class="glow-effect"></div>
            </div>

            <div class="report-controls">
                <div class="report-type-toggle">
                    <a href="AdminReportServlet?employeeId=${param.employeeId}&reportType=monthly&month=${month}&year=${year}" 
                       class="toggle-btn ${reportType ne 'yearly' ? 'active' : ''}">Monthly</a>
                    <a href="AdminReportServlet?employeeId=${param.employeeId}&reportType=yearly&year=${year}" 
                       class="toggle-btn ${reportType eq 'yearly' ? 'active' : ''}">Yearly</a>
                </div>

                <form method="get" action="AdminReportServlet" class="date-selector">
                    <input type="hidden" name="employeeId" value="${param.employeeId}">
                    <input type="hidden" name="reportType" value="${reportType}">

                    <c:if test="${reportType ne 'yearly'}">
                        <div class="form-group">
                            <label for="month">Month</label>
                            <select id="month" name="month" class="futuristic-select">
                                <c:forEach var="m" begin="1" end="12">
                                    <option value="${m}" ${m == month ? 'selected' : ''}>
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
                            <c:set var="currentYear" value="<%=java.time.Year.now().getValue()%>" />
                            <c:forEach var="y" begin="${currentYear - 1}" end="${currentYear + 10}">
                                <option value="${y}" ${y == year ? 'selected' : ''}>${y}</option>
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
                                            <span class="data-value">${reportData.getOrDefault("Annual Workdays", 252)}</span>
                                        </div>
                                        <div class="data-item">
                                            <span class="data-label">Total Workdays Used:</span>
                                            <span class="data-value">${reportData.getOrDefault("Total Workdays", 0)}</span>
                                        </div>
                                        <div class="data-item">
                                            <span class="data-label">Total Leaves Taken:</span>
                                            <span class="data-value">${reportData.getOrDefault("Total Leaves", 0)}</span>
                                        </div>
                                        <div class="data-item highlight">
                                            <span class="data-label">Productivity Ratio:</span>
                                            <span class="data-value">
                                                <c:set var="annualWorkdays" value="${reportData.getOrDefault('Annual Workdays', 252)}" />
                                                <c:set var="totalWorkdays" value="${reportData.getOrDefault('Total Workdays', 0)}" />
                                                <c:choose>
                                                    <c:when test="${annualWorkdays > 0}">
                                                        <fmt:formatNumber value="${(totalWorkdays / annualWorkdays) * 100}" maxFractionDigits="1" />%
                                                    </c:when>
                                                    <c:otherwise>0%</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="data-item">
                                            <span class="data-label">Available Workdays:</span>
                                            <span class="data-value">${reportData.getOrDefault("Workdays", 21)}</span>
                                        </div>
                                        <div class="data-item">
                                            <span class="data-label">Leaves Taken:</span>
                                            <span class="data-value">${reportData.getOrDefault("Leaves Taken", 0)}</span>
                                        </div>
                                        <div class="data-item">
                                            <span class="data-label">Annual Workdays Remaining:</span>
                                            <span class="data-value">${reportData.getOrDefault("Annual Workdays", 252)}</span>
                                        </div>
                                        <div class="data-item highlight">
                                            <span class="data-label">Productivity Ratio:</span>
                                            <span class="data-value">
                                                <c:set var="monthlyWorkdays" value="${reportData.getOrDefault('Workdays', 21)}" />
                                                <c:choose>
                                                    <c:when test="${monthlyWorkdays > 0}">
                                                        <fmt:formatNumber value="${(monthlyWorkdays / 21) * 100}" maxFractionDigits="1" />%
                                                    </c:when>
                                                    <c:otherwise>0%</c:otherwise>
                                                </c:choose>
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
                                    <span class="data-value">${reportData.getOrDefault("Total Projects", 0)}</span>
                                </div>
                                <div class="data-item">
                                    <span class="data-label">Completed:</span>
                                    <span class="data-value">${reportData.getOrDefault("Completed Projects", 0)}</span>
                                </div>
                                <div class="data-item">
                                    <span class="data-label">In Progress:</span>
                                    <span class="data-value">${reportData.getOrDefault("In Progress Projects", 0)}</span>
                                </div>
                                <div class="data-item">
                                    <span class="data-label">On Hold:</span>
                                    <span class="data-value">${reportData.getOrDefault("On Hold Projects", 0)}</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <script>
                    // Prepare data for the chart
                    <c:choose>
                        <c:when test="${reportType eq 'yearly'}">
                    const workdays = ${reportData.getOrDefault("Total Workdays", 0)};
                    const leavesTaken = ${reportData.getOrDefault("Total Leaves", 0)};
                        </c:when>
                        <c:otherwise>
                    const workdays = ${reportData.getOrDefault("Workdays", 21)};
                    const leavesTaken = ${reportData.getOrDefault("Leaves Taken", 0)};
                        </c:otherwise>
                    </c:choose>
                    const completedProjects = ${reportData.getOrDefault("Completed Projects", 0)};
                    const inProgressProjects = ${reportData.getOrDefault("In Progress Projects", 0)};
                    const onHoldProjects = ${reportData.getOrDefault("On Hold Projects", 0)};

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
                                    data: [
                                        Math.max(0, workdays),
                                        Math.max(0, leavesTaken),
                                        Math.max(0, completedProjects),
                                        Math.max(0, inProgressProjects),
                                        Math.max(0, onHoldProjects)
                                    ],
                                    backgroundColor: [
                                        'rgba(0, 231, 255, 0.7)',
                                        'rgba(255, 71, 87, 0.7)',
                                        'rgba(46, 213, 115, 0.7)',
                                        'rgba(255, 165, 2, 0.7)',
                                        'rgba(162, 155, 254, 0.7)'
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
                                            const percentage = total > 0 ? Math.round((value / total) * 100) : 0;
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
                <a href="${pageContext.request.contextPath}/admin/allemployees.jsp" class="back-btn">Back to Employee List</a>
            </div>
        </div>
    </body>
</html>