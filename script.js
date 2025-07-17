// School Management System JavaScript
// This file handles all the interactive functionality for the interface

// Global variables
let currentUser = null;
let currentSection = 'dashboard';
let mockData = {
    students: [],
    teachers: [],
    classes: [],
    subjects: [],
    attendance: [],
    announcements: [],
    stats: {
        totalStudents: 0,
        totalTeachers: 0,
        totalClasses: 0,
        attendanceRate: 0
    }
};

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
    loadMockData();
});

// Initialize application
function initializeApp() {
    // Check if user is logged in
    const savedUser = localStorage.getItem('currentUser');
    if (savedUser) {
        currentUser = JSON.parse(savedUser);
        showApp();
    } else {
        showLogin();
    }
}

// Setup event listeners
function setupEventListeners() {
    // Login form
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }

    // Logout button
    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', handleLogout);
    }

    // Menu toggle for mobile
    const menuToggle = document.getElementById('menuToggle');
    if (menuToggle) {
        menuToggle.addEventListener('click', toggleSidebar);
    }

    // Navigation links
    const navLinks = document.querySelectorAll('.nav-link');
    navLinks.forEach(link => {
        link.addEventListener('click', handleNavigation);
    });

    // Modal close buttons
    const closeButtons = document.querySelectorAll('[data-close]');
    closeButtons.forEach(button => {
        button.addEventListener('click', handleModalClose);
    });

    // Add buttons
    const addStudentBtn = document.getElementById('addStudentBtn');
    if (addStudentBtn) {
        addStudentBtn.addEventListener('click', () => showModal('studentModal'));
    }

    const addTeacherBtn = document.getElementById('addTeacherBtn');
    if (addTeacherBtn) {
        addTeacherBtn.addEventListener('click', () => showModal('teacherModal'));
    }

    const addClassBtn = document.getElementById('addClassBtn');
    if (addClassBtn) {
        addClassBtn.addEventListener('click', () => showModal('classModal'));
    }

    // Forms
    const studentForm = document.getElementById('studentForm');
    if (studentForm) {
        studentForm.addEventListener('submit', handleStudentSubmit);
    }

    // Search and filter inputs
    const studentSearch = document.getElementById('studentSearch');
    if (studentSearch) {
        studentSearch.addEventListener('input', filterStudents);
    }

    const classFilter = document.getElementById('classFilter');
    if (classFilter) {
        classFilter.addEventListener('change', filterStudents);
    }

    const statusFilter = document.getElementById('statusFilter');
    if (statusFilter) {
        statusFilter.addEventListener('change', filterStudents);
    }

    // Attendance date input
    const attendanceDate = document.getElementById('attendanceDate');
    if (attendanceDate) {
        attendanceDate.value = new Date().toISOString().split('T')[0];
        attendanceDate.addEventListener('change', loadAttendanceData);
    }

    const attendanceClass = document.getElementById('attendanceClass');
    if (attendanceClass) {
        attendanceClass.addEventListener('change', loadAttendanceData);
    }
}

// Authentication functions
function handleLogin(e) {
    e.preventDefault();
    const formData = new FormData(e.target);
    const credentials = {
        username: formData.get('username'),
        password: formData.get('password'),
        role: formData.get('role')
    };

    // Mock authentication - in real app, this would be an API call
    if (credentials.username && credentials.password && credentials.role) {
        currentUser = {
            id: 1,
            username: credentials.username,
            role: credentials.role,
            name: getDisplayName(credentials.username, credentials.role)
        };
        
        localStorage.setItem('currentUser', JSON.stringify(currentUser));
        showApp();
        showNotification('Login successful!', 'success');
    } else {
        showNotification('Please fill in all fields', 'error');
    }
}

function handleLogout() {
    currentUser = null;
    localStorage.removeItem('currentUser');
    showLogin();
    showNotification('Logged out successfully', 'success');
}

function getDisplayName(username, role) {
    const names = {
        'admin': 'Administrator',
        'teacher': 'John Teacher',
        'student': 'Jane Student',
        'parent': 'Parent User',
        'staff': 'Staff Member'
    };
    return names[role] || username;
}

// UI Navigation functions
function showLogin() {
    document.getElementById('loginModal').classList.add('active');
    document.getElementById('app').classList.remove('active');
}

function showApp() {
    document.getElementById('loginModal').classList.remove('active');
    document.getElementById('app').classList.add('active');
    
    // Update user info in header
    document.getElementById('userName').textContent = currentUser.name;
    document.getElementById('userRole').textContent = currentUser.role.charAt(0).toUpperCase() + currentUser.role.slice(1);
    
    // Load dashboard data
    loadDashboardData();
    
    // Show appropriate sections based on role
    updateUIForRole();
}

