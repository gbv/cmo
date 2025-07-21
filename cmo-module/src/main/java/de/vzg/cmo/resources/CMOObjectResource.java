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

import jakarta.ws.rs.DELETE;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.core.Response.Status;
import java.io.IOException;
import java.util.List;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.Namespace;
import org.mycore.access.MCRAccessException;
import org.mycore.access.MCRAccessManager;
import org.mycore.common.MCRException;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.transformer.MCRContentTransformerFactory;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.frontend.cli.MCRObjectCommands;

import com.google.gson.Gson;
import org.mycore.mei.MEIAttributeConstants;
import org.mycore.mei.MEIElementConstants;
import org.mycore.mei.MEIUtils;
import org.mycore.mei.MEIWorkWrapper;
import org.mycore.mei.MEIWrapper;

@Path("cmo/object/")
public class CMOObjectResource {

    public static final Namespace EXPORT_NAMESPACE = Namespace
        .getNamespace("export", "http://www.corpus-musicae-ottomanicae.de/ns/export");

    private static final Logger LOGGER = LogManager.getLogger();

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

    @Path("unlink/{from}/{to}")
    @Produces(MediaType.APPLICATION_JSON)
    @DELETE
    public Response unlinkObjects(@PathParam("from") String from, @PathParam("to") String to) {
        Optional<Response> validate = Stream.of(validateObjectID(from), validateObjectID(to))
            .filter(Objects::nonNull)
            .findFirst();
        if (validate.isPresent()) {
            return validate.get();
        }
        Optional<Response> rightsCheck = Stream.of(
                checkObjectRights(MCRObjectID.getInstance(from)),
                checkObjectRights(MCRObjectID.getInstance(to)))
            .filter(Objects::nonNull)
            .findFirst();
        if (rightsCheck.isPresent()) {
            return rightsCheck.get();
        }

        MCRObjectID fromID = MCRObjectID.getInstance(from);
        MCRObjectID toID = MCRObjectID.getInstance(to);

        Optional<Response> existsCheck = Stream.of(
                checkObjectExists(fromID),
                checkObjectExists(toID))
            .filter(Objects::nonNull)
            .findFirst();
        if (existsCheck.isPresent()) {
            return existsCheck.get();
        }

        return unlinkWorkAndExpression(fromID, toID);
    }

    private Response unlinkWorkAndExpression(MCRObjectID fromID, MCRObjectID toID) {
        MCRObject expression = MCRMetadataManager.retrieveMCRObject(toID);

        MEIWrapper expressionWrapper = MEIWrapper.getWrapper(expression);
        if (expressionWrapper == null) {
            throw new IllegalArgumentException("Given expression does not contain a MEI wrapper!");
        }

        MCRObject work = MCRMetadataManager.retrieveMCRObject(fromID);
        MEIWorkWrapper workWrapper = (MEIWorkWrapper) MEIWrapper.getWrapper(work);
        if (workWrapper == null) {
            throw new IllegalArgumentException("Given work does not contain a MEI wrapper!");
        }

        Element expressionList = workWrapper.getOrCreateElement(
            MEIElementConstants.EXPRESSION_LIST);

        List<Element> matchingExpressions = expressionList.getChildren(
                MEIElementConstants.EXPRESSION, MEIUtils.MEI_NAMESPACE)
            .stream()
            .filter(expressionElement -> {
                String codeVal = expressionElement
                    .getAttributeValue(MEIAttributeConstants.CODEDVAL);
                return codeVal != null && codeVal.equals(toID.toString());
            })
            .toList();

        if (!matchingExpressions.isEmpty()) {
            matchingExpressions.forEach(Element::detach);
            try {
                MCRMetadataManager.update(work);
            } catch (MCRAccessException e) {
                throw new MCRException("Impossible", e);
            }
        }

        Element relationList = expressionWrapper.getOrCreateElement(
            MEIElementConstants.RELATION_LIST);
        List<Element> matchingRelations = relationList.getChildren(MEIElementConstants.RELATION,
                MEIUtils.MEI_NAMESPACE)
            .stream()
            .filter(relationElement -> {
                String target = relationElement
                    .getAttributeValue(MEIAttributeConstants.TARGET);
                return target != null && target.equals(fromID.toString());
            })
            .toList();
        if (!matchingRelations.isEmpty()) {
            matchingRelations.forEach(Element::detach);
            try {
                MCRMetadataManager.update(expression);
            } catch (MCRAccessException e) {
                throw new MCRException("Impossible", e);
            }
        }

        return Response.status(Status.OK).entity("{}").build();
    }

    private Response validateObjectID(String objectID) {
        if (!MCRObjectID.isValid(objectID)) {
            return Response
                .status(Response.Status.BAD_REQUEST)
                .entity(new Gson().toJson(new CMOResourceError("Invalid object ID " + objectID)))
                .build();
        }
        return null;
    }

    private Response checkObjectRights(MCRObjectID objectID) {
        if(!MCRAccessManager.checkPermission(objectID, MCRAccessManager.PERMISSION_WRITE)) {
            return Response
                .status(Response.Status.UNAUTHORIZED)
                .entity(new Gson()
                    .toJson(new CMOResourceError("No Rights to write to object " + objectID)))
                .build();
        }
        return null;
    }

    private Response checkObjectExists(MCRObjectID objectID) {
        if (!MCRMetadataManager.exists(objectID)) {
            return Response
                .status(Response.Status.BAD_REQUEST)
                .entity(new Gson().toJson(new CMOResourceError(
                    "Object with ID " + objectID + " does not exist or was deleted!")))
                .build();
        }
        return null;
    }

