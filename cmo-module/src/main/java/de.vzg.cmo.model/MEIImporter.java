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

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.mycore.common.MCRException;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRXSLTransformer;
import org.mycore.datamodel.metadata.MCRMetaElement;
import org.mycore.datamodel.metadata.MCRMetaXML;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.metadata.MCRObjectMetadata;
import org.mycore.tools.MCRObjectFactory;
import org.xml.sax.SAXException;

public class MEIImporter extends SimpleFileVisitor<Path> {

    private static final String BIBLIOGRAPHY_FOLDER = "bibliography";

    private static final String EXPRESSIONS_FOLDER = "expressions";

    private static final String MANUSCRIPTS_FOLDER = "manuscripts";

    private static final String PERSONS_FOLDER = "persons";

    private static final String WORKS_FOLDER = "works";

    private static final String PRINTS_FOLDER = "prints";

    private static final String CLASSIFICATION_FOLDER = "_index";

    private static final Logger LOGGER = LogManager.getLogger();

    // bibliography folder
    private ConcurrentHashMap<String, Document> bibliographicMap;

    // expression folder
    private ConcurrentHashMap<String, Document> expressionMap;

    // persons folder
    private ConcurrentHashMap<String, Document> personMap;

    // works folder
    private ConcurrentHashMap<String, Document> workMap;

    // manuscript folder & prints folder( source )
    private ConcurrentHashMap<String, Document> sourceMap;

    // index folder (classifications not converted)
    private ConcurrentHashMap<String, Document> classificationMap;

    // almost everything from above combined in one map
    private ConcurrentHashMap<String, Document> allCombinedMap;

    private ConcurrentHashMap<String, MCRObjectID> idMCRObjectIDMap;

    private ConcurrentHashMap<String, String> childParentMap;

    private Path root;

    public MEIImporter() {
        bibliographicMap = new ConcurrentHashMap<>();
        expressionMap = new ConcurrentHashMap<>();
        personMap = new ConcurrentHashMap<>();
        workMap = new ConcurrentHashMap<>();

        sourceMap = new ConcurrentHashMap<>();

        classificationMap = new ConcurrentHashMap<>();

        allCombinedMap = new ConcurrentHashMap<>();
        idMCRObjectIDMap = new ConcurrentHashMap<>();
        childParentMap = new ConcurrentHashMap<>();
    }

    public ConcurrentHashMap<String, Document> getAllCombinedMap() {
        return allCombinedMap;
    }

    public ConcurrentHashMap<String, String> getChildParentMap() {
        return childParentMap;
    }

