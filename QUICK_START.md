# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- MySQL 5.7+ or MariaDB 10.2+
- Basic knowledge of SQL and web development

### Option 1: Automated Setup (Recommended)
```bash
# Make the setup script executable
chmod +x setup_database.sh

# Run the setup script
./setup_database.sh
```

The script will:
1. Check MySQL installation
2. Create the database
3. Import the schema
4. Optionally create an admin user
5. Verify the installation

### Option 2: Manual Setup
```bash
# Login to MySQL
mysql -u root -p

# Create database and import schema
CREATE DATABASE school_management;
USE school_management;
source school_management_schema.sql;
```

## 📋 What's Included

### Database Tables (25 tables)
- **Users & Authentication**: `users`
- **Academic Structure**: `academic_years`, `departments`, `classes`, `subjects`
- **People**: `teachers`, `students`, `parents`, `student_parents`
- **Operations**: `attendance`, `examinations`, `grades`, `timetable`
- **Finance**: `fee_structure`, `fee_payments`, `fee_categories`
- **Library**: `books`, `book_issues`
- **Communication**: `announcements`, `messages`
- **System**: `system_settings`, `time_slots`

### Pre-built Views
- `student_details` - Complete student information
- `teacher_details` - Teacher information with departments
- `class_timetable` - Class schedules
- `student_fee_status` - Fee payment status

### Sample Data
- Default academic year (2024-2025)
- Exam types (Unit Test, Mid Term, Final Exam)
- Fee categories (Tuition, Library, Laboratory, Sports, Transport)
- Time slots (8 periods + breaks)
- System settings

## 🔧 Immediate Usage

### 1. Create Your First Admin User
```sql
INSERT INTO users (username, email, password_hash, role) 
VALUES ('admin', 'admin@yourschool.edu', SHA2('your_password', 256), 'admin');
```

### 2. Add a Department
```sql
INSERT INTO departments (department_name, department_code, description) 
VALUES ('Mathematics', 'MATH', 'Mathematics Department');
```

### 3. Create a Class
```sql
INSERT INTO classes (class_name, class_code, grade_level, academic_year_id) 
VALUES ('Grade 10A', '10A', 10, 1);
```

### 4. Add a Subject
```sql
INSERT INTO subjects (subject_name, subject_code, department_id) 
VALUES ('Algebra', 'ALG', 1);
```

## 🌐 Web Integration Examples

### PHP Connection
```php
<?php
$pdo = new PDO('mysql:host=localhost;dbname=school_management', 'username', 'password');
$pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

// Get all students
$stmt = $pdo->query("SELECT * FROM student_details WHERE is_active = 1");
$students = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>
```

### Node.js Connection
```javascript
const mysql = require('mysql2/promise');

const connection = await mysql.createConnection({
  host: 'localhost',
  database: 'school_management',
  user: 'username',
  password: 'password'
});

// Get all classes
const [classes] = await connection.execute('SELECT * FROM classes WHERE is_active = 1');
```

### Python Connection
```python
import pymysql

connection = pymysql.connect(
    host='localhost',
    database='school_management',
    user='username',
    password='password'
)

# Get all teachers
with connection.cursor() as cursor:
    cursor.execute("SELECT * FROM teacher_details WHERE is_active = 1")
    teachers = cursor.fetchall()
```

## 📊 Common Queries

### Get Students by Class
```sql
SELECT s.admission_number, s.first_name, s.last_name, s.phone
FROM students s
JOIN classes c ON s.class_id = c.class_id
WHERE c.class_name = 'Grade 10A' AND s.is_active = 1;
```

### Mark Attendance
```sql
INSERT INTO attendance (student_id, class_id, date, status, marked_by)
VALUES (1, 1, CURDATE(), 'Present', 1);
```

### Get Class Timetable
```sql
SELECT * FROM class_timetable 
WHERE class_name = 'Grade 10A' 
ORDER BY FIELD(day_of_week, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'), start_time;
```

### Check Fee Status
```sql
SELECT * FROM student_fee_status 
WHERE student_id = 1 AND balance_amount > 0;
```

## 🔒 Security Notes

1. **Password Hashing**: Use proper password hashing in production
   ```php
   $hash = password_hash($password, PASSWORD_DEFAULT);
   ```

2. **Prepared Statements**: Always use prepared statements
   ```php
   $stmt = $pdo->prepare("SELECT * FROM users WHERE username = ?");
   $stmt->execute([$username]);
   ```

3. **Role-Based Access**: Implement proper role checking
   ```php
   if ($user['role'] !== 'admin') {
       die('Access denied');
   }
   ```

## 📱 API Endpoints Structure

```
GET    /api/students              - List students
POST   /api/students              - Create student
GET    /api/students/{id}         - Get student details
PUT    /api/students/{id}         - Update student
DELETE /api/students/{id}         - Deactivate student

GET    /api/classes/{id}/students - Students in class
POST   /api/attendance            - Mark attendance
GET    /api/grades/{student_id}   - Student grades
POST   /api/fees/payment          - Record fee payment
```

## 🎯 Next Steps

1. **Review Documentation**: Read the full `README.md`
2. **Test Queries**: Try the sample queries
3. **Build Your App**: Start building your web application
4. **Add Features**: Extend the schema as needed
5. **Deploy**: Set up production environment

## 📞 Support

- Check table structure: `DESCRIBE table_name`
- View relationships: Check foreign keys in schema
- Use provided views for complex queries
- Test with sample data before production

## 🔄 Backup & Restore

### Backup
```bash
mysqldump -u root -p school_management > backup.sql
```

### Restore
```bash
mysql -u root -p school_management < backup.sql
```

---

**Ready to build your school management system!** 🎓

The database is designed to be flexible, scalable, and easy to integrate with any web framework. Start with the basic functionality and extend as needed.