#!/bin/bash

# Study Progress Tracker Deployment Script for Ubuntu with Tomcat 9
# Run with: sudo bash deploy.sh

set -e  # Exit on any error

echo "🚀 Starting deployment of Study Progress Tracker on Ubuntu with Tomcat 9..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TOMCAT_VERSION="9.0.80"
JAVA_VERSION="11"
APP_NAME="study-progress-tracker"
TOMCAT_USER="tomcat"
STUDY_MATERIALS_DIR="/home/study-materials"
TOMCAT_HOME="/opt/tomcat"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

# Update system packages
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install Java 11
print_status "Installing OpenJDK 11..."
apt install -y openjdk-11-jdk

# Verify Java installation
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
print_success "Java installed at: $JAVA_HOME"

# Create tomcat user
print_status "Creating tomcat user..."
if ! id "$TOMCAT_USER" &>/dev/null; then
    useradd -m -U -d /opt/tomcat -s /bin/false tomcat
    print_success "Tomcat user created"
else
    print_warning "Tomcat user already exists"
fi

# Download and install Tomcat 9
print_status "Downloading Apache Tomcat $TOMCAT_VERSION..."
cd /tmp
if [ ! -f "apache-tomcat-$TOMCAT_VERSION.tar.gz" ]; then
    wget https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
fi

print_status "Installing Tomcat..."
if [ -d "$TOMCAT_HOME" ]; then
    print_warning "Tomcat directory exists, backing up..."
    mv $TOMCAT_HOME ${TOMCAT_HOME}_backup_$(date +%Y%m%d_%H%M%S)
fi

tar -xf apache-tomcat-$TOMCAT_VERSION.tar.gz -C /opt/
mv /opt/apache-tomcat-$TOMCAT_VERSION $TOMCAT_HOME

