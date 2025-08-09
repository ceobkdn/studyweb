package com.studytracker.servlet;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/upload/*")
public class FileUploadServlet extends HttpServlet {
    
    private static final int MEMORY_THRESHOLD = 1024 * 1024 * 3;  // 3MB
    private static final int MAX_FILE_SIZE = 1024 * 1024 * 50;    // 50MB
    private static final int MAX_REQUEST_SIZE = 1024 * 1024 * 50; // 50MB
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        // Check if request contains multipart content
        if (!ServletFileUpload.isMultipartContent(req)) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("Error: Form must have enctype=multipart/form-data.");
            return;
        }
        
        // Configure upload settings
        DiskFileItemFactory factory = new DiskFileItemFactory();
        factory.setSizeThreshold(MEMORY_THRESHOLD);
        factory.setRepository(new File(System.getProperty("java.io.tmpdir")));
        
        ServletFileUpload upload = new ServletFileUpload(factory);
        upload.setFileSizeMax(MAX_FILE_SIZE);
        upload.setSizeMax(MAX_REQUEST_SIZE);
        
        // Get base path
        String basePath = getServletContext().getInitParameter("studyBasePath");
        if (basePath == null) {
            basePath = System.getProperty("user.home") + "/study-materials";
        }
        
        String pathInfo = req.getPathInfo();
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        try {
            if ("/materials".equals(pathInfo)) {
                handleMaterialUpload(req, resp, upload, basePath);
            } else {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                writeJsonResponse(resp, "error", "Upload endpoint not found");
            }
        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            writeJsonResponse(resp, "error", "Upload failed: " + e.getMessage());
        }
    }
    
    private void handleMaterialUpload(HttpServletRequest req, HttpServletResponse resp,
                                    ServletFileUpload upload, String basePath) 
            throws Exception {
        
        List<FileItem> formItems = upload.parseRequest(req);
        String targetFolder = null;
        
        if (formItems == null || formItems.isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJsonResponse(resp, "error", "No files uploaded");
            return;
        }
        
        // Find target folder from form data
        for (FileItem item : formItems) {
            if (item.isFormField() && "folder".equals(item.getFieldName())) {
                targetFolder = item.getString();
                break;
            }
        }
        
        if (targetFolder == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            writeJsonResponse(resp, "error", "Target folder not specified");
            return;
        }
        
        // Create target directory if it doesn't exist
        File uploadDir = new File(basePath, targetFolder);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }
        
        int uploadedCount = 0;
        StringBuilder uploadedFiles = new StringBuilder();
        
        // Process uploaded files
        for (FileItem item : formItems) {
            if (!item.isFormField()) {
                String fileName = item.getName();
                if (fileName != null && !fileName.isEmpty()) {
                    // Sanitize filename
                    fileName = sanitizeFileName(fileName);
                    
                    File uploadFile = new File(uploadDir, fileName);
                    
                    // Check if file already exists
                    if (uploadFile.exists()) {
                        // Create unique filename
                        String baseName = getBaseName(fileName);
                        String extension = getFileExtension(fileName);
                        int counter = 1;
                        
                        while (uploadFile.exists()) {
                            uploadFile = new File(uploadDir, baseName + "_" + counter + extension);
                            counter++;
                        }
                    }
                    
                    // Save file
                    item.write(uploadFile);
                    uploadedCount++;
                    
                    if (uploadedFiles.length() > 0) {
                        uploadedFiles.append(", ");
                    }
                    uploadedFiles.append(uploadFile.getName());
                }
            }
        }
        
        if (uploadedCount > 0) {
            writeJsonResponse(resp, "success", 
                "Uploaded " + uploadedCount + " file(s): " + uploadedFiles.toString());
        } else {
            writeJsonResponse(resp, "error", "No valid files uploaded");
        }
    }
    
    private String sanitizeFileName(String fileName) {
        // Remove path separators and dangerous characters
        fileName = fileName.replaceAll("[\\\\/:*?\"<>|]", "_");
        // Remove leading/trailing spaces and dots
        fileName = fileName.trim().replaceAll("^\\.+", "");
        // Ensure filename is not empty
        if (fileName.isEmpty()) {
            fileName = "unnamed_file";
        }
        return fileName;
    }
    
    private String getBaseName(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0) {
            return fileName.substring(0, lastDotIndex);
        }
        return fileName;
    }
    
    private String getFileExtension(String fileName) {
        int lastDotIndex = fileName.lastIndexOf('.');
        if (lastDotIndex > 0 && lastDotIndex < fileName.length() - 1) {
            return fileName.substring(lastDotIndex);
        }
        return "";
    }
    
    private void writeJsonResponse(HttpServletResponse resp, String status, String message) 
            throws IOException {
        try (PrintWriter writer = resp.getWriter()) {
            writer.write(String.format("{\"status\":\"%s\",\"message\":\"%s\"}", status, message));
        }
    }
}
