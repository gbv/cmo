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

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Attribute;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.Parent;
import org.jdom2.filter.Filters;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.XMLOutputter;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;

public class MEIUtils {

    public static final Namespace MEI_NAMESPACE = Namespace.getNamespace("mei", "http://www.music-encoding.org/ns/mei");

    public static final Namespace TEI_NAMESPACE = Namespace.getNamespace("tei", "http://www.tei-c.org/ns/1.0");

    private static final XPathExpression<Element> RELATION_XPATH = XPathFactory.instance()
        .compile(".//mei:relation[@target]", Filters.element(), null, TEI_NAMESPACE,
            MEI_NAMESPACE);

    private static final Logger LOGGER = LogManager.getLogger();

    private static final XPathExpression<Element> DATA_XPATH = XPathFactory.instance()
        .compile(".//tei:*[@data]|.//mei:*[@data]", Filters.element(), null, TEI_NAMESPACE, MEI_NAMESPACE);

    private static final XPathExpression<Element> TARGET_XPATH = XPathFactory.instance()
        .compile(".//tei:*[@target]|.//mei:*[@target]", Filters.element(), null, TEI_NAMESPACE, MEI_NAMESPACE);

    private static final XPathExpression<Element> EXPRESSION_LIST_XPATH = XPathFactory.instance()
        .compile(".//mei:expressionList/mei:expression", Filters.element(), null, TEI_NAMESPACE, MEI_NAMESPACE);

    private static final XPathExpression<Element> PERSON_XPATH = XPathFactory.instance()
        .compile(".//mei:persName[@dbkey]", Filters.element(), null, TEI_NAMESPACE, MEI_NAMESPACE);

    private static final XPathExpression<Attribute> PERSON_ANALOG_XPATH = XPathFactory.instance()
        .compile(".//mei:persName/@analog", Filters.attribute(), null, TEI_NAMESPACE, MEI_NAMESPACE);

    private static final XPathExpression<Element> EMBODIMENT_RELATION = XPathFactory.instance()
        .compile(".//mei:source//mei:relationList/mei:relation[@rel='isEmbodimentOf']", Filters.element(), null,
            TEI_NAMESPACE, MEI_NAMESPACE);

    private static final Namespace CMO_NAMESPACE = Namespace
        .getNamespace("cmo", "http://www.corpus-musicae-ottomanicae.de/ns/cmo");

    private static final XPathExpression<Attribute> CMO_BAD_ATTRIBUTES = XPathFactory.instance()
        .compile("//@cmo:*|//@meiversion.num", Filters.attribute(), null, TEI_NAMESPACE, MEI_NAMESPACE, CMO_NAMESPACE);

    private static final XPathExpression<Element> CMO_BAD_ELEMENTS = XPathFactory.instance()
        .compile("//cmo:*", Filters.element(), null, TEI_NAMESPACE, MEI_NAMESPACE, CMO_NAMESPACE);

    private static final String EXTRACT_XPATH_STRING = "/mei:*/mei:componentGrp/mei:*";

    public static final XPathExpression<Element> CHILD_EXTRACT_XPATH = XPathFactory
        .instance().compile(EXTRACT_XPATH_STRING, Filters.element(), null, MEIUtils.MEI_NAMESPACE);

    public static void clear(Element root) {
        CMO_BAD_ATTRIBUTES.evaluate(root).forEach(attr -> {
            attr.getParent().removeAttribute(attr);
        });
        CMO_BAD_ELEMENTS.evaluate(root).stream().forEach(elem -> {
            elem.getParent().removeContent(elem);
        });
    }

    public static void resolveLinkTargets(Element root, Consumer<String> consumer) {
        Stream<Element> linkTargetElementStream = getLinkElementStream(root);
        Function<Element, String> valueMapper = MEIUtils::getLinkTarget;
        linkTargetElementStream.map(valueMapper).forEach(consumer);
    }

    public static void clearCircularDependency(Element root) {
        PERSON_ANALOG_XPATH.evaluate(root).forEach(attribute -> {
            LOGGER.info(() -> "Remove(attribute @analog) to clear circular dependencys: " + new XMLOutputter()
                .outputString(attribute.getParent()));
            attribute.getParent().removeAttribute(attribute);
        });

        EMBODIMENT_RELATION.evaluate(root).forEach(element -> {
            LOGGER.info(() -> "Remove to clear circular dependencys: " + new XMLOutputter().outputString(element));
            element.getParent().removeContent(element);
        });
    }

    private static String getLinkTarget(Element linkElement) {
        switch (linkElement.getName()) {
            case "relation":
            case "ref":
            case "bibl":
                if (linkElement.getAttributeValue("data") != null) {
                    return linkElement.getAttributeValue("data");
                }
                if (linkElement.getAttributeValue("target") != null) {
                    return linkElement.getAttributeValue("target");
                }
            case "expression":
                return linkElement.getAttributeValue("data");
            case "persName":
                if (linkElement.getAttribute("nymref") != null) {
                    return linkElement.getAttributeValue("nymref");
                }
                if (linkElement.getAttribute("dbkey") != null) {
                    return linkElement.getAttributeValue("dbkey");
                }
                return null;
            default:
                return null;
        }
    }

    private static void setLinkTarget(Element linkElement, String newTarget) {
        switch (linkElement.getName()) {
            case "bibl":
                linkElement.removeAttribute("data");
            case "relation":
            case "ref":
                linkElement.setAttribute("target", newTarget);
                break;
            case "expression":
                linkElement.setAttribute("data", newTarget);
                break;
            case "persName":
                linkElement.removeAttribute("dbkey");
                linkElement.setAttribute("nymref", newTarget);
                break;
        }
    }

