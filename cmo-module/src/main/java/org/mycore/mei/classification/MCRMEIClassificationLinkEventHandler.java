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

import org.mycore.datamodel.classifications2.MCRCategLinkReference;
import org.mycore.datamodel.classifications2.MCRCategLinkServiceFactory;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.mei.MEIWrapper;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.classifications2.MCRCategoryDAO;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRObject;

import java.util.HashSet;

public class MCRMEIClassificationLinkEventHandler extends MCREventHandlerBase {

    private static final MCRCategoryDAO DAO = MCRCategoryDAOFactory.getInstance();

    private static final Logger LOGGER = LogManager.getLogger();

    @Override
    protected void handleObjectCreated(MCREvent evt, MCRObject obj) {
        MEIWrapper wrapper = MEIWrapper.getWrapper(obj);
        if (wrapper != null) {
            wrapper.getClassification().forEach((classification, valueList) -> {
                final MCRCategory classificationFromURI = MCRMEIClassificationSupport
                    .getClassificationFromURI(classification);

                HashSet<MCRCategoryID> categories = new HashSet<>();
                valueList.forEach(categValue -> {
                    final MCRCategoryID categoryID = MCRMEIClassificationSupport
                        .getChildID(classificationFromURI, categValue);

                    if (categoryID == null) {
                        LOGGER.warn("Could not find unknown classification: {} -> {},{}", obj.getId().toString(),
                            classification, categValue);
                    } else {
                        categories.add(categoryID);
                    }
                });
                if (!categories.isEmpty()) {
                    final MCRCategLinkReference objectReference = new MCRCategLinkReference(obj.getId());
                    MCRCategLinkServiceFactory.getInstance().setLinks(objectReference, categories);
                }
            });
        }
    }


    @Override
    protected void handleObjectUpdated(MCREvent evt, MCRObject obj) {
        handleObjectCreated(evt, obj);
    }

    @Override
    protected void handleObjectRepaired(MCREvent evt, MCRObject obj) {
        handleObjectCreated(evt, obj);
    }
}
