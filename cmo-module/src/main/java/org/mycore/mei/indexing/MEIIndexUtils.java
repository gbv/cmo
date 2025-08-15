package org.mycore.mei.indexing;

import java.util.Collection;
import java.util.List;
import java.util.Objects;

import java.util.stream.Collectors;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.output.DOMOutputter;
import org.jdom2.transform.JDOMSource;
import org.mycore.common.MCRException;
import org.mycore.datamodel.common.MCRLinkTableManager;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mei.MEIUtils;
import org.mycore.mei.MEIWrapper;
import org.w3c.dom.NodeList;

public class MEIIndexUtils {

    /**
     * Returns a list of sources linked to the given expressionID.
     * The sources are returned as a NodeList of elements with the name "source".
     * Each source element has an attribute "id" which contains the ID of the source.
     * The sources are retrieved from the MCRLinkTableManager using the expressionID.
     * @param expressionID the ID of the expression to get linked sources for
     * @return a NodeList of source elements
     * @throws JDOMException if there is an error during the conversion to DOM
     * @see MCRLinkTableManager
     */
    public static NodeList getLinkedSources(String expressionID) {
        Element tempSourcesElement = getLinkedJDOMSources(expressionID);

        DOMOutputter domOutputter = new DOMOutputter();
        try {
            return domOutputter.output(tempSourcesElement).getElementsByTagName("source");
        } catch (JDOMException e) {
            throw new MCRException("Error while converting sources to DOM", e);
        }
    }

    private static Element getLinkedJDOMSources(String expressionID) {
        Element tempSourcesElement = new Element("sources");
        MCRLinkTableManager.instance().getSourceOf(expressionID)
            .stream()
            .filter((String str) -> str.contains("_source_"))
            .map(MCRObjectID::getInstance)
            .filter(MCRMetadataManager::exists)
            .map((MCRObjectID id) -> {
                Element sourceElement = new Element("source");
                sourceElement.setAttribute("id", id.toString());
                return sourceElement;
            }).forEach(tempSourcesElement::addContent);
        return tempSourcesElement;
    }

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
  public static NodeList getRolesOfPerson(String personIDStr) throws JDOMException {
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
