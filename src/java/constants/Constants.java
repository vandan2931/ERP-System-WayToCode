package constants;

public class Constants {

    // Database Configuration
    public static final String DB_URL = "jdbc:mysql://localhost:3306/erp_system";
    public static final String DB_USER = "root";
    public static final String DB_PASSWORD = "";
    public static final String DB_DRIVER = "com.mysql.jdbc.Driver";

    // Database Tables
    public static final String TABLE_EMPLOYEES = "employees";
    public static final String TABLE_LEAVE_REQUESTS = "leave_requests";
    public static final String TABLE_LEAVE_POLICY = "leave_policy";
    public static final String TABLE_PROJECTS = "projects";

    // Database Columns (Common)
    public static final String COL_ID = "id";
    public static final String COL_NAME = "name";
    public static final String COL_EMAIL = "email";
    public static final String COL_PASSWORD = "password";
    public static final String COL_STATUS = "status";
    public static final String COL_ROLE = "role";

    // Employee Table Columns
    public static final String COL_CONTACT = "contact";
    public static final String COL_DEPARTMENT = "department";
    public static final String COL_AGE = "age";
    public static final String COL_DOB = "dob";
    public static final String COL_CURRENT_SALARY = "current_salary";
    public static final String COL_PREVIOUS_SALARY = "previous_salary";
    public static final String COL_DATE_OF_JOINING = "date_of_joining";
    public static final String COL_EXPERIENCE = "experience";
    public static final String COL_PROFILE_IMAGE = "profile_image";

    // Leave Requests Table Columns
    public static final String COL_EMPLOYEE_ID = "employee_id";
    public static final String COL_LEAVE_TYPE = "leave_type";
    public static final String COL_START_DATE = "start_date";
    public static final String COL_END_DATE = "end_date";
    public static final String COL_REASON = "reason";
    public static final String COL_APPLIED_ON = "applied_on";

    // Leave Policy Table Columns
    public static final String COL_YEAR = "year";
    public static final String COL_MONTH = "month";
    public static final String COL_TOTAL_LEAVES = "total_leaves";
    public static final String COL_LEAVES_TAKEN = "leaves_taken";
    public static final String COL_LEAVES_REMAINING = "leaves_remaining";
    public static final String COL_ANNUAL_WORKDAYS = "annual_workdays";
    public static final String COL_MONTHLY_WORKDAYS = "monthly_workdays";

    // Projects Table Columns
    public static final String COL_TITLE = "title";
    public static final String COL_DESCRIPTION = "description";
    public static final String COL_PROGRESS_PERCENT = "progress_percent";
    public static final String COL_PROJECT_STATUS = "status";
    public static final String COL_PRIORITY = "priority";

    // Database Queries
    public static final String QUERY_GET_EMPLOYEE_BY_ID = "SELECT * FROM " + TABLE_EMPLOYEES + " WHERE " + COL_ID + " = ?";
    public static final String QUERY_GET_EMPLOYEE_BY_CREDENTIALS = "SELECT * FROM " + TABLE_EMPLOYEES + " WHERE " + COL_EMAIL + " = ? AND " + COL_PASSWORD + " = ?";
    public static final String QUERY_INSERT_EMPLOYEE = "INSERT INTO " + TABLE_EMPLOYEES + " (" + COL_NAME + ", " + COL_EMAIL + ", " + COL_CONTACT + ", " + COL_PASSWORD + ", " + COL_STATUS + ", " + COL_ROLE + ") VALUES (?, ?, ?, ?, ?, ?)";
    public static final String QUERY_UPDATE_EMPLOYEE = "UPDATE " + TABLE_EMPLOYEES + " SET " + COL_NAME + " = ?, " + COL_EMAIL + " = ?, " + COL_CONTACT + " = ?, " + COL_DEPARTMENT + " = ? WHERE " + COL_ID + " = ?";
    public static final String QUERY_GET_ALL_EMPLOYEES = "SELECT * FROM " + TABLE_EMPLOYEES;
    public static final String QUERY_GET_PENDING_EMPLOYEES = "SELECT * FROM " + TABLE_EMPLOYEES + " WHERE " + COL_STATUS + " = 'pending'";

