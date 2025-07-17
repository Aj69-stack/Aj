<?php
/**
 * School Management System API
 * This file provides REST API endpoints for the school management system
 * Connects the frontend interface to the MySQL database
 */

// Enable CORS for frontend requests
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Database configuration
$config = [
    'host' => 'localhost',
    'dbname' => 'school_management',
    'username' => 'root',
    'password' => '',
    'charset' => 'utf8mb4'
];

// Database connection
try {
    $pdo = new PDO(
        "mysql:host={$config['host']};dbname={$config['dbname']};charset={$config['charset']}", 
        $config['username'], 
        $config['password'],
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false
        ]
    );
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit();
}

// Get request method and endpoint
$method = $_SERVER['REQUEST_METHOD'];
$request = $_SERVER['REQUEST_URI'];
$path = parse_url($request, PHP_URL_PATH);
$path = str_replace('/api.php', '', $path);
$segments = explode('/', trim($path, '/'));

// Main router
try {
    switch ($segments[0]) {
        case 'auth':
            handleAuth($method, $segments);
            break;
        case 'dashboard':
            handleDashboard($method, $segments);
            break;
        case 'students':
            handleStudents($method, $segments);
            break;
        case 'teachers':
            handleTeachers($method, $segments);
            break;
        case 'classes':
            handleClasses($method, $segments);
            break;
        case 'subjects':
            handleSubjects($method, $segments);
            break;
        case 'attendance':
            handleAttendance($method, $segments);
            break;
        case 'examinations':
            handleExaminations($method, $segments);
            break;
        case 'grades':
            handleGrades($method, $segments);
            break;
        case 'fees':
            handleFees($method, $segments);
            break;
        case 'library':
            handleLibrary($method, $segments);
            break;
        case 'announcements':
            handleAnnouncements($method, $segments);
            break;
        case 'settings':
            handleSettings($method, $segments);
            break;
        default:
            http_response_code(404);
            echo json_encode(['error' => 'Endpoint not found']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}

// Authentication endpoints
function handleAuth($method, $segments) {
    global $pdo;
    
    if ($method === 'POST' && isset($segments[1])) {
        switch ($segments[1]) {
            case 'login':
                $input = json_decode(file_get_contents('php://input'), true);
                
                if (!$input['username'] || !$input['password'] || !$input['role']) {
                    http_response_code(400);
                    echo json_encode(['error' => 'Username, password, and role are required']);
                    return;
                }
                
                $stmt = $pdo->prepare("
                    SELECT user_id, username, password_hash, role, is_active 
                    FROM users 
                    WHERE username = ? AND role = ? AND is_active = 1
                ");
                $stmt->execute([$input['username'], $input['role']]);
                $user = $stmt->fetch();
                
                if ($user && password_verify($input['password'], $user['password_hash'])) {
                    // Get additional user info based on role
                    $userInfo = getUserInfo($user['user_id'], $user['role']);
                    
                    // Update last login
                    $stmt = $pdo->prepare("UPDATE users SET last_login = NOW() WHERE user_id = ?");
                    $stmt->execute([$user['user_id']]);
                    
                    // Generate session token (in production, use proper JWT)
                    $token = bin2hex(random_bytes(32));
                    
                    echo json_encode([
                        'success' => true,
                        'token' => $token,
                        'user' => [
                            'id' => $user['user_id'],
                            'username' => $user['username'],
                            'role' => $user['role'],
                            'info' => $userInfo
                        ]
                    ]);
                } else {
                    http_response_code(401);
                    echo json_encode(['error' => 'Invalid credentials']);
                }
                break;
                
            case 'logout':
                echo json_encode(['success' => true, 'message' => 'Logged out successfully']);
                break;
        }
    }
}

// Dashboard endpoints
function handleDashboard($method, $segments) {
    global $pdo;
    
    if ($method === 'GET') {
        // Get dashboard statistics
        $stats = [];
        
        // Total students
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM students WHERE is_active = 1");
        $stats['totalStudents'] = $stmt->fetch()['count'];
        
        // Total teachers
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM teachers WHERE is_active = 1");
        $stats['totalTeachers'] = $stmt->fetch()['count'];
        
        // Total classes
        $stmt = $pdo->query("SELECT COUNT(*) as count FROM classes WHERE is_active = 1");
        $stats['totalClasses'] = $stmt->fetch()['count'];
        
        // Attendance rate (last 30 days)
        $stmt = $pdo->query("
            SELECT 
                ROUND(
                    (COUNT(CASE WHEN status = 'Present' THEN 1 END) / COUNT(*)) * 100, 
                    2
                ) as attendance_rate
            FROM attendance 
            WHERE date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
        ");
        $result = $stmt->fetch();
        $stats['attendanceRate'] = $result['attendance_rate'] ?: 0;
        
        // Recent announcements
        $stmt = $pdo->query("
            SELECT announcement_id, title, content, priority, created_at 
            FROM announcements 
            WHERE is_active = 1 
            ORDER BY created_at DESC 
            LIMIT 5
        ");
        $announcements = $stmt->fetchAll();
        
        // Today's schedule (mock data for demonstration)
        $schedule = [
            ['time' => '09:00 AM', 'subject' => 'Mathematics', 'class' => 'Grade 10A', 'teacher' => 'Dr. Sarah Wilson'],
            ['time' => '10:00 AM', 'subject' => 'Physics', 'class' => 'Grade 11A', 'teacher' => 'Mr. David Miller'],
            ['time' => '11:00 AM', 'subject' => 'English', 'class' => 'Grade 12A', 'teacher' => 'Ms. Emily Davis']
        ];
        
        echo json_encode([
            'stats' => $stats,
            'announcements' => $announcements,
            'schedule' => $schedule
        ]);
    }
}

// Students endpoints
function handleStudents($method, $segments) {
    global $pdo;
    
    switch ($method) {
        case 'GET':
            if (isset($segments[1])) {
                // Get specific student
                $studentId = $segments[1];
                $stmt = $pdo->prepare("SELECT * FROM student_details WHERE student_id = ?");
                $stmt->execute([$studentId]);
                $student = $stmt->fetch();
                
                if ($student) {
                    echo json_encode($student);
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Student not found']);
                }
            } else {
                // Get all students with filters
                $where = "WHERE s.is_active = 1";
                $params = [];
                
                if (isset($_GET['class_id'])) {
                    $where .= " AND s.class_id = ?";
                    $params[] = $_GET['class_id'];
                }
                
                if (isset($_GET['search'])) {
                    $where .= " AND (s.first_name LIKE ? OR s.last_name LIKE ? OR s.admission_number LIKE ?)";
                    $searchTerm = '%' . $_GET['search'] . '%';
                    $params[] = $searchTerm;
                    $params[] = $searchTerm;
                    $params[] = $searchTerm;
                }
                
                $stmt = $pdo->prepare("
                    SELECT 
                        s.student_id, s.admission_number, s.first_name, s.last_name, 
                        s.phone, s.email, s.is_active, c.class_name
                    FROM students s
                    LEFT JOIN classes c ON s.class_id = c.class_id
                    $where
                    ORDER BY s.first_name, s.last_name
                ");
                $stmt->execute($params);
                $students = $stmt->fetchAll();
                
                echo json_encode($students);
            }
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            // Validate required fields
            $required = ['admission_number', 'first_name', 'last_name', 'class_id', 'email', 'date_of_birth'];
            foreach ($required as $field) {
                if (!isset($input[$field]) || empty($input[$field])) {
                    http_response_code(400);
                    echo json_encode(['error' => "Field '$field' is required"]);
                    return;
                }
            }
            
            try {
                $pdo->beginTransaction();
                
                // Create user account
                $password_hash = password_hash($input['admission_number'], PASSWORD_DEFAULT); // Default password
                $stmt = $pdo->prepare("
                    INSERT INTO users (username, email, password_hash, role) 
                    VALUES (?, ?, ?, 'student')
                ");
                $stmt->execute([$input['admission_number'], $input['email'], $password_hash]);
                $userId = $pdo->lastInsertId();
                
                // Create student record
                $stmt = $pdo->prepare("
                    INSERT INTO students (
                        user_id, admission_number, first_name, last_name, 
                        date_of_birth, gender, phone, address, class_id, admission_date
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, CURDATE())
                ");
                $stmt->execute([
                    $userId,
                    $input['admission_number'],
                    $input['first_name'],
                    $input['last_name'],
                    $input['date_of_birth'],
                    $input['gender'] ?? null,
                    $input['phone'] ?? null,
                    $input['address'] ?? null,
                    $input['class_id']
                ]);
                
                $studentId = $pdo->lastInsertId();
                $pdo->commit();
                
                echo json_encode(['success' => true, 'student_id' => $studentId]);
                
            } catch (Exception $e) {
                $pdo->rollback();
                http_response_code(500);
                echo json_encode(['error' => 'Failed to create student: ' . $e->getMessage()]);
            }
            break;
            
        case 'PUT':
            if (!isset($segments[1])) {
                http_response_code(400);
                echo json_encode(['error' => 'Student ID is required']);
                return;
            }
            
            $studentId = $segments[1];
            $input = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare("
                UPDATE students 
                SET first_name = ?, last_name = ?, phone = ?, address = ?, 
                    class_id = ?, gender = ?, updated_at = NOW()
                WHERE student_id = ?
            ");
            $stmt->execute([
                $input['first_name'],
                $input['last_name'],
                $input['phone'],
                $input['address'],
                $input['class_id'],
                $input['gender'],
                $studentId
            ]);
            
            echo json_encode(['success' => true]);
            break;
            
        case 'DELETE':
            if (!isset($segments[1])) {
                http_response_code(400);
                echo json_encode(['error' => 'Student ID is required']);
                return;
            }
            
            $studentId = $segments[1];
            $stmt = $pdo->prepare("UPDATE students SET is_active = 0 WHERE student_id = ?");
            $stmt->execute([$studentId]);
            
            echo json_encode(['success' => true]);
            break;
    }
}

// Teachers endpoints
function handleTeachers($method, $segments) {
    global $pdo;
    
    switch ($method) {
        case 'GET':
            if (isset($segments[1])) {
                // Get specific teacher
                $teacherId = $segments[1];
                $stmt = $pdo->prepare("SELECT * FROM teacher_details WHERE teacher_id = ?");
                $stmt->execute([$teacherId]);
                $teacher = $stmt->fetch();
                
                if ($teacher) {
                    echo json_encode($teacher);
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Teacher not found']);
                }
            } else {
                // Get all teachers
                $stmt = $pdo->query("SELECT * FROM teacher_details WHERE is_active = 1");
                $teachers = $stmt->fetchAll();
                echo json_encode($teachers);
            }
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            // Similar implementation as students
            echo json_encode(['success' => true, 'message' => 'Teacher creation not implemented yet']);
            break;
    }
}

// Classes endpoints
function handleClasses($method, $segments) {
    global $pdo;
    
    switch ($method) {
        case 'GET':
            $stmt = $pdo->query("
                SELECT 
                    c.class_id, c.class_name, c.class_code, c.grade_level, 
                    c.max_students, c.is_active,
                    COUNT(s.student_id) as student_count,
                    CONCAT(t.first_name, ' ', t.last_name) as class_teacher
                FROM classes c
                LEFT JOIN students s ON c.class_id = s.class_id AND s.is_active = 1
                LEFT JOIN teachers t ON c.class_teacher_id = t.teacher_id
                WHERE c.is_active = 1
                GROUP BY c.class_id
                ORDER BY c.grade_level, c.class_name
            ");
            $classes = $stmt->fetchAll();
            echo json_encode($classes);
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare("
                INSERT INTO classes (class_name, class_code, grade_level, academic_year_id, max_students) 
                VALUES (?, ?, ?, (SELECT year_id FROM academic_years WHERE is_current = 1), ?)
            ");
            $stmt->execute([
                $input['class_name'],
                $input['class_code'],
                $input['grade_level'],
                $input['max_students'] ?? 30
            ]);
            
            echo json_encode(['success' => true, 'class_id' => $pdo->lastInsertId()]);
            break;
    }
}

// Attendance endpoints
function handleAttendance($method, $segments) {
    global $pdo;
    
    switch ($method) {
        case 'GET':
            $classId = $_GET['class_id'] ?? null;
            $date = $_GET['date'] ?? date('Y-m-d');
            
            if (!$classId) {
                http_response_code(400);
                echo json_encode(['error' => 'Class ID is required']);
                return;
            }
            
            $stmt = $pdo->prepare("
                SELECT 
                    s.student_id, s.admission_number, s.first_name, s.last_name,
                    a.status, a.remarks
                FROM students s
                LEFT JOIN attendance a ON s.student_id = a.student_id AND a.date = ?
                WHERE s.class_id = ? AND s.is_active = 1
                ORDER BY s.first_name, s.last_name
            ");
            $stmt->execute([$date, $classId]);
            $students = $stmt->fetchAll();
            
            echo json_encode($students);
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare("
                INSERT INTO attendance (student_id, class_id, date, status, marked_by) 
                VALUES (?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE 
                status = VALUES(status), marked_by = VALUES(marked_by), marked_at = NOW()
            ");
            $stmt->execute([
                $input['student_id'],
                $input['class_id'],
                $input['date'],
                $input['status'],
                $input['marked_by'] ?? 1 // Default teacher ID
            ]);
            
            echo json_encode(['success' => true]);
            break;
    }
}

// Announcements endpoints
function handleAnnouncements($method, $segments) {
    global $pdo;
    
    switch ($method) {
        case 'GET':
            $stmt = $pdo->query("
                SELECT 
                    a.announcement_id, a.title, a.content, a.priority, 
                    a.target_audience, a.created_at,
                    CONCAT(u.username) as created_by_name
                FROM announcements a
                JOIN users u ON a.created_by = u.user_id
                WHERE a.is_active = 1
                ORDER BY a.created_at DESC
                LIMIT 20
            ");
            $announcements = $stmt->fetchAll();
            echo json_encode($announcements);
            break;
            
        case 'POST':
            $input = json_decode(file_get_contents('php://input'), true);
            
            $stmt = $pdo->prepare("
                INSERT INTO announcements (title, content, target_audience, priority, created_by) 
                VALUES (?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $input['title'],
                $input['content'],
                $input['target_audience'],
                $input['priority'],
                $input['created_by']
            ]);
            
            echo json_encode(['success' => true, 'announcement_id' => $pdo->lastInsertId()]);
            break;
    }
}

// Utility functions
function getUserInfo($userId, $role) {
    global $pdo;
    
    switch ($role) {
        case 'student':
            $stmt = $pdo->prepare("
                SELECT s.*, c.class_name 
                FROM students s 
                LEFT JOIN classes c ON s.class_id = c.class_id 
                WHERE s.user_id = ?
            ");
            break;
        case 'teacher':
            $stmt = $pdo->prepare("
                SELECT t.*, d.department_name 
                FROM teachers t 
                LEFT JOIN departments d ON t.department_id = d.department_id 
                WHERE t.user_id = ?
            ");
            break;
        case 'parent':
            $stmt = $pdo->prepare("SELECT * FROM parents WHERE user_id = ?");
            break;
        default:
            return null;
    }
    
    $stmt->execute([$userId]);
    return $stmt->fetch();
}

function validateToken($token) {
    // In production, implement proper JWT token validation
    return true;
}

// Placeholder functions for other endpoints
function handleSubjects($method, $segments) {
    echo json_encode(['message' => 'Subjects endpoint not implemented yet']);
}

function handleExaminations($method, $segments) {
    echo json_encode(['message' => 'Examinations endpoint not implemented yet']);
}

function handleGrades($method, $segments) {
    echo json_encode(['message' => 'Grades endpoint not implemented yet']);
}

function handleFees($method, $segments) {
    echo json_encode(['message' => 'Fees endpoint not implemented yet']);
}

function handleLibrary($method, $segments) {
    echo json_encode(['message' => 'Library endpoint not implemented yet']);
}

function handleSettings($method, $segments) {
    global $pdo;
    
    if ($method === 'GET') {
        $stmt = $pdo->query("SELECT * FROM system_settings ORDER BY setting_key");
        $settings = $stmt->fetchAll();
        echo json_encode($settings);
    }
}

?>