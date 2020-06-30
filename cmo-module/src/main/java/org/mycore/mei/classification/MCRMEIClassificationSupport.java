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

package org.mycore.mei.classification;

import java.text.MessageFormat;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.output.DOMOutputter;
import org.mycore.common.MCRConstants;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;
import org.mycore.mei.MEIUtils;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class MCRMEIClassificationSupport {

    private static final MCRCategoryDAO DAO = MCRCategoryDAOFactory.getInstance();

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String MEICLASS_INDEX_IDS = "MEIClassIndex.ids";

    private static final String LABEL_LANG_URI = "x-uri";

    @Deprecated
    public static MCRMEIAuthorityInfo getAuthorityInfo(org.jdom2.Element classCodeElement) {
        String authority = classCodeElement.getAttributeValue("authority");
        String authorityURI = classCodeElement.getAttributeValue("authURI");
        String classCodeID = classCodeElement.getAttributeValue("id", Namespace.XML_NAMESPACE);

        return buildAuthorityInfo(authority, authorityURI, classCodeID);
    }

    @Deprecated
    public static MCRMEIAuthorityInfo buildAuthorityInfo(String authority, String authorityURI, String classCodeID) {
        if (classCodeID == null) {
            return null;
        }

        if (authority == null && authorityURI == null) {
            return null;
        }

        return new MCRMEIAuthorityInfo(authority, authorityURI);
    }

    @Deprecated
    public static MCRMEIAuthorityInfo getAuthorityInfo(Element classCodeElement) {
        String authority = classCodeElement.getAttribute("authority");
        String authorityURI = classCodeElement
            .getAttribute("authURI");
        if ("".equals(authorityURI)) {
            authorityURI = null;
        }
        if ("".equals(authority)) {
            authority = null;
        }
        String classCodeID = classCodeElement.getAttributeNS(Namespace.XML_NAMESPACE.getURI().toString(), "id");

        return buildAuthorityInfo(authority, authorityURI, classCodeID);

    }

    public static String getRootClassLabel(String classAttribute) {
        final int i = classAttribute.lastIndexOf("/")+1;
        final String classID = classAttribute.substring(i);
        final MCRCategoryID mcrCategoryID = new MCRCategoryID(classID, "");
        Optional<MCRLabel> labelOptional = DAO.getCategory(mcrCategoryID, 0).getCurrentLabel();
        if (labelOptional.isPresent()) {
            return labelOptional.get().getText();
        } else {
            return classAttribute;
        }
    }

    @Deprecated
    public static String getClassLabel(String uri, String termContent) {
        final int i = uri.lastIndexOf("/")+1;
        final String classID = uri.substring(i);

        if(termContent.contains(":")){
            termContent=termContent.split(":")[1];
        }

        final MCRCategoryID mcrCategoryID = new MCRCategoryID(classID, termContent);
        Optional<MCRLabel> labelOptional = DAO.getCategory(mcrCategoryID, 0).getCurrentLabel();
        if (labelOptional.isPresent()) {
            return labelOptional.get().getText();
        } else {
            return uri + ":" + termContent;
        }
    }

    @Deprecated
    public static String getParentClassLabel(String uri, String termContent) {
        final int i = uri.lastIndexOf("/")+1;
        final String classID = uri.substring(i);

        if(termContent.contains(":")){
            termContent=termContent.split(":")[1];
        }
        final MCRCategoryID mcrCategoryID = new MCRCategoryID(classID, termContent);
        Optional<MCRLabel> labelOptional = DAO.getParents(mcrCategoryID).get(0).getCurrentLabel();
        if (labelOptional.isPresent()) {
            return labelOptional.get().getText();
        } else {
            return uri + ":" + termContent;
        }
    }

    public static String getStdClassLabel(String uri, String termContent) {
        final int i = uri.lastIndexOf("/")+1;
        final String classID = uri.substring(i);

        if(termContent.contains(":")){
            termContent=termContent.split(":")[1];
        }
        final MCRCategoryID mcrCategoryID = new MCRCategoryID(classID, termContent);

        final List<MCRCategory> parents = DAO.getParents(mcrCategoryID);
        Optional<MCRLabel> labelOptional;

        if(parents.size()>1){
            labelOptional = parents.get(0).getCurrentLabel();
        } else {
            labelOptional = DAO.getCategory(mcrCategoryID,0).getCurrentLabel();
        }
        if (labelOptional.isPresent()) {
            return labelOptional.get().getText();
        } else {
            return uri + ":" + termContent;
        }
    }

    public static String getLabelOfLanguage(NodeList terms) {
        if (terms.getLength() == 1) {
            final Node languageItem = terms.item(0);
            final String auth = languageItem.getAttributes().getNamedItem("auth").getTextContent();
            final String id = languageItem.getAttributes().getNamedItemNS(MCRConstants.XML_NAMESPACE.getURI(), "id")
                .getTextContent();


            final MCRCategoryID categoryID = new MCRCategoryID(auth, id);
            return Optional.ofNullable(MCRCategoryDAOFactory.getInstance().getCategory(categoryID, 0))
                .map(MCRCategory::getCurrentLabel)
                .filter(Optional::isPresent)
                .map(Optional::get)
                .map(MCRLabel::getText)
                .orElseGet(() -> auth + ":" + id);
        }
        return null;
    }



    public static String getClassificationLinkFromTerm(String uri, String term) {
        final int i = uri.lastIndexOf("/")+1;
        final String classID = uri.substring(i);

        if(term.contains(":")){
            term=term.split(":")[1];
        }
        return MessageFormat
            .format("classification:metadata:0:parents:{0}:{1}", classID, term);
    }

    private static MCRCategory getClassificationFromElement(NodeList terms) {
        Node termNode = terms.item(0);
        if(termNode==null){
            return null;
        }
        Node parentNode = termNode.getParentNode();

        // in this case is a element with authority and id e.g. mei:language
        if (termNode.getNodeType() == Node.ELEMENT_NODE) {
            Element element = (Element) termNode;
            MCRMEIAuthorityInfo authority = getAuthorityInfo(element);

            if (authority != null) {
                MCRCategoryID categoryID = authority
                    .getCategoryID(element.getAttributeNS(Namespace.XML_NAMESPACE.getURI().toString(), "id"));
                return DAO.getCategory(categoryID, 0);
            }
        }

        // in this case its a mei:term
        if (parentNode.getNodeType() == Node.ELEMENT_NODE) {
            Element element = (Element) parentNode;

            String classcode = element.getAttribute("classcode");

            if (classcode != null) {
                if (classcode.startsWith("#")) {
                    classcode = classcode.substring(1);
                }

                Node classificationNode = element.getParentNode();
                if (classificationNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element classificationElement = (Element) classificationNode;
                    NodeList classCodeElements = classificationElement
                        .getElementsByTagNameNS(MEIUtils.MEI_NAMESPACE.getURI().toString(), "classCode");
                    for (int i = 0; i < classCodeElements.getLength(); i++) {
                        Element classCodeElement = (Element) classCodeElements.item(i);
                        String id = classCodeElement.getAttributeNS(Namespace.XML_NAMESPACE.getURI().toString(), "id");
                        if (id.equals(classcode)) {
                            MCRMEIAuthorityInfo authorityInfo = getAuthorityInfo(classCodeElement);
                            MCRCategoryID categoryID = authorityInfo.getCategoryID(termNode.getTextContent());
                            if (categoryID == null) {
                                LOGGER.warn("Can not resolve classification of: " + MEIUtils.getNodeString(getRoot(termNode)));
                                return null;
                            }
                            return DAO
                                .getCategory(categoryID, 0);
                        }
                    }
                }
            }

        }
        return null;
    }

    private static Node getRoot(Node x) {
        if(x.getLocalName().equals("mycoreobject")){
            return x;
        }
        Node parent = x.getParentNode();
        if (parent != null) {
            return getRoot(parent);
        }
        return x;
    }

    /**
     * @return returns all classifications which should be indexed in a extra solr-field
     */
    public static NodeList getIndexClassification() throws JDOMException {
        org.jdom2.Element list = new org.jdom2.Element("list");
        MCRConfiguration.instance().getStrings(MEICLASS_INDEX_IDS)
            .stream()
            .map(id -> new org.jdom2.Element("classification").setAttribute("id", id))
            .forEach(list::addContent);

        return new DOMOutputter().output(list).getElementsByTagName("classification");
    }

    public static String buildIDForLabel(String label) {
        return Integer.toString(label.hashCode(), 16);
    }

    public static String getClassificationIDFromURI(String authorityURI) {
        return Optional.ofNullable(getClassificationFromURI(authorityURI)).map(MCRCategory::getId)
            .map(MCRCategoryID::toString).orElse(null);
    }

    public static MCRCategory getClassificationFromURI(String authorityURI) {
        Collection<MCRCategory> classificationByURI = DAO.getCategoriesByLabel(LABEL_LANG_URI, authorityURI);
        return classificationByURI.stream().findFirst().orElse(null);
    }

    public static MCRCategoryID getChildID(MCRCategory category, String value) {
        return getChildID(category.getId(), value);
    }

    public static MCRCategoryID getChildID(MCRCategoryID categoryid, String value) {
        MCRCategoryID representedCategID = new MCRCategoryID(categoryid.getRootID(), value);
        if (DAO.exist(representedCategID)) {
            return representedCategID;
        }
        LOGGER.warn("The id: '{}' was not found in classification '{}'", value, categoryid.getRootID());
        return null;
    }

}