    public static final String QUERY_INSERT_LEAVE_REQUEST = "INSERT INTO " + TABLE_LEAVE_REQUESTS + " (" + COL_EMPLOYEE_ID + ", " + COL_LEAVE_TYPE + ", " + COL_START_DATE + ", " + COL_END_DATE + ", " + COL_REASON + ", " + COL_STATUS + ", " + COL_APPLIED_ON + ") VALUES (?, ?, ?, ?, ?, 'pending', CURDATE())";
    public static final String QUERY_GET_LEAVE_REQUESTS_BY_EMPLOYEE = "SELECT * FROM " + TABLE_LEAVE_REQUESTS + " WHERE " + COL_EMPLOYEE_ID + " = ?";
    public static final String QUERY_GET_PENDING_LEAVE_REQUESTS = "SELECT * FROM " + TABLE_LEAVE_REQUESTS + " WHERE " + COL_STATUS + " = 'pending'";

    public static final String QUERY_INSERT_PROJECT = "INSERT INTO " + TABLE_PROJECTS + " (" + COL_EMPLOYEE_ID + ", " + COL_TITLE + ", " + COL_DESCRIPTION + ", " + COL_START_DATE + ", " + COL_END_DATE + ", " + COL_PROGRESS_PERCENT + ", " + COL_PROJECT_STATUS + ") VALUES (?, ?, ?, ?, ?, ?, ?)";
    public static final String QUERY_GET_PROJECTS_BY_EMPLOYEE = "SELECT * FROM " + TABLE_PROJECTS + " WHERE " + COL_EMPLOYEE_ID + " = ?";

    // Session Attributes
    public static final String SESSION_USER_ID = "userId";
    public static final String SESSION_USER_NAME = "userName";
    public static final String SESSION_USER_ROLE = "userRole";
    public static final String SESSION_ADMIN_ID = "adminId";
    public static final String SESSION_ADMIN_NAME = "adminName";

    // User Roles
    public static final String ROLE_EMPLOYEE = "employee";
    public static final String ROLE_ADMIN = "admin";

    // Status Values
    public static final String STATUS_PENDING = "pending";
    public static final String STATUS_APPROVED = "approved";
    public static final String STATUS_REJECTED = "rejected";
    public static final String STATUS_ACTIVE = "active";
    public static final String STATUS_PENDING_ADMIN = "pending_admin";

    // Leave Types
    public static final String LEAVE_TYPE_ANNUAL = "Annual Leave";
    public static final String LEAVE_TYPE_SICK = "Sick Leave";
    public static final String LEAVE_TYPE_CASUAL = "Casual Leave";
    public static final String LEAVE_TYPE_MATERNITY_PATERNITY = "Maternity/Paternity Leave";
    public static final String LEAVE_TYPE_BEREAVEMENT = "Bereavement Leave";

    // Leave Limits
    public static final int MAX_ANNUAL_LEAVES = 20;
    public static final int MONTHLY_WORKDAYS = 21;
    public static final int ANNUAL_WORKDAYS = 252; // 21 * 12
    public static final int DEFAULT_MONTHLY_WORKDAYS = 21;
    public static final int DEFAULT_ANNUAL_WORKDAYS = 252;

