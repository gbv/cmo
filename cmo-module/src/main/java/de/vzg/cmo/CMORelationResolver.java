package de.vzg.cmo;

import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;
import org.mycore.datamodel.common.MCRLinkTableManager;
import org.mycore.datamodel.metadata.MCRObjectID;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import java.util.Collection;
import java.util.List;

public class CMORelationResolver implements URIResolver {

    public static final String MODE_SOURCES_BY_LINK_TO_EXPRESSION = "sourcesByLinkToExpression";

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        String[] split = href.split(":");

        if (split.length != 3) {
            throw new TransformerException("Invalid relation format: " + href + " ");
        }

        //String resolver = split[0];
        String mode = split[1];
        String idStr = split[2];

        if(!MCRObjectID.isValid(idStr)){
            throw new TransformerException("Invalid object id: " + idStr);
        }

        MCRObjectID id = MCRObjectID.getInstance(idStr);

        switch (mode){
            case MODE_SOURCES_BY_LINK_TO_EXPRESSION:
                return resolveSourcesByLinkToExpression(id);
            default:
                throw new TransformerException("Unknown mode: " + mode);
        }
    }

    /**
     * Resolves all the sources linked to the expression with the given id
     * @param id the object id
     * @return a source containing the list of objects
     */
    protected Source resolveSourcesByLinkToExpression(MCRObjectID id) {
        Collection<String> sourceOf = MCRLinkTableManager.instance().getSourceOf(id, MCRLinkTableManager.ENTRY_TYPE_REFERENCE);
        List<MCRObjectID> sources = sourceOf.stream().filter(MCRObjectID::isValid)
                .map(MCRObjectID::getInstance)
                .filter(linkSource -> linkSource.getTypeId().equals("source"))
                .toList();

        return buildObjectList(sources);
    }


    /**
     * Builds a list of objects
     * @param objectIDList list of object ids
     * @return a source containing the list of objects
     */
    protected Source buildObjectList(List<MCRObjectID> objectIDList) {
        Element objects = new Element("objects");

        objectIDList.forEach(objectID -> {
            Element object = new Element("object");
            object.setAttribute("id", objectID.toString());
            objects.addContent(object);
        });

        return new JDOMSource(objects);
    }
}