function handleNavigation(e) {
    e.preventDefault();
    const section = e.target.getAttribute('data-section') || e.target.closest('.nav-link').getAttribute('data-section');
    
    if (section) {
        showSection(section);
    }
}

function showSection(sectionName) {
    // Hide all sections
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });
    
    // Show selected section
    const targetSection = document.getElementById(sectionName);
    if (targetSection) {
        targetSection.classList.add('active');
        currentSection = sectionName;
        
        // Update active nav link
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
        });
        document.querySelector(`[data-section="${sectionName}"]`).classList.add('active');
        
        // Load section-specific data
        loadSectionData(sectionName);
    }
}

function toggleSidebar() {
    const sidebar = document.getElementById('sidebar');
    sidebar.classList.toggle('active');
}

function updateUIForRole() {
    // Hide/show features based on user role
    const role = currentUser.role;
    
    // Students and parents have limited access
    if (role === 'student' || role === 'parent') {
        const restrictedSections = ['teachers', 'settings'];
        restrictedSections.forEach(section => {
            const navLink = document.querySelector(`[data-section="${section}"]`);
            if (navLink) {
                navLink.style.display = 'none';
            }
        });
    }
}

// Data loading functions
function loadMockData() {
    // Generate mock data for demonstration
    mockData.classes = [
        { id: 1, class_name: 'Grade 10A', class_code: '10A', grade_level: 10, max_students: 30, is_active: true },
        { id: 2, class_name: 'Grade 10B', class_code: '10B', grade_level: 10, max_students: 30, is_active: true },
        { id: 3, class_name: 'Grade 11A', class_code: '11A', grade_level: 11, max_students: 25, is_active: true },
        { id: 4, class_name: 'Grade 12A', class_code: '12A', grade_level: 12, max_students: 25, is_active: true }
    ];

    mockData.students = [
        { id: 1, admission_number: 'STU001', first_name: 'John', last_name: 'Doe', class_id: 1, phone: '123-456-7890', email: 'john.doe@email.com', is_active: true },
        { id: 2, admission_number: 'STU002', first_name: 'Jane', last_name: 'Smith', class_id: 1, phone: '123-456-7891', email: 'jane.smith@email.com', is_active: true },
        { id: 3, admission_number: 'STU003', first_name: 'Bob', last_name: 'Johnson', class_id: 2, phone: '123-456-7892', email: 'bob.johnson@email.com', is_active: true },
        { id: 4, admission_number: 'STU004', first_name: 'Alice', last_name: 'Brown', class_id: 3, phone: '123-456-7893', email: 'alice.brown@email.com', is_active: false }
    ];

    mockData.teachers = [
        { id: 1, employee_id: 'EMP001', first_name: 'Dr. Sarah', last_name: 'Wilson', department: 'Mathematics', qualification: 'PhD Mathematics', phone: '123-456-8001', is_active: true },
        { id: 2, employee_id: 'EMP002', first_name: 'Mr. David', last_name: 'Miller', department: 'Science', qualification: 'MSc Physics', phone: '123-456-8002', is_active: true },
        { id: 3, employee_id: 'EMP003', first_name: 'Ms. Emily', last_name: 'Davis', department: 'English', qualification: 'MA English', phone: '123-456-8003', is_active: true }
    ];

    mockData.announcements = [
        { id: 1, title: 'Parent-Teacher Meeting', content: 'PTM scheduled for next week', priority: 'High', created_at: '2024-01-15' },
        { id: 2, title: 'Sports Day', content: 'Annual sports day on March 15th', priority: 'Medium', created_at: '2024-01-14' },
        { id: 3, title: 'Exam Schedule', content: 'Final exams from April 1st', priority: 'Urgent', created_at: '2024-01-13' }
    ];

    mockData.stats = {
        totalStudents: mockData.students.filter(s => s.is_active).length,
        totalTeachers: mockData.teachers.filter(t => t.is_active).length,
        totalClasses: mockData.classes.filter(c => c.is_active).length,
        attendanceRate: 85
    };

    // Populate class dropdowns
    populateClassDropdowns();
}

function loadDashboardData() {
    // Update statistics
    document.getElementById('totalStudents').textContent = mockData.stats.totalStudents;
    document.getElementById('totalTeachers').textContent = mockData.stats.totalTeachers;
    document.getElementById('totalClasses').textContent = mockData.stats.totalClasses;
    document.getElementById('attendanceRate').textContent = mockData.stats.attendanceRate + '%';

    // Load recent announcements
    loadRecentAnnouncements();
    
    // Load today's schedule
    loadTodaySchedule();
}

