package org.mycore.mei;

import java.io.IOException;

import org.jdom2.Document;
import org.jdom2.JDOMException;
import org.mycore.frontend.xeditor.MCRPostProcessorXSL;
import org.xml.sax.SAXException;

public class MEIPostProcessor extends MCRPostProcessorXSL {

    @Override
    public Document process(Document xml) throws IOException, JDOMException, SAXException {
        Document returns = super.process(xml);

        MEIWrapper.getWrapper(returns.getRootElement()).orderTopLevelElement();

        return returns;
    }
}
