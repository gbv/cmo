package de.vzg.cmo.model.cli;

import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import javax.naming.OperationNotSupportedException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jdom2.xpath.XPathFactory;
import org.mycore.access.MCRAccessException;
import org.mycore.common.MCRClassTools;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration;
import org.mycore.common.config.MCRConfigurationDir;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.MCRObjectCommands;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mei.MEIWrapper;
import org.mycore.mei.migration.CMOClassificationIDPatch;
import org.mycore.mei.migration.MEIMigrator;

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

@MCRCommandGroup(name = "CMO Migration Commands")
public class MCRCMOMigrationCommands {

    public static final String MIGRATE_CLASSIFICATIONS_IN_OBJECT = "migrate classifications in object ";

    private static final Logger LOGGER = LogManager.getLogger();

    private static List<MEIMigrator> migrators;

    private static final String UPDATE_CLASSIFICATION_FROM_FILE = "update classification from file ";

    private static List<CMOClassificationIDPatch> patches;

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
    public static void migrateToMEI4(String objectID) throws MCRAccessException {
        final MCRObjectID idObject = MCRObjectID.getInstance(objectID);

        MCRObject object = MCRMetadataManager.retrieveMCRObject(idObject);
        final MEIWrapper wrapper = MEIWrapper.getWrapper(object);
        migrators.forEach(migrator -> migrator.migrate(wrapper));
        object.validate();
        MCRMetadataManager.update(object);
    }

    @MCRCommand(syntax = MIGRATE_CLASSIFICATIONS_IN_OBJECT + "{0}")
    public static void migrateObject(String id) throws OperationNotSupportedException, MCRAccessException {
        MCRObject obj = MCRMetadataManager.retrieveMCRObject(MCRObjectID.getInstance(id));
        final MEIWrapper wrapper = MEIWrapper.getWrapper(obj);

        HashMap<String, List<String>> newClassifications = wrapper.getClassification();

        wrapper.getClassification().forEach((key, vals) -> {
            String classID=key.substring(key.lastIndexOf("/")+1);
            patches.stream().filter(m -> m.getRootID().equals(classID)).findFirst().ifPresent(patch -> {
                List<String> newValues = vals.stream().map(val -> {
                    final String match = patch.getResultMap().get(classID + ":" + val);
                    LOGGER.info("replace " + classID + ":" + val + " with " + match + " in " + id);
                    return match.substring(match.indexOf(":")+1);
                }).collect(Collectors.toList());

                newClassifications.put(key, newValues);
            });
        });

        wrapper.setClassification(newClassifications);
        MCRMetadataManager.update(obj);
    }

    @MCRCommand(syntax = "select all objects to migrate")
    public static void selectObjects() {
        List<String> ll = new LinkedList<>();
        ll.addAll(MCRXMLMetadataManager.instance().listIDsOfType("source"));
        ll.addAll(MCRXMLMetadataManager.instance().listIDsOfType("expression"));
        ll.addAll(MCRXMLMetadataManager.instance().listIDsOfType("work"));
        MCRObjectCommands.setSelectedObjectIDs(ll);
    }

    @MCRCommand(syntax = "fix cmo identifier of {0}")
    public static void fixCMOIdentifier(String objectIdString) throws MCRAccessException {
        final MCRObjectID objectID = MCRObjectID.getInstance(objectIdString);

        if (!MCRMetadataManager.exists(objectID)) {
            throw new MCRException("The object " + objectID.toString() + " does not exist!");
        }

        final MCRObject obj = MCRMetadataManager.retrieveMCRObject(objectID);
        final MEIWrapper wrapper = MEIWrapper.getWrapper(obj);
        final Element root = wrapper.getRoot();

        final List<Element> identifierList = XPathFactory.instance().compile(".//mei:identifier[@type='CMO']",
            Filters.element(), null, MEI_NAMESPACE).evaluate(root);

        final List<Element> expressionList = XPathFactory.instance()
            .compile(".//mei:expression[contains(@label,'CMO')]",
                Filters.element(), null, MEI_NAMESPACE).evaluate(root);

        final long changedIdentifier = identifierList.stream()
            .filter(identifierElement -> identifierElement.getTextTrim().startsWith("CMO_"))
            .peek(identifierElement -> identifierElement
                .setText(identifierElement.getTextTrim().substring("CMO_".length())))

            .count() + expressionList.stream().filter(
            expression -> expression.getAttributeValue("label") != null && expression.getAttributeValue("label")
                .startsWith("CMO_"))
            .peek(expression -> expression
                .setAttribute("label", expression.getAttributeValue("label").substring("CMO_".length())))
            .count();

        if (changedIdentifier > 0) {
            LOGGER.info("Changed identifier of " + objectIdString);
            MCRMetadataManager.update(obj);
        }
    }

    @MCRCommand(syntax = "migrate all classifications")
    public static List<String> migrateClassifications()
        throws MCRAccessException, InterruptedException, IOException {

        final List<String> classificationsToMigrate = Stream.of("cmo_contentType", "cmo_litform", "cmo_makamler",
            "cmo_musictype", "cmo_notationType", "cmo_sourceType", "cmo_usuler").collect(Collectors.toList());

        final Path migratedClassificationsFolderPath = MCRConfigurationDir.getConfigurationDirectory().toPath()
            .resolve("migratedClassifications");

        Files.createDirectories(migratedClassificationsFolderPath);

        patches = classificationsToMigrate.stream().map(categoryID -> {
            final CMOClassificationIDPatch cmoClassificationIDPatch = new CMOClassificationIDPatch();
            final MCRCategory category = MCRCategoryDAOFactory.getInstance()
                .getCategory(new MCRCategoryID(categoryID, ""), -1);
            cmoClassificationIDPatch.fixClassification(category);
            return cmoClassificationIDPatch;
        }).collect(Collectors.toList());

        final LinkedList<String> commands = patches.stream().map(p -> {
            final Document resultDocument = p.getResultDocument();
            final String fileName = p.getRootID() + ".xml";
            final Path newClassificationPath = migratedClassificationsFolderPath.resolve(fileName);
            try (OutputStream os = Files.newOutputStream(newClassificationPath,
                StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING)) {
                new XMLOutputter(Format.getPrettyFormat()).output(resultDocument, os);
            } catch (IOException e) {
                throw new MCRException("Error while write classification " + p.getRootID() + "!", e);
            }
            return newClassificationPath;
        })
            .map(Path::toAbsolutePath)
            .map(Path::toString)
            .map(UPDATE_CLASSIFICATION_FROM_FILE::concat)
            .collect(Collectors.toCollection(LinkedList::new));


        List<String> ll = new LinkedList<>();

        ll.addAll(MCRXMLMetadataManager.instance().listIDsOfType("source"));
        ll.addAll(MCRXMLMetadataManager.instance().listIDsOfType("expression"));
        ll.addAll(MCRXMLMetadataManager.instance().listIDsOfType("work"));

        ll.stream()
            .map(MCRObjectID::getInstance)
            .filter(MCRMetadataManager::exists)
            .map(MCRObjectID::toString)
            .map(MIGRATE_CLASSIFICATIONS_IN_OBJECT::concat)
            .forEach(commands::add);

        return commands;
    }

}