function loadRecentAnnouncements() {
    const container = document.getElementById('recentAnnouncements');
    if (!container) return;

    const announcements = mockData.announcements.slice(0, 5);
    
    if (announcements.length === 0) {
        container.innerHTML = '<p class="text-secondary">No recent announcements</p>';
        return;
    }

    container.innerHTML = announcements.map(announcement => `
        <div class="announcement-item" style="padding: 0.75rem 0; border-bottom: 1px solid var(--border-color);">
            <h4 style="margin: 0 0 0.25rem 0; font-size: 0.9rem; color: var(--text-primary);">${announcement.title}</h4>
            <p style="margin: 0 0 0.25rem 0; font-size: 0.8rem; color: var(--text-secondary);">${announcement.content}</p>
            <small style="color: var(--text-secondary);">${formatDate(announcement.created_at)}</small>
        </div>
    `).join('');
}

function loadTodaySchedule() {
    const container = document.getElementById('todaySchedule');
    if (!container) return;

    // Mock schedule data
    const schedule = [
        { time: '09:00 AM', subject: 'Mathematics', class: 'Grade 10A', teacher: 'Dr. Sarah Wilson' },
        { time: '10:00 AM', subject: 'Physics', class: 'Grade 11A', teacher: 'Mr. David Miller' },
        { time: '11:00 AM', subject: 'English', class: 'Grade 12A', teacher: 'Ms. Emily Davis' }
    ];

    container.innerHTML = schedule.map(item => `
        <div class="schedule-item" style="padding: 0.75rem 0; border-bottom: 1px solid var(--border-color);">
            <div style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h4 style="margin: 0 0 0.25rem 0; font-size: 0.9rem; color: var(--text-primary);">${item.subject}</h4>
                    <p style="margin: 0; font-size: 0.8rem; color: var(--text-secondary);">${item.class} - ${item.teacher}</p>
                </div>
                <span style="font-size: 0.8rem; color: var(--primary-color); font-weight: 500;">${item.time}</span>
            </div>
        </div>
    `).join('');
}

function loadSectionData(sectionName) {
    switch (sectionName) {
        case 'students':
            loadStudentsData();
            break;
        case 'teachers':
            loadTeachersData();
            break;
        case 'classes':
            loadClassesData();
            break;
        case 'attendance':
            loadAttendanceData();
            break;
        default:
            break;
    }
}

function loadStudentsData() {
    const tbody = document.querySelector('#studentsTable tbody');
    if (!tbody) return;

    const students = mockData.students;
    
    tbody.innerHTML = students.map(student => {
        const className = getClassNameById(student.class_id);
        const statusClass = student.is_active ? 'status-active' : 'status-inactive';
        const statusText = student.is_active ? 'Active' : 'Inactive';
        
        return `
            <tr>
                <td>${student.admission_number}</td>
                <td>${student.first_name} ${student.last_name}</td>
                <td>${className}</td>
                <td>${student.phone}</td>
                <td><span class="status-badge ${statusClass}">${statusText}</span></td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn edit" onclick="editStudent(${student.id})">Edit</button>
                        <button class="action-btn delete" onclick="deleteStudent(${student.id})">Delete</button>
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

function loadTeachersData() {
    const tbody = document.querySelector('#teachersTable tbody');
    if (!tbody) return;

    const teachers = mockData.teachers;
    
    tbody.innerHTML = teachers.map(teacher => {
        const statusClass = teacher.is_active ? 'status-active' : 'status-inactive';
        const statusText = teacher.is_active ? 'Active' : 'Inactive';
        
        return `
            <tr>
                <td>${teacher.employee_id}</td>
                <td>${teacher.first_name} ${teacher.last_name}</td>
                <td>${teacher.department}</td>
                <td>${teacher.qualification}</td>
                <td>${teacher.phone}</td>
                <td><span class="status-badge ${statusClass}">${statusText}</span></td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn edit" onclick="editTeacher(${teacher.id})">Edit</button>
                        <button class="action-btn delete" onclick="deleteTeacher(${teacher.id})">Delete</button>
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

function loadClassesData() {
    const tbody = document.querySelector('#classesTable tbody');
    if (!tbody) return;

    const classes = mockData.classes;
    
    tbody.innerHTML = classes.map(cls => {
        const studentCount = mockData.students.filter(s => s.class_id === cls.id && s.is_active).length;
        const statusClass = cls.is_active ? 'status-active' : 'status-inactive';
        const statusText = cls.is_active ? 'Active' : 'Inactive';
        
        return `
            <tr>
                <td>${cls.class_code}</td>
                <td>${cls.class_name}</td>
                <td>${cls.grade_level}</td>
                <td>-</td>
                <td>${studentCount}/${cls.max_students}</td>
                <td><span class="status-badge ${statusClass}">${statusText}</span></td>
                <td>
                    <div class="action-buttons">
                        <button class="action-btn edit" onclick="editClass(${cls.id})">Edit</button>
                        <button class="action-btn delete" onclick="deleteClass(${cls.id})">Delete</button>
                    </div>
                </td>
            </tr>
        `;
    }).join('');
}

function loadAttendanceData() {
    const classId = document.getElementById('attendanceClass').value;
    const date = document.getElementById('attendanceDate').value;
    
    if (!classId || !date) {
        document.getElementById('attendanceGrid').innerHTML = '<p class="text-secondary">Please select a class and date</p>';
        return;
    }

    const students = mockData.students.filter(s => s.class_id == classId && s.is_active);
    const container = document.getElementById('attendanceGrid');
    
    container.innerHTML = students.map(student => `
        <div class="attendance-student">
            <div class="student-info">
                <div class="student-avatar">${student.first_name.charAt(0)}</div>
                <div>
                    <h4>${student.first_name} ${student.last_name}</h4>
                    <p>${student.admission_number}</p>
                </div>
            </div>
            <div class="attendance-controls">
                <button class="attendance-btn present" onclick="markAttendance(${student.id}, 'Present')">Present</button>
                <button class="attendance-btn absent" onclick="markAttendance(${student.id}, 'Absent')">Absent</button>
                <button class="attendance-btn late" onclick="markAttendance(${student.id}, 'Late')">Late</button>
            </div>
        </div>
    `).join('');
}

// Modal functions
function showModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('active');
        
        // Reset form if it exists
        const form = modal.querySelector('form');
        if (form) {
            form.reset();
        }
    }
}

function hideModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('active');
    }
}

