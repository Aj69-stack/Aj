#!/bin/bash

# School Management System Database Setup Script
# This script helps you set up the MySQL database for the school management system

echo "=========================================="
echo "School Management System Database Setup"
echo "=========================================="

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if MySQL is installed
check_mysql() {
    if ! command -v mysql &> /dev/null; then
        print_error "MySQL is not installed or not in PATH"
        echo "Please install MySQL first:"
        echo "  Ubuntu/Debian: sudo apt-get install mysql-server"
        echo "  CentOS/RHEL: sudo yum install mysql-server"
        echo "  macOS: brew install mysql"
        exit 1
    fi
    print_status "MySQL found"
}

# Check if schema file exists
check_schema_file() {
    if [ ! -f "school_management_schema.sql" ]; then
        print_error "Schema file 'school_management_schema.sql' not found"
        echo "Please ensure the schema file is in the current directory"
        exit 1
    fi
    print_status "Schema file found"
}

# Get MySQL credentials
get_credentials() {
    echo ""
    echo "Please provide MySQL connection details:"
    read -p "MySQL Host (default: localhost): " MYSQL_HOST
    MYSQL_HOST=${MYSQL_HOST:-localhost}
    
    read -p "MySQL Root Username (default: root): " MYSQL_USER
    MYSQL_USER=${MYSQL_USER:-root}
    
    read -s -p "MySQL Root Password: " MYSQL_PASSWORD
    echo ""
    
    read -p "Database Name (default: school_management): " DB_NAME
    DB_NAME=${DB_NAME:-school_management}
}

# Test MySQL connection
test_connection() {
    print_status "Testing MySQL connection..."
    if mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" &> /dev/null; then
        print_status "MySQL connection successful"
    else
        print_error "Failed to connect to MySQL"
        echo "Please check your credentials and try again"
        exit 1
    fi
}

# Create database if it doesn't exist
create_database() {
    print_status "Creating database '$DB_NAME' if it doesn't exist..."
    mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_status "Database '$DB_NAME' is ready"
    else
        print_error "Failed to create database"
        exit 1
    fi
}

# Import schema
import_schema() {
    print_status "Importing database schema..."
    mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" < school_management_schema.sql
    if [ $? -eq 0 ]; then
        print_status "Schema imported successfully"
    else
        print_error "Failed to import schema"
        exit 1
    fi
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Count tables
    TABLE_COUNT=$(mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" -e "SHOW TABLES;" 2>/dev/null | wc -l)
    TABLE_COUNT=$((TABLE_COUNT - 1)) # Subtract header row
    
    if [ $TABLE_COUNT -gt 0 ]; then
        print_status "Found $TABLE_COUNT tables in the database"
        
        # Show some sample data
        echo ""
        echo "Sample system settings:"
        mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" -e "SELECT setting_key, setting_value FROM system_settings LIMIT 5;" 2>/dev/null
        
        echo ""
        echo "Default exam types:"
        mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" -e "SELECT type_name, description FROM exam_types;" 2>/dev/null
        
    else
        print_error "No tables found. Installation may have failed."
        exit 1
    fi
}

# Create sample admin user
create_admin_user() {
    echo ""
    read -p "Would you like to create a sample admin user? (y/n): " CREATE_ADMIN
    
    if [[ $CREATE_ADMIN =~ ^[Yy]$ ]]; then
        read -p "Admin username (default: admin): " ADMIN_USERNAME
        ADMIN_USERNAME=${ADMIN_USERNAME:-admin}
        
        read -p "Admin email (default: admin@school.edu): " ADMIN_EMAIL
        ADMIN_EMAIL=${ADMIN_EMAIL:-admin@school.edu}
        
        read -s -p "Admin password: " ADMIN_PASSWORD
        echo ""
        
        if [ -z "$ADMIN_PASSWORD" ]; then
            print_warning "Password cannot be empty. Skipping admin user creation."
            return
        fi
        
        # Hash password (simple method - in production, use proper password hashing)
        HASHED_PASSWORD=$(echo -n "$ADMIN_PASSWORD" | sha256sum | cut -d' ' -f1)
        
        # Insert admin user
        mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$DB_NAME" -e "
        INSERT INTO users (username, email, password_hash, role) 
        VALUES ('$ADMIN_USERNAME', '$ADMIN_EMAIL', '$HASHED_PASSWORD', 'admin')
        ON DUPLICATE KEY UPDATE 
        email = '$ADMIN_EMAIL', 
        password_hash = '$HASHED_PASSWORD';" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            print_status "Admin user created successfully"
            echo "  Username: $ADMIN_USERNAME"
            echo "  Email: $ADMIN_EMAIL"
            print_warning "Note: This uses simple SHA256 hashing. Use proper password hashing in production!"
        else
            print_error "Failed to create admin user"
        fi
    fi
}

# Show connection info
show_connection_info() {
    echo ""
    echo "=========================================="
    echo "Database Setup Complete!"
    echo "=========================================="
    echo "Database Details:"
    echo "  Host: $MYSQL_HOST"
    echo "  Database: $DB_NAME"
    echo "  Tables: $TABLE_COUNT"
    echo ""
    echo "Connection String Examples:"
    echo ""
    echo "PHP (PDO):"
    echo "  \$pdo = new PDO('mysql:host=$MYSQL_HOST;dbname=$DB_NAME', 'username', 'password');"
    echo ""
    echo "Node.js (mysql2):"
    echo "  const connection = mysql.createConnection({"
    echo "    host: '$MYSQL_HOST',"
    echo "    database: '$DB_NAME',"
    echo "    user: 'username',"
    echo "    password: 'password'"
    echo "  });"
    echo ""
    echo "Python (pymysql):"
    echo "  connection = pymysql.connect(host='$MYSQL_HOST', database='$DB_NAME', user='username', password='password')"
    echo ""
    echo "Next Steps:"
    echo "1. Review the README.md file for detailed documentation"
    echo "2. Set up your web application to connect to the database"
    echo "3. Create additional users, departments, and classes as needed"
    echo "4. Configure your application's authentication system"
    echo ""
    print_status "Setup completed successfully!"
}

# Main execution
main() {
    check_mysql
    check_schema_file
    get_credentials
    test_connection
    create_database
    import_schema
    verify_installation
    create_admin_user
    show_connection_info
}

# Run the main function
main