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

package org.mycore.mei;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Consumer;
import java.util.function.Predicate;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.naming.OperationNotSupportedException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Attribute;
import org.jdom2.Content;
import org.jdom2.Element;
import org.jdom2.EntityRef;
import org.jdom2.Namespace;
import org.jdom2.ProcessingInstruction;
import org.jdom2.Text;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.datamodel.metadata.MCRMetaElement;
import org.mycore.datamodel.metadata.MCRMetaXML;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mei.classification.MCRMEIAuthorityInfo;
import org.mycore.mei.classification.MCRMEIClassificationSupport;

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

public abstract class MEIWrapper {

    private static final XPathExpression<Element> DATE_XPATH = XPathFactory.instance()
        .compile(".//mei:date", Filters.element(), null, MEI_NAMESPACE);

    private static final Logger LOGGER = LogManager.getLogger();

    private static final Set<String> ALLOWED_EMPTY_NODES = Stream.of("lb").collect(Collectors.toSet());

    private final Element root;

    protected MEIWrapper(Element root) {
        String rootName = root.getName();
        if (!isValidName(rootName)) {
            throw new IllegalArgumentException(rootName + " is can not be wrapped by " + this.getClass().toString());
        }
        this.root = root;
    }

    private boolean isValidName(String rootName) {
        return getWrappedElementName().equals(rootName);
    }

    @Deprecated(forRemoval = true)
    public static MEIWrapper getWrapper(Element rootElement) {
        return getWrapper(rootElement, MEIWrapper.class);
    }

    public static <T extends MEIWrapper> T getWrapper(Element rootElement, Class<T> wrapperClass) {
        String id = rootElement.getName();
        switch (id) {
            case "manifestation":
                return wrapperClass.cast(new MEIManifestationWrapper(rootElement));
            case "source":
              return wrapperClass.cast(new MEISourceWrapper(rootElement));
            case "expression":
              return wrapperClass.cast(new MEIExpressionWrapper(rootElement));
            case "persName":
              return wrapperClass.cast(new MEIPersonWrapper(rootElement));
            case "work":
              return wrapperClass.cast(new MEIWorkWrapper(rootElement));
            case "mycoreobject":
                return getWrapper(
                    XPathFactory.instance()
                        .compile("metadata/def.meiContainer/meiContainer/*", Filters.element())
                        .evaluateFirst(rootElement), wrapperClass);
        }
        return null;
    }

    @Deprecated(forRemoval = true)
    public static MEIWrapper getWrapper(MCRObject object) {
        return getWrapper(object, MEIWrapper.class);
    }

    /**
     * Gets the MEIWrapper for a specific MyCoRe-Object.
     * @param object
     * @return the wrapper or null if it cannot be wrapped
     */
    public static <T extends MEIWrapper> T getWrapper(MCRObject object, Class<T> wrapperClass) {
        MCRMetaElement metadataElement = object.getMetadata().getMetadataElement("def.meiContainer");
        if (metadataElement != null) {
            MCRMetaXML mx = (MCRMetaXML) (metadataElement.getElement(0));
            for (Content content : mx.getContent()) {
                if (content instanceof Element) {
                    return getWrapper((Element) content, wrapperClass);
                }
            }
        }

        return null;
    }

    @Deprecated(forRemoval = true)
    public static MEIWrapper getWrapper(String objectIdString) {
      return getWrapper(objectIdString, MEIWrapper.class);
    }

    public static <T extends MEIWrapper> T getWrapper(String objectIdString, Class<T> wrapperClass) {
        MCRObjectID objectID = MCRObjectID.getInstance(objectIdString);
        MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
        return getWrapper(object, wrapperClass);
    }

    /**
     * @param node
     * @return true if the content is empty and can be removed
     */
    public boolean removeEmptyNodes(Content node) {
        if (node instanceof Element) {
            Predicate<Content> removeNodes = this::removeEmptyNodes;
            List<Content> content = ((Element) node).getContent();
            List<Content> elementsToRemove = content.stream().filter(removeNodes)
                .collect(Collectors.toList());
            elementsToRemove.forEach(((Element) node)::removeContent);

            return !isElementRelevant((Element) node);
        } else if (node instanceof Text) {
            return ((Text) node).getTextTrim().equals("");
        } else if (node instanceof ProcessingInstruction || node instanceof EntityRef) {
            return false;
        }

        return true;
    }

