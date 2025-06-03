package com.vdt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;

@WebServlet("/upload")
@MultipartConfig
public class UploadServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        Part filePart = req.getPart("file");
        String fileName = filePart.getSubmittedFileName();

        String appPath = req.getServletContext().getRealPath("/");
        String uploadPath = appPath + "uploads";

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        filePart.write(uploadPath + File.separator + fileName);

        String fileUrl = req.getContextPath() + "/uploads/" + fileName;
        resp.setContentType("text/html");
        resp.getWriter().println("<h1>File uploaded successfully!</h1>");
        resp.getWriter().println("<a href='" + fileUrl + "'>Open the file</a>");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // redirect to upload.jsp
        System.out.println("Redirecting to upload.jsp");
        resp.sendRedirect("upload.jsp");
    }
}