    public static void removeLinkTo(String target, Element root) {
        List<Element> elementList = getLinkElementStream(root).filter(element -> {
            if (getLinkTarget(element).equals(target)) {
                Parent parent = element.getParent();
                if (parent == null) {
                    LOGGER.warn("Parent of Element is null (target: {} element: {})", target, root.toString());
                    return false;
                } else {
                    parent.removeContent(element);
                    return true;
                }
            } else {
                return false;
            }
        }).collect(Collectors.toList());
        if (elementList.size() == 0) {
            LOGGER.warn("No Link to {} present", target);
        }
    }

    public static void changeLinkTargets(Element root, Function<String, String> changeFunction) {
        Stream<Element> linkTargetElementStream = getLinkElementStream(root);

        linkTargetElementStream.forEach(element -> {
            String oldValue, newValue;
            oldValue = getLinkTarget(element);
            if (oldValue != null) {
                newValue = changeFunction.apply(oldValue);
                if (newValue != null) {
                    setLinkTarget(element, newValue);
                }
            }
        });
    }

    public static Stream<Element> getLinkElementStream(Element root) {
        List<Element> elementList1 = TARGET_XPATH.evaluate(root);
        List<Element> elementList2 = RELATION_XPATH.evaluate(root);
        List<Element> elementList3 = EXPRESSION_LIST_XPATH.evaluate(root);
        List<Element> elementList4 = PERSON_XPATH.evaluate(root);
        List<Element> elementList5 = DATA_XPATH.evaluate(root);

        return Stream.concat(elementList1.stream(),
            Stream.concat(elementList2.stream(),
                Stream.concat(elementList3.stream(),
                    Stream.concat(elementList4.stream(), elementList5.stream())))).distinct();
    }

    public static void main(String[] args) {
        Path path = FileSystems.getDefault()
            .getPath("/Users/sebastian/IdeaProjects/gitworkspace/cmo_old/cmo-paket_all/works/wr-25544197-5.xml");
        SAXBuilder saxBuilder = new SAXBuilder();

        try (InputStream inputStream = Files.newInputStream(path)) {
            Document document = saxBuilder.build(inputStream);
            Element rootElement = document.getRootElement();

            clearCircularDependency(rootElement);
            ArrayList<String> targets = new ArrayList<>();
            resolveLinkTargets(rootElement, (e) -> {
                System.out.println("links to " + e);
                targets.add(e);
            });
            targets.forEach(t -> {
                removeLinkTo(t, rootElement);
            });
            resolveLinkTargets(rootElement, t -> {
                throw new RuntimeException("There is a lt left " + t);
            });

            extractChildren(rootElement.getAttributeValue("id", Namespace.XML_NAMESPACE), rootElement);
        } catch (IOException | JDOMException e) {
            e.printStackTrace();
        }

        Path path1 = FileSystems.getDefault()
            .getPath("/Users/sebastian/IdeaProjects/gitworkspace/cmo_old/cmo-paket_all/expressions/ex-10035085-5.xml");
        try (InputStream inputStream = Files.newInputStream(path1)) {
            Document document = saxBuilder.build(inputStream);
            Element rootElement = document.getRootElement();
            resolveLinkTargets(rootElement, (e) -> {
                System.out.println("links to " + e);
            });
            extractChildren(rootElement.getAttributeValue("id", Namespace.XML_NAMESPACE), rootElement);
        } catch (IOException | JDOMException e) {
            e.printStackTrace();
        }

        Path path2 = FileSystems.getDefault()
            .getPath("/Users/sebastian/IdeaProjects/gitworkspace/cmo_old/cmo-paket_all/prints/pr-26361457-9.xml");
        try (InputStream inputStream = Files.newInputStream(path2)) {
            Document document = saxBuilder.build(inputStream);
            Element rootElement = document.getRootElement();

            resolveLinkTargets(rootElement, (e) -> {
                System.out.println("links to " + e);
            });

            clearCircularDependency(rootElement);

            extractChildren(rootElement.getAttributeValue("id", Namespace.XML_NAMESPACE), rootElement);
        } catch (IOException | JDOMException e) {
            e.printStackTrace();
        }
    }

    public static ConcurrentHashMap<String, Document> extractChildren(String idOfElementToExtractFrom,
        Element elementToExtractFrom) {
        ConcurrentHashMap<String, Document> newChildren = new ConcurrentHashMap<>();

        CHILD_EXTRACT_XPATH.evaluate(elementToExtractFrom).forEach(matchedXpath -> {
            String idOfElementToExtract = matchedXpath.getAttributeValue("id", Namespace.XML_NAMESPACE);
            LOGGER.info("Found Element {} to extract in {}", idOfElementToExtract, idOfElementToExtractFrom);
            matchedXpath.getParent().removeContent(matchedXpath);
            Element newChild = matchedXpath.detach();
            newChildren.put(idOfElementToExtract, new Document(newChild));
        });

        ConcurrentHashMap<String, Document> newChildrenMap = new ConcurrentHashMap<>();
        newChildren.forEach((from, doc) -> {
            newChildrenMap.putAll(extractChildren(from, doc.getRootElement()));
        });

        newChildren.putAll(newChildrenMap);

        return newChildren;
    }

    public static void orderElements(Element root) {

    }

}