    // Password Requirements
    public static final String PASSWORD_REGEX = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\\S+$).{8,}$";
    public static final String PASSWORD_REQUIREMENTS = "Password must contain:\n"
            + "✓ At least 8 characters\n"
            + "✓ 1 uppercase letter\n"
            + "✓ 1 lowercase letter\n"
            + "✓ 1 number\n"
            + "✓ 1 special character (!@#$%^&* etc.)";

    // JSP Paths
    public static final String JSP_LOGIN = "login.jsp";
    public static final String JSP_ADMIN_LOGIN = "adminlogin.jsp";
    public static final String JSP_DASHBOARD = "dashboard.jsp";
    public static final String JSP_ADMIN_DASHBOARD = "admin/admindashboard.jsp";
    public static final String JSP_PERSONAL_DATA = "personaldata.jsp";
    public static final String JSP_LEAVE_FORM = "leaveform.jsp";
    public static final String JSP_APPROVE_USERS = "admin/approveusers.jsp";
    public static final String JSP_LEAVE_REQUESTS = "admin/leaverequests.jsp";
    public static final String JSP_MONTHLY_REPORT = "monthlyyearlyreport.jsp";
    public static final String JSP_PROJECT = "Project.jsp";
    public static final String JSP_PROJECT_REPORT = "projectreport.jsp";
    public static final String JSP_VIEW_REPORT = "/admin/viewReport.jsp";
    public static final String JSP_ALL_EMPLOYEES = "allemployees.jsp";

    // Servlet Paths
    public static final String SERVLET_LOGIN = "LoginServlet";
    public static final String SERVLET_LOGOUT = "LogoutServlet";
    public static final String SERVLET_SIGNUP = "SignupServlet";
    public static final String SERVLET_ADMIN_SIGNUP = "AdminSignupServlet";
    public static final String SERVLET_ADMIN_LOGIN = "AdminLoginServlet";
    public static final String SERVLET_ADMIN_APPROVAL = "AdminApprovalServlet";
    public static final String SERVLET_LEAVE_FORM = "LeaveFormServlet";
    public static final String SERVLET_LEAVE_APPROVAL = "LeaveApprovalServlet";
    public static final String SERVLET_PERSONAL_DATA = "PersonalDataServlet";
    public static final String SERVLET_MONTHLY_REPORT = "MonthlyReportServlet";
    public static final String SERVLET_PROJECT = "ProjectServlet";
    public static final String SERVLET_ADMIN_REPORT = "AdminReportServlet";

    public static final String MSG_CONTENT = "messageContent";  // For storing the actual message text
    public static final String MSG_TYPE = "messageType";       // For storing message type (success/error/info)

    // Success Messages
    public static final String MSG_LOGIN_SUCCESS = "Login successful";
    public static final String MSG_REGISTRATION_SUCCESS = "Registration successful, Login After Admin Approval";
    public static final String MSG_ADMIN_REQUEST_SUBMITTED = "Admin request submitted";
    public static final String MSG_LEAVE_SUBMITTED = "Leave application submitted successfully";
    public static final String MSG_PROFILE_UPDATED = "Profile updated successfully!";
    public static final String MSG_PROJECT_ADDED = "Project added successfully!";
    public static final String MSG_PROJECT_UPDATED = "Project updated successfully!";
    public static final String MSG_PROJECT_DELETED = "Project deleted successfully!";
    public static final String MSG_USER_APPROVED = "User approved successfully";
    public static final String MSG_USER_REJECTED = "User rejected and deleted successfully";

    // Error Messages
    public static final String ERR_INVALID_CREDENTIALS = "Invalid email or password";
    public static final String ERR_PASSWORD_MISMATCH = "Passwords do not match";
    public static final String ERR_EMAIL_EXISTS = "Email already exists";
    public static final String ERR_REGISTRATION_FAILED = "Registration failed";
    public static final String ERR_SERVER_ERROR = "Server error";
    public static final String ERR_ACCOUNT_PENDING = "Account pending approval";
    public static final String ERR_LOGIN_ERROR = "Login error";
    public static final String ERR_NO_RECORDS_UPDATED = "No records were updated. User ID not found.";
    public static final String ERR_DATABASE_ERROR = "Database error";
    public static final String ERR_INVALID_NUMBER_FORMAT = "Invalid number format for field";
    public static final String ERR_INVALID_DATE_FORMAT = "Invalid date format (use yyyy-MM-dd)";
    public static final String ERR_UNEXPECTED_ERROR = "An unexpected error occurred";
    public static final String ERR_REQUIRED_FIELDS_EMPTY = "All required fields must be filled";
    public static final String ERR_INVALID_CONTACT = "Contact number must be exactly 10 digits";
    public static final String ERR_INVALID_DEPARTMENT = "Invalid department selected";
    public static final String ERR_NO_CHANGES_MADE = "No changes were made to the profile.";
    public static final String ERR_INVALID_PROJECT_ID = "Invalid project ID";
    public static final String ERR_PROJECT_UPDATE = "Error updating project";
    public static final String ERR_PROJECT_ADD = "Error adding project";
    public static final String ERR_PROJECT_DELETE = "Error deleting project";
    public static final String ERR_LOADING_PROFILE = "Error loading profile";
    public static final String ERR_LEAVE_HISTORY = "Unable to load leave history";
    public static final String ERR_NOT_ENOUGH_LEAVES = "Not enough leaves available";
    public static final String ERR_OVERLAPPING_LEAVE = "Leave dates overlap with existing approved leave";
    public static final String ERR_PAST_DATE_NOT_ALLOWED = "Past dates are not allowed for leave requests";
    public static final String ERR_INVALID_DATE_RANGE = "End date must be after start date";
    public static final String ERR_INVALID_REQUEST = "Invalid request";
    public static final String ERR_INVALID_ACTION = "Invalid action";
    public static final String ERR_REPORT_ERROR = "report_error";
    
    // Date Formats
    public static final String DATE_FORMAT_DISPLAY = "dd-MM-yyyy";
    public static final String DATE_FORMAT_HTML = "yyyy-MM-dd";
    public static final String DATE_FORMAT_DB = "yyyy-MM-dd";

    // Message Types
    public static final String MSG_TYPE_SUCCESS = "success";
    public static final String MSG_TYPE_ERROR = "error";
    public static final String MSG_TYPE_INFO = "info";
    public static final String MSG_TYPE_WARNING = "warning";

    // Request Parameters
    public static final String PARAM_ACTION = "action";
    public static final String PARAM_EMPLOYEE_ID = "employeeId";
    public static final String PARAM_LEAVE_REQUEST_ID = "requestId";
    public static final String PARAM_PROJECT_ID = "projectId";
    public static final String PARAM_MONTH = "month";
    public static final String PARAM_YEAR = "year";
    public static final String PARAM_REPORT_TYPE = "reportType";
    public static final String PARAM_ID = "id";
    public static final String PARAM_TYPE = "type";
    public static final String PARAM_START = "start";
    public static final String PARAM_END = "end";
    public static final String PARAM_REASON = "reason";

    // Actions
    public static final String ACTION_APPROVE = "approve";
    public static final String ACTION_REJECT = "reject";
    public static final String ACTION_EDIT = "edit";
    public static final String ACTION_DELETE = "delete";
    public static final String ACTION_LIST = "list";
    public static final String ACTION_GENERATE_REPORT = "generateReport";

    // Report Types
    public static final String REPORT_TYPE_MONTHLY = "monthly";
    public static final String REPORT_TYPE_YEARLY = "yearly";
    public static final String REPORT_TYPE_STATUS = "status";
    public static final String REPORT_TYPE_PRIORITY = "priority";
    public static final String REPORT_TYPE_TIMELINE = "timeline";

    // Departments
    public static final String[] DEPARTMENTS = {
        "Web Development", "Frontend", "Backend", "Full Stack", "UI/UX Design",
        "Mobile App Development", "QA/Testing", "DevOps", "IT Support",
        "Project Management", "Business Analysis", "Product Management",
        "HR", "Sales", "Digital Marketing", "Content Writing", "Finance"
    };
    public static String COL_CONFIRM ="confirm";
}