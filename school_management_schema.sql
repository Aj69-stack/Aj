-- School Management System Database Schema
-- MySQL Database for School Management System
-- Created for easy web integration

-- Create database
CREATE DATABASE IF NOT EXISTS school_management;
USE school_management;

-- Set charset and collation
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ================================
-- CORE SYSTEM TABLES
-- ================================

-- Users table for authentication and authorization
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'teacher', 'student', 'parent', 'staff') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role),
    INDEX idx_active (is_active)
);

-- Academic years
CREATE TABLE academic_years (
    year_id INT AUTO_INCREMENT PRIMARY KEY,
    year_name VARCHAR(20) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_current (is_current),
    INDEX idx_dates (start_date, end_date)
);

-- Departments
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    department_code VARCHAR(10) NOT NULL UNIQUE,
    head_teacher_id INT NULL,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_code (department_code),
    INDEX idx_active (is_active)
);

-- ================================
-- ACADEMIC STRUCTURE
-- ================================

-- Classes/Grades
CREATE TABLE classes (
    class_id INT AUTO_INCREMENT PRIMARY KEY,
    class_name VARCHAR(50) NOT NULL,
    class_code VARCHAR(10) NOT NULL,
    grade_level INT NOT NULL,
    department_id INT,
    class_teacher_id INT NULL,
    academic_year_id INT NOT NULL,
    max_students INT DEFAULT 30,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(year_id),
    
    INDEX idx_grade (grade_level),
    INDEX idx_active (is_active),
    INDEX idx_year (academic_year_id),
    UNIQUE KEY uk_class_year (class_code, academic_year_id)
);

-- Subjects
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT PRIMARY KEY,
    subject_name VARCHAR(100) NOT NULL,
    subject_code VARCHAR(10) NOT NULL UNIQUE,
    department_id INT,
    credits INT DEFAULT 1,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    
    INDEX idx_code (subject_code),
    INDEX idx_active (is_active)
);

-- Class-Subject mapping
CREATE TABLE class_subjects (
    class_subject_id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NULL,
    periods_per_week INT DEFAULT 1,
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (class_id) REFERENCES classes(class_id) ON DELETE CASCADE,
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    
    UNIQUE KEY uk_class_subject (class_id, subject_id),
    INDEX idx_teacher (teacher_id),
    INDEX idx_active (is_active)
);

-- ================================
-- PEOPLE MANAGEMENT
-- ================================

-- Teachers
CREATE TABLE teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    employee_id VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE,
    gender ENUM('Male', 'Female', 'Other'),
    phone VARCHAR(20),
    address TEXT,
    qualification VARCHAR(100),
    specialization VARCHAR(100),
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    department_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    
    INDEX idx_employee_id (employee_id),
    INDEX idx_name (first_name, last_name),
    INDEX idx_active (is_active)
);

-- Students
CREATE TABLE students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    admission_number VARCHAR(20) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender ENUM('Male', 'Female', 'Other'),
    phone VARCHAR(20),
    address TEXT,
    emergency_contact VARCHAR(20),
    class_id INT,
    admission_date DATE NOT NULL,
    blood_group VARCHAR(5),
    medical_conditions TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    
    INDEX idx_admission (admission_number),
    INDEX idx_name (first_name, last_name),
    INDEX idx_class (class_id),
    INDEX idx_active (is_active)
);

-- Parents/Guardians
CREATE TABLE parents (
    parent_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    relationship ENUM('Father', 'Mother', 'Guardian', 'Other') NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    occupation VARCHAR(100),
    address TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    
    INDEX idx_name (first_name, last_name),
    INDEX idx_active (is_active)
);

-- Student-Parent relationship
CREATE TABLE student_parents (
    student_parent_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    parent_id INT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES parents(parent_id) ON DELETE CASCADE,
    
    UNIQUE KEY uk_student_parent (student_id, parent_id),
    INDEX idx_primary (is_primary)
);

-- ================================
-- ATTENDANCE MANAGEMENT
-- ================================

-- Attendance records
CREATE TABLE attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    date DATE NOT NULL,
    status ENUM('Present', 'Absent', 'Late', 'Excused') NOT NULL,
    remarks TEXT,
    marked_by INT,
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (marked_by) REFERENCES teachers(teacher_id),
    
    UNIQUE KEY uk_student_date (student_id, date),
    INDEX idx_date (date),
    INDEX idx_status (status),
    INDEX idx_class_date (class_id, date)
);

