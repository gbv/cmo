package org.mycore.mei.migration;

import java.util.ArrayList;
import java.util.List;

import org.jdom2.Element;
import org.mycore.mei.MEIWrapper;

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

public class MEIEmptyTitleMigrator extends MEIMigrator {

    @Override
    public void migrate(MEIWrapper obj) {
        final String wrappedElementName = obj.getWrappedElementName();

        if ("expression".equals(wrappedElementName) || "work".equals(wrappedElementName)) {
            final Element root = obj.getRoot();
            addTitleIfNotPresent(root);
            final Element expressionList = root.getChild("expressionList", MEI_NAMESPACE);
            if (expressionList != null) {
                final List<Element> expressions = expressionList.getChildren("expression", MEI_NAMESPACE);
                expressions.forEach(this::addTitleIfNotPresent);
            }
            obj.orderTopLevelElement();
        }
    }

    private void addTitleIfNotPresent(Element ele) {
        if (ele.getChild("title", MEI_NAMESPACE) == null) {
            ele.addContent(new Element("title", MEI_NAMESPACE));
        }
    }

    @Override
    public List<Class<? extends MEIMigrator>> getDependencies() {
        final List<Class<? extends MEIMigrator>> dependencies = new ArrayList<>();
        dependencies.add(MEIExpressionTitleStmtMigrator.class);
        return dependencies;
    }
}
