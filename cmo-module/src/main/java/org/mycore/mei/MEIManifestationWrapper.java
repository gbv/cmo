package org.mycore.mei;

import org.jdom2.Element;

public class MEIManifestationWrapper extends MEISourceWrapper {

    public MEIManifestationWrapper(Element sourceRoot) {
        super(sourceRoot);
    }

    @Override
    public String getWrappedElementName() {
        return "manifestation";
    }
}
