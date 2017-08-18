/*
 *  This file is part of ***  M y C o R e  ***
 *  See http://www.mycore.de/ for details.
 *
 *  This program is free software; you can use it, redistribute it
 *  and / or modify it under the terms of the GNU General Public License
 *  (GPL) as published by the Free Software Foundation; either version 2
 *  of the License or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program, in a file called gpl.txt or license.txt.
 *  If not, write to the Free Software Foundation Inc.,
 *  59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 *
 */

package de.vzg.cmo.model;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Consumer;
import java.util.stream.Collectors;

import javax.naming.OperationNotSupportedException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Content;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.mycore.datamodel.metadata.MCRMetaElement;
import org.mycore.datamodel.metadata.MCRMetaXML;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mei.classification.MCRMEIAuthorityInfo;
import org.mycore.mei.classification.MCRMEIClassificationSupport;

public abstract class MEIWrapper {

    private final Element root;

    private static final Logger LOGGER = LogManager.getLogger();

    protected MEIWrapper(Element root) {
        String rootName = root.getName();
        if (!getWrappedElementName().equals(rootName)) {
            throw new IllegalArgumentException(rootName + " is can not be wrapped by " + this.getClass().toString());
        }
        this.root = root;
    }

    public abstract String getWrappedElementName();

    public Element getRoot() {
        return root;
    }

    protected abstract int getRankOf(Element topLevelElement);

    public void orderTopLevelElement() {
        Consumer<Element> elementConsumer = (Consumer<Element>) this.root::removeContent;
        Comparator<Element> sortFn = (e1, e2) -> getRankOf(e1) - getRankOf(e2);
        new ArrayList<>(this.root.getChildren())
            .stream()
            .peek(elementConsumer)
            .sorted(sortFn)
            .forEach(this.root::addContent);
    }

    public static MEIWrapper getWrapper(Element rootElement) {
        String id = rootElement.getName();
        switch (id) {
            case "source":
                return new MEISourceWrapper(rootElement);
            case "expression":
                return new MEIExpressionWrapper(rootElement);
            case "persName":
                return new MEIPersonWrapper(rootElement);
            case "work":
                return new MEIWorkWrapper(rootElement);
        }
        return null;
    }

    /**
     * Gets the MEIWrapper for a specific MyCoRe-Object.
     * @param object
     * @return the wrapper or null if it cannot be wrapped
     */
    public static MEIWrapper getWrapper(MCRObject object) {
        MCRMetaElement metadataElement = object.getMetadata().getMetadataElement("def.meiContainer");
        if (metadataElement != null) {
            MCRMetaXML mx = (MCRMetaXML) (metadataElement.getElement(0));
            for (Content content : mx.getContent()) {
                if (content instanceof Element) {
                    return getWrapper((Element) content);
                }
            }
        }

        return null;
    }

    public static MEIWrapper getWrapper(String objectIdString){
        MCRObjectID objectID = MCRObjectID.getInstance(objectIdString);
        MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
        return getWrapper(object);
    }


    public HashMap<MCRMEIAuthorityInfo, List<String>> getClassification() {
        Element classificationElement = this.root.getChild("classification", MEIUtils.MEI_NAMESPACE);
        HashMap<MCRMEIAuthorityInfo, List<String>> classificationMap = new HashMap<>();

        if (classificationElement != null) {
            List<Element> classCodes = classificationElement.getChildren("classCode", MEIUtils.MEI_NAMESPACE);
            List<Element> terMListElements = classificationElement.getChildren("termList", MEIUtils.MEI_NAMESPACE);

            for (Element classCodeElement : classCodes) {
                // this is the value which is used to Link a term to class code
                String classCodeID = classCodeElement.getAttributeValue("id", Namespace.XML_NAMESPACE);


                MCRMEIAuthorityInfo authorityInfo = MCRMEIClassificationSupport.getAuthorityInfo(classCodeElement);

                Optional<Element> matchingListOptional = terMListElements.stream()
                    .filter(element -> ("#" + classCodeID).equals(element.getAttributeValue("classcode")))
                    .findFirst();

                if (!matchingListOptional.isPresent()) {
                    LOGGER.warn("No matching term list for " + classCodeID + ". Skip Element..");
                    continue;
                }

                Element matchingList = matchingListOptional.get();
                List<Element> terms = matchingList.getChildren("term", MEIUtils.MEI_NAMESPACE);
                List<String> termStringList = terms.stream().map(e -> e.getTextTrim()).collect(Collectors.toList());
                classificationMap.put(authorityInfo, termStringList);
            }
        }

        return classificationMap;
    }

    public void setClassification(Map<MCRMEIAuthorityInfo, List<String>> classificationMap)
        throws OperationNotSupportedException {
        deleteClassification();
        Element classificationElement = new Element("classification", MEIUtils.MEI_NAMESPACE);
        if (classificationMap.size() > 0) {
            this.root.addContent(classificationElement);
            classificationMap.forEach((authorityInfo, valueList) -> {
                Element classCodeElement = new Element("classCode", MEIUtils.MEI_NAMESPACE);
                String authorityURI = authorityInfo.getAuthorityURI();
                if (authorityURI != null) {
                    classCodeElement.setAttribute("authURI", authorityURI);
                }
                String authority = authorityInfo.getAuthority();
                if (authority != null) {
                    classCodeElement.setAttribute("authority", authority);
                }

                String uniqID = String.format("id%s", Integer.toHexString(authorityInfo.hashCode()));
                classCodeElement.setAttribute("id", uniqID, Namespace.XML_NAMESPACE);
                classificationElement.addContent(classCodeElement);

                Element termList = new Element("termList", MEIUtils.MEI_NAMESPACE);
                termList.setAttribute("classcode", "#" + uniqID);
                classificationElement.addContent(termList);

                valueList
                    .stream()
                    .map(v -> {
                        Element term = new Element("term", MEIUtils.MEI_NAMESPACE);
                        term.setText(v);
                        return term;
                    }).forEach(termList::addContent);
            });
        }
    }

    public void deleteClassification() {
        this.root.getChildren("classification", MEIUtils.MEI_NAMESPACE).forEach(Element::detach);
    }


    /**
     * Removes all empty elements recursive
     */
    public void removeEmptyElements() {
        MEIUtils.removeEmptyNodes(this.root);
    }
}
