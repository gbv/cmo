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

import de.vzg.cmo.model.MEIUtils;

import java.util.Optional;

import org.jdom2.Namespace;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRLabel;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

public class MCRMEIClassificationSupport {

    private static final MCRCategoryDAO DAO = MCRCategoryDAOFactory.getInstance();

    public static MCRMEIAuthorityInfo getAuthorityInfo(org.jdom2.Element classCodeElement) {
        String authority = classCodeElement.getAttributeValue("authority");
        String authorityURI = classCodeElement.getAttributeValue("authorityURI");
        String classCodeID = classCodeElement.getAttributeValue("id", Namespace.XML_NAMESPACE);

        return buildAuthorityInfo(authority, authorityURI, classCodeID);
    }

    public static MCRMEIAuthorityInfo buildAuthorityInfo(String authority, String authorityURI, String classCodeID) {
        if (classCodeID == null) {
            return null;
        }

        if (authority == null && authorityURI == null) {
            return null;
        }

        return new MCRMEIAuthorityInfo(authority, authorityURI);
    }

    public static MCRMEIAuthorityInfo getAuthorityInfo(Element classCodeElement) {
        String authority = classCodeElement.getAttribute("authority");
        String authorityURI = classCodeElement
            .getAttribute("authorityURI");
        if("".equals(authorityURI)){
            authorityURI = null;
        }
        if("".equals(authority)){
            authority = null;
        }
        String classCodeID = classCodeElement.getAttributeNS(Namespace.XML_NAMESPACE.getURI().toString(), "id");

        return buildAuthorityInfo(authority, authorityURI, classCodeID);

    }

    public static String getClassLabel(NodeList classCodes) {
        if (classCodes.getLength() == 0) {
            return null;
        }

        final Element classCode = (Element) classCodes.item(0);
        MCRMEIAuthorityInfo authorityInfo = getAuthorityInfo(classCode);

        Optional<MCRLabel> labelOptional = DAO.getCategory(authorityInfo.getRootID(), 0).getCurrentLabel();
        if (labelOptional.isPresent()) {
            return labelOptional.get().getText();
        } else {
            return authorityInfo.getRootID().getID();
        }
    }

    public static String getClassValue(NodeList terms) {
        Node termNode = terms.item(0);
        Node termList = termNode.getParentNode();

        if (termList.getNodeType() == Node.ELEMENT_NODE) {
            Element termListElement = (Element) termList;

            String classcode = termListElement.getAttribute("classcode");
            if (classcode != null) {
                if (classcode.startsWith("#")) {
                    classcode = classcode.substring(1);
                }

                Node classificationNode = termListElement.getParentNode();
                if (classificationNode.getNodeType() == Node.ELEMENT_NODE) {
                    Element classificationElement = (Element) classificationNode;
                    NodeList classCodeElements = classificationElement
                        .getElementsByTagNameNS(MEIUtils.MEI_NAMESPACE.getURI().toString(), "classCode");
                    for (int i = 0; i < classCodeElements.getLength(); i++) {
                        Element classCodeElement = (Element) classCodeElements.item(i);
                        String id = classCodeElement.getAttributeNS(Namespace.XML_NAMESPACE.getURI().toString(), "id");
                        if(id.equals(classcode)){
                            MCRMEIAuthorityInfo authorityInfo = getAuthorityInfo(classCodeElement);
                            Optional<MCRLabel> currentLabel = DAO
                                .getCategory(authorityInfo.getCategoryID(termNode.getTextContent()), 0)
                                .getCurrentLabel();

                            if(currentLabel.isPresent()){
                                return currentLabel.get().getText();
                            }
                        }
                    }
                }
            }
        }

        return termNode.getTextContent();
    }

}
