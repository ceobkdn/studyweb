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
print_status "Setting
