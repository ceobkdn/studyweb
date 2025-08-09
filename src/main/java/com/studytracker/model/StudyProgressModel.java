package com.studytracker.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class StudyProgressModel {
    private String folderName;
    private String folderDesc;
    private String name;
    private String path;
    private int completed;
    private String lastUpdated;
    private String fileType;
    private String icon;
    
    // Constructors
    public StudyProgressModel() {
        this.lastUpdated = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        this.completed = 0;
    }
    
    public StudyProgressModel(String folderName, String folderDesc, String name, String path) {
        this();
        this.folderName = folderName;
        this.folderDesc = folderDesc;
        this.name = name;
        this.path = path;
        this.fileType = getFileExtension(name);
        this.icon = getFileIcon(name);
    }
    
    // Getters and Setters
    public String getFolderName() {
        return folderName;
    }
    
    public void setFolderName(String folderName) {
        this.folderName = folderName;
    }
    
    public String getFolderDesc() {
        return folderDesc;
    }
    
    public void setFolderDesc(String folderDesc) {
        this.folderDesc = folderDesc;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
        this.fileType = getFileExtension(name);
        this.icon = getFileIcon(name);
    }
    
    public String getPath() {
        return path;
    }
    
    public void setPath(String path) {
        this.path = path;
    }
    
    public int getCompleted() {
        return completed;
    }
    
    public void setCompleted(int completed) {
        this.completed = completed;
        this.lastUpdated = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
    
    public String getLastUpdated() {
        return lastUpdated;
    }
    
    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
    
    public String getFileType() {
        return fileType;
    }
    
    public String getIcon() {
        return icon;
    }
    
    // Utility methods
    private String getFileExtension(String filename) {
        if (filename == null || filename.lastIndexOf('.') == -1) {
            return "";
        }
        return filename.substring(filename.lastIndexOf('.')).toLowerCase();
    }
    
    private String getFileIcon(String filename) {
        String ext = getFileExtension(filename);
        switch (ext) {
            case ".pdf": return "📄";
            case ".doc": case ".docx": return "📝";
            case ".txt": case ".md": return "📄";
            case ".mp4": case ".avi": case ".mkv": case ".mov": case ".wmv": return "🎥";
            case ".ppt": case ".pptx": return "📊";
            case ".xls": case ".xlsx": case ".csv": return "📊";
            case ".ipynb": return "📓";
            case ".py": return "🐍";
            case ".js": return "📜";
            case ".html": return "🌐";
            case ".jpg": case ".jpeg": case ".png": case ".gif": return "🖼️";
            case ".zip": case ".rar": case ".7z": return "📦";
            case ".json": return "📄";
            default: return "📁";
        }
    }
    
    public boolean isVideoFile() {
        String ext = getFileExtension(name);
        return ext.matches("\\.(mp4|avi|mkv|mov|wmv|flv|webm|m4v)");
    }
    
    public boolean isViewableFile() {
        String ext = getFileExtension(name);
        return ext.matches("\\.(txt|md|py|ipynb|pdf|html|csv|json)");
    }
    
    @Override
    public String toString() {
        return "StudyProgressModel{" +
                "folderName='" + folderName + '\'' +
                ", name='" + name + '\'' +
                ", path='" + path + '\'' +
                ", completed=" + completed +
                ", lastUpdated='" + lastUpdated + '\'' +
                '}';
    }
}
