package com.studytracker.service;

import com.studytracker.model.StudyProgressModel;
import com.opencsv.CSVReader;
import com.opencsv.CSVWriter;

import java.io.*;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

public class StudyProgressService {
    
    private static final Map<String, String> LEARNING_DIRECTORIES = new LinkedHashMap<>();
    
    static {
        LEARNING_DIRECTORIES.put("00_Books", "📚 Giáo trình");
        LEARNING_DIRECTORIES.put("01_Lecture_Notes", "📝 Ghi chú bài giảng");
        LEARNING_DIRECTORIES.put("02_Videos", "🎥 Video bài giảng");
        LEARNING_DIRECTORIES.put("03_Homework", "📋 Bài tập về nhà");
        LEARNING_DIRECTORIES.put("04_Simulation", "🔬 Mô phỏng");
        LEARNING_DIRECTORIES.put("05_Reference_Papers", "📄 Tài liệu tham khảo");
        LEARNING_DIRECTORIES.put("06_Projects", "🚀 Dự án");
        LEARNING_DIRECTORIES.put("07_Exam", "📝 Bài thi");
        LEARNING_DIRECTORIES.put("08_Questions", "❓ Một số câu hỏi");
    }
    
    private final String basePath;
    private final String progressFile;
    private final String backupFile;
    
    public StudyProgressService(String basePath) {
        this.basePath = basePath;
        this.progressFile = basePath + "/learning_progress.csv";
        this.backupFile = basePath + "/learning_progress_backup.csv";
    }
    
    public static Map<String, String> getLearningDirectories() {
        return LEARNING_DIRECTORIES;
    }
    
    public List<StudyProgressModel> loadProgress() {
        List<StudyProgressModel> materials = new ArrayList<>();
        File file = new File(progressFile);
        
        if (!file.exists()) {
            return materials;
        }
        
        try (CSVReader reader = new CSVReader(new FileReader(file))) {
            List<String[]> records = reader.readAll();
            
            if (records.isEmpty()) {
                return materials;
            }
            
            // Skip header
            for (int i = 1; i < records.size(); i++) {
                String[] record = records.get(i);
                if (record.length >= 6) {
                    StudyProgressModel material = new StudyProgressModel();
                    material.setFolderName(record[0]);
                    material.setFolderDesc(record[1]);
                    material.setName(record[2]);
                    material.setPath(record[3]);
                    material.setCompleted(Integer.parseInt(record[4]));
                    material.setLastUpdated(record[5]);
                    materials.add(material);
                }
            }
        } catch (Exception e) {
            System.err.println("Error loading progress: " + e.getMessage());
        }
        
        return materials;
    }
    
    public boolean saveProgress(List<StudyProgressModel> materials) {
        try {
            // Create backup
            File originalFile = new File(progressFile);
            if (originalFile.exists()) {
                Files.copy(Paths.get(progressFile), Paths.get(backupFile), 
                          StandardCopyOption.REPLACE_EXISTING);
            }
            
            // Write new data
            try (CSVWriter writer = new CSVWriter(new FileWriter(progressFile))) {
                // Write header
                String[] header = {"folder_name", "folder_desc", "name", "path", "completed", "last_updated"};
                writer.writeNext(header);
                
                // Write data
                for (StudyProgressModel material : materials) {
                    String[] record = {
                        material.getFolderName(),
                        material.getFolderDesc(),
                        material.getName(),
                        material.getPath(),
                        String.valueOf(material.getCompleted()),
                        material.getLastUpdated()
                    };
                    writer.writeNext(record);
                }
            }
            return true;
        } catch (Exception e) {
            System.err.println("Error saving progress: " + e.getMessage());
            return false;
        }
    }
    
    public List<StudyProgressModel> scanMaterials() {
        List<StudyProgressModel> materials = new ArrayList<>();
        
        for (Map.Entry<String, String> entry : LEARNING_DIRECTORIES.entrySet()) {
            String folderName = entry.getKey();
            String folderDesc = entry.getValue();
            
            Path folderPath = Paths.get(basePath, folderName);
            
            if (Files.exists(folderPath) && Files.isDirectory(folderPath)) {
                try {
                    Files.walk(folderPath)
                         .filter(Files::isRegularFile)
                         .filter(path -> !path.getFileName().toString().startsWith("."))
                         .filter(path -> !path.getFileName().toString().contains("checkpoint"))
                         .forEach(path -> {
                             String fileName = path.getFileName().toString();
                             String relativePath = Paths.get(basePath).relativize(path).toString();
                             
                             StudyProgressModel material = new StudyProgressModel(
                                 folderName, folderDesc, fileName, relativePath
                             );
                             materials.add(material);
                         });
                } catch (IOException e) {
                    System.err.println("Error scanning folder " + folderName + ": " + e.getMessage());
                }
            }
        }
        
        // Sort materials naturally
        materials.sort((a, b) -> {
            int folderCompare = a.getFolderName().compareTo(b.getFolderName());
            if (folderCompare != 0) {
                return folderCompare;
            }
            return naturalCompare(a.getName(), b.getName());
        });
        
        return materials;
    }
    
    public List<StudyProgressModel> initializeData() {
        List<StudyProgressModel> existing = loadProgress();
        List<StudyProgressModel> scanned = scanMaterials();
        
        if (scanned.isEmpty()) {
            return existing;
        }
        
        if (existing.isEmpty()) {
            saveProgress(scanned);
            return scanned;
        }
        
        // Merge existing progress with scanned files
        Map<String, StudyProgressModel> existingMap = existing.stream()
            .collect(Collectors.toMap(StudyProgressModel::getPath, m -> m));
        
        for (StudyProgressModel scannedMaterial : scanned) {
            StudyProgressModel existingMaterial = existingMap.get(scannedMaterial.getPath());
            if (existingMaterial != null) {
                scannedMaterial.setCompleted(existingMaterial.getCompleted());
                scannedMaterial.setLastUpdated(existingMaterial.getLastUpdated());
            }
        }
        
        saveProgress(scanned);
        return scanned;
    }
    
    public List<StudyProgressModel> filterMaterials(List<StudyProgressModel> materials, 
                                                   String searchTerm, 
                                                   String folderFilter, 
                                                   String progressFilter) {
        return materials.stream()
            .filter(m -> {
                // Search filter
                if (searchTerm != null && !searchTerm.trim().isEmpty()) {
                    if (!m.getName().toLowerCase().contains(searchTerm.toLowerCase())) {
                        return false;
                    }
                }
                
                // Folder filter
                if (folderFilter != null && !folderFilter.equals("all")) {
                    if (!m.getFolderName().equals(folderFilter)) {
                        return false;
                    }
                }
                
                // Progress filter
                if (progressFilter != null && !progressFilter.equals("all")) {
                    switch (progressFilter) {
                        case "0":
                            return m.getCompleted() == 0;
                        case "partial":
                            return m.getCompleted() > 0 && m.getCompleted() < 100;
                        case "100":
                            return m.getCompleted() == 100;
                    }
                }
                
                return true;
            })
            .collect(Collectors.toList());
    }
    
    public Map<String, Object> getOverallStats(List<StudyProgressModel> materials) {
        Map<String, Object> stats = new HashMap<>();
        
        if (materials.isEmpty()) {
            stats.put("totalFiles", 0);
            stats.put("completedFiles", 0);
            stats.put("avgProgress", 0.0);
            return stats;
        }
        
        int totalFiles = materials.size();
        long completedFiles = materials.stream().mapToInt(StudyProgressModel::getCompleted).filter(p -> p == 100).count();
        double avgProgress = materials.stream().mapToInt(StudyProgressModel::getCompleted).average().orElse(0.0);
        
        stats.put("totalFiles", totalFiles);
        stats.put("completedFiles", completedFiles);
        stats.put("avgProgress", avgProgress);
        
        return stats;
    }
    
    public Map<String, Map<String, Object>> getFolderStats(List<StudyProgressModel> materials) {
        Map<String, Map<String, Object>> folderStats = new LinkedHashMap<>();
        
        for (String folderName : LEARNING_DIRECTORIES.keySet()) {
            List<StudyProgressModel> folderMaterials = materials.stream()
                .filter(m -> m.getFolderName().equals(folderName))
                .collect(Collectors.toList());
            
            if (!folderMaterials.isEmpty()) {
                Map<String, Object> stats = new HashMap<>();
                int total = folderMaterials.size();
                long completed = folderMaterials.stream().mapToInt(StudyProgressModel::getCompleted).filter(p -> p == 100).count();
                double avgProgress = folderMaterials.stream().mapToInt(StudyProgressModel::getCompleted).average().orElse(0.0);
                
                stats.put("total", total);
                stats.put("completed", completed);
                stats.put("avgProgress", avgProgress);
                stats.put("folderDesc", LEARNING_DIRECTORIES.get(folderName));
                
                folderStats.put(folderName, stats);
            }
        }
        
        return folderStats;
    }
    
    public boolean updateProgress(List<StudyProgressModel> materials, String path, int progress) {
        for (StudyProgressModel material : materials) {
            if (material.getPath().equals(path)) {
                material.setCompleted(progress);
                return saveProgress(materials);
            }
        }
        return false;
    }
    
    public String readFileContent(String filePath) {
        try {
            Path path = Paths.get(basePath, filePath);
            if (!Files.exists(path)) {
                return "File not found";
            }
            
            List<String> lines = Files.readAllLines(path);
            return String.join("\n", lines);
        } catch (Exception e) {
            return "Error reading file: " + e.getMessage();
        }
    }
    
    private int naturalCompare(String a, String b) {
        String[] aParts = a.split("(?<=\\D)(?=\\d)|(?<=\\d)(?=\\D)");
        String[] bParts = b.split("(?<=\\D)(?=\\d)|(?<=\\d)(?=\\D)");
        
        int minLength = Math.min(aParts.length, bParts.length);
        
        for (int i = 0; i < minLength; i++) {
            String aPart = aParts[i];
            String bPart = bParts[i];
            
            boolean aIsNumber = aPart.matches("\\d+");
            boolean bIsNumber = bPart.matches("\\d+");
            
            if (aIsNumber && bIsNumber) {
                int aNum = Integer.parseInt(aPart);
                int bNum = Integer.parseInt(bPart);
                int result = Integer.compare(aNum, bNum);
                if (result != 0) return result;
            } else {
                int result = aPart.compareToIgnoreCase(bPart);
                if (result != 0) return result;
            }
        }
        
        return Integer.compare(aParts.length, bParts.length);
    }
}
