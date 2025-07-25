# 🏢 ERP System - WayToCode

This is a full-featured **Enterprise Resource Planning (ERP) System** developed using Java Servlets, JSP, MySQL, and JDBC. It provides modules for employee management, leave tracking, project assignments, admin approvals, and report generation.

---

## 📽️ Live Demo

▶️ [Click here to watch the live demo](https://drive.google.com/drive/folders/18GT3-rb4-gPUo6YY4-fRQmQYnBX9W3Xq?usp=drive_link)

> This video walkthrough demonstrates user signup/login, leave requests, admin approval, project assignments, and real-time reporting.

---

## 🚀 Features

- 👤 **User Authentication**: Signup and Login with session management
- 📝 **Leave Management**: Application with auto summary updates
- 👨‍💼 **Admin Dashboard**: Centralized approval system and reporting
- 📊 **Reporting**: Monthly & yearly reports with visual graphs
- 🏗️ **Project Tracking**: Assignment and progress monitoring
- 🖼️ **User Profiles**: Picture upload and management
- 🔐 **Access Control**: Role-based permissions (Admin/User)

---

## 📂 Project Structure

```

WayToCodeERPSystem/
├── src/                          # Java Servlets, DAO, Bean files
├── web/                          # JSPs, CSS, JS, images
├── database/erp\_system.sql       # SQL database dump
├── nbproject/                    # NetBeans IDE configuration
└── README.md                     # Project documentation

````

---

## 🔧 Tech Stack

- **Frontend**: HTML5, CSS3, JSP
- **Backend**: Java Servlets, JDBC
- **Database**: MySQL 8.0+
- **Server**: Apache Tomcat 9+
- **Development**: NetBeans IDE 12+

---

## ⚙️ Setup Guide

1. **Clone the Repository**
   ```bash
   git clone https://github.com/vandan2931/ERP-System-WayToCode.git
````

2. **Database Setup**

   * Create a new database:

     ```sql
     CREATE DATABASE erp_system;
     ```
   * Import the schema:

     ```bash
     mysql -u root -p erp_system < database/erp_system.sql
     ```

3. **Configure Database Connection**

   * Update the credentials in:

     ```java
     // src/your/package/DBConnection.java
     String url = "jdbc:mysql://localhost:3306/erp_system";
     String user = "root";
     String pass = "";
     ```

4. **Run in NetBeans**

   * Open the project folder in NetBeans
   * Deploy to Tomcat server
   * Access via: `http://localhost:8080/WayToCodeERPSystem`

---

## 📘 Core Modules

| Module             | Description                                |
| ------------------ | ------------------------------------------ |
| **Authentication** | Secure login/logout for all users          |
| **Leave**          | Apply/view leave requests (Admin approval) |
| **Projects**       | Task assignment and progress tracking      |
| **Admin Console**  | User management and system configuration   |
| **Reporting**      | Generate PDF/Excel reports with analytics  |

---

## 👨‍💻 Developer Information

* **Name**: Vandan Shah
* **Location**: Ahmedabad, Gujarat, India
* **Role**: Full Stack Java Developer
* **GitHub**: [@vandan2931](https://github.com/vandan2931)

---

## 📜 License

This project is licensed for educational use. You may:

* Use for learning purposes
* Modify for personal projects
* Adapt for internal organizational use

> **Note:** Commercial use requires explicit permission from the developer.

---

## 🤝 Contributing

We welcome contributions! Here's how to get started:

1. Fork the repository
2. Create your feature branch

   ```bash
   git checkout -b feature/your-feature
   ```
3. Commit your changes

   ```bash
   git commit -m 'Add some feature'
   ```
4. Push the changes

   ```bash
   git push origin feature/your-feature
   ```
5. Open a Pull Request

*For major changes, please open an issue first to discuss the improvements.*

---

> 💡 *Built for academic, personal, and portfolio use to demonstrate a complete Java Full Stack ERP system with real-time leave and project management.*


