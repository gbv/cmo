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

package de.vzg.cmo.model.cli;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;

import javax.naming.OperationNotSupportedException;

import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.access.MCRAccessException;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mei.MEIExpressionWrapper;
import org.mycore.mei.MEIUtils;
import org.mycore.mei.MEIWrapper;
import org.mycore.mei.classification.MCRMEIClassificationSupport;

import de.vzg.cmo.model.MEIImporter;

@MCRCommandGroup(name = "CMO Commands")
public class MCRCMOImportCommands {


    @MCRCommand(syntax = "import cmo from folder {0} {1}")
    public static List<String> importCMOFromFolder(String folder, String tempFolder) {
        try {
            MEIImporter meiImporter;
            meiImporter = new MEIImporter();
           return  meiImporter.importMEIS(FileSystems.getDefault().getPath(folder), FileSystems.getDefault().getPath(
               tempFolder));
        } catch (IOException e) {
            e.printStackTrace();
        }

        return Collections.emptyList();
    }

    @MCRCommand(syntax = "clean redundant classifications in {0}")
    public static void cleanRedundantClassification(String mycoreID)
        throws OperationNotSupportedException, MCRAccessException {
        final MCRObjectID objectID = MCRObjectID.getInstance(mycoreID);
        final MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
        final MEIWrapper meiWrapper = MEIWrapper.getWrapper(object);

        final HashMap<String, List<String>> classifications = meiWrapper.getClassification();
        final HashMap<String, List<String>> newClassifications = new HashMap<>();

        classifications.keySet().forEach(classification -> {
            final List<String> values = classifications.get(classification);
            MCRCategory category = MCRMEIClassificationSupport.getClassificationFromURI(classification);
            HashSet<String> keepValues = new HashSet<>(values);
            values.forEach(categValue -> {
                MCRCategoryID categoryID = MCRMEIClassificationSupport.getChildID(category,categValue);
                if (categoryID != null) {
                    MCRCategoryDAOFactory.getInstance().getParents(categoryID)
                        .stream()
                        .map(MCRCategory::getId)
                        .map(MCRCategoryID::getID)
                        .filter(keepValues::contains)
                        .forEach(keepValues::remove);
                }
            });

            if(!keepValues.isEmpty()){
                newClassifications.put(classification,new ArrayList<>(keepValues));
            }
        });

        meiWrapper.setClassification(newClassifications);
        MCRMetadataManager.update(object);
    }

    @MCRCommand(syntax = "clean tempo in {0}")
    public static void cleanTempo(String mycoreID) throws MCRAccessException {
        final MCRObjectID objectID = MCRObjectID.getInstance(mycoreID);
        final MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);

        if ("expression".equals(objectID.getTypeId())) {
            final MEIExpressionWrapper expressionWrapper = (MEIExpressionWrapper) MEIWrapper.getWrapper(object);
            final XPathExpression<Element> tempoXPath = XPathFactory.instance()
                .compile(".//mei:tempo", Filters.element(), Collections.emptyMap(), MEIUtils.MEI_NAMESPACE);

            AtomicInteger tempoElementsChanged = new AtomicInteger(0);
            tempoXPath.evaluate(expressionWrapper.getRoot())
                .stream()
                .forEach(tempo -> {
                    final String text = tempo.getText();

                    String newText;
                    String newType;

                    if (text.contains(":")) {
                        // assume text is category:id
                        final String[] vals = text.split(":");
                        newText = vals[1];
                        newType = vals[0];
                    } else if (tempo.getAttributeValue("label") != null) {
                        // assume label is id
                        newText = tempo.getAttributeValue("label");
                        tempo.removeAttribute("label");
                        newType = "cmo_tempo";
                    } else {
                        // assume text is id
                        newText = text;
                        newType = "cmo_tempo";
                    }

                    tempo.setText(newText);
                    tempo.setAttribute("type", newType);
                    tempoElementsChanged.incrementAndGet();
                });

            if (tempoElementsChanged.get() > 0) {
                MCRMetadataManager.update(object);
            }
        }
    }

}