function handleModalClose(e) {
    const modalId = e.target.getAttribute('data-close');
    if (modalId) {
        hideModal(modalId);
    }
}

// Form handling functions
function handleStudentSubmit(e) {
    e.preventDefault();
    const formData = new FormData(e.target);
    
    const studentData = {
        id: Date.now(), // Mock ID
        admission_number: formData.get('admission_number'),
        first_name: formData.get('first_name'),
        last_name: formData.get('last_name'),
        class_id: parseInt(formData.get('class_id')),
        phone: formData.get('phone'),
        email: formData.get('email'),
        date_of_birth: formData.get('date_of_birth'),
        gender: formData.get('gender'),
        address: formData.get('address'),
        is_active: true
    };
    
    // Add to mock data
    mockData.students.push(studentData);
    mockData.stats.totalStudents++;
    
    // Refresh the students table
    loadStudentsData();
    
    // Update dashboard stats
    document.getElementById('totalStudents').textContent = mockData.stats.totalStudents;
    
    // Hide modal and show success message
    hideModal('studentModal');
    showNotification('Student added successfully!', 'success');
}

// Utility functions
function populateClassDropdowns() {
    const selects = ['classFilter', 'studentClass', 'attendanceClass'];
    
    selects.forEach(selectId => {
        const select = document.getElementById(selectId);
        if (select) {
            const currentOptions = select.innerHTML;
            const newOptions = mockData.classes.map(cls => 
                `<option value="${cls.id}">${cls.class_name}</option>`
            ).join('');
            
            if (selectId === 'classFilter') {
                select.innerHTML = '<option value="">All Classes</option>' + newOptions;
            } else if (selectId === 'attendanceClass') {
                select.innerHTML = '<option value="">Select Class</option>' + newOptions;
            } else {
                select.innerHTML = '<option value="">Select Class</option>' + newOptions;
            }
        }
    });
}

function getClassNameById(classId) {
    const cls = mockData.classes.find(c => c.id === classId);
    return cls ? cls.class_name : 'Unknown';
}

function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { 
        year: 'numeric', 
        month: 'short', 
        day: 'numeric' 
    });
}

function showNotification(message, type = 'info') {
    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification notification-${type}`;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        color: white;
        font-weight: 500;
        z-index: 1001;
        animation: slideIn 0.3s ease;
    `;
    
    // Set background color based on type
    const colors = {
        success: '#10b981',
        error: '#ef4444',
        warning: '#f59e0b',
        info: '#3b82f6'
    };
    
    notification.style.backgroundColor = colors[type] || colors.info;
    notification.textContent = message;
    
    // Add to page
    document.body.appendChild(notification);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            document.body.removeChild(notification);
        }, 300);
    }, 3000);
}

