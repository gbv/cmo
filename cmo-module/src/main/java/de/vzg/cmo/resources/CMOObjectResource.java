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

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.mycore.access.MCRAccessException;
import org.mycore.datamodel.common.MCRActiveLinkException;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.MCRObjectCommands;

import com.google.gson.Gson;

@Path("cmo/object/")
public class CMOObjectResource {

    @Path("move/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @GET
    public Response setParent(@PathParam("id") String objectID, @QueryParam("to") String target) {
        if (!(MCRObjectID.isValid(objectID) && MCRObjectID.isValid(target))) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity(new Gson().toJson(new CMOResourceError("Invalid object IDs")))
                .build();
        }
        try {
            MCRObjectCommands.replaceParent(objectID, target);
            return Response.status(Response.Status.OK).entity("{}").build();
        } catch (MCRActiveLinkException | MCRAccessException e) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity(new Gson().toJson(new CMOResourceError("Something went wrong", e)))
                .build();
        }
    }
}
