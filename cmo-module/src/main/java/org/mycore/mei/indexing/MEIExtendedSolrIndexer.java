package org.mycore.mei.indexing;

import java.util.Collection;
import org.mycore.common.events.MCREvent;
import org.mycore.datamodel.common.MCRLinkTableManager;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.solr.index.MCRSolrIndexEventHandler;

public class MEIExtendedSolrIndexer extends MCRSolrIndexEventHandler {

    @Override
    protected synchronized void addObject(MCREvent evt, MCRBase objectOrDerivate) {
        super.addObject(evt, objectOrDerivate);

        if (objectOrDerivate.getId().getTypeId().equals("source")) {
            // if the object is a source, we also index the linked sources
            MCRObject source = (MCRObject) objectOrDerivate;
            Collection<String> destinationOf = MCRLinkTableManager.instance()
                .getDestinationOf(source.getId(), "reference");
            for (String destination : destinationOf) {
                MCRObjectID destinationID = MCRObjectID.getInstance(destination);
                if (!destinationID.getTypeId().equals("source")) {
                    super.addObject(evt, MCRMetadataManager.retrieveMCRObject(destinationID));
                }
            }
        }
    }
}