-- ================================
-- EXAMINATION SYSTEM
-- ================================

-- Examination types
CREATE TABLE exam_types (
    exam_type_id INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    weightage DECIMAL(5,2) DEFAULT 100.00,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_active (is_active)
);

-- Examinations
CREATE TABLE examinations (
    exam_id INT AUTO_INCREMENT PRIMARY KEY,
    exam_name VARCHAR(100) NOT NULL,
    exam_type_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (exam_type_id) REFERENCES exam_types(exam_type_id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(year_id),
    
    INDEX idx_dates (start_date, end_date),
    INDEX idx_active (is_active),
    INDEX idx_year (academic_year_id)
);

-- Exam schedules
CREATE TABLE exam_schedules (
    schedule_id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    exam_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    room VARCHAR(50),
    max_marks DECIMAL(5,2) DEFAULT 100.00,
    
    FOREIGN KEY (exam_id) REFERENCES examinations(exam_id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    
    INDEX idx_exam_date (exam_date),
    INDEX idx_class_subject (class_id, subject_id),
    UNIQUE KEY uk_exam_class_subject (exam_id, class_id, subject_id)
);

-- Student grades/marks
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    schedule_id INT NOT NULL,
    marks_obtained DECIMAL(5,2),
    grade_letter VARCHAR(2),
    grade_points DECIMAL(3,2),
    remarks TEXT,
    entered_by INT,
    entered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (schedule_id) REFERENCES exam_schedules(schedule_id),
    FOREIGN KEY (entered_by) REFERENCES teachers(teacher_id),
    
    UNIQUE KEY uk_student_schedule (student_id, schedule_id),
    INDEX idx_grade (grade_letter),
    INDEX idx_points (grade_points)
);

-- ================================
-- TIMETABLE MANAGEMENT
-- ================================

-- Time slots
CREATE TABLE time_slots (
    slot_id INT AUTO_INCREMENT PRIMARY KEY,
    slot_name VARCHAR(20) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_times (start_time, end_time),
    INDEX idx_active (is_active)
);

-- Timetable
CREATE TABLE timetable (
    timetable_id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    day_of_week ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday') NOT NULL,
    slot_id INT NOT NULL,
    room VARCHAR(50),
    academic_year_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id),
    FOREIGN KEY (slot_id) REFERENCES time_slots(slot_id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(year_id),
    
    INDEX idx_class_day (class_id, day_of_week),
    INDEX idx_teacher_day (teacher_id, day_of_week),
    INDEX idx_active (is_active),
    UNIQUE KEY uk_class_day_slot (class_id, day_of_week, slot_id, academic_year_id)
);

-- ================================
-- FEES MANAGEMENT
-- ================================

-- Fee categories
CREATE TABLE fee_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    
    INDEX idx_active (is_active)
);

-- Fee structure
CREATE TABLE fee_structure (
    fee_id INT AUTO_INCREMENT PRIMARY KEY,
    class_id INT NOT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    academic_year_id INT NOT NULL,
    due_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    FOREIGN KEY (category_id) REFERENCES fee_categories(category_id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(year_id),
    
    INDEX idx_class_year (class_id, academic_year_id),
    INDEX idx_active (is_active),
    UNIQUE KEY uk_class_category_year (class_id, category_id, academic_year_id)
);

-- Fee payments
CREATE TABLE fee_payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    fee_id INT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    payment_method ENUM('Cash', 'Card', 'Bank Transfer', 'Online', 'Cheque') NOT NULL,
    transaction_id VARCHAR(100),
    receipt_number VARCHAR(50) UNIQUE,
    remarks TEXT,
    received_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (fee_id) REFERENCES fee_structure(fee_id),
    FOREIGN KEY (received_by) REFERENCES users(user_id),
    
    INDEX idx_student (student_id),
    INDEX idx_date (payment_date),
    INDEX idx_receipt (receipt_number)
);

-- ================================
-- LIBRARY MANAGEMENT
-- ================================

-- Books
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100),
    publication_year YEAR,
    category VARCHAR(50),
    total_copies INT DEFAULT 1,
    available_copies INT DEFAULT 1,
    price DECIMAL(8,2),
    location VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_isbn (isbn),
    INDEX idx_title (title),
    INDEX idx_author (author),
    INDEX idx_category (category),
    INDEX idx_active (is_active)
);

-- Book issues
CREATE TABLE book_issues (
    issue_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    student_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    fine_amount DECIMAL(6,2) DEFAULT 0.00,
    status ENUM('Issued', 'Returned', 'Lost', 'Damaged') DEFAULT 'Issued',
    issued_by INT,
    returned_by INT,
    remarks TEXT,
    
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (issued_by) REFERENCES users(user_id),
    FOREIGN KEY (returned_by) REFERENCES users(user_id),
    
    INDEX idx_student (student_id),
    INDEX idx_status (status),
    INDEX idx_dates (issue_date, due_date),
    INDEX idx_return (return_date)
);

-- ================================
-- COMMUNICATION SYSTEM
-- ================================

-- Announcements
CREATE TABLE announcements (
    announcement_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    target_audience ENUM('All', 'Students', 'Teachers', 'Parents', 'Staff') NOT NULL,
    priority ENUM('Low', 'Medium', 'High', 'Urgent') DEFAULT 'Medium',
    created_by INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (created_by) REFERENCES users(user_id),
    
    INDEX idx_audience (target_audience),
    INDEX idx_priority (priority),
    INDEX idx_active (is_active),
    INDEX idx_created (created_at)
);

-- Messages
CREATE TABLE messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    recipient_id INT NOT NULL,
    subject VARCHAR(200),
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    
    FOREIGN KEY (sender_id) REFERENCES users(user_id),
    FOREIGN KEY (recipient_id) REFERENCES users(user_id),
    
    INDEX idx_sender (sender_id),
    INDEX idx_recipient (recipient_id),
    INDEX idx_read (is_read),
    INDEX idx_sent (sent_at)
);

-- ================================
-- SYSTEM CONFIGURATION
-- ================================

-- System settings
CREATE TABLE system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(50) NOT NULL UNIQUE,
    setting_value TEXT,
    description TEXT,
    updated_by INT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (updated_by) REFERENCES users(user_id),
    
    INDEX idx_key (setting_key)
);

-- ================================
-- TRIGGERS AND CONSTRAINTS
-- ================================

-- Update foreign key constraints
ALTER TABLE departments ADD FOREIGN KEY (head_teacher_id) REFERENCES teachers(teacher_id);
ALTER TABLE classes ADD FOREIGN KEY (class_teacher_id) REFERENCES teachers(teacher_id);
ALTER TABLE class_subjects ADD FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id);

-- ================================
-- INITIAL DATA SETUP
-- ================================

-- Insert default academic year
INSERT INTO academic_years (year_name, start_date, end_date, is_current) 
VALUES ('2024-2025', '2024-04-01', '2025-03-31', TRUE);

-- Insert default exam types
INSERT INTO exam_types (type_name, description, weightage) VALUES
('Unit Test', 'Monthly unit tests', 20.00),
('Mid Term', 'Mid-term examinations', 30.00),
('Final Exam', 'Final examinations', 50.00);

-- Insert default fee categories
INSERT INTO fee_categories (category_name, description) VALUES
('Tuition Fee', 'Monthly tuition fees'),
('Library Fee', 'Library maintenance fee'),
('Laboratory Fee', 'Laboratory usage fee'),
('Sports Fee', 'Sports and activities fee'),
('Transport Fee', 'School transport fee');

-- Insert default time slots
INSERT INTO time_slots (slot_name, start_time, end_time) VALUES
('Period 1', '09:00:00', '09:45:00'),
('Period 2', '09:45:00', '10:30:00'),
('Break', '10:30:00', '10:45:00'),
('Period 3', '10:45:00', '11:30:00'),
('Period 4', '11:30:00', '12:15:00'),
('Lunch', '12:15:00', '13:00:00'),
('Period 5', '13:00:00', '13:45:00'),
('Period 6', '13:45:00', '14:30:00');

