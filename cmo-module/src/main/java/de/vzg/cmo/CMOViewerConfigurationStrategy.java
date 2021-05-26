package de.vzg.cmo;

import java.util.Locale;

import javax.servlet.http.HttpServletRequest;

import org.mycore.common.xml.MCRXMLFunctions;
import org.mycore.common.xsl.MCRParameterCollector;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.viewer.configuration.MCRViewerConfiguration;
import org.mycore.viewer.configuration.MCRViewerDefaultConfigurationStrategy;

public class CMOViewerConfigurationStrategy extends MCRViewerDefaultConfigurationStrategy {

    @Override
    public MCRViewerConfiguration get(HttpServletRequest request) {
        MCRViewerConfiguration mcrViewerConfiguration = super.get(request);
        String baseURL = MCRFrontendUtil.getBaseURL(request);
        MCRParameterCollector params = new MCRParameterCollector(request);

        if (!MCRXMLFunctions.isMobileDevice(request.getHeader("User-Agent"))) {
            // Default Stylesheet

            String cmoBootstrapCSSURL = String.format(Locale.ROOT, "%srsc/sass/scss/bootstrap-cmo.css", baseURL);
            mcrViewerConfiguration.addCSS(cmoBootstrapCSSURL);


            if (request.getParameter("embedded") != null) {
                mcrViewerConfiguration.setProperty("permalink.updateHistory", false);
                mcrViewerConfiguration.setProperty("chapter.showOnStart", false);
            } else {
                // Default JS
                mcrViewerConfiguration
                    .addScript(MCRFrontendUtil.getBaseURL() + "webjars/bootstrap/4.3.1/js/bootstrap.bundle.min.js");
            }
        }

        return mcrViewerConfiguration;
    }
}
