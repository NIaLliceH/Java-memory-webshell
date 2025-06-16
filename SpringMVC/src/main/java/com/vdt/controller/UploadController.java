package com.vdt.controller;

import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;

@Controller
public class UploadController {
    @GetMapping("/upload")
    public String uploadForm() {
        return "upload";
    }

    @PostMapping("/upload")
    public void uploadFile(@RequestParam("file") MultipartFile file, HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String fileName = file.getOriginalFilename();
        ServletContext context = req.getServletContext();
        String appPath = context.getRealPath("/");
        String uploadPath = appPath + "uploads";

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        File savedFile = new File(uploadDir, fileName);
        file.transferTo(savedFile);

        String fileUrl = req.getContextPath() + "/uploads/" + fileName;

        resp.setContentType("text/html");
        resp.getWriter().println("<h1>File Uploaded Successfully</h1>");
        resp.getWriter().println("<a href='" + fileUrl + "'>Open the file</a>");
    }
}
