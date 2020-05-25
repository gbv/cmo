package org.mycore.mei.migration;

import java.util.List;

import org.jdom2.Element;
import org.mycore.mei.MEIWrapper;

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

public class MEILangUsageMigrator extends MEIMigrator {

    @Override
    public void migrate(MEIWrapper obj) {
        if ("expression".equals(obj.getWrappedElementName()) || "source".equals(obj.getWrappedElementName())
            || "manifestation".equals(obj.getWrappedElementName())) {
            final Element langUsageElement = obj.getRoot().getChild("langUsage", MEI_NAMESPACE);
            if (langUsageElement != null) {
                final List<Element> languageElementList = langUsageElement.getChildren("language", MEI_NAMESPACE);
                languageElementList.forEach(languageElement -> {
                    final String authorityValue = languageElement.getAttributeValue("authority");
                    languageElement.removeAttribute("authority");
                    languageElement.setAttribute("auth", authorityValue);
                });
            }
        }
    }

}
