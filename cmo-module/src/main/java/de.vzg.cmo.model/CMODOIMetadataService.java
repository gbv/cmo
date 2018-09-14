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

package de.vzg.cmo.model;

import static org.mycore.mods.identifier.MCRAbstractMODSMetadataService.PREFIX_PROPERTY_KEY;

import java.util.Optional;

import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.datamodel.metadata.MCRBase;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.mei.MEIUtils;
import org.mycore.mei.MEIWrapper;
import org.mycore.mods.identifier.MCRMODSDOIMetadataService;
import org.mycore.pi.MCRPIManager;
import org.mycore.pi.MCRPIMetadataService;
import org.mycore.pi.MCRPersistentIdentifier;
import org.mycore.pi.doi.MCRDigitalObjectIdentifier;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;

public class CMODOIMetadataService extends MCRPIMetadataService<MCRDigitalObjectIdentifier> {

    protected static final String ALLOWED_MEI_TYPES_PROPERTY = "AllowedMEITypes";

    private MCRMODSDOIMetadataService mcrmodsdoiMetadataService;

    public CMODOIMetadataService(String metadataManagerID) {
        super(metadataManagerID);
        mcrmodsdoiMetadataService = new MCRMODSDOIMetadataService(metadataManagerID);
    }

    @Override
    public void insertIdentifier(MCRDigitalObjectIdentifier identifier, MCRBase obj, String additional)
        throws MCRPersistentIdentifierException {

        String type = obj.getId().getTypeId();
        if (type.equals("mods")) {
            mcrmodsdoiMetadataService.insertIdentifier(identifier, obj, additional);
        } else if (obj instanceof MCRObject && getProperties().get(ALLOWED_MEI_TYPES_PROPERTY).contains(type)) {
            MEIWrapper mayWrapper = MEIWrapper.getWrapper((MCRObject) obj);
            Element identifierElement = new Element("identifier", MEIUtils.MEI_NAMESPACE);
            identifierElement.addContent(identifier.asString());
            identifierElement.setAttribute("type", "doi");
            mayWrapper.getRoot().addContent(identifierElement);
        } else {
            throw new MCRPersistentIdentifierException(
                "The type " + type + " is not supported(" + getProperties().get(ALLOWED_MEI_TYPES_PROPERTY) + ")");
        }
    }

    @Override
    public void removeIdentifier(MCRDigitalObjectIdentifier identifier, MCRBase obj, String additional) {
        String type = obj.getId().getTypeId();
        if (type.equals("mods")) {
            mcrmodsdoiMetadataService.removeIdentifier(identifier, obj, additional);
        } else if (obj instanceof MCRObject && getProperties().get(ALLOWED_MEI_TYPES_PROPERTY).contains(type)) {
            Optional<MEIWrapper> mayWrapper = Optional.ofNullable(MEIWrapper.getWrapper((MCRObject) obj));
            mayWrapper.map(wrapper -> getIdentifierElement(wrapper.getRoot(),
                " and starts-with(text(), '" + identifier.asString() + "')"))
                .ifPresent(element -> {
                    element.getParent().removeContent(element);
                });
        }else {
            throw new MCRException(new MCRPersistentIdentifierException(
                "The type " + type + " is not supported(" + getProperties().get(ALLOWED_MEI_TYPES_PROPERTY) + ")"));
        }
    }

    @Override
    public Optional<MCRPersistentIdentifier> getIdentifier(MCRBase obj, String additional)
        throws MCRPersistentIdentifierException {
        String type = obj.getId().getTypeId();
        if (type.equals("mods")) {
            return mcrmodsdoiMetadataService.getIdentifier(obj, additional);
        } else if (obj instanceof MCRObject && getProperties().get(ALLOWED_MEI_TYPES_PROPERTY).contains(type)) {
            Optional<MEIWrapper> mayWrapper = Optional.ofNullable(MEIWrapper.getWrapper((MCRObject) obj));

            return mayWrapper.map(wrapper -> {
                Element root = wrapper.getRoot();
                return getIdentifierElement(root, "");
            }).map(Element::getTextTrim)
                .flatMap(s -> MCRPIManager.getInstance().getParserForType("doi").parse(s));

        }

        return Optional.empty();
    }

    private Element getIdentifierElement(Element root, String additionalCondition) {
        final String prefixCondition = (getProperties().containsKey(PREFIX_PROPERTY_KEY) ?
            " and starts-with(text(), '" + getProperties().get(PREFIX_PROPERTY_KEY) + "')" : "");
        final String xPath = "mei:identifier[@type='doi'" + prefixCondition + "" + additionalCondition + "]";

        return XPathFactory.instance()
            .compile(xPath, Filters.element(), null, MEIUtils.MEI_NAMESPACE, MCRConstants.XLINK_NAMESPACE)
            .evaluateFirst(root);
    }
}