# Set permissions
print_status "Setting Tomcat permissions..."
chown -R tomcat:tomcat $TOMCAT_HOME
chmod +x $TOMCAT_HOME/bin/*.sh

# Create study materials directory
print_status "Creating study materials directory..."
mkdir -p $STUDY_MATERIALS_DIR

# Create sample directory structure
print_status "Creating sample learning directory structure..."
mkdir -p $STUDY_MATERIALS_DIR/{00_Books,01_Lecture_Notes,02_Videos,03_Homework,04_Simulation,05_Reference_Papers,06_Projects,07_Exam,08_Questions}

# Set permissions for study materials
chown -R tomcat:tomcat $STUDY_MATERIALS_DIR
chmod -R 755 $STUDY_MATERIALS_DIR

# Install Maven
print_status "Installing Maven..."
apt install -y maven

# Create Tomcat systemd service
print_status "Creating Tomcat systemd service..."
cat > /etc/systemd/system/tomcat.service << 'EOL'
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Configure Tomcat users
print_status "Configuring Tomcat users..."
cat > $TOMCAT_HOME/conf/tomcat-users.xml << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <role rolename="admin-gui"/>
  <role rolename="user"/>
  
  <user username="admin" password="admin123" roles="manager-gui,admin-gui"/>
  <user username="study" password="study123" roles="user"/>
</tomcat-users>
EOL

# Configure manager app access
print_status "Configuring manager app access..."
mkdir -p $TOMCAT_HOME/webapps/manager/META-INF
cat > $TOMCAT_HOME/webapps/manager/META-INF/context.xml << 'EOL'
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true">
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.0\.0\.1|::1|0:0:0:0:0:0:0:1|.*" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$(?:1|2))?|java\.util\.(?:Linked)?HashMap"/>
</Context>
EOL

# Set proper ownership
chown -R tomcat:tomcat $TOMCAT_HOME

# Reload systemd and start Tomcat
print_status "Starting Tomcat service..."
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

# Wait for Tomcat to start
print_status "Waiting for Tomcat to start..."
sleep 10

# Check if Tomcat is running
if systemctl is-active --quiet tomcat; then
    print_success "Tomcat is running successfully"
else
    print_error "Tomcat failed to start"
    systemctl status tomcat
    exit 1
fi

# Install additional dependencies
print_status "Installing additional dependencies..."
apt install -y unzip wget curl

# Create project directory
print_status "Setting up project directory..."
PROJECT_DIR="/opt/study-tracker-project"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

# Create the Maven project structure if not exists
if [ ! -f "pom.xml" ]; then
    print_status "Creating Maven project structure..."
    
    # Create directory structure
    mkdir -p src/main/java/com/studytracker/{model,service,servlet}
    mkdir -p src/main/webapp/{WEB-INF,css,js,images}
    mkdir -p src/main/resources
    
    print_warning "Please copy your Java source files to the appropriate directories:"
    print_warning "  - Model classes: src/main/java/com/studytracker/model/"
    print_warning "  - Service classes: src/main/java/com/studytracker/service/"
    print_warning "  - Servlet classes: src/main/java/com/studytracker/servlet/"
    print_warning "  - JSP files: src/main/webapp/"
    print_warning "  - web.xml: src/main/webapp/WEB-INF/"
    print_warning "  - pom.xml: project root"
    
    print_status "Creating sample README.md for project structure..."
    cat > README.md << 'EOL'
# Study Progress Tracker

## Project Structure
```
study-tracker-project/
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/studytracker/
│   │   │       ├── model/
│   │   │       │   └── StudyProgressModel.java
│   │   │       ├── service/
│   │   │       │   └── StudyProgressService.java
│   │   │       └── servlet/
│   │   │           ├── StudyProgressServlet.java
│   │   │           └── FileUploadServlet.java
│   │   ├── webapp/
│   │   │   ├── index.jsp
│   │   │   ├── error.jsp
│   │   │   └── WEB-INF/
│   │   │       └── web.xml
│   │   └── resources/
│   └── test/
└── target/
```

## Building and Deployment
1. Copy source files to appropriate directories
2. Run: mvn clean package
3. Deploy: cp target/*.war /opt/tomcat/webapps/
4. Access: http://localhost:8080/study-progress-tracker

## Study Materials Directory
- Location: /home/study-materials/
- Structure:
  - 00_Books/ (📚 Giáo trình)
  - 01_Lecture_Notes/ (📝 Ghi chú bài giảng)
  - 02_Videos/ (🎥 Video bài giảng)
  - 03_Homework/ (📋 Bài tập về nhà)
  - 04_Simulation/ (🔬 Mô phỏng)
  - 05_Reference_Papers/ (📄 Tài liệu tham khảo)
  - 06_Projects/ (🚀 Dự án)
  - 07_Exam/ (📝 Bài thi)
  - 08_Questions/ (❓ Một số câu hỏi)
EOL

fi

# Set ownership
chown -R tomcat:tomcat $PROJECT_DIR

# Create build script
print_status "Creating build and deploy script..."
cat > $PROJECT_DIR/build-and-deploy.sh << 'EOL'
#!/bin/bash

echo "🔨 Building Study Progress Tracker..."

# Change to project directory
cd /opt/study-tracker-project

# Clean and build
mvn clean package -DskipTests

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Stop Tomcat
    echo "🛑 Stopping Tomcat..."
    systemctl stop tomcat
    
    # Remove old deployment
    rm -rf /opt/tomcat/webapps/study-progress-tracker*
    
    # Deploy new WAR
    echo "🚀 Deploying application..."
    cp target/study-progress-tracker.war /opt/tomcat/webapps/
    
    # Start Tomcat
    echo "▶️ Starting Tomcat..."
    systemctl start tomcat
    
    echo "✅ Deployment completed!"
    echo "🌐 Access the application at: http://localhost:8080/study-progress-tracker"
else
    echo "❌ Build failed!"
    exit 1
fi
EOL

chmod +x $PROJECT_DIR/build-and-deploy.sh

# Create sample files upload script
print_status "Creating sample study materials..."
cat > $PROJECT_DIR/create-sample-materials.sh << 'EOL'
#!/bin/bash

echo "📚 Creating sample study materials..."

MATERIALS_DIR="/home/study-materials"

# Create sample files in each directory
echo "Sample Textbook Content" > $MATERIALS_DIR/00_Books/sample_textbook.txt
echo "Lecture Notes Content" > $MATERIALS_DIR/01_Lecture_Notes/lecture_01.md
echo "# Python Basics\nprint('Hello World')" > $MATERIALS_DIR/01_Lecture_Notes/python_basics.py
echo "Homework Assignment 1" > $MATERIALS_DIR/03_Homework/assignment_01.txt
echo "import pandas as pd\ndf = pd.DataFrame()" > $MATERIALS_DIR/04_Simulation/data_analysis.py
echo "Research Paper Abstract" > $MATERIALS_DIR/05_Reference_Papers/research_paper.txt
echo "Final Project Documentation" > $MATERIALS_DIR/06_Projects/final_project.md
echo "Exam Questions and Answers" > $MATERIALS_DIR/07_Exam/midterm_exam.txt
echo "Q: What is Java?\nA: Programming language" > $MATERIALS_DIR/08_Questions/java_questions.txt

# Create a simple HTML file
cat > $MATERIALS_DIR/01_Lecture_Notes/web_development.html << 'HTMLEOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Development Basics</title>
</head>
<body>
    <h1>Welcome to Web Development</h1>
    <p>This is a sample HTML file for demonstration.</p>
</body>
</html>
HTMLEOF

# Create a simple CSV file
cat > $MATERIALS_DIR/04_Simulation/student_grades.csv << 'CSVEOF'
Name,Subject,Grade
John Doe,Math,85
Jane Smith,Physics,92
Bob Johnson,Chemistry,78
Alice Brown,Biology,95
CSVEOF

# Create a JSON file
cat > $MATERIALS_DIR/05_Reference_Papers/data.json << 'JSONEOF'
{
  "students": [
    {"name": "John", "age": 20, "major": "Computer Science"},
    {"name": "Jane", "age": 21, "major": "Mathematics"},
    {"name": "Bob", "age": 19, "major": "Physics"}
  ],
  "total_count": 3
}
JSONEOF

# Set proper permissions
chown -R tomcat:tomcat $MATERIALS_DIR
chmod -R 644 $MATERIALS_DIR/*
chmod -R 755 $MATERIALS_DIR/*/