    public List<String> importMEIS(Path root, Path temp) throws IOException {
        this.root = root;
        Set<String> typeSet = new HashSet<>();
        Files.walkFileTree(root, this);
        ConcurrentHashMap<String, Document> newSourceChilds = new ConcurrentHashMap<>();

        extractChildren(sourceMap);
        extractChildren(workMap);
        extractChildren(expressionMap);

        convertPerson();
        convertSources();

        combine();

        allCombinedMap.entrySet().stream().sequential().forEach((es) -> {
            Document v = es.getValue();
            String k = es.getKey();

            MCRObjectID cmoID = createMyCoReID(k);
            idMCRObjectIDMap.put(k, cmoID);
            LOGGER.info("{} new id will be {}", k, cmoID.toString());
        });

        XMLOutputter xmlOutputter = new XMLOutputter(Format.getPrettyFormat());

        allCombinedMap.forEach((key, v) -> {
            MCRObjectID cmoID = idMCRObjectIDMap.get(key);
            Document sampleObject = MCRObjectFactory.getSampleObject(cmoID);
            MCRObject mcrObject = new MCRObject(sampleObject);

            MCRObjectMetadata metadata = mcrObject.getMetadata();

            String typeId = cmoID.getTypeId();
            if ("bibl".equals(typeId)) {
                mcrObject.setSchema("datamodel-tei-" + typeId + ".xsd");
            } else {
                mcrObject.setSchema("datamodel-mei-" + typeId + ".xsd");
            }

            MEIUtils.clear(v.getRootElement());

            MCRMetaXML meiContainer = new MCRMetaXML("meiContainer", null, 0);
            List<MCRMetaXML> list = Collections.nCopies(1, meiContainer);
            MCRMetaElement defModsContainer = new MCRMetaElement(MCRMetaXML.class, "def.meiContainer",
                false, true, list);
            metadata.setMetadataElement(defModsContainer);

            Element rootElement = v.detachRootElement();
            MEIUtils.changeLinkTargets(rootElement,
                (from) -> {
                    MCRObjectID id = this.idMCRObjectIDMap.get(from);
                    return id == null ? null : id.toString();

                });
            MEIWrapper wrapper = null;
            switch (cmoID.getTypeId()) {
                case "source":
                    wrapper = new MEISourceWrapper(rootElement);
                    break;
                case "expression":
                    wrapper = new MEIExpressionWrapper(rootElement);
                    break;
            }

            if (wrapper != null) {
                wrapper.orderTopLevelElement();
            }

            MEIUtils.clearCircularDependency(rootElement);

            meiContainer.addContent(rootElement);

            if (childParentMap.containsKey(key)) {
                mcrObject.getStructure().setParent(idMCRObjectIDMap.get(childParentMap.get(key)));
            }

            Document document = mcrObject.createXML();

            String type = typeId;
            Path targetFolder = temp.resolve(type);
            typeSet.add(type);

            try {
                Files.createDirectories(targetFolder);
                Path exportFile = targetFolder.resolve(cmoID + ".xml");
                try (OutputStream os = Files.newOutputStream(exportFile)) {
                    xmlOutputter.output(document, os);
                }
            } catch (IOException e) {
                LOGGER.error("Error while exporting file " + cmoID.toString() + " (" + key + ")", e);
            }
        });
        return typeSet.stream()
            .sorted((p1, p2) -> {
                return getOrder(p1) - getOrder(p2);
            })
            .map(type -> temp.resolve(type).toString())
            .map(pathToFolder -> "load all objects in topological order from directory " + pathToFolder)
            .collect(Collectors.toList());
    }

    public void convertSources() {
        ConcurrentHashMap<String, Document> newSourceMap = new ConcurrentHashMap<>();
        sourceMap.forEach((cmoID, doc) -> {
            MCRXSLTransformer transformer = new MCRXSLTransformer("xsl/model/cmo/import/source-fix-physLocation.xsl");
            try {
                Document document = transformer.transform(new MCRJDOMContent(doc)).asXML();
                newSourceMap.put(cmoID, document);
            } catch (JDOMException | IOException | SAXException e) {
                LOGGER.error(e);
            }
        });
        sourceMap = newSourceMap;
    }

    public void convertPerson() {
        ConcurrentHashMap<String, Document> newPersonMap = new ConcurrentHashMap<>();
        personMap.forEach((cmoID, doc) -> {
            MCRXSLTransformer transformer = new MCRXSLTransformer("xsl/model/cmo/import/tei-person2mei-person.xsl");
            try {
                Document document = transformer.transform(new MCRJDOMContent(doc)).asXML();
                newPersonMap.put(cmoID, document);
            } catch (JDOMException | IOException | SAXException e) {
                LOGGER.error(e);
            }
        });
        personMap = newPersonMap;
    }

    public void extractChildren(Map<String, Document> newChildMap) {
        ConcurrentHashMap<String, Document> newWorkChildren = new ConcurrentHashMap<>();
        newChildMap.forEach((idOfElementToExtractFrom, elementToExtractFrom) -> {
            ConcurrentHashMap<String, Document> m = MEIUtils
                .extractChildren(idOfElementToExtractFrom, elementToExtractFrom.getRootElement());
            m.forEach((extractedID, document) -> {
                childParentMap.put(extractedID, idOfElementToExtractFrom);
            });
            newWorkChildren.putAll(m);
        });
        newChildMap.putAll(newWorkChildren);
    }

    public int getOrder(String type) {
        switch (type) {
            case "person":
                return 1;
            case "bibl":
                return 2;
            case "source":
                return 3;
            case "expression":
                return 4;
            case "work":
                return 6;

        }
        throw new IllegalArgumentException("Unknown type " + type);
    }

