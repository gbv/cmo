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

import java.util.Collection;
import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.MCRException;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;

public class MCRMEIAuthorityInfo {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String LABEL_LANG_URI = "x-uri";

    private static final MCRCategoryDAO DAO = MCRCategoryDAOFactory.getInstance();

    private static final String LABEL_LANG_AUTH = "x-auth";

    private String authority = null;

    private String authorityURI = null;

    private MCRCategoryID classificationID;

    public MCRMEIAuthorityInfo(String authority, String authorityURI) {
        this.authority = authority;
        this.authorityURI = authorityURI;

        if (authorityURI != null) {
            Collection<MCRCategory> classificationByURI = DAO.getCategoriesByLabel(LABEL_LANG_URI, authorityURI);
            classificationID = classificationByURI.stream().findFirst().map(MCRCategory::getId).orElse(null);
        } else {
            classificationID = MCRCategoryID.rootID(authority);
        }

        if (classificationID == null || !DAO.exist(classificationID)) {
            throw new MCRException("Classification with authority '" + authority + "' or authority " + authorityURI
                + " could not be mapped!");
        }

        MCRCategory category = DAO.getCategory(classificationID, 0);
        category.getLabel(LABEL_LANG_URI).ifPresent(label -> this.authorityURI = label.getText());
        category.getLabel(LABEL_LANG_AUTH).ifPresent(label -> this.authority = label.getText());
    }

    /**
     * Returns the label value of the given type ("language"), or the given default if that label does not exist in the
     * category.
     */
    protected static String getLabel(MCRCategory category, String labelType, String defaultLabel) {
        return category.getLabel(labelType).map(MCRLabel::getText).orElse(defaultLabel);
    }

    /**
     * Returns the category ID that is represented by this authority information.
     * @return the category ID that maps this authority information, or null if no matching category exists.
     */
    public MCRCategoryID getCategoryID(String value) {
        MCRCategoryID representedCategID = new MCRCategoryID(getRootID().getRootID(), value);
        if (DAO.exist(representedCategID)) {
            return representedCategID;
        }

        LOGGER.warn("The id: '{}' was not found in classification '{}'", value, getRootID().getRootID());
        return null;
    }

    public MCRCategoryID getRootID() {
        return classificationID;
    }

    public String getAuthority() {
        return authority;
    }

    public String getAuthorityURI() {
        return authorityURI;
    }

    @Override
    public boolean equals(Object obj) {
        if (!(obj instanceof MCRMEIAuthorityInfo)) {
            return false;
        }
        MCRMEIAuthorityInfo otherAuthority = (MCRMEIAuthorityInfo) obj;
        MCRCategoryID obj1RootID = getRootID();
        MCRCategoryID obj2RootID = otherAuthority.getRootID();
        return obj1RootID != null && obj2RootID != null && obj1RootID.equals(obj2RootID);
    }

    @Override
    public int hashCode() {
        return this.getRootID().hashCode();
    }

    @Override
    public String toString() {
        return Optional.ofNullable(getAuthorityURI()).orElse(getAuthority());
    }
}
