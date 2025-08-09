# Study Progress Tracker - Deployment Guide

Hướng dẫn chuyển đổi và triển khai ứng dụng Python Jupyter thành Java Web Application trên Tomcat 9.

## 📋 Tổng Quan

Dự án này chuyển đổi ứng dụng quản lý tiến độ học tập từ Python/Jupyter sang Java Web Application chạy trên Apache Tomcat 9.

### ✨ Tính Năng Chính

- 📊 Theo dõi tiến độ học tập theo thư mục
- 🎥 Phát video trực tiếp trên web
- 📄 Xem nội dung file (PDF, TXT, CSV, JSON, etc.)
- 🔍 Tìm kiếm và lọc tài liệu
- 📈 Thống kê tiến độ tổng quan
- 💾 Lưu trữ dữ liệu CSV
- 📤 Xuất báo cáo thống kê

## 🏗️ Kiến Trúc Hệ Thống

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Web Browser   │ ──▶│   Tomcat 9       │ ──▶│  Study Materials│
│   (Bootstrap)   │◀──▶│   (Java Web App) │◀──▶│   Directory     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │    CSV Files     │
                       │  (Progress Data) │
                       └──────────────────┘
```

## 📁 Cấu Trúc Thư Mục

```
study-progress-tracker/
├── pom.xml                          # Maven configuration
├── src/
│   ├── main/
│   │   ├── java/com/studytracker/
│   │   │   ├── model/
│   │   │   │   └── StudyProgressModel.java
│   │   │   ├── service/
│   │   │   │   └── StudyProgressService.java
│   │   │   └── servlet/
│   │   │       ├── StudyProgressServlet.java
│   │   │       └── FileUploadServlet.java
│   │   └── webapp/
│   │       ├── index.jsp           # Main interface
│   │       ├── error.jsp           # Error page
│   │       └── WEB-INF/
│   │           └── web.xml         # Web configuration
│   └── test/
├── deploy.sh                       # Deployment script
└── README.md
```

## 🚀 Triển Khai Tự Động

### 1. Chạy Script Triển Khai

```bash
# Download deployment script
wget https://raw.githubusercontent.com/your-repo/deploy.sh

# Make executable
chmod +x deploy.sh

# Run as root
sudo ./deploy.sh
```

Script sẽ tự động:
- ✅ Cài đặt Java 11
- ✅ Cài đặt Apache Tomcat 9
- ✅ Tạo user và cấu hình bảo mật
- ✅ Tạo thư mục tài liệu học tập
- ✅ Cấu hình systemd service
- ✅ Tạo sample data
- ✅ Cấu hình firewall

### 2. Copy Source Code

```bash
# Copy các file Java
cp StudyProgressModel.java /opt/study-tracker-project/src/main/java/com/studytracker/model/
cp StudyProgressService.java /opt/study-tracker-project/src/main/java/com/studytracker/service/
cp StudyProgressServlet.java /opt/study-tracker-project/src/main/java/com/studytracker/servlet/
cp FileUploadServlet.java /opt/study-tracker-project/src/main/java/com/studytracker/servlet/

# Copy các file web
cp index.jsp /opt/study-tracker-project/src/main/webapp/
cp error.jsp /opt/study-tracker-project/src/main/webapp/
cp web.xml /opt/study-tracker-project/src/main/webapp/WEB-INF/
cp pom.xml /opt/study-tracker-project/
```

### 3. Build và Deploy

```bash
cd /opt/study-tracker-project
./build-and-deploy.sh
```

## 🔧 Triển Khai Thủ Công

### Yêu Cầu Hệ Thống

- Ubuntu 18.04+ hoặc CentOS 7+
- RAM: tối thiểu 2GB
- Disk: tối thiểu 5GB trống
- Java 11
- Apache Tomcat 9
- Maven 3.6+

### 1. Cài Đặt Java 11

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y openjdk-11-jdk

# CentOS/RHEL
sudo yum install -y java-11-openjdk-devel
```

### 2. Cài Đặt Tomcat 9

```bash
# Tạo user tomcat
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat

# Download và cài đặt Tomcat
cd /tmp
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.80/bin/apache-tomcat-9.0.80.tar.gz
sudo tar -xf apache-tomcat-9.0.80.tar.gz -C /opt/
sudo mv /opt/apache-tomcat-9.0.80 /opt/tomcat
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh
```

### 3. Cấu Hình Systemd Service

```bash
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable và start service
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
```

### 4. Tạo Thư Mục Học Tập

```bash
# Tạo cấu trúc thư mục
sudo mkdir -p /home/study-materials/{00_Books,01_Lecture_Notes,02_Videos,03_Homework,04_Simulation,05_Reference_Papers,06_Projects,07_Exam,08_Questions}

# Cấp quyền
sudo chown -R tomcat:tomcat /home/study-materials
sudo chmod -R 755 /home/study-materials
```

### 5. Build Project

```bash
# Clone hoặc tạo project
mkdir -p /opt/study-tracker-project
cd /opt/study-tracker-project

# Copy source files (như đã mô tả ở trên)
# ...

# Build với Maven
mvn clean package

# Deploy WAR file
sudo cp target/study-progress-tracker.war /opt/tomcat/webapps/
sudo systemctl restart tomcat
```

## 🌐 Truy Cập Ứng Dụng

### URLs Chính

- **Ứng dụng chính**: http://localhost:8080/study-progress-tracker
- **Tomcat Manager**: http://localhost:8080/manager
- **Admin Console**: http://localhost:8080/host-manager

### Tài Khoản Mặc Định

- **Admin**: admin / admin123
- **User**: study / study123

> ⚠️ **Quan trọng**: Đổi password mặc định trong môi trường production!

## 📊 API Endpoints

| Method | Endpoint | Mô Tả |
|--------|----------|-------|
| GET | `/api/materials` | Lấy danh sách tài liệu |
| GET | `/api/scan` | Quét lại thư mục |
| GET | `/api/stats` | Thống kê tổng quan |
| GET | `/api/directories` | Danh sách thư mục |
| GET | `/api/file-content` | Nội dung file |
| POST | `/api/update-progress` | Cập nhật tiến độ |
| POST | `/api/bulk-update` | Cập nhật hàng loạt |
| POST | `/api/save` | Lưu tiến độ |

## 🔍 Kiểm Tra Và Khắc Phục Sự Cố

### Kiểm Tra Trạng Thái

```bash
# Kiểm tra Tomcat
sudo systemctl status tomcat

# Xem log
sudo tail -f /opt/tomcat/logs/catalina.out

# Kiểm tra port
sudo netstat -tlnp | grep :8080

# Kiểm tra quyền truy cập
ls -la /home/study-materials/
```

### Các Lỗi Thường Gặp

#### 1. Tomcat không khởi động

```bash
# Kiểm tra Java
java -version

# Kiểm tra quyền
sudo chown -R tomcat:tomcat /opt/tomcat

# Khởi động lại
sudo systemctl restart tomcat
```

#### 2. Không truy cập được ứng dụng

```bash
# Kiểm tra firewall
sudo ufw status
sudo ufw allow 8080/tcp

# Kiểm tra WAR file
ls -la /opt/tomcat/webapps/
```

#### 3. Lỗi quyền truy cập file

```bash
# Cấp quyền cho thư mục study materials
sudo chown -R tomcat:tomcat /home/study-materials
sudo chmod -R 755 /home/study-materials
```

### Log Files

- **Tomcat logs**: `/opt/tomcat/logs/`
- **Application logs**: `/opt/tomcat/logs/catalina.out`
- **Access logs**: `/opt/tomcat/logs/localhost_access_log.txt`

## 🔧 Cấu Hình Nâng Cao

### 1. Tăng Memory Heap

Edit `/etc/systemd/system/tomcat.service`:

```ini
Environment="CATALINA_OPTS=-Xms1024M -Xmx2048M -server -XX:+UseG1GC"
```

### 2. Enable HTTPS

Tạo SSL certificate và cấu hình trong `server.xml`:

```xml
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
           maxThreads="150" scheme="https" secure="true"
           keystoreFile="conf/.keystore" keystorePass="password"
           clientAuth="false" sslProtocol="TLS"/>
```

### 3. Database Integration

Thêm dependency vào `pom.xml` để tích hợp database:

```xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.33</version>
</dependency>
```

### 4. Load Balancing với nginx

Cài đặt nginx làm reverse proxy:

```bash
sudo apt install -y nginx

# Cấu hình nginx
sudo tee /etc/nginx/sites-available/study-tracker > /dev/null <<EOF
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:8080/study-progress-tracker/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/study-tracker /etc/nginx/sites-enabled/
sudo systemctl restart nginx
```

## 🔄 Backup và Restore

### Backup Script

```bash
#!/bin/bash
# backup-study-tracker.sh

BACKUP_DIR="/backup/study-tracker"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# Backup study materials
tar -czf $BACKUP_DIR/study-materials-$DATE.tar.gz -C /home study-materials/

# Backup CSV progress files
cp /home/study-materials/learning_progress*.csv $BACKUP_DIR/

# Backup Tomcat webapps
tar -czf $BACKUP_DIR/webapps-$DATE.tar.gz -C /opt/tomcat webapps/

echo "Backup completed: $BACKUP_DIR"
```

### Restore Script

```bash
#!/bin/bash
# restore-study-tracker.sh

BACKUP_FILE=$1
if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup-file>"
    exit 1
fi

# Stop Tomcat
sudo systemctl stop tomcat

# Restore files
tar -xzf $BACKUP_FILE -C /

# Restart Tomcat  
sudo systemctl start tomcat

echo "Restore completed"
```

