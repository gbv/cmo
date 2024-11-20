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

import java.io.IOException;
import java.util.stream.Stream;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.cli.MCRObjectCommands;

import com.google.gson.Gson;

@Path("cmo/object/")
public class CMOObjectResource {

    public static final Namespace EXPORT_NAMESPACE = Namespace
        .getNamespace("export", "http://www.corpus-musicae-ottomanicae.de/ns/export");

    @Path("export/{transformer}/{ids}")
    @Produces(MediaType.APPLICATION_OCTET_STREAM)
    @GET
    public Response export(@PathParam("transformer") String transformer, @PathParam("ids") String idListString)
        throws IOException {
        Document doc = new Document(new Element("export", EXPORT_NAMESPACE));
        final Element exportElement = doc.getRootElement();
        Stream.of(idListString.split(","))
            .map(id -> {
                final Element dependency = new Element("dependency", EXPORT_NAMESPACE);
                dependency.setAttribute("id",id);
                dependency.setAttribute("resolved","false");
                return dependency;
            })
            .forEach(exportElement::addContent);

        final MCRContent result = MCRContentTransformerFactory
            .getTransformer(transformer)
            .transform(new MCRJDOMContent(doc));

        return Response
            .status(Response.Status.OK)
            .header("Content-disposition", transformer.endsWith("-pdf") ? "attachment; filename=\"export.pdf\"" : "attachment; filename=\"export.zip\"")
            .entity(result.asByteArray())
            .build();
    }

    @Path("move/{id}")
    @Produces(MediaType.APPLICATION_JSON)
    @GET
    public Response setParent(@PathParam("id") String objectID, @QueryParam("to") String target) {
        if (!(MCRObjectID.isValid(objectID) && MCRObjectID.isValid(target))) {
            return Response
                .status(Response.Status.BAD_REQUEST)
                .entity(new Gson().toJson(new CMOResourceError("Invalid object IDs")))
                .build();
        }

        if (!MCRAccessManager.checkPermission(objectID, MCRAccessManager.PERMISSION_WRITE)) {
            return Response
                .status(Response.Status.UNAUTHORIZED)
                .entity(new Gson()
                    .toJson(new CMOResourceError("No Rights!"))).build();
        }

        try {
            MCRObjectCommands.replaceParent(objectID, target);
            return Response.status(Response.Status.OK).entity("{}").build();
        } catch (Throwable e) {
            return Response.status(Response.Status.BAD_REQUEST)
                .entity(new Gson().toJson(new CMOResourceError("Something went wrong", e)))
                .build();
        }
    }
}
