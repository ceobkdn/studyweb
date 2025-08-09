<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🎓 Hệ Thống Quản Lý Tiến Độ Học Tập</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    
    <style>
        :root {
            --primary-color: #2e86ab;
            --success-color: #28a745;
            --warning-color: #ffc107;
            --danger-color: #dc3545;
            --info-color: #17a2b8;
        }
        
        body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        .header-gradient {
            background: linear-gradient(135deg, var(--primary-color) 0%, #764ba2 100%);
            color: white;
            padding: 30px 0;
            margin-bottom: 30px;
            border-radius: 0 0 20px 20px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        }
        
        .stats-card {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin: 15px 0;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        
        .stats-card:hover {
            transform: translateY(-5px);
        }
        
        .progress-bar {
            height: 25px;
            border-radius: 12px;
            transition: width 0.5s ease;
        }
        
        .file-item {
            background: white;
            border: 1px solid #e0e0e0;
            border-radius: 10px;
            padding: 15px;
            margin: 10px 0;
            transition: all 0.3s ease;
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }
        
        .file-item:hover {
            border-color: var(--primary-color);
            box-shadow: 0 5px 15px rgba(46, 134, 171, 0.1);
        }
        
        .control-panel {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin: 20px 0;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .btn-custom {
            border-radius: 25px;
            padding: 10px 25px;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .btn-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        
        .video-container {
            background: white;
            border-radius: 15px;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .loading-spinner {
            display: none;
            text-align: center;
            padding: 50px;
        }
        
        .message {
            padding: 15px;
            border-radius: 10px;
            margin: 15px 0;
            border: none;
            font-weight: 500;
        }
        
        .message.success {
            background: rgba(40, 167, 69, 0.1);
            color: var(--success-color);
            border-left: 4px solid var(--success-color);
        }
        
        .message.error {
            background: rgba(220, 53, 69, 0.1);
            color: var(--danger-color);
            border-left: 4px solid var(--danger-color);
        }
        
        .message.info {
            background: rgba(23, 162, 184, 0.1);
            color: var(--info-color);
            border-left: 4px solid var(--info-color);
        }
        
        .folder-tab {
            background: white;
            border-radius: 15px;
            padding: 25px;
            margin: 20px 0;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        .media-viewer {
            background: white;
            border-radius: 15px;
            padding: 20px;
            margin: 20px 0;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            min-height: 300px;
        }
        
        .nav-tabs .nav-link {
            border-radius: 15px 15px 0 0;
            border: none;
            background: #f8f9fa;
            margin-right: 5px;
            transition: all 0.3s ease;
        }
        
        .nav-tabs .nav-link.active {
            background: var(--primary-color);
            color: white;
        }
        
        @media (max-width: 768px) {
            .control-panel .row {
                flex-direction: column;
            }
            
            .control-panel .col-md-3,
            .control-panel .col-md-2 {
                margin: 10px 0;
            }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <div class="header-gradient">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-8">
                    <h1 class="mb-0">🎓 Hệ Thống Quản Lý Tiến Độ Học Tập</h1>
                    <p class="mb-0 mt-2 opacity-75">Theo dõi và quản lý hiệu quả quá trình học tập của bạn</p>
                </div>
                <div class="col-md-4 text-end">
                    <div id="overall-progress-text"></div>
                    <div class="progress mt-2" style="height: 25px;">
                        <div id="overall-progress-bar" class="progress-bar bg-success" 
                             role="progressbar" style="width: 0%"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container">
        <!-- Control Panel -->
        <div class="control-panel">
            <h4 class="text-primary mb-3">🔧 ĐIỀU KHIỂN</h4>
            <div class="row align-items-end">
                <div class="col-md-3">
                    <label for="search-box" class="form-label">🔍 Tìm kiếm tài liệu:</label>
                    <input type="text" id="search-box" class="form-control" 
                           placeholder="Nhập tên tài liệu...">
                </div>
                <div class="col-md-3">
                    <label for="folder-filter" class="form-label">📁 Thư mục:</label>
                    <select id="folder-filter" class="form-select">
                        <option value="all">Tất cả thư mục</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <label for="progress-filter" class="form-label">📊 Trạng thái:</label>
                    <select id="progress-filter" class="form-select">
                        <option value="all">Tất cả</option>
                        <option value="0">Chưa bắt đầu (0%)</option>
                        <option value="partial">Đang thực hiện (1-99%)</option>
                        <option value="100">Đã hoàn thành (100%)</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <div class="btn-group" role="group">
                        <button id="rescan-btn" class="btn btn-info btn-custom">
                            <i class="fas fa-sync-alt"></i> Quét lại
                        </button>
                        <button id="save-btn" class="btn btn-success btn-custom">
                            <i class="fas fa-save"></i> Lưu
                        </button>
                        <button id="export-btn" class="btn btn-warning btn-custom">
                            <i class="fas fa-chart-bar"></i> Thống kê
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Loading Spinner -->
        <div id="loading-spinner" class="loading-spinner">
            <div class="spinner-border text-primary" role="status" style="width: 3rem; height: 3rem;">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-3 text-primary">Đang tải dữ liệu...</p>
        </div>

        <!-- Messages -->
        <div id="message-container"></div>

        <!-- Main Content Tabs -->
        <ul class="nav nav-tabs" id="main-tabs">
            <li class="nav-item">
                <a class="nav-link active" id="overview-tab" data-bs-toggle="tab" href="#overview">
                    📈 Tổng quan
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="search-tab" data-bs-toggle="tab" href="#search">
                    🔍 Tìm kiếm
                </a>
            </li>
        </ul>

        <div class="tab-content" id="main-tab-content">
            <!-- Overview Tab -->
            <div class="tab-pane fade show active" id="overview">
                <div class="folder-tab">
                    <div id="overview-content">
                        <!-- Overview content will be loaded here -->
                    </div>
                </div>
            </div>

            <!-- Search Tab -->
            <div class="tab-pane fade" id="search">
                <div class="folder-tab">
                    <div id="search-results">
                        <!-- Search results will be loaded here -->
                    </div>
                </div>
            </div>
        </div>

        <!-- Dynamic Folder Tabs will be added here -->
        <div id="folder-tabs-container"></div>

        <!-- Media Viewer -->
        <div class="media-viewer" id="media-viewer" style="display: none;">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h5 class="text-primary mb-0">📱 Media Viewer</h5>
                <button class="btn btn-sm btn-outline-secondary" onclick="closeMediaViewer()">
                    <i class="fas fa-times"></i> Đóng
                </button>
            </div>
            <div id="media-content">
                <!-- Media content will be loaded here -->
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <script>
        // Global variables
        let currentMaterials = [];
        let folderTabs = {};
        let currentMediaPath = null;

        // Initialize application
        document.addEventListener('DOMContentLoaded', function() {
            initializeApp();
            setupEventListeners();
        });

        async function initializeApp() {
            showLoading(true);
            try {
                await loadDirectories();
                await loadMaterials();
                await loadStats();
                updateOverview();
                showMessage('🎓 Hệ thống đã sẵn sàng!', 'success');
            } catch (error) {
                showMessage('❌ Lỗi khi khởi tạo: ' + error.message, 'error');
            } finally {
                showLoading(false);
            }
        }

        function setupEventListeners() {
            // Search and filter events
            document.getElementById('search-box').addEventListener('input', debounce(onSearchChange, 300));
            document.getElementById('folder-filter').addEventListener('change', onFilterChange);
            document.getElementById('progress-filter').addEventListener('change', onFilterChange);
            
            // Button events
            document.getElementById('rescan-btn').addEventListener('click', onRescan);
            document.getElementById('save-btn').addEventListener('click', onSave);
            document.getElementById('export-btn').addEventListener('click', onExport);
            
            // Tab events
            document.getElementById('search-tab').addEventListener('click', updateSearchResults);
        }

        async function loadDirectories() {
            const response = await fetch('/api/directories');
            const data = await response.json();
            
            const folderFilter = document.getElementById('folder-filter');
            Object.entries(data.directories).forEach(([key, value]) => {
                const option = document.createElement('option');
                option.value = key;
                option.textContent = value;
                folderFilter.appendChild(option);
            });
        }

        async function loadMaterials() {
            const response = await fetch('/api/materials');
            const data = await response.json();
            currentMaterials = data.materials;
            
            // Create folder tabs
            createFolderTabs();
        }

        async function loadStats() {
            const response = await fetch('/api/stats');
            const data = await response.json();
            
            updateOverallProgress(data.overall);
            updateOverviewStats(data.overall, data.folders);
        }

        function createFolderTabs() {
            const foldersData = {};
            currentMaterials.forEach(material => {
                if (!foldersData[material.folderName]) {
                    foldersData[material.folderName] = {
                        desc: material.folderDesc,
                        materials: []
                    };
                }
                foldersData[material.folderName].materials.push(material);
            });

            // Add folder tabs to navigation
            const tabsNav = document.getElementById('main-tabs');
            const tabsContent = document.getElementById('main-tab-content');
            
            Object.entries(foldersData).forEach(([folderName, folderData]) => {
                // Create nav tab
                const navItem = document.createElement('li');
                navItem.className = 'nav-item';
                navItem.innerHTML = `
                    <a class="nav-link" id="${folderName}-tab" data-bs-toggle="tab" href="#${folderName}">
                        ${folderData.desc}
                    </a>
                `;
                tabsNav.appendChild(navItem);
                
                // Create tab content
                const tabPane = document.createElement('div');
                tabPane.className = 'tab-pane fade';
                tabPane.id = folderName;
                tabPane.innerHTML = `
                    <div class="folder-tab">
                        <div id="${folderName}-content">
                            ${createFolderContent(folderName, folderData.materials)}
                        </div>
                    </div>
                `;
                tabsContent.appendChild(tabPane);
            });
        }

        function createFolderContent(folderName, materials) {
            if (materials.length === 0) {
                return `<p class="text-center text-muted">📂 Chưa có tài liệu nào trong thư mục này</p>`;
            }

            // Folder stats
            const total = materials.length;
            const completed = materials.filter(m => m.completed === 100).length;
            const avgProgress = materials.reduce((sum, m) => sum + m.completed, 0) / total;
            
            let html = `
                <div class="mb-4">
                    <div class="row align-items-center mb-3">
                        <div class="col-md-6">
                            <h5 class="text-primary">📊 Thống kê thư mục</h5>
                            <p class="mb-1"><strong>${completed}/${total}</strong> tài liệu đã hoàn thành 
                               (<strong>${avgProgress.toFixed(1)}%</strong>)</p>
                        </div>
                        <div class="col-md-6">
                            <div class="progress" style="height: 25px;">
                                <div class="progress-bar ${avgProgress === 100 ? 'bg-success' : 'bg-info'}" 
                                     style="width: ${avgProgress}%"></div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-4">
                            <label class="form-label">Đặt tất cả thành:</label>
                            <select class="form-select" id="bulk-${folderName}">
                                <option value="0">0%</option>
                                <option value="25">25%</option>
                                <option value="50">50%</option>
                                <option value="75">75%</option>
                                <option value="100">100%</option>
                            </select>
                        </div>
                        <div class="col-md-2">
                            <label class="form-label">&nbsp;</label>
                            <button class="btn btn-warning btn-custom w-100" 
                                    onclick="bulkUpdateProgress('${folderName}')">
                                Áp dụng
                            </button>
                        </div>
                    </div>
                </div>
                <hr>
                <h5 class="text-primary mb-3">📁 Danh sách tài liệu</h5>
            `;

            // File list
            materials.forEach(material => {
                html += createFileItem(material, folderName);
            });

            return html;
        }

        function createFileItem(material, folderName = null) {
            const progressClass = material.completed === 100 ? 'bg-success' : 
                                 material.completed > 50 ? 'bg-warning' : 'bg-info';
            
            return `
                <div class="file-item" data-path="${material.path}">
                    <div class="row align-items-center">
                        <div class="col-md-5">
                            <div class="d-flex align-items-center">
                                <span class="me-2" style="font-size: 1.2em;">${material.icon}</span>
                                <div>
                                    <strong>${material.name}</strong>
                                    ${folderName ? '' : `<br><small class="text-muted">${material.folderDesc}</small>`}
                                    <br><small class="text-muted">${material.path}</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <select class="form-select progress-select" 
                                    onchange="updateProgress('${material.path}', this.value)">
                                <option value="0" ${material.completed === 0 ? 'selected' : ''}>0%</option>
                                <option value="25" ${material.completed === 25 ? 'selected' : ''}>25%</option>
                                <option value="50" ${material.completed === 50 ? 'selected' : ''}>50%</option>
                                <option value="75" ${material.completed === 75 ? 'selected' : ''}>75%</option>
                                <option value="100" ${material.completed === 100 ? 'selected' : ''}>100%</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <div class="progress" style="height: 20px;">
                                <div class="progress-bar ${progressClass}" 
                                     style="width: ${material.completed}%">${material.completed}%</div>
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="btn-group btn-group-sm">
                                ${material.videoFile ? `
                                    <button class="btn btn-info" onclick="playVideo('${material.path}')">
                                        <i class="fas fa-play"></i>
                                    </button>
                                ` : ''}
                                ${material.viewableFile ? `
                                    <button class="btn btn-success" onclick="viewFile('${material.path}')">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                ` : ''}
                            </div>
                            <br><small class="text-muted">${material.lastUpdated}</small>
                        </div>
                    </div>
                </div>
            `;
        }

        function updateOverallProgress(stats) {
            const progressBar = document.getElementById('overall-progress-bar');
            const progressText = document.getElementById('overall-progress-text');
            
            progressBar.style.width = `${stats.avgProgress}%`;
            progressText.innerHTML = `
                <strong>${stats.completedFiles}/${stats.totalFiles}</strong> tài liệu đã hoàn thành 
                (<strong>${stats.avgProgress.toFixed(1)}%</strong>)
            `;
        }

        function updateOverviewStats(overallStats, folderStats) {
            let html = `
                <div class="stats-card">
                    <h3 class="text-primary mb-4">📊 THỐNG KÊ TỔNG QUAN</h3>
                    <div class="row text-center">
                        <div class="col-md-3">
                            <div class="p-3 bg-success bg-opacity-10 rounded">
                                <h2 class="text-success">${overallStats.completedFiles}</h2>
                                <p class="mb-0">Đã hoàn thành</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="p-3 bg-warning bg-opacity-10 rounded">
                                <h2 class="text-warning">${overallStats.totalFiles - overallStats.completedFiles}</h2>
                                <p class="mb-0">Đang thực hiện</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="p-3 bg-info bg-opacity-10 rounded">
                                <h2 class="text-info">${overallStats.totalFiles}</h2>
                                <p class="mb-0">Tổng cộng</p>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="p-3 bg-primary bg-opacity-10 rounded">
                                <h2 class="text-primary">${overallStats.avgProgress.toFixed(1)}%</h2>
                                <p class="mb-0">Tiến độ TB</p>
                            </div>
                        </div>
                    </div>
                </div>
                
                <h4 class="text-primary mt-4 mb-3">📁 TIẾN ĐỘ THEO THƯ MỤC</h4>
            `;
            
            Object.entries(folderStats).forEach(([folderName, stats]) => {
                const progressClass = stats.avgProgress === 100 ? 'bg-success' : 
                                     stats.avgProgress > 50 ? 'bg-warning' : 'bg-info';
                
                html += `
                    <div class="row align-items-center mb-3">
                        <div class="col-md-3">
                            <strong class="text-primary">${stats.folderDesc}</strong>
                        </div>
                        <div class="col-md-6">
                            <div class="progress" style="height: 25px;">
                                <div class="progress-bar ${progressClass}" 
                                     style="width: ${stats.avgProgress}%">${stats.avgProgress.toFixed(1)}%</div>
                            </div>
                        </div>
                        <div class="col-md-3 text-end">
                            <span class="text-muted">${stats.completed}/${stats.total} (${stats.avgProgress.toFixed(1)}%)</span>
                        </div>
                    </div>
                `;
            });
            
            document.getElementById('overview-content').innerHTML = html;
        }

        // Event handlers
        async function onSearchChange() {
            updateSearchResults();
        }

        async function onFilterChange() {
            updateSearchResults();
        }

        async function updateSearchResults() {
            const searchTerm = document.getElementById('search-box').value;
            const folderFilter = document.getElementById('folder-filter').value;
            const progressFilter = document.getElementById('progress-filter').value;
            
            try {
                const params = new URLSearchParams();
                if (searchTerm) params.append('search', searchTerm);
                if (folderFilter !== 'all') params.append('folder', folderFilter);
                if (progressFilter !== 'all') params.append('progress', progressFilter);
                
                const response = await fetch(`/api/materials?${params}`);
                const data = await response.json();
                
                displaySearchResults(data.materials);
            } catch (error) {
                showMessage('❌ Lỗi khi tìm kiếm: ' + error.message, 'error');
            }
        }

        function displaySearchResults(materials) {
            let html = '';
            
            if (materials.length === 0) {
                html = `
                    <div class="text-center text-muted py-5">
                        <h3>🔍 Không tìm thấy kết quả</h3>
                        <p>Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc</p>
                    </div>
                `;
            } else {
                html = `<h4 class="text-primary mb-3">🔍 KẾT QUẢ TÌM KIẾM (${materials.length} tài liệu)</h4>`;
                materials.forEach(material => {
                    html += createFileItem(material);
                });
            }
            
            document.getElementById('search-results').innerHTML = html;
        }

        async function onRescan() {
            showLoading(true);
            showMessage('🔄 Đang quét lại tài liệu...', 'info');
            
            try {
                const response = await fetch('/api/scan');
                const data = await response.json();
                
                currentMaterials = data.materials;
                await loadStats();
                updateOverview();
                
                // Recreate folder tabs
                recreateFolderTabs();
                
                showMessage('✅ Đã hoàn thành quét lại tài liệu!', 'success');
            } catch (error) {
                showMessage('❌ Lỗi khi quét lại: ' + error.message, 'error');
            } finally {
                showLoading(false);
            }
        }

        async function onSave() {
            try {
                const response = await fetch('/api/save', { method: 'POST' });
                const data = await response.json();
                
                if (data.success) {
                    showMessage('💾 Đã lưu tiến độ thành công!', 'success');
                } else {
                    showMessage('❌ Lỗi khi lưu: ' + data.error, 'error');
                }
            } catch (error) {
                showMessage('❌ Lỗi khi lưu: ' + error.message, 'error');
            }
        }

        async function onExport() {
            try {
                const response = await fetch('/api/stats');
                const data = await response.json();
                
                // Create and download CSV
                exportStatsToCSV(data.folders);
                showMessage('📊 Đã xuất thống kê thành công!', 'success');
            } catch (error) {
                showMessage('❌ Lỗi khi xuất thống kê: ' + error.message, 'error');
            }
        }

        async function updateProgress(path, progress) {
            try {
                const formData = new FormData();
                formData.append('path', path);
                formData.append('progress', progress);
                
                const response = await fetch('/api/update-progress', {
                    method: 'POST',
                    body: formData
                });
                
                const data = await response.json();
                
                if (data.success) {
                    // Update local data
                    const material = currentMaterials.find(m => m.path === path);
                    if (material) {
                        material.completed = parseInt(progress);
                        material.lastUpdated = new Date().toLocaleString('vi-VN');
                    }
                    
                    // Refresh stats
                    await loadStats();
                    updateOverview();
                    
                    showMessage(`✅ Cập nhật '${path.split('/').pop()}' thành ${progress}%`, 'success');
                } else {
                    showMessage('❌ Lỗi khi cập nhật: ' + data.error, 'error');
                }
            } catch (error) {
                showMessage('❌ Lỗi khi cập nhật: ' + error.message, 'error');
            }
        }

        async function bulkUpdateProgress(folderName) {
            const selectElement = document.getElementById(`bulk-${folderName}`);
            const progress = selectElement.value;
            
            try {
                const formData = new FormData();
                formData.append('folder', folderName);
                formData.append('progress', progress);
                
                const response = await fetch('/api/bulk-update', {
                    method: 'POST',
                    body: formData
                });
                
                const data = await response.json();
                
                if (data.success) {
                    // Update local data
                    currentMaterials.forEach(material => {
                        if (material.folderName === folderName) {
                            material.completed = parseInt(progress);
                            material.lastUpdated = new Date().toLocaleString('vi-VN');
                        }
                    });
                    
                    // Refresh display
                    await loadStats();
                    updateOverview();
                    recreateFolderTabs();
                    
                    showMessage(data.message, 'success');
                } else {
                    showMessage('❌ Lỗi khi cập nhật hàng loạt: ' + data.error, 'error');
                }
            } catch (error) {
                showMessage('❌ Lỗi khi cập nhật hàng loạt: ' + error.message, 'error');
            }
        }

        function playVideo(path) {
            currentMediaPath = path;
            const mediaViewer = document.getElementById('media-viewer');
            const mediaContent = document.getElementById('media-content');
            
            const fileName = path.split('/').pop();
            
            mediaContent.innerHTML = `
                <div class="border rounded p-3 mb-3" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                    <h5 class="mb-1">🎥 ${fileName}</h5>
                    <small>Đường dẫn: ${path}</small>
                </div>
                <video width="100%" height="450" controls preload="auto" class="rounded">
                    <source src="/materials/${path}" type="video/mp4">
                    Trình duyệt của bạn không hỗ trợ thẻ video.
                </video>
                <div class="mt-3">
                    <label class="form-label fw-bold">Đánh dấu tiến độ:</label>
                    <div class="btn-group">
                        <button class="btn btn-info btn-sm" onclick="updateProgressFromMedia('${path}', 25)">25%</button>
                        <button class="btn btn-warning btn-sm" onclick="updateProgressFromMedia('${path}', 50)">50%</button>
                        <button class="btn btn-success btn-sm" onclick="updateProgressFromMedia('${path}', 75)">75%</button>
                        <button class="btn btn-success btn-sm" onclick="updateProgressFromMedia('${path}', 100)">✅ Hoàn thành</button>
                    </div>
                </div>
            `;
            
            mediaViewer.style.display = 'block';
            mediaViewer.scrollIntoView({ behavior: 'smooth' });
            
            showMessage(`🎥 Đang phát: ${fileName}`, 'info');
        }

        async function viewFile(path) {
            currentMediaPath = path;
            const mediaViewer = document.getElementById('media-viewer');
            const mediaContent = document.getElementById('media-content');
            
            const fileName = path.split('/').pop();
            
            try {
                const response = await fetch(`/api/file-content?path=${encodeURIComponent(path)}`);
                const data = await response.json();
                
                let contentHtml = '';
                if (path.toLowerCase().endsWith('.pdf')) {
                    contentHtml = `
                        <p class="text-muted">📄 PDF File - Tải xuống để xem</p>
                        <a href="/materials/${path}" class="btn btn-danger" download>Tải PDF</a>
                    `;
                } else if (path.toLowerCase().endsWith('.ipynb')) {
                    contentHtml = `
                        <p class="text-muted">📓 Jupyter Notebook</p>
                        <a href="/materials/${path}" class="btn btn-primary" target="_blank">Mở Notebook</a>
                    `;
                } else {
                    contentHtml = `
                        <div style="max-height: 400px; overflow-y: auto;">
                            <pre class="bg-light p-3 rounded">${data.content}</pre>
                        </div>
                    `;
                }
                
                mediaContent.innerHTML = `
                    <div class="border rounded p-3 mb-3" style="background: linear-gradient(135deg, #28a745 0%, #20c997 100%); color: white;">
                        <h5 class="mb-1">${getMaterialIcon(fileName)} ${fileName}</h5>
                        <small>Đường dẫn: ${path}</small>
                    </div>
                    ${contentHtml}
                    <div class="mt-3">
                        <label class="form-label fw-bold">Đánh dấu tiến độ:</label>
                        <div class="btn-group">
                            <button class="btn btn-info btn-sm" onclick="updateProgressFromMedia('${path}', 25)">25%</button>
                            <button class="btn btn-warning btn-sm" onclick="updateProgressFromMedia('${path}', 50)">50%</button>
                            <button class="btn btn-success btn-sm" onclick="updateProgressFromMedia('${path}', 75)">75%</button>
                            <button class="btn btn-success btn-sm" onclick="updateProgressFromMedia('${path}', 100)">✅ Hoàn thành</button>
                        </div>
                    </div>
                `;
                
                mediaViewer.style.display = 'block';
                mediaViewer.scrollIntoView({ behavior: 'smooth' });
                
                showMessage(`📄 Đang xem: ${fileName}`, 'info');
                
            } catch (error) {
                showMessage('❌ Lỗi khi đọc file: ' + error.message, 'error');
            }
        }

        async function updateProgressFromMedia(path, progress) {
            await updateProgress(path, progress);
        }

        function closeMediaViewer() {
            document.getElementById('media-viewer').style.display = 'none';
            currentMediaPath = null;
        }

        function recreateFolderTabs() {
            // Remove existing folder tabs
            const tabsNav = document.getElementById('main-tabs');
            const tabsContent = document.getElementById('main-tab-content');
            
            // Remove tabs beyond the first 2 (overview and search)
            while (tabsNav.children.length > 2) {
                tabsNav.removeChild(tabsNav.lastChild);
            }
            while (tabsContent.children.length > 2) {
                tabsContent.removeChild(tabsContent.lastChild);
            }
            
            // Recreate folder tabs
            createFolderTabs();
        }

        function exportStatsToCSV(folderStats) {
            let csvContent = "Thư mục,Tổng số tài liệu,Đã hoàn thành,Đang thực hiện,Chưa bắt đầu,Tiến độ trung bình (%)\n";
            
            Object.entries(folderStats).forEach(([folderName, stats]) => {
                const partial = stats.total - stats.completed - (stats.total - stats.completed);
                const notStarted = stats.total - stats.completed - partial;
                
                csvContent += `"${stats.folderDesc}",${stats.total},${stats.completed},${partial},${notStarted},${stats.avgProgress.toFixed(1)}\n`;
            });
            
            const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
            const link = document.createElement('a');
            const url = URL.createObjectURL(blob);
            
            link.setAttribute('href', url);
            link.setAttribute('download', `learning_stats_${new Date().toISOString().split('T')[0]}.csv`);
            link.style.visibility = 'hidden';
            
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }

        function getMaterialIcon(filename) {
            const ext = filename.substring(filename.lastIndexOf('.')).toLowerCase();
            const icons = {
                '.pdf': '📄', '.doc': '📝', '.docx': '📝', '.txt': '📄', '.md': '📄',
                '.mp4': '🎥', '.avi': '🎥', '.mkv': '🎥', '.mov': '🎥', '.wmv': '🎥',
                '.ppt': '📊', '.pptx': '📊', '.xls': '📊', '.xlsx': '📊',
                '.ipynb': '📓', '.py': '🐍', '.js': '📜', '.html': '🌐',
                '.jpg': '🖼️', '.jpeg': '🖼️', '.png': '🖼️', '.gif': '🖼️',
                '.zip': '📦', '.rar': '📦', '.7z': '📦',
                '.csv': '📊', '.json': '📄'
            };
            return icons[ext] || '📁';
        }

        // Utility functions
        function showLoading(show) {
            document.getElementById('loading-spinner').style.display = show ? 'block' : 'none';
        }

        function showMessage(message, type) {
            const container = document.getElementById('message-container');
            const messageDiv = document.createElement('div');
            messageDiv.className = `message ${type}`;
            messageDiv.innerHTML = message;
            
            container.innerHTML = '';
            container.appendChild(messageDiv);
            
            // Auto-hide after 5 seconds
            setTimeout(() => {
                if (messageDiv.parentNode) {
                    messageDiv.parentNode.removeChild(messageDiv);
                }
            }, 5000);
        }

        function debounce(func, wait) {
            let timeout;
            return function executedFunction(...args) {
                const later = () => {
                    clearTimeout(timeout);
                    func(...args);
                };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        }

        function updateOverview() {
            // This function is called when overview needs to be refreshed
            loadStats().then(() => {
                // Overview is automatically updated in loadStats
            });
        }
    </script>
</body>
</html>
