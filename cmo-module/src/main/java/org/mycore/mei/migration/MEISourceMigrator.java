package org.mycore.mei.migration;

import java.util.List;

import org.jdom2.Attribute;
import org.jdom2.Element;
import org.mycore.mei.MEIWrapper;

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

public class MEISourceMigrator extends MEIMigrator {

    @Override
    public void migrate(MEIWrapper obj) {
        if (obj.getWrappedElementName().equals("source")) {
            final Element sourceElement = obj.getRoot();
            fixSource(sourceElement);
        }
    }

    private void fixSource(Element sourceElement) {
        sourceElement.setName("manifestation");

        final Element relationListElement = sourceElement.getChild("relationList", MEI_NAMESPACE);
        if (relationListElement != null) {
            final List<Element> relations = relationListElement.getChildren("relation", MEI_NAMESPACE);
            if (relations != null) {
                relations.forEach(relation -> {
                    final Attribute n = relation.getAttribute("n");
                    final String value = n.getValue().replace(" ", "");
                    n.setValue(value);
                });
            }
        }

        final Element componentGrp = sourceElement.getChild("componentGrp", MEI_NAMESPACE);
        if (componentGrp != null) {
            componentGrp.setName("componentList");
            final List<Element> children = componentGrp.getChildren("source", MEI_NAMESPACE);
            if (children != null) {
                children.forEach(this::fixSource);
            }
        }
    }

}
