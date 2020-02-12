package org.mycore.mei.migration;

import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.atomic.AtomicReference;

import javax.naming.OperationNotSupportedException;

import org.mycore.common.MCRException;
import org.mycore.mei.MEIWrapper;
import org.mycore.mei.classification.MCRMEIAuthorityInfo;

public class MEIClassificationMigrator extends MEIMigrator {

    @Override
    public void migrate(MEIWrapper obj) {
        final HashMap<MCRMEIAuthorityInfo, List<String>> oldClass = obj.getClassificationOld();
        final HashMap<String, List<String>> migrated = new HashMap<>();
        oldClass.keySet().forEach(authInfo -> {
            AtomicReference<String> clazz = new AtomicReference<>();

            final String authorityURI = authInfo.getAuthorityURI();
            Optional.ofNullable(authorityURI).ifPresent(clazz::set);

            final List<String> values = oldClass.get(authInfo);
            if (clazz.get() == null) {
                throw new MCRException("Could not detect class value for " + authInfo.toString());
            }
            migrated.put(clazz.get(), values);
        });
        try {
            if(migrated.size()>0){
                obj.setClassification(migrated);
            }
        } catch (OperationNotSupportedException e) {
            // this is ok
        }
    }
}
