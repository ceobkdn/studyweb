package com.studytracker.servlet;

import com.studytracker.model.StudyProgressModel;
import com.studytracker.service.StudyProgressService;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet("/api/*")
public class StudyProgressServlet extends HttpServlet {
    
    private StudyProgressService service;
    private ObjectMapper objectMapper = new ObjectMapper();
    
    @Override
    public void init() throws ServletException {
        super.init();
        // Initialize service with base path (can be configured)
        String basePath = getServletContext().getInitParameter("studyBasePath");
        if (basePath == null) {
            basePath = System.getProperty("user.home") + "/study-materials";
        }
        service = new StudyProgressService(basePath);
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String pathInfo = req.getPathInfo();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            switch (pathInfo) {
                case "/materials":
                    getMaterials(req, resp);
                    break;
                case "/scan":
                    scanMaterials(req, resp);
                    break;
                case "/stats":
                    getStats(req, resp);
                    break;
                case "/directories":
                    getDirectories(req, resp);
                    break;
                case "/file-content":
                    getFileContent(req, resp);
                    break;
                default:
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    writeJsonResponse(resp, Map.of("error", "Endpoint not found"));
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJsonResponse(resp, Map.of("error", e.getMessage()));
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String pathInfo = req.getPathInfo();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            switch (pathInfo) {
                case "/update-progress":
                    updateProgress(req, resp);
                    break;
                case "/bulk-update":
                    bulkUpdateProgress(req, resp);
                    break;
                case "/save":
                    saveProgress(req, resp);
                    break;
                default:
                    resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    writeJsonResponse(resp, Map.of("error", "Endpoint not found"));
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJsonResponse(resp, Map.of("error", e.getMessage()));
        }
    }
    
    private void getMaterials(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        List<StudyProgressModel> materials = service.initializeData();
        
        String searchTerm = req.getParameter("search");
        String folderFilter = req.getParameter("folder");
        String progressFilter = req.getParameter("progress");
        
        if (searchTerm != null || folderFilter != null || progressFilter != null) {
            materials = service.filterMaterials(materials, searchTerm, folderFilter, progressFilter);
        }
        
        writeJsonResponse(resp, Map.of("materials", materials));
    }
    
    private void scanMaterials(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        List<StudyProgressModel> materials = service.initializeData();
        writeJsonResponse(resp, Map.of("materials", materials, "message", "Scan completed"));
    }
    
    private void getStats(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        List<StudyProgressModel> materials = service.initializeData();
        Map<String, Object> overallStats = service.getOverallStats(materials);
        Map<String, Map<String, Object>> folderStats = service.getFolderStats(materials);
        
        writeJsonResponse(resp, Map.of(
            "overall", overallStats,
            "folders", folderStats
        ));
    }
    
    private void getDirectories(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        writeJsonResponse(resp, Map.of("directories", StudyProgressService.getLearningDirectories()));
    }
    
    private void getFileContent(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        String filePath = req.getParameter("path");
        if (filePath == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJsonResponse(resp, Map.of("error", "File path is required"));
            return;
        }
        
        String content = service.readFileContent(filePath);
        writeJsonResponse(resp, Map.of("content", content));
    }
    
    private void updateProgress(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        String path = req.getParameter("path");
        String progressStr = req.getParameter("progress");
        
        if (path == null || progressStr == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJsonResponse(resp, Map.of("error", "Path and progress are required"));
            return;
        }
        
        try {
            int progress = Integer.parseInt(progressStr);
            if (progress < 0 || progress > 100) {
                throw new IllegalArgumentException("Progress must be between 0 and 100");
            }
            
            List<StudyProgressModel> materials = service.initializeData();
            boolean success = service.updateProgress(materials, path, progress);
            
            if (success) {
                writeJsonResponse(resp, Map.of("success", true, "message", "Progress updated"));
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                writeJsonResponse(resp, Map.of("error", "File not found"));
            }
            
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJsonResponse(resp, Map.of("error", "Invalid progress value"));
        }
    }
    
    private void bulkUpdateProgress(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        String folder = req.getParameter("folder");
        String progressStr = req.getParameter("progress");
        
        if (folder == null || progressStr == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJsonResponse(resp, Map.of("error", "Folder and progress are required"));
            return;
        }
        
        try {
            int progress = Integer.parseInt(progressStr);
            if (progress < 0 || progress > 100) {
                throw new IllegalArgumentException("Progress must be between 0 and 100");
            }
            
            List<StudyProgressModel> materials = service.initializeData();
            int updatedCount = 0;
            
            for (StudyProgressModel material : materials) {
                if (material.getFolderName().equals(folder)) {
                    material.setCompleted(progress);
                    updatedCount++;
                }
            }
            
            service.saveProgress(materials);
            writeJsonResponse(resp, Map.of("success", true, "message", "Updated " + updatedCount + " files"));
            
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJsonResponse(resp, Map.of("error", "Invalid progress value"));
        }
    }
    
    private void saveProgress(HttpServletRequest req, HttpServletResponse resp) 
            throws IOException {
        
        List<StudyProgressModel> materials = service.initializeData();
        boolean success = service.saveProgress(materials);
        
        if (success) {
            writeJsonResponse(resp, Map.of("success", true, "message", "Progress saved"));
        } else {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJsonResponse(resp, Map.of("error", "Failed to save progress"));
        }
    }
    
    private void writeJsonResponse(HttpServletResponse resp, Object data) throws IOException {
        try (PrintWriter writer = resp.getWriter()) {
            objectMapper.writeValue(writer, data);
        }
    }
}
