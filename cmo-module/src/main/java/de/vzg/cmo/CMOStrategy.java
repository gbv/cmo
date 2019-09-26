package de.vzg.cmo;

import java.util.List;

import org.mycore.access.strategies.MCRCreatorRuleStrategy;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.mods.MCRMODSWrapper;

public class CMOStrategy extends MCRCreatorRuleStrategy {

    @Override
    public boolean checkPermission(String id, String permission) {
        // disallow mint of doi for mods bibl
        if ("register-Datacite".equals(permission)) {
            final MCRObjectID objectID = MCRObjectID.getInstance(id);
            if ("mods".equals(objectID.getTypeId())) {
                final MCRObject modsObject = MCRMetadataManager.retrieveMCRObject(objectID);
                final MCRMODSWrapper wrapper = new MCRMODSWrapper(modsObject);
                final List<MCRCategoryID> categoryIDs = wrapper.getMcrCategoryIDs();
                if (categoryIDs.stream().anyMatch(categoryID ->
                    "cmo_kindOfData".equals(categoryID.getRootID()) && "source".equals(categoryID.getID()))) {
                    return false;
                }
            }
        }

        return super.checkPermission(id, permission);
    }
}
