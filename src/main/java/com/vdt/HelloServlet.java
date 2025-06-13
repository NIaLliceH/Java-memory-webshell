package com.vdt;

import java.io.*;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

//@WebServlet("/hello")
public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");
        resp.getWriter().println("<h1>Hello World!</h1>");
    }

    @Override
    public void init() throws ServletException {
        // This method is called when the servlet is initialized
        System.out.println("HelloServlet initialized");
    }
}