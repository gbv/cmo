package org.mycore.mei.migration;

import java.util.List;

import org.jdom2.Element;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.mei.MEIWrapper;

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

public class MEIWorkCodedvalMigrator extends MEIMigrator {
    @Override
    public void migrate(MEIWrapper obj) {
        if ("work".equals(obj.getWrappedElementName())) {
            final Element expressionList = obj.getRoot().getChild("expressionList", MEI_NAMESPACE);
            if (expressionList != null) {
                final List<Element> expressions = expressionList.getChildren("expression", MEI_NAMESPACE);
                expressions.forEach(this::fixCodedVal);
            }
        }
    }

    private void fixCodedVal(Element expressionInList) {
        final String codedval = expressionInList.getAttributeValue("data");
        expressionInList.removeAttribute("data");
        expressionInList.setAttribute("codedval", codedval);
        expressionInList.setAttribute("auth.uri", MCRFrontendUtil.getBaseURL() + "receive/");
    }
}
