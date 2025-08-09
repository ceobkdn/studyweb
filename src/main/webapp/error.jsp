<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lỗi - Study Progress Tracker</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .error-container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 600px;
        }
        .error-code {
            font-size: 6rem;
            font-weight: bold;
            color: #dc3545;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.1);
        }
        .error-title {
            color: #2e86ab;
            margin: 20px 0;
        }
        .error-message {
            color: #666;
            margin: 20px 0;
            line-height: 1.6;
        }
        .btn-home {
            background: linear-gradient(135deg, #2e86ab 0%, #764ba2 100%);
            border: none;
            padding: 12px 30px;
            border-radius: 25px;
            color: white;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        .btn-home:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(46, 134, 171, 0.3);
            color: white;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <%
            String errorCode = "500";
            String errorTitle = "Lỗi Hệ Thống";
            String errorMessage = "Đã xảy ra lỗi không mong muốn. Vui lòng thử lại sau.";
            
            if (response.getStatus() == 404) {
                errorCode = "404";
                errorTitle = "Không Tìm Thấy Trang";
                errorMessage = "Trang bạn đang tìm kiếm không tồn tại hoặc đã bị di chuyển.";
            } else if (response.getStatus() == 403) {
                errorCode = "403";
                errorTitle = "Truy Cập Bị Từ Chối";
                errorMessage = "Bạn không có quyền truy cập vào trang này.";
            }
        %>
        
        <div class="error-code"><%= errorCode %></div>
        <h2 class="error-title">😵 <%= errorTitle %></h2>
        <p class="error-message"><%= errorMessage %></p>
        
        <% if (exception != null) { %>
            <div class="alert alert-danger mt-3" role="alert">
                <strong>Chi tiết lỗi:</strong><br>
                <%= exception.getClass().getSimpleName() %>: <%= exception.getMessage() %>
            </div>
        <% } %>
        
        <div class="mt-4">
            <a href="${pageContext.request.contextPath}/" class="btn-home">
                🏠 Về Trang Chủ
            </a>
        </div>
        
        <div class="mt-4 text-muted">
            <small>
                Nếu vấn đề vẫn tiếp tục, vui lòng liên hệ quản trị viên hệ thống.
            </small>
        </div>
    </div>
</body>
</html>
