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

package org.mycore.mei;

import static org.mycore.datamodel.common.MCRLinkTableManager.ENTRY_TYPE_REFERENCE;

import java.util.AbstractMap;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Attribute;
import org.jdom2.Element;
import org.jdom2.Text;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.events.MCREvent;
import org.mycore.common.events.MCREventHandlerBase;
import org.mycore.datamodel.common.MCRLinkTableManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;

/**
 * This event handler looks to which objects the created/edited object links in the metadata and according to this
 * information it updates the Database.
 * It also changes the Labels of the links according to rules defined in <i>MEILinkEventHandler.labelRules.</i>.
 * Rules have to be like
 *
 * MEILinkEventHandler.LabelRules.sourceType.localLinkElementName.targetType=xpath
 * MEILinkEventHandler.LabelRules.source.persName.person=.//mei:identifier[@type="TMAS-main"]
 *
 */
public class MEILinkEventHandler extends MCREventHandlerBase {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String MEILINK_EVENT_HANDLER_LABEL_RULES = "MEILinkEventHandler.LabelRules.";

    static MCRLinkTableManager linkTable = MCRLinkTableManager.instance();

    private Map<String, Function<Element, String>> changeFunctions = buildChangeFunctions();

    private Map<String, Function<Element, String>> buildChangeFunctions() {
        HashMap<String, Function<Element, String>> changeFunctions = new HashMap<>();

        Map<String, String> propertiesMap = MCRConfiguration2.getSubPropertiesMap(MEILINK_EVENT_HANDLER_LABEL_RULES);

        propertiesMap.forEach((rule, xpath) -> {
            String[] ruleDef = rule.split(".");
            if (ruleDef.length != 3) {
                LOGGER.error("Invalid Rule {}", rule);
            }

            Function<Element, String> changeFunction = (Element element) -> {
                XPathExpression xp = XPathFactory.instance().compile(xpath, Filters.fpassthrough(), null, MEIUtils.MEI_NAMESPACE);

                String linkTarget = MEIUtils.getLinkTarget(element);

                Element root = MEIWrapper.getWrapper(linkTarget).getRoot();
                Object match = xp.evaluateFirst(root);

                if (match instanceof Element) {
                    return ((Element) match).getTextTrim();
                }

                if (match instanceof Attribute) {
                    return ((Attribute) match).getValue();
                }

                if (match instanceof Text) {
                    return ((Text) match).getTextTrim();
                }

                return null;
            };

            changeFunctions.put(rule, changeFunction);
        });

        return changeFunctions;
    }

    @Override
    protected void handleObjectCreated(MCREvent evt, MCRObject obj) {
        Element objectXML = obj.getMetadata().createXML();

        MCRObjectID id = obj.getId();
        deleteOldLinks(id);

        LOGGER.info("Handle references of {}", id);
        MEIUtils.changeLinkLabels(objectXML, (element, target) -> {
            String sourceType = id.getTypeId();
            if (MCRObjectID.isValid(target)) {

                String targetType = MCRObjectID.getInstance(target).getTypeId();
                String name = element.getName();
                String key = String.format("%s.%s.%s", sourceType, name, targetType);

                if (changeFunctions.containsKey(key)) {
                    LOGGER.info("Found rule for " + key);
                    return changeFunctions.get(key).apply(element);
                } else {
                    LOGGER.info("No rule for " + key);
                }
            }
            return null;
        });

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

  @Override
  protected void handleObjectUpdated(MCREvent evt, MCRObject obj) {
      handleObjectCreated(evt, obj);
  }

  private void deleteOldLinks(final MCRObjectID objectId) {
        LOGGER.info("Remove all references form {} from Database!", objectId);
        linkTable.deleteReferenceLink(objectId);
    }
}
