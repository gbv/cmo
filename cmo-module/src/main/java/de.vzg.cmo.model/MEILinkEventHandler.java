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

import static org.mycore.datamodel.common.MCRLinkTableManager.ENTRY_TYPE_REFERENCE;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.common.MCRLinkTableManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * This event handler looks to which objects the created/edited object links in the metadata and according to this
 * information it updates the Database.
 */
public class MEILinkEventHandler extends MCREventHandlerBase {

    private static final Logger LOGGER = LogManager.getLogger();

    static MCRLinkTableManager linkTable = MCRLinkTableManager.instance();

    @Override
    protected void handleObjectCreated(MCREvent evt, MCRObject obj) {
        Element objectXML = obj.getMetadata().createXML();

        MCRObjectID id = obj.getId();
        deleteOldLinks(id);

        MEIUtils.resolveLinkTargets(objectXML, (linksTo) -> {
            LOGGER.info("Add reference from {} to {} to the Database.", id, linksTo);
            linkTable.addReferenceLink(id.toString(), linksTo, ENTRY_TYPE_REFERENCE, "");
        });
    }

    @Override
    protected void handleObjectDeleted(MCREvent evt, MCRObject obj) {
        deleteOldLinks(obj.getId());
    }

    @Override protected void handleObjectRepaired(MCREvent evt, MCRObject obj) {
        handleObjectCreated(evt, obj);
    }

    private void deleteOldLinks(final MCRObjectID objectId) {
        LOGGER.info("Remove all references form {} from Database!", objectId);
        linkTable.deleteReferenceLink(objectId);
    }
}