    public MCRObjectID createMyCoReID(String cmoID) {
        String type;
        switch (cmoID.substring(0, 2)) {
            case "pr":
            case "ms":
            case "sc":
                type = "source";
                break;
            case "bb":
                type = "bibl";
                break;
            case "pp":
                type = "person";
                break;
            case "ex":
            case "ec":
                type = "expression";
                break;
            case "wc":
            case "wr":
                type = "work";
                break;
            default:
                throw new MCRException("Unknown Type!");
        }
        return MCRObjectID.getNextFreeId("cmo", type);
    }

    private void addRelation(Element documentRootElement, String rel, String relationID) {
        Element parentRelationList = getOrCreateRelationList(documentRootElement);
        Element relation = new Element("relation", MEIUtils.MEI_NAMESPACE);
        relation.setAttribute("rel", rel);
        relation.setAttribute("target", relationID);
        parentRelationList.addContent(relation);
    }

    private Element getOrCreateRelationList(Element elementToExtractFrom) {
        Element relationList = elementToExtractFrom
            .getChild("relationList", MEIUtils.MEI_NAMESPACE);

        if (relationList == null) {
            elementToExtractFrom.addContent(relationList = new Element("relationList",
                MEIUtils.MEI_NAMESPACE));
        }
        return relationList;
    }

    private void combine() {
        bibliographicMap.forEach(allCombinedMap::put);
        expressionMap.forEach(allCombinedMap::put);
        personMap.forEach(allCombinedMap::put);
        workMap.forEach(allCombinedMap::put);
        sourceMap.forEach(allCombinedMap::put);
        classificationMap.forEach(allCombinedMap::put);
    }

    private void importMEI(Path meiFilePath) {
        try (InputStream is = Files.newInputStream(meiFilePath)) {
            SAXBuilder saxBuilder = new SAXBuilder();
            Document document = saxBuilder.build(is);
            LOGGER.info("Read document: {}", meiFilePath.toString());

            final ConcurrentHashMap<String, Document> hashMap = chooseType(meiFilePath, document);
            if (hashMap == null) {
                return;
            }
            Element rootElement = document.getRootElement();
            String id = rootElement.getAttributeValue("id", Namespace.XML_NAMESPACE);
            if (id == null) {
                LOGGER.warn("Could not evaluate ID of {}", meiFilePath);
                return;
            }
            hashMap.put(id, document);
        } catch (IOException | JDOMException e) {
            LOGGER.error("Error while importing MEI", e);
        }
    }

    private ConcurrentHashMap<String, Document> chooseType(Path meiFilePath, Document document) {
        Element rootElement = document.getRootElement();
        String rootElementName = rootElement.getName();
        switch (rootElementName) {
            case "work":
                return workMap;
            case "bibl":
                return bibliographicMap;
            case "expression":
                return expressionMap;
            case "person":
                return personMap;
            case "source":
                return sourceMap;
            case "list":
                return classificationMap;
            default:
                LOGGER.warn("Unknown root tag {} in {}", rootElement, meiFilePath.toString());
                return null;
        }
    }

    @Override
    public FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes fileAttributes) throws IOException {
        String folderName = dir.getFileName().toString();

        if (root.equals(dir)) {
            return FileVisitResult.CONTINUE;
        }

        switch (folderName) {
            case BIBLIOGRAPHY_FOLDER:
            case EXPRESSIONS_FOLDER:
            case MANUSCRIPTS_FOLDER:
            case PERSONS_FOLDER:
            case PRINTS_FOLDER:
            case WORKS_FOLDER:
                return FileVisitResult.CONTINUE;

            case CLASSIFICATION_FOLDER:
            default:
                LOGGER.info("Skipping {}", dir.toString());
                return FileVisitResult.SKIP_SUBTREE;
        }
    }

    @Override
    public FileVisitResult visitFile(Path file, BasicFileAttributes fileAttributes) throws IOException {
        if (file.getFileName().toString().endsWith(".xml")) {
            importMEI(file);
        }
        return FileVisitResult.CONTINUE;
    }

    @Override
    public FileVisitResult visitFileFailed(Path file, IOException exception) throws IOException {
        return FileVisitResult.CONTINUE;
    }
}
