# School Management System Database Schema

A comprehensive MySQL database schema designed for easy integration into web-based school management systems.

## Features

### Core Functionality
- **User Management**: Multi-role authentication (Admin, Teacher, Student, Parent, Staff)
- **Academic Structure**: Years, Departments, Classes, Subjects
- **People Management**: Students, Teachers, Parents with relationships
- **Attendance Tracking**: Daily attendance with multiple status options
- **Examination System**: Flexible exam types, schedules, and grading
- **Timetable Management**: Class schedules with time slots
- **Fee Management**: Flexible fee structure and payment tracking
- **Library System**: Book management and issue tracking
- **Communication**: Announcements and messaging system
- **System Configuration**: Configurable settings

### Database Design Features
- **Normalized Structure**: Proper 3NF normalization
- **Referential Integrity**: Foreign key constraints
- **Performance Optimized**: Strategic indexes for fast queries
- **Web-Ready**: Designed for web application integration
- **Scalable**: Supports multiple academic years and large datasets
- **Flexible**: Extensible design for future enhancements

## Quick Setup

### 1. Database Creation
```bash
# Login to MySQL
mysql -u root -p

# Run the schema file
source school_management_schema.sql
```

### 2. Verify Installation
```sql
USE school_management;
SHOW TABLES;
SELECT * FROM system_settings;
```

## Database Structure

### Core Tables

#### `users`
Central authentication table for all system users.
- **Primary Key**: `user_id`
- **Unique Fields**: `username`, `email`
- **Roles**: admin, teacher, student, parent, staff
- **Features**: Password hashing, role-based access, activity tracking

#### `academic_years`
Manages school academic years.
- **Primary Key**: `year_id`
- **Features**: Start/end dates, current year marking
- **Example**: "2024-2025" from April 1, 2024 to March 31, 2025

#### `departments`
School departments/faculties.
- **Primary Key**: `department_id`
- **Features**: Department codes, head teacher assignment
- **Examples**: Mathematics, Science, English, etc.

### Academic Structure

#### `classes`
Student classes/grades.
- **Primary Key**: `class_id`
- **Relationships**: Links to departments, academic years, class teachers
- **Features**: Grade levels, student capacity limits

#### `subjects`
Academic subjects.
- **Primary Key**: `subject_id`
- **Features**: Subject codes, credit systems, department mapping

#### `class_subjects`
Maps subjects to classes with teacher assignments.
- **Primary Key**: `class_subject_id`
- **Features**: Periods per week, teacher assignments

### People Management

#### `teachers`
Teacher profiles and employment details.
- **Primary Key**: `teacher_id`
- **Links to**: `users` table for authentication
- **Features**: Employee IDs, qualifications, salary, hire dates

#### `students`
Student profiles and academic information.
- **Primary Key**: `student_id`
- **Links to**: `users` table, `classes` table
- **Features**: Admission numbers, emergency contacts, medical info

#### `parents`
Parent/guardian information.
- **Primary Key**: `parent_id`
- **Features**: Relationship types, contact information

#### `student_parents`
Links students to their parents/guardians.
- **Features**: Primary contact designation

### Operational Tables

#### `attendance`
Daily attendance tracking.
- **Statuses**: Present, Absent, Late, Excused
- **Features**: Date-wise tracking, remarks, teacher marking

#### `examinations` & `exam_schedules`
Examination management system.
- **Features**: Multiple exam types, scheduling, room assignments

#### `grades`
Student examination results.
- **Features**: Marks, letter grades, grade points, remarks

#### `timetable`
Class schedule management.
- **Features**: Day-wise scheduling, room assignments, time slots

#### `fee_structure` & `fee_payments`
Fee management system.
- **Features**: Category-based fees, payment tracking, receipt generation

#### `books` & `book_issues`
Library management.
- **Features**: ISBN tracking, availability, issue/return, fines

## Useful Views

### `student_details`
Complete student information with class and parent details.
```sql
SELECT * FROM student_details WHERE class_name = 'Grade 10A';
```

### `teacher_details`
Teacher information with department details.
```sql
SELECT * FROM teacher_details WHERE department_name = 'Mathematics';
```

### `class_timetable`
Class schedule view.
```sql
SELECT * FROM class_timetable WHERE class_name = 'Grade 10A' AND day_of_week = 'Monday';
```

### `student_fee_status`
Fee payment status for students.
```sql
SELECT * FROM student_fee_status WHERE balance_amount > 0;
```

## Web Integration Guide

### 1. Connection Setup
```php
// PHP Example
$host = 'localhost';
$dbname = 'school_management';
$username = 'your_username';
$password = 'your_password';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch(PDOException $e) {
    die("Connection failed: " . $e->getMessage());
}
```

### 2. User Authentication
```php
// Login verification
function authenticateUser($username, $password) {
    global $pdo;
    $stmt = $pdo->prepare("SELECT user_id, password_hash, role FROM users WHERE username = ? AND is_active = 1");
    $stmt->execute([$username]);
    $user = $stmt->fetch();
    
    if ($user && password_verify($password, $user['password_hash'])) {
        return $user;
    }
    return false;
}
```

### 3. Common Queries

#### Get Student List by Class
```sql
SELECT s.student_id, s.admission_number, s.first_name, s.last_name, s.phone
FROM students s
JOIN classes c ON s.class_id = c.class_id
WHERE c.class_name = 'Grade 10A' AND s.is_active = 1
ORDER BY s.first_name, s.last_name;
```

#### Get Teacher's Classes
```sql
SELECT DISTINCT c.class_name, c.grade_level, s.subject_name
FROM class_subjects cs
JOIN classes c ON cs.class_id = c.class_id
JOIN subjects s ON cs.subject_id = s.subject_id
JOIN teachers t ON cs.teacher_id = t.teacher_id
WHERE t.employee_id = 'EMP001' AND cs.is_active = 1;
```

#### Get Student Attendance Summary
```sql
SELECT 
    s.first_name, s.last_name,
    COUNT(*) as total_days,
    SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) as present_days,
    ROUND((SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) as attendance_percentage
FROM students s
JOIN attendance a ON s.student_id = a.student_id
WHERE a.date BETWEEN '2024-04-01' AND '2024-04-30'
GROUP BY s.student_id;
```

### 4. API Endpoints Examples

#### REST API Structure
```
GET    /api/students              - List all students
GET    /api/students/{id}         - Get student details
POST   /api/students              - Create new student
PUT    /api/students/{id}         - Update student
DELETE /api/students/{id}         - Deactivate student

GET    /api/classes/{id}/students - Get students in a class
POST   /api/attendance            - Mark attendance
GET    /api/grades/{student_id}   - Get student grades
```

### 5. Security Considerations

#### Password Hashing
```php
// When creating/updating user passwords
$password_hash = password_hash($plain_password, PASSWORD_DEFAULT);
```

#### Role-Based Access Control
```php
function checkPermission($user_role, $required_role) {
    $role_hierarchy = ['student' => 1, 'parent' => 2, 'teacher' => 3, 'staff' => 4, 'admin' => 5];
    return $role_hierarchy[$user_role] >= $role_hierarchy[$required_role];
}
```

#### Input Validation
```php
// Always use prepared statements
$stmt = $pdo->prepare("SELECT * FROM students WHERE student_id = ?");
$stmt->execute([$student_id]);
```

## Sample Data Insertion

### Create Admin User
```sql
INSERT INTO users (username, email, password_hash, role) 
VALUES ('admin', 'admin@school.edu', '$2y$10$example_hash', 'admin');
```

### Create Department
```sql
INSERT INTO departments (department_name, department_code, description) 
VALUES ('Mathematics', 'MATH', 'Mathematics Department');
```

### Create Class
```sql
INSERT INTO classes (class_name, class_code, grade_level, academic_year_id) 
VALUES ('Grade 10A', '10A', 10, 1);
```

### Create Subject
```sql
INSERT INTO subjects (subject_name, subject_code, department_id) 
VALUES ('Algebra', 'ALG', 1);
```

## Performance Optimization

### Indexes
The schema includes strategic indexes for:
- User authentication (username, email)
- Student searches (admission number, name)
- Attendance queries (student_id, date)
- Grade lookups (student_id, marks)
- Fee tracking (student_id, payment_date)

### Query Optimization Tips
1. Use the provided views for complex joins
2. Add date range filters for time-based queries
3. Use LIMIT for paginated results
4. Consider caching for frequently accessed data

## Backup and Maintenance

### Regular Backups
```bash
# Daily backup
mysqldump -u root -p school_management > backup_$(date +%Y%m%d).sql

# Restore from backup
mysql -u root -p school_management < backup_20241201.sql
```

### Maintenance Tasks
1. **Archive old data**: Move old academic year data to archive tables
2. **Update statistics**: Run `ANALYZE TABLE` on large tables
3. **Monitor performance**: Check slow query log
4. **Clean up**: Remove inactive users and old temporary data

## Extension Ideas

### Additional Features You Can Add
1. **Online Assignments**: Add assignment submission system
2. **Events Calendar**: School events and holidays
3. **Transportation**: Bus routes and student transport
4. **Hostel Management**: Room allocation and mess management
5. **Staff Payroll**: Salary processing and tax calculations
6. **Alumni Management**: Graduate tracking system
7. **Inventory Management**: School assets and supplies
8. **Medical Records**: Student health tracking

### Schema Extensions
```sql
-- Example: Adding assignments table
CREATE TABLE assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    due_date DATE NOT NULL,
    max_marks DECIMAL(5,2),
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (created_by) REFERENCES teachers(teacher_id)
);
```

## Support

For questions or issues:
1. Check the table structure using `DESCRIBE table_name`
2. Review the foreign key relationships
3. Use the provided views for complex queries
4. Test with sample data before production use

This schema provides a solid foundation for a comprehensive school management system that can be easily integrated into web applications using any modern web framework.