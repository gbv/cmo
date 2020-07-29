package de.vzg.cmo;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import org.mycore.common.xml.MCRURIResolver;
import org.mycore.mei.classification.MCRMEIClassificationSupport;

public class CMOClassificationURIResolver implements URIResolver {

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        final String classAndTerm = href.substring("meiClassification:".length());
        final int i = classAndTerm.lastIndexOf("/");
        final String clazz = classAndTerm.substring(0, i);
        final String term = classAndTerm.substring(i + 1);

        return MCRURIResolver.instance()
            .resolve(MCRMEIClassificationSupport.getClassificationLinkFromTerm(clazz, term), base);
    }

}