// Filter functions
function filterStudents() {
    const searchTerm = document.getElementById('studentSearch').value.toLowerCase();
    const classFilter = document.getElementById('classFilter').value;
    const statusFilter = document.getElementById('statusFilter').value;
    
    let filteredStudents = mockData.students;
    
    // Apply search filter
    if (searchTerm) {
        filteredStudents = filteredStudents.filter(student => 
            student.first_name.toLowerCase().includes(searchTerm) ||
            student.last_name.toLowerCase().includes(searchTerm) ||
            student.admission_number.toLowerCase().includes(searchTerm)
        );
    }
    
    // Apply class filter
    if (classFilter) {
        filteredStudents = filteredStudents.filter(student => 
            student.class_id == classFilter
        );
    }
    
    // Apply status filter
    if (statusFilter !== '') {
        filteredStudents = filteredStudents.filter(student => 
            student.is_active == (statusFilter === '1')
        );
    }
    
    // Update table with filtered data
    const tbody = document.querySelector('#studentsTable tbody');
    if (tbody) {
        tbody.innerHTML = filteredStudents.map(student => {
            const className = getClassNameById(student.class_id);
            const statusClass = student.is_active ? 'status-active' : 'status-inactive';
            const statusText = student.is_active ? 'Active' : 'Inactive';
            
            return `
                <tr>
                    <td>${student.admission_number}</td>
                    <td>${student.first_name} ${student.last_name}</td>
                    <td>${className}</td>
                    <td>${student.phone}</td>
                    <td><span class="status-badge ${statusClass}">${statusText}</span></td>
                    <td>
                        <div class="action-buttons">
                            <button class="action-btn edit" onclick="editStudent(${student.id})">Edit</button>
                            <button class="action-btn delete" onclick="deleteStudent(${student.id})">Delete</button>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');
    }
}

// Action functions
function editStudent(id) {
    const student = mockData.students.find(s => s.id === id);
    if (student) {
        // Populate form with student data
        document.getElementById('studentAdmissionNo').value = student.admission_number;
        document.getElementById('studentFirstName').value = student.first_name;
        document.getElementById('studentLastName').value = student.last_name;
        document.getElementById('studentClass').value = student.class_id;
        document.getElementById('studentPhone').value = student.phone;
        document.getElementById('studentEmail').value = student.email;
        document.getElementById('studentDOB').value = student.date_of_birth;
        document.getElementById('studentGender').value = student.gender;
        document.getElementById('studentAddress').value = student.address;
        
        // Change modal title
        document.getElementById('studentModalTitle').textContent = 'Edit Student';
        
        // Show modal
        showModal('studentModal');
    }
}

function deleteStudent(id) {
    if (confirm('Are you sure you want to delete this student?')) {
        mockData.students = mockData.students.filter(s => s.id !== id);
        mockData.stats.totalStudents = mockData.students.filter(s => s.is_active).length;
        
        loadStudentsData();
        document.getElementById('totalStudents').textContent = mockData.stats.totalStudents;
        showNotification('Student deleted successfully!', 'success');
    }
}

function editTeacher(id) {
    showNotification('Teacher edit functionality coming soon!', 'info');
}

function deleteTeacher(id) {
    if (confirm('Are you sure you want to delete this teacher?')) {
        mockData.teachers = mockData.teachers.filter(t => t.id !== id);
        loadTeachersData();
        showNotification('Teacher deleted successfully!', 'success');
    }
}

function editClass(id) {
    showNotification('Class edit functionality coming soon!', 'info');
}

function deleteClass(id) {
    if (confirm('Are you sure you want to delete this class?')) {
        mockData.classes = mockData.classes.filter(c => c.id !== id);
        loadClassesData();
        populateClassDropdowns();
        showNotification('Class deleted successfully!', 'success');
    }
}

function markAttendance(studentId, status) {
    const date = document.getElementById('attendanceDate').value;
    const classId = document.getElementById('attendanceClass').value;
    
    // Find the attendance buttons for this student
    const studentDiv = event.target.closest('.attendance-student');
    const buttons = studentDiv.querySelectorAll('.attendance-btn');
    
    // Remove active class from all buttons
    buttons.forEach(btn => btn.classList.remove('active'));
    
    // Add active class to clicked button
    event.target.classList.add('active');
    
    // In a real app, this would save to database
    console.log(`Marked ${status} for student ${studentId} on ${date}`);
    
    showNotification(`Attendance marked as ${status}`, 'success');
}

// Add CSS for notifications
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);