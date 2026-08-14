/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package de.vzg.cmo.model.cli;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Attribute;
import org.jdom2.Document;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessManager;
import org.mycore.access.MCRRuleAccessInterface;
import org.mycore.common.MCRException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRPathContent;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetaClassification;
import org.mycore.datamodel.metadata.MCRMetaIFS;
import org.mycore.datamodel.metadata.MCRMetaLinkID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.niofs.MCRPath;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.xml.sax.SAXException;

import de.vzg.cmo.resources.CMODerivateResource;

/**
 * Commands to import the TEI text edition sources (see {@code xsl/TEI-cmoedition.xsl}) and attach
 * them to the mods object they belong to.
 * <p>
 * A TEI source file references its mods object via
 * {@code <milestone unit="cite" source="#cmo_mods_..."/>} inside {@code <div type="newPieceStart">}.
 * The file is stored in a derivate of the mods object which is marked with the
 * {@code derivate_types:edition_tei} classification, so the viewer can pick it up as the text edition.
 */
@MCRCommandGroup(name = "CMO TEI Source Commands")
public class MCRCMOTEISourceCommands {

    /**
     * The category inside the {@code derivate_types} classification which marks a TEI edition derivate.
     */
    public static final String EDITION_TEI_CATEGORY = "edition_tei";

    private static final Logger LOGGER = LogManager.getLogger();

    private static final Namespace TEI_NAMESPACE = Namespace.getNamespace("tei", "http://www.tei-c.org/ns/1.0");

    /**
     * Returns one {@code update tei source from file} command per {@code *.xml} file in the given directory.
     * The commands are executed by the MyCoRe CLI afterwards.
     *
     * @param directory the directory holding the TEI source files
     * @return a list of {@code update tei source from file} commands
     */
    @MCRCommand(syntax = "update tei sources from directory {0}",
        help = "Reads all TEI files (*.xml) in directory {0} and returns one "
            + "'update tei source from file {file}' command per file",
        order = 10)
    public static List<String> updateFromDirectory(String directory) {
        File dir = new File(directory);
        if (!dir.isDirectory()) {
            throw new MCRException(String.format(Locale.ENGLISH, "%s is not a directory.", directory));
        }

        String[] list = dir.list();
        if (list == null || list.length == 0) {
            LOGGER.warn("No files found in directory {}", dir);
            return Collections.emptyList();
        }

        return Arrays.stream(list)
            .filter(file -> file.toLowerCase(Locale.ROOT).endsWith(".xml"))
            .sorted()
            .map(file -> String.format(Locale.ENGLISH, "update tei source from file %s",
                new File(dir, file).getAbsolutePath()))
            .collect(Collectors.toList());
    }

    /**
     * Uploads a single TEI source file to the {@code edition_tei} derivate of the mods object it references.
     * If the mods object does not have such a derivate yet, a new one is created.
     *
     * @param teiFileName the path to the TEI source file
     */
    @MCRCommand(syntax = "update tei source from file {0}",
        help = "Uploads the TEI file {0} to the edition_tei derivate of the linked mods object, "
            + "creating the derivate if necessary",
        order = 20)
    public static void updateFromFile(String teiFileName)
        throws JDOMException, IOException, SAXException, MCRAccessException {
        File teiFile = new File(teiFileName);
        if (!teiFile.isFile()) {
            throw new MCRException(String.format(Locale.ENGLISH, "%s is not a file.", teiFile.getAbsolutePath()));
        }

        Document teiDoc = new MCRPathContent(teiFile.toPath()).asXML();
        MCRObjectID modsID = extractModsID(teiDoc, teiFile);

        if (!MCRMetadataManager.exists(modsID)) {
            throw new MCRException(String.format(Locale.ENGLISH,
                "The mods object %s referenced by %s does not exist.", modsID, teiFile.getAbsolutePath()));
        }

        String fileName = teiFile.getName();
        MCRObjectID derivateID = findEditionTeiDerivate(modsID);
        MCRDerivate derivate = derivateID != null
            ? MCRMetadataManager.retrieveMCRDerivate(derivateID)
            : createEditionTeiDerivate(modsID);

        MCRPath target = MCRPath.getPath(derivate.getId().toString(), "/" + fileName);
        try (InputStream in = Files.newInputStream(teiFile.toPath())) {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        }

        derivate.getDerivate().getInternals().setMainDoc(fileName);
        MCRMetadataManager.update(derivate);

        LOGGER.info("Updated TEI source {} in derivate {} of mods object {}", fileName, derivate.getId(), modsID);
    }

    /**
     * Extracts the linked mods object id from the TEI document. The link is expressed as
     * {@code <milestone unit="cite" source="#cmo_mods_..."/>}.
     */
    private static MCRObjectID extractModsID(Document teiDoc, File teiFile) {
        XPathExpression<Attribute> xpath = XPathFactory.instance()
            .compile("//tei:milestone[@unit='cite']/@source", Filters.attribute(), Collections.emptyMap(),
                TEI_NAMESPACE);
        Attribute source = xpath.evaluateFirst(teiDoc);
        if (source == null) {
            throw new MCRException(String.format(Locale.ENGLISH,
                "No <milestone unit=\"cite\" source=\"#cmo_mods_...\"/> found in %s.", teiFile.getAbsolutePath()));
        }

        String reference = source.getValue();
        if (reference.startsWith("#")) {
            reference = reference.substring(1);
        }

        if (!MCRObjectID.isValid(reference) || !"mods".equals(MCRObjectID.getInstance(reference).getTypeId())) {
            throw new MCRException(String.format(Locale.ENGLISH,
                "The milestone source '%s' in %s is not a valid mods object id.", reference,
                teiFile.getAbsolutePath()));
        }

        return MCRObjectID.getInstance(reference);
    }

    /**
     * Returns the id of the {@code edition_tei} derivate of the given mods object, or {@code null} if none exists.
     */
    private static MCRObjectID findEditionTeiDerivate(MCRObjectID modsID) {
        for (MCRObjectID derivateID : MCRMetadataManager.getDerivateIds(modsID, 10, TimeUnit.MINUTES)) {
            MCRDerivate derivate = MCRMetadataManager.retrieveMCRDerivate(derivateID);
            boolean isEditionTei = derivate.getDerivate().getClassifications().stream()
                .anyMatch(classification -> CMODerivateResource.DERIVATE_TYPES_CLASSIFICATION
                    .equals(classification.getClassId()) && EDITION_TEI_CATEGORY.equals(classification.getCategId()));
            if (isEditionTei) {
                return derivateID;
            }
        }
        return null;
    }

    /**
     * Creates a new, empty derivate linked to the given mods object and marked as {@code edition_tei}.
     */
    private static MCRDerivate createEditionTeiDerivate(MCRObjectID modsID) throws MCRAccessException {
        MCRCategoryID editionTei = new MCRCategoryID(CMODerivateResource.DERIVATE_TYPES_CLASSIFICATION,
            EDITION_TEI_CATEGORY);
        if (!MCRCategoryDAOFactory.getInstance().exist(editionTei)) {
            throw new MCRException(String.format(Locale.ENGLISH, "The derivate type %s does not exist.", editionTei));
        }

        MCRDerivate derivate = new MCRDerivate();
        String base = modsID.getProjectId() + "_derivate";
        derivate.setId(MCRMetadataManager.getMCRObjectIDGenerator().getNextFreeId(base));

        String schema = MCRConfiguration2.getString("MCR.Metadata.Config.derivate")
            .orElse("datamodel-derivate.xml")
            .replaceAll(".xml", ".xsd");
        derivate.setSchema(schema);

        MCRMetaIFS ifs = new MCRMetaIFS();
        ifs.setSubTag("internal");
        ifs.setSourcePath(null);
        derivate.getDerivate().setInternals(ifs);

        MCRMetaLinkID linkId = new MCRMetaLinkID();
        linkId.setSubTag("linkmeta");
        linkId.setReference(modsID, null, null);
        derivate.getDerivate().setLinkMeta(linkId);

        derivate.getDerivate().getClassifications()
            .add(new MCRMetaClassification("classification", 0, null, editionTei));

        MCRMetadataManager.create(derivate);
        setDefaultPermissions(derivate.getId());

        LOGGER.info("Created new edition_tei derivate {} for mods object {}", derivate.getId(), modsID);
        return derivate;
    }

    /**
     * Adds the configured default access rules to a newly created derivate.
     */
    private static void setDefaultPermissions(MCRObjectID derivateID) {
        if (MCRConfiguration2.getBoolean("MCR.Access.AddDerivateDefaultRule").orElse(true)
            && MCRAccessManager.getAccessImpl() instanceof MCRRuleAccessInterface ruleAccess) {
            ruleAccess.getAccessPermissionsFromConfiguration()
                .forEach(permission -> MCRAccessManager.addRule(derivateID, permission,
                    MCRAccessManager.getTrueRule(), "default derivate rule"));
        }
    }

}
