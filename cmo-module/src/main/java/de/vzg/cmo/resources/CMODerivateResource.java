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

package de.vzg.cmo.resources;

import java.net.URI;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.core.Context;
import jakarta.ws.rs.core.Response;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessManager;
import org.mycore.datamodel.classifications2.MCRCategoryDAOFactory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.metadata.MCRDerivate;
import org.mycore.datamodel.metadata.MCRMetaClassification;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObjectDerivate;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.MCRFrontendUtil;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Resource which allows to set the {@code derivate_types} classification of a derivate.
 * <p>
 * The type is used to distinguish the different file areas of a derivate (e.g. the actual
 * content or a TEI edition). The single supported classification is {@code derivate_types}.
 */
@Path("cmo/derivate/")
public class CMODerivateResource {

    /**
     * The classification which holds the possible derivate types.
     */
    public static final String DERIVATE_TYPES_CLASSIFICATION = "derivate_types";

    private static final Logger LOGGER = LogManager.getLogger();

    /**
     * Sets the {@code derivate_types} category of the given derivate to the given type and
     * redirects back to the page the request came from (or to the owning object page).
     *
     * @param derivateID the id of the derivate to change
     * @param type       the category id inside the {@link #DERIVATE_TYPES_CLASSIFICATION} classification
     * @param request    the current request, used to determine the redirect target
     * @return a redirect response back to the referring page
     */
    @Path("{derid}/set-type/{type}")
    @GET
    public Response setType(@PathParam("derid") String derivateID, @PathParam("type") String type,
        @Context HttpServletRequest request) {
        if (!MCRObjectID.isValid(derivateID)) {
            return Response.status(Response.Status.BAD_REQUEST).entity("Invalid derivate id " + derivateID).build();
        }

        MCRObjectID derId = MCRObjectID.getInstance(derivateID);
        if (!MCRMetadataManager.exists(derId)) {
            return Response.status(Response.Status.NOT_FOUND).entity("Derivate " + derivateID + " does not exist")
                .build();
        }

        if (!MCRAccessManager.checkPermission(derId, MCRAccessManager.PERMISSION_WRITE)) {
            return Response.status(Response.Status.FORBIDDEN)
                .entity("No permission to write derivate " + derivateID).build();
        }

        MCRCategoryID categoryID = new MCRCategoryID(DERIVATE_TYPES_CLASSIFICATION, type);
        if (!MCRCategoryDAOFactory.getInstance().exist(categoryID)) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity("Unknown derivate type " + type).build();
        }

        MCRDerivate derivate = MCRMetadataManager.retrieveMCRDerivate(derId);
        MCRObjectDerivate objectDerivate = derivate.getDerivate();

        // replace any previously set derivate type
        objectDerivate.getClassifications()
            .removeIf(classification -> DERIVATE_TYPES_CLASSIFICATION.equals(classification.getClassId()));
        objectDerivate.getClassifications()
            .add(new MCRMetaClassification("classification", 0, null, categoryID));

        try {
            MCRMetadataManager.update(derivate);
        } catch (MCRAccessException e) {
            return Response.status(Response.Status.FORBIDDEN)
                .entity("No permission to write derivate " + derivateID).build();
        }

        LOGGER.info("Set derivate type of {} to {}", derivateID, type);
        return Response.seeOther(getRedirectTarget(request, derivate.getOwnerID())).build();
    }

    private URI getRedirectTarget(HttpServletRequest request, MCRObjectID ownerID) {
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isBlank()) {
            return URI.create(referer);
        }
        return URI.create(MCRFrontendUtil.getBaseURL() + "receive/" + ownerID);
    }

}