echo "✅ Sample materials created successfully!"
EOL

chmod +x $PROJECT_DIR/create-sample-materials.sh

# Run the sample materials creation script
$PROJECT_DIR/create-sample-materials.sh

# Configure firewall
print_status "Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 8080/tcp
    ufw allow 22/tcp
    print_success "Firewall configured to allow Tomcat (port 8080) and SSH (port 22)"
else
    print_warning "UFW not installed. Please manually configure firewall to allow port 8080"
fi

# Create monitoring script
print_status "Creating monitoring script..."
cat > /usr/local/bin/tomcat-monitor.sh << 'EOL'
#!/bin/bash

# Tomcat monitoring script
TOMCAT_HOME="/opt/tomcat"
LOG_FILE="/var/log/tomcat-monitor.log"

check_tomcat() {
    if systemctl is-active --quiet tomcat; then
        echo "$(date): Tomcat is running" >> $LOG_FILE
        return 0
    else
        echo "$(date): Tomcat is not running, attempting restart" >> $LOG_FILE
        systemctl start tomcat
        sleep 10
        if systemctl is-active --quiet tomcat; then
            echo "$(date): Tomcat restarted successfully" >> $LOG_FILE
        else
            echo "$(date): Failed to restart Tomcat" >> $LOG_FILE
        fi
        return 1
    fi
}

check_tomcat
EOL

chmod +x /usr/local/bin/tomcat-monitor.sh

# Add cron job for monitoring
print_status "Setting up Tomcat monitoring cron job..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/tomcat-monitor.sh") | crontab -

# Create log rotation
print_status "Setting up log rotation..."
cat > /etc/logrotate.d/tomcat << 'EOL'
/opt/tomcat/logs/*.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 0644 tomcat tomcat
    postrotate
        systemctl reload tomcat > /dev/null 2>&1 || true
    endscript
}
EOL

# Final status check
print_status "Performing final status check..."
sleep 5

if systemctl is-active --quiet tomcat; then
    TOMCAT_STATUS="✅ Running"
else
    TOMCAT_STATUS="❌ Not Running"
fi

# Display deployment summary
echo ""
echo "==================== DEPLOYMENT SUMMARY ===================="
print_success "Study Progress Tracker deployment completed!"
echo ""
echo "📋 Configuration Summary:"
echo "  • Java Version: $(java -version 2>&1 | head -n1)"
echo "  • Tomcat Home: $TOMCAT_HOME"
echo "  • Tomcat Status: $TOMCAT_STATUS"
echo "  • Study Materials: $STUDY_MATERIALS_DIR"
echo "  • Project Directory: $PROJECT_DIR"
echo ""
echo "🌐 Access Information:"
echo "  • Tomcat Manager: http://localhost:8080/manager"
echo "    - Username: admin"
echo "    - Password: admin123"
echo "  • Application URL: http://localhost:8080/study-progress-tracker"
echo ""
echo "📁 Important Directories:"
echo "  • Tomcat Logs: $TOMCAT_HOME/logs/"
echo "  • Application Logs: $TOMCAT_HOME/logs/catalina.out"
echo "  • Study Materials: $STUDY_MATERIALS_DIR"
echo "  • Project Source: $PROJECT_DIR"
echo ""
echo "🔧 Useful Commands:"
echo "  • Check Tomcat status: systemctl status tomcat"
echo "  • Restart Tomcat: systemctl restart tomcat"
echo "  • View logs: tail -f $TOMCAT_HOME/logs/catalina.out"
echo "  • Build and deploy: cd $PROJECT_DIR && ./build-and-deploy.sh"
echo ""
echo "📝 Next Steps:"
echo "  1. Copy your Java source files to $PROJECT_DIR/src/main/java/"
echo "  2. Copy your JSP files to $PROJECT_DIR/src/main/webapp/"
echo "  3. Copy your web.xml to $PROJECT_DIR/src/main/webapp/WEB-INF/"
echo "  4. Copy your pom.xml to $PROJECT_DIR/"
echo "  5. Run: cd $PROJECT_DIR && ./build-and-deploy.sh"
echo ""
print_warning "SECURITY NOTE: Please change default passwords in production!"
echo "=============================================================="

# Create a quick start guide
cat > $PROJECT_DIR/QUICKSTART.md << 'EOL'
# Quick Start Guide

## 1. Copy Source Files
Copy the provided Java files to their respective directories:
```bash
# Copy model files
cp StudyProgressModel.java /opt/study-tracker-project/src/main/java/com/studytracker/model/

# Copy service files  
cp StudyProgressService.java /opt/study-tracker-project/src/main/java/com/studytracker/service/

# Copy servlet files
cp StudyProgressServlet.java /opt/study-tracker-project/src/main/java/com/studytracker/servlet/
cp FileUploadServlet.java /opt/study-tracker-project/src/main/java/com/studytracker/servlet/

# Copy web files
cp index.jsp /opt/study-tracker-project/src/main/webapp/
cp web.xml /opt/study-tracker-project/src/main/webapp/WEB-INF/
cp pom.xml /opt/study-tracker-project/
```

## 2. Build and Deploy
```bash
cd /opt/study-tracker-project
./build-and-deploy.sh
```

## 3. Access Application
Open browser and navigate to:
http://localhost:8080/study-progress-tracker

## 4. Troubleshooting
- Check Tomcat status: `systemctl status tomcat`
- View logs: `tail -f /opt/tomcat/logs/catalina.out`
- Check permissions: `ls -la /home/study-materials/`
- Restart services: `systemctl restart tomcat`

## 5. Adding Study Materials
- Upload files to appropriate directories in `/home/study-materials/`
- Use the web interface to scan and track progress
- Supported formats: PDF, DOC, TXT, MD, MP4, AVI, CSV, JSON, etc.
EOL

print_success "Deployment script completed successfully!"
print_status "Check $PROJECT_DIR/QUICKSTART.md for next steps."