    protected boolean isElementRelevant(Element element) {
        final String elementName = element.getName();
        final Element parentElement = element.getParentElement();

        if (parentElement == null) {
            return false;
        }

        if (elementName.equals("head") && parentElement.getChildren().size() <= 1) {
            // event with only head can be removed
            return false;
        }

        if (elementName.equals("geogName") && element.getContent().size() == 0) {
            return false;
        }

        if (elementName.equals("hand") && element.getContent().size() == 0) {
            return false;
        }

        if (elementName.equals("dimensions") && element.getContent().size() == 0) {
            return false;
        }

        if (elementName.equals("identifier") && element.getContent().size() == 0) {
            return false;
        }

        if (elementName.equals("event") && element.getContent().stream()
            .noneMatch(content -> !content.getCType().equals(
                Content.CType.Element) || !((Element) content).getName().equals("head"))) {
            return false;
        }

        if (elementName.equals("desc") || elementName.equals("annot")) {
            return !element.getContent().stream()
                .allMatch(content -> content instanceof Element && "lb".equals(((Element) content).getName()));
        }

        final boolean attributesRelevant = element.getAttributes()
            .stream().anyMatch(MEIWrapper::isAttributeRelevant);

        return attributesRelevant || element.getContent().size() > 0 || ALLOWED_EMPTY_NODES.contains(elementName);
    }

    private static boolean isAttributeRelevant(Attribute attribute) {
        final Element parentElement = attribute.getParent();
        if (parentElement == null) {
            return false;
        }

        if (parentElement.getName().equals("geogName") && attribute.getName().equals("type")) {
            return false;
        }

        if (parentElement.getName().equals("corpName") && attribute.getName().equals("type")) {
            return false;
        }

        if (parentElement.getName().equals("hand") && attribute.getName().equals("lang")) {
            return false;
        }

        if(parentElement.getName().equals("relation") && attribute.getName().equals("label")){
            return false;
        }

        return true;
    }

    public abstract String getWrappedElementName();

    public Element getRoot() {
        return root;
    }

    protected abstract int getRankOf(Element topLevelElement);

    public void orderTopLevelElement() {
        Consumer<Element> elementConsumer = this.root::removeContent;
        Comparator<Element> sortFn = Comparator.comparingInt(this::getRankOf);
        new ArrayList<>(this.root.getChildren())
            .stream()
            .peek(elementConsumer)
            .sorted(sortFn)
            .forEach(this.root::addContent);
    }

    public void normalize() {
        List<Element> dates = DATE_XPATH.evaluate(this.root);

        dates.forEach(dateElement -> {
            String notBefore = dateElement.getAttributeValue("notbefore");
            String notAfter = dateElement.getAttributeValue("notafter");
            String startDate = dateElement.getAttributeValue("startdate");
            String endDate = dateElement.getAttributeValue("enddate");

            if (notBefore != null && notBefore.equals(notAfter)) {
                LOGGER.info("clean up notbefore:{} and notafter:{} (same)", notBefore, notAfter);
                dateElement.removeAttribute("notebefore");
                dateElement.removeAttribute("notafter");

                if (dateElement.getAttribute("isodate") == null) {
                    dateElement.setAttribute("isodate", notBefore);
                } else {
                    LOGGER.warn("ISO date is already set. Not sure what to do now!");
                }
            }

            if (startDate != null && startDate.equals(endDate)) {
                LOGGER.info("clean up startdate:{} and enddate:{} (same)", startDate, endDate);
                dateElement.removeAttribute("startdate");
                dateElement.removeAttribute("enddate");

                if (dateElement.getAttribute("isodate") == null) {
                    dateElement.setAttribute("isodate", startDate);
                } else {
                    LOGGER.warn("ISO date is already set. Not sure what to do now!");
                }
            }
        });
    }

