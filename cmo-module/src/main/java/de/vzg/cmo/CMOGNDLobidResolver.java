package de.vzg.cmo;

import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.jdom2.Element;
import org.jdom2.transform.JDOMSource;
import org.mycore.common.MCRException;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class CMOGNDLobidResolver implements URIResolver {

    private static final String LOBID_URL = "https://lobid.org/gnd/";

    @Override
    public Source resolve(String href, String base) throws TransformerException {
        String[] split = href.split(":");

        if (split.length != 2) {
            throw new TransformerException("Invalid uri resolver format: " + href + " ");
        }

        String gndStr = split[1];
        try (CloseableHttpClient client = HttpClients.createDefault()) {
            HttpGet httpGet = new HttpGet(LOBID_URL + gndStr + ".json");
            try (CloseableHttpResponse resp = client.execute(httpGet)) {
                try (InputStream content = resp.getEntity().getContent()) {
                    try(InputStreamReader isr = new InputStreamReader(content); BufferedReader br = new BufferedReader(isr)) {
                        String json = br.lines().collect(Collectors.joining(System.lineSeparator()));
                        Element jsonElement = new Element("json");
                        jsonElement.setText(json);
                        return new JDOMSource(jsonElement);
                    }
                }
            }
        } catch (IOException e) {
            throw new MCRException(e);
        }
    }


}
