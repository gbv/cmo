package org.mycore.mei.migration;

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

import java.util.ArrayList;
import java.util.List;

import org.jdom2.Element;
import org.mycore.mei.MEIWrapper;

public class MEIExpressionTitleStmtMigrator extends MEIMigrator {
    @Override
    public void migrate(MEIWrapper obj) {
        if ("expression".equals(obj.getWrappedElementName()) || "work".equals(obj.getWrappedElementName())) {
            final Element expression = obj.getRoot();
            final Element titleStmt = expression.getChild("titleStmt", MEI_NAMESPACE);
            if (titleStmt != null) {
                expression.removeContent(titleStmt);

                final List<Element> children = new ArrayList<>(titleStmt.getChildren());
                children.forEach(Element::detach);
                children.forEach(expression::addContent);
                obj.orderTopLevelElement();
            }
        }
    }
}