## 📈 Monitoring và Performance

### 1. JVM Monitoring

Thêm JMX monitoring:

```bash
# Thêm vào CATALINA_OPTS
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port=9999
-Dcom.sun.management.jmxremote.authenticate=false
-Dcom.sun.management.jmxremote.ssl=false
```

### 2. Application Monitoring

```bash
# Script kiểm tra health
#!/bin/bash
# health-check.sh

URL="http://localhost:8080/study-progress-tracker/api/stats"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

if [ $RESPONSE -eq 200 ]; then
    echo "Application is healthy"
    exit 0
else
    echo "Application is down (HTTP: $RESPONSE)"
    exit 1
fi
```

### 3. Log Analysis

```bash
# Phân tích access log
tail -f /opt/tomcat/logs/localhost_access_log.$(date +%Y-%m-%d).txt | grep -E "(ERROR|WARN)"

# Theo dõi memory usage
while true; do
    free -h
    sleep 5
done
```

## 🔐 Bảo Mật

### 1. Hardening Tomcat

```xml
<!-- server.xml - Ẩn version info -->
<Connector port="8080" protocol="HTTP/1.1"
           connectionTimeout="20000"
           redirectPort="8443"
           server="Apache" />

<!-- Disable shutdown port -->
<Server port="-1" shutdown="SHUTDOWN">
```

### 2. File Permissions

```bash
# Secure Tomcat files
sudo find /opt/tomcat -type f -name "*.sh" -exec chmod 750 {} \;
sudo find /opt/tomcat -type d -exec chmod 750 {} \;
sudo chmod -R 640 /opt/tomcat/conf/*
sudo chmod 750 /opt/tomcat/conf
```

### 3. User Authentication

Cấu hình LDAP hoặc database authentication trong `web.xml`:

```xml
<security-constraint>
    <web-resource-collection>
        <web-resource-name>Protected Area</web-resource-name>
        <url-pattern>/api/*</url-pattern>
    </web-resource-collection>
    <auth-constraint>
        <role-name>user</role-name>
    </auth-constraint>
</security-constraint>
```

## 📱 Mobile Responsive

Ứng dụng đã được tối ưu cho mobile với Bootstrap 5:

- ✅ Responsive design
- ✅ Touch-friendly interface  
- ✅ Mobile navigation
- ✅ Optimized media player

## 🌍 Internationalization

Để hỗ trợ đa ngôn ngữ, thêm vào `web.xml`:

```xml
<context-param>
    <param-name>javax.servlet.jsp.jstl.fmt.localizationContext</param-name>
    <param-value>messages</param-value>
</context-param>
```

Tạo file properties:
- `messages_vi.properties` (tiếng Việt)
- `messages_en.properties` (English)

## 🧪 Testing

### Unit Testing

```bash
# Chạy tests
mvn test

# Test coverage
mvn jacoco:report
```

### Integration Testing

```bash
# Test API endpoints
curl -X GET http://localhost:8080/study-progress-tracker/api/stats
curl -X POST -d "path=test.txt&progress=50" http://localhost:8080/study-progress-tracker/api/update-progress
```

### Load Testing

```bash
# Sử dụng Apache Bench
ab -n 1000 -c 10 http://localhost:8080/study-progress-tracker/

# Sử dụng curl
for i in {1..100}; do
    curl -s http://localhost:8080/study-progress-tracker/ > /dev/null
done
```

## 📞 Hỗ Trợ

### Thông Tin Liên Hệ

- 📧 Email: support@studytracker.com
- 📱 Hotline: +84 xxx-xxx-xxx
- 🌐 Website: https://studytracker.com

### Tài Liệu Tham Khảo

- [Apache Tomcat Documentation](https://tomcat.apache.org/tomcat-9.0-doc/)
- [Maven Documentation](https://maven.apache.org/guides/)
- [Bootstrap Documentation](https://getbootstrap.com/docs/)
- [Java Servlet Specification](https://javaee.github.io/servlet-spec/)

## 📝 Changelog

### Version 1.0.0 (2024-01-15)
- ✅ Initial release
- ✅ Basic progress tracking
- ✅ File viewer integration
- ✅ Video player support

### Version 1.1.0 (Planning)
- 🔄 Database integration
- 🔄 User management
- 🔄 Real-time notifications
- 🔄 Advanced reporting

## 📄 License

This project is licensed under the MIT License. See LICENSE file for details.

## 🙏 Acknowledgments

- Apache Tomcat team
- Bootstrap contributors
- OpenCSV library
- Jackson JSON library

---

**Happy Learning! 🎓**

> Nếu bạn gặp bất kỳ vấn đề nào trong quá trình triển khai, vui lòng tham khảo phần "Kiểm Tra Và Khắc Phục Sự Cố" hoặc tạo issue trên GitHub repository.
