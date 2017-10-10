package org.mycore.mei.indexing;

import java.util.Collection;
import java.util.Objects;

import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.output.DOMOutputter;
import org.mycore.datamodel.common.MCRLinkTableManager;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mei.MEIUtils;
import org.mycore.mei.MEIWrapper;

public class MEIIndexUtils {

    /**
     * A roles elements looks like:
     * <code>
     *        &lt;role name=&quot;lyricist&quot; in=&quot;cmo_expression_00000000&quot;/&gt;
     *        &lt;role name=&quot;expression&quot; in=&quot;cmo_expression_00000000&quot;/&gt;
     * </code>
     *
     * @param personIDStr
     * @return role elements
     * @throws JDOMException
     */
    public static org.w3c.dom.NodeList getRolesOfPerson(String personIDStr) throws JDOMException {
        Element el = new Element("roles");

        MCRObjectID personID = MCRObjectID.getInstance(personIDStr);
        String persID = personID.toString();
        Collection<String> sources = MCRLinkTableManager.instance()
            .getSourceOf(persID, MCRLinkTableManager.ENTRY_TYPE_REFERENCE);

        sources.stream().map(MCRObjectID::getInstance)
            .map(MCRMetadataManager::retrieveMCRObject)
            .filter(obj -> MEIWrapper.getWrapper(obj) != null)
            .map(obj -> {
                MEIWrapper wrapper = MEIWrapper.getWrapper(obj);
                return MEIUtils.getLinkElementStream(wrapper.getRoot())
                    .filter(element -> Objects.equals(MEIUtils.getLinkTarget(element), persID))
                    .map(element -> {
                        String parentElementName = ((Element) element.getParent()).getName();
                        switch (parentElementName) {
                            case "lyricist":
                            case "composer":
                                Element role = new Element("role");
                                role.setAttribute("in", obj.getId().toString());
                                role.setAttribute("name", parentElementName);
                                return role;
                            default:
                                return null;
                        }
                    }).filter(Objects::nonNull);
            }).flatMap(s -> s)
            .forEach(el::addContent);
        return new DOMOutputter().output(el).getElementsByTagName("role");
    }
}
