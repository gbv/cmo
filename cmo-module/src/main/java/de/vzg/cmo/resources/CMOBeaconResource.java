package de.vzg.cmo.resources;

import java.io.IOException;
import java.net.URI;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.core.Response;

import org.apache.solr.client.solrj.SolrClient;
import org.apache.solr.client.solrj.SolrServerException;
import org.apache.solr.common.SolrDocument;
import org.apache.solr.common.params.ModifiableSolrParams;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.frontend.MCRFrontendUtil;
import org.mycore.solr.MCRSolrClientFactory;
import org.mycore.solr.search.MCRSolrSearchUtils;

@Path("gnd/")
public class CMOBeaconResource {

    @Path("beacon.txt")
    @GET
    public Response getBeacon() {
        StringBuilder sb = new StringBuilder();

        sb.append("#FORMAT: GND-BEACON\n");
        sb.append("#VERSION: 0.1\n");
        sb.append("#FEED: ").append(MCRFrontendUtil.getBaseURL()).append("rsc/gnd/beacon.txt").append("\n");
        sb.append("#TARGET: ").append(MCRFrontendUtil.getBaseURL()).append("rsc/gnd/{ID}\n");
        sb.append("#PREFIX: http://d-nb.info/gnd/\n");
        sb.append("#NAME: ").append(MCRConfiguration2.getString("MCR.NameOfProject").get()).append("\n");
        sb.append("#CONTACT: ").append(MCRConfiguration2.getString("CMO.GND.Beacon.Contact").get()).append("\n");
        sb.append("#INSTITUTION: ").append(MCRConfiguration2.getString("CMO.GND.Beacon.Institution").get()).append("\n");
        sb.append("#MESSAGE: ").append(MCRConfiguration2.getString("CMO.GND.Beacon.Message").get()).append("\n");
        sb.append("#UPDATE: will be rebuilt on every request\n");


        final SolrClient mainSolrClient = MCRSolrClientFactory.getMainSolrClient();
        final ModifiableSolrParams params = new ModifiableSolrParams();
        params.set("q", "identifier.type.GND:*");
        params.set("rows", 99999);
        params.set("fl", "identifier.type.GND");
        MCRSolrSearchUtils.stream(mainSolrClient, params)
            .map(r -> r.getFirstValue("identifier.type.GND") + "\n")
            .forEach(sb::append);

        return Response.ok(sb.toString()).build();
    }

    @Path("{gnd}")
    @GET
    public Response getRedirect(@PathParam("gnd") String gnd) {
        final SolrDocument solrDocument;
        try {
            solrDocument = MCRSolrSearchUtils.first(MCRSolrClientFactory.getMainSolrClient(),
                "identifier.type.GND:" + gnd);
            final String id = (String) solrDocument.getFieldValue("id");

            return Response.temporaryRedirect(URI.create(MCRFrontendUtil.getBaseURL() + "receive/" + id)).build();
        } catch (IOException | SolrServerException e) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

    }
}
