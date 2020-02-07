package de.vzg.cmo.model.cli;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.List;
import java.util.stream.Collectors;

import org.mycore.common.MCRClassTools;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mei.MEIWrapper;
import org.mycore.mei.migration.MEIMigrator;

@MCRCommandGroup(name = "CMO Migration Commands")
public class MCRCMOMigrationCommands {

    private static List<MEIMigrator> migrators;

    static {
        migrators = MCRConfiguration.instance().getStrings("MCR.CMO.Migrators")
            .stream()
            .map(migrator -> {
                try {
                    final Class<? extends MEIMigrator> migratorClass = MCRClassTools.forName(migrator);
                    final Constructor<? extends MEIMigrator> constructor = migratorClass.getConstructor();
                    return constructor.newInstance();
                } catch (ClassNotFoundException | NoSuchMethodException | InstantiationException | IllegalAccessException | InvocationTargetException e) {
                    throw new MCRException("Error while creating instance of Migrator!", e);
                }
            })
            .sorted()
            .collect(Collectors.toList());
    }

    @MCRCommand(syntax = "migrate to mei4 {0}")
    public static void migrateToMEI4(String objectID){
        final MCRObjectID idObject = MCRObjectID.getInstance(objectID);

        MCRObject object = MCRMetadataManager.retrieveMCRObject(idObject);
        final MEIWrapper wrapper = MEIWrapper.getWrapper(object);
        migrators.forEach(migrator-> migrator.migrate(wrapper));
    }

}