    public HashMap<String, List<String>> getClassification() {
        Element classificationElement = this.root.getChild("classification", MEI_NAMESPACE);
        HashMap<String, List<String>> classificationMap = new HashMap<>();
        if (classificationElement != null) {
            List<Element> terMListElements = classificationElement.getChildren("termList", MEI_NAMESPACE);
            terMListElements.forEach(termListElement -> {
                final String clazz = termListElement.getAttributeValue("class");
                final List<Element> terms = termListElement.getChildren("term", MEI_NAMESPACE);
                classificationMap.put(clazz, terms.stream().map(Element::getTextTrim).collect(Collectors.toList()));
            });
        }
        return classificationMap;
    }

    public void setClassification(HashMap<String, List<String>> classificationMap)
        throws OperationNotSupportedException {
        deleteClassification();
        Element classificationElement = new Element("classification", MEI_NAMESPACE);

        classificationMap.keySet().forEach(clazz -> {
            final Element termList = new Element("termList", MEI_NAMESPACE);
            termList.setAttribute("class", clazz);
            classificationMap.get(clazz).stream().map(val -> {
                final Element term = new Element("term", MEI_NAMESPACE);
                term.setText(val);
                return term;
            }).forEach(termList::addContent);
            if (termList.getChildren().size() > 0) {
                classificationElement.addContent(termList);
            }
        });

        if (classificationElement.getChildren().size() > 0) {
            this.root.addContent(classificationElement);
        }
    }

    public HashMap<MCRMEIAuthorityInfo, List<String>> getClassificationOld() {
        Element classificationElement = this.root.getChild("classification", MEI_NAMESPACE);
        HashMap<MCRMEIAuthorityInfo, List<String>> classificationMap = new HashMap<>();

        if (classificationElement != null) {
            List<Element> classCodes = classificationElement.getChildren("classCode", MEI_NAMESPACE);
            List<Element> terMListElements = classificationElement.getChildren("termList", MEI_NAMESPACE);

            if (classCodes.size() == 0) { // this should happen if the classification is already migrated
                return classificationMap;
            }
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
                List<Element> terms = matchingList.getChildren("term", MEI_NAMESPACE);
                List<String> termStringList = terms.stream().map(e -> e.getTextTrim()).collect(Collectors.toList());
                classificationMap.put(authorityInfo, termStringList);
            }
        }

        return classificationMap;
    }

    public void setClassificationOld(Map<MCRMEIAuthorityInfo, List<String>> classificationMap)
        throws OperationNotSupportedException {
        deleteClassification();
        Element classificationElement = new Element("classification", MEI_NAMESPACE);
        if (classificationMap.size() > 0) {
            this.root.addContent(classificationElement);
            classificationMap.forEach((authorityInfo, valueList) -> {
                Element classCodeElement = new Element("classCode", MEI_NAMESPACE);
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

                Element termList = new Element("termList", MEI_NAMESPACE);
                termList.setAttribute("classcode", "#" + uniqID);
                classificationElement.addContent(termList);

                valueList
                    .stream()
                    .map(v -> {
                        Element term = new Element("term", MEI_NAMESPACE);
                        term.setText(v);
                        return term;
                    }).forEach(termList::addContent);
            });
        }
    }

    public Element getXpath(String xpath) {
        XPathExpression<Element> expression = XPathFactory.instance().compile(xpath, Filters.element(), null, MEI_NAMESPACE);
        return expression.evaluateFirst(this.root);
    }

    public Element getElement(String name) {
        return this.root.getChild(name, MEI_NAMESPACE);
    }

    public Element getOrCreateElement(String name) {
        Element element = this.root.getChild(name, MEI_NAMESPACE);
        if (element == null) {
            element = new Element(name, MEI_NAMESPACE);
            this.root.addContent(element);
        }
        return element;
    }

    public void deleteClassification() {
        this.root.getChildren("classification", MEI_NAMESPACE).forEach(Element::detach);
    }

    /**
     * Removes all empty elements recursive
     */
    public void removeEmptyElements() {
        removeEmptyNodes(this.root);
    }

    public void fixElements() {
    }
}