    @Path("link/{from}/{to}")
    @Produces(MediaType.APPLICATION_JSON)
    @POST
    public Response linkObjects(@PathParam("from") String from, @PathParam("to") String to) {
        Optional<Response> validate = Stream.of(validateObjectID(from), validateObjectID(to))
            .filter(Objects::nonNull)
            .findFirst();
        if (validate.isPresent()) {
            return validate.get();
        }
        Optional<Response> rightsCheck = Stream.of(
            checkObjectRights(MCRObjectID.getInstance(from)),
            checkObjectRights(MCRObjectID.getInstance(to)))
            .filter(Objects::nonNull)
            .findFirst();
        if (rightsCheck.isPresent()) {
            return rightsCheck.get();
        }

        MCRObjectID fromID = MCRObjectID.getInstance(from);
        MCRObjectID toID = MCRObjectID.getInstance(to);

        Optional<Response> existsCheck = Stream.of(
            checkObjectExists(fromID),
            checkObjectExists(toID))
            .filter(Objects::nonNull)
            .findFirst();
        if (existsCheck.isPresent()) {
            return existsCheck.get();
        }

        if (!(fromID.getTypeId().equals("work") && toID.getTypeId().equals("expression"))) {
            return Response
                .status(Status.BAD_REQUEST)
                .entity(new Gson().toJson(
                    new CMOResourceError("Linking is only supported from work to expression!")))
                .build();
        }

        return linkWorkAndExpression(fromID, toID);
    }

    private Response linkWorkAndExpression(MCRObjectID fromID, MCRObjectID toID) {
        MCRObject expression = MCRMetadataManager.retrieveMCRObject(toID);

        MEIWrapper expressionWrapper = MEIWrapper.getWrapper(expression);
        if (expressionWrapper == null) {
            throw new IllegalArgumentException("Given expression does not contain a MEI wrapper!");
        }
        
        String expressionCMOId = getCMOIdentifier(expressionWrapper);
        
        MCRObject work = MCRMetadataManager.retrieveMCRObject(fromID);
        MEIWorkWrapper workWrapper = (MEIWorkWrapper) MEIWrapper.getWrapper(work);
        if (workWrapper == null) {
            throw new IllegalArgumentException("Given work does not contain a MEI wrapper!");
        }
        String workCMOId = getCMOIdentifier(workWrapper);

        addExpressionLinkToWorkAndSave(toID, workWrapper, expressionCMOId, work);
        addWorkRelationToExpressionAndSave(fromID, toID, expressionWrapper, workCMOId, expression);

        return Response.status(Status.OK).entity("{}").build();
    }

    private static void addExpressionLinkToWorkAndSave(MCRObjectID toID, MEIWorkWrapper workWrapper,
        String expressionCMOId, MCRObject work) {
        Element expressionList = workWrapper.getOrCreateElement(
            MEIElementConstants.EXPRESSION_LIST);


        boolean expressionExists = false;
        for (Element expressionElement : expressionList.getChildren(
            MEIElementConstants.EXPRESSION, MEIUtils.MEI_NAMESPACE)) {
            String codeVal = expressionElement
                .getAttributeValue(MEIAttributeConstants.CODEDVAL);
            if (codeVal != null && codeVal.equals(toID.toString())) {
                expressionExists = true;
                break;
            }
        }

        if (!expressionExists) {
            Element newExpression = new Element(MEIElementConstants.EXPRESSION,
                MEIUtils.MEI_NAMESPACE);
            newExpression.setAttribute(MEIAttributeConstants.CODEDVAL, toID.toString());
            newExpression.setAttribute("auth.uri", MCRFrontendUtil.getBaseURL() + "receive/");
            newExpression.setAttribute("label", expressionCMOId);
            expressionList.addContent(newExpression);
            try {
                MCRMetadataManager.update(work);
            } catch (MCRAccessException e) {
                throw new MCRException("Impossible", e);
            }
        }
    }

    private static void addWorkRelationToExpressionAndSave(MCRObjectID fromID, MCRObjectID toID,
        MEIWrapper expressionWrapper, String workCMOId, MCRObject expression) {
        Element relationList = expressionWrapper.getOrCreateElement(
            MEIElementConstants.RELATION_LIST);

        boolean relationExists = false;
        for (Element relationElement : relationList.getChildren(MEIElementConstants.EXPRESSION,
            MEIUtils.MEI_NAMESPACE)) {
            String target = relationElement
                .getAttributeValue(MEIAttributeConstants.CODEDVAL);
            if (target != null && target.equals(toID.toString())) {
                relationExists = true;
                break;
            }
        }

        if (!relationExists) {
            Element newRelation = new Element(MEIElementConstants.RELATION, MEIUtils.MEI_NAMESPACE);
            newRelation.setAttribute(MEIAttributeConstants.REL, "isRealizationOf");
            newRelation.setAttribute(MEIAttributeConstants.TARGET, fromID.toString());
            newRelation.setAttribute("label", workCMOId);
            relationList.addContent(newRelation);
            try {
                MCRMetadataManager.update(expression);
            } catch (MCRAccessException e) {
                throw new MCRException("Impossible", e);
            }
        }
    }

    private static String getCMOIdentifier(MEIWrapper expressionWrapper) {
        Element identifier = expressionWrapper.getXpath(
            ".//mei:" + MEIElementConstants.IDENTIFIER + "[@type='CMO']");
        if (identifier == null) {
            throw new IllegalArgumentException("Given element does not contain a CMO identifier!");
        }

        return identifier.getTextTrim();
    }
}