-- Insert default system settings
INSERT INTO system_settings (setting_key, setting_value, description) VALUES
('school_name', 'Demo School', 'Name of the school'),
('school_address', '123 Education Street, Learning City', 'School address'),
('school_phone', '+1-234-567-8900', 'School contact number'),
('school_email', 'info@demoschool.edu', 'School email address'),
('academic_year_start_month', '4', 'Month when academic year starts (1-12)'),
('default_class_size', '30', 'Default maximum students per class'),
('library_fine_per_day', '1.00', 'Library fine amount per day'),
('attendance_required_percentage', '75', 'Minimum attendance percentage required');

-- Enable foreign key checks
SET FOREIGN_KEY_CHECKS = 1;

-- ================================
-- VIEWS FOR COMMON QUERIES
-- ================================

-- Student details with class and parent information
CREATE VIEW student_details AS
SELECT 
    s.student_id,
    s.admission_number,
    s.first_name,
    s.last_name,
    s.date_of_birth,
    s.gender,
    s.phone,
    s.address,
    c.class_name,
    c.grade_level,
    u.email,
    u.is_active,
    p.first_name as parent_first_name,
    p.last_name as parent_last_name,
    p.phone as parent_phone,
    p.relationship
FROM students s
LEFT JOIN classes c ON s.class_id = c.class_id
LEFT JOIN users u ON s.user_id = u.user_id
LEFT JOIN student_parents sp ON s.student_id = sp.student_id AND sp.is_primary = TRUE
LEFT JOIN parents p ON sp.parent_id = p.parent_id;

-- Teacher details with department
CREATE VIEW teacher_details AS
SELECT 
    t.teacher_id,
    t.employee_id,
    t.first_name,
    t.last_name,
    t.qualification,
    t.specialization,
    t.hire_date,
    d.department_name,
    u.email,
    u.is_active
FROM teachers t
LEFT JOIN departments d ON t.department_id = d.department_id
LEFT JOIN users u ON t.user_id = u.user_id;

-- Class timetable view
CREATE VIEW class_timetable AS
SELECT 
    tt.timetable_id,
    c.class_name,
    s.subject_name,
    CONCAT(t.first_name, ' ', t.last_name) as teacher_name,
    tt.day_of_week,
    ts.slot_name,
    ts.start_time,
    ts.end_time,
    tt.room,
    ay.year_name
FROM timetable tt
JOIN classes c ON tt.class_id = c.class_id
JOIN subjects s ON tt.subject_id = s.subject_id
JOIN teachers t ON tt.teacher_id = t.teacher_id
JOIN time_slots ts ON tt.slot_id = ts.slot_id
JOIN academic_years ay ON tt.academic_year_id = ay.year_id
WHERE tt.is_active = TRUE;

-- Student fee status
CREATE VIEW student_fee_status AS
SELECT 
    s.student_id,
    s.admission_number,
    CONCAT(s.first_name, ' ', s.last_name) as student_name,
    c.class_name,
    fc.category_name,
    fs.amount as fee_amount,
    COALESCE(SUM(fp.amount_paid), 0) as paid_amount,
    (fs.amount - COALESCE(SUM(fp.amount_paid), 0)) as balance_amount,
    fs.due_date,
    ay.year_name
FROM students s
JOIN classes c ON s.class_id = c.class_id
JOIN fee_structure fs ON c.class_id = fs.class_id
JOIN fee_categories fc ON fs.category_id = fc.category_id
JOIN academic_years ay ON fs.academic_year_id = ay.year_id
LEFT JOIN fee_payments fp ON s.student_id = fp.student_id AND fs.fee_id = fp.fee_id
WHERE s.is_active = TRUE AND fs.is_active = TRUE
GROUP BY s.student_id, fs.fee_id;

-- ================================
-- INDEXES FOR PERFORMANCE
-- ================================

-- Additional performance indexes
CREATE INDEX idx_students_class_active ON students(class_id, is_active);
CREATE INDEX idx_attendance_student_date ON attendance(student_id, date DESC);
CREATE INDEX idx_grades_student_marks ON grades(student_id, marks_obtained DESC);
CREATE INDEX idx_fee_payments_student_date ON fee_payments(student_id, payment_date DESC);
CREATE INDEX idx_book_issues_student_status ON book_issues(student_id, status);
CREATE INDEX idx_messages_recipient_read ON messages(recipient_id, is_read);

-- ================================
-- COMPLETION MESSAGE
-- ================================

SELECT 'School Management System Database Schema Created Successfully!' as Status;