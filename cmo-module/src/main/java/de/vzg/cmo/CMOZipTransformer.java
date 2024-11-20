package de.vzg.cmo;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.List;
import java.util.Optional;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.mycore.common.MCRException;
import org.mycore.common.content.MCRByteContent;
import org.mycore.common.content.MCRContent;
import org.mycore.common.content.MCRJDOMContent;
import org.mycore.common.content.MCRStringContent;
import org.mycore.common.content.transformer.MCRContentTransformer;
import org.xml.sax.SAXException;

/**
 * Transforms XML Files like this: <br/>
 * <code>
 *     &lt;zip:zip&gt;<br/>
 *   &lt;zip:entry fileName=&quot;index.xml&quot;&gt;<br/>
 *     &lt;mycoreobject id=&quot;...&quot;&gt;...&lt;/mycoreobject&gt;<br/>
 *   &lt;/zip:entry&gt;<br/>
 * &lt;/zip:entry&gt;<br/>
 * </code>
 */
public class CMOZipTransformer extends MCRContentTransformer {

    public static final Namespace ZIP_NAMESPACE = Namespace
        .getNamespace("zip", "http://mycore.de/ns/zip");

    public static final Logger LOGGER = LogManager.getLogger();

    @Override
    public MCRContent transform(MCRContent mcrContent) throws IOException {
        try {
            final Document xml = mcrContent.asXML();
            final List<Element> zipXMLEntry = xml.getRootElement().getChildren("entry", ZIP_NAMESPACE);
            return new MCRZipContent(zipXMLEntry);
        } catch (JDOMException e) {
            throw new MCRException("Error while getting xml of source", e);
        }
    }

    private static class MCRZipContent extends MCRContent {

        private final List<Element> zipXMLEntry;

        MCRZipContent(List<Element> zipXMLEntry) {
            this.zipXMLEntry = zipXMLEntry;
        }

        @Override
        public InputStream getInputStream() throws IOException {
            final Path tempZip = Files.createTempFile("export", ".tmp.zip");
            try (OutputStream os = Files.newOutputStream(tempZip)) {
                final ZipOutputStream zipOutputStream = new ZipOutputStream(os);
                this.zipXMLEntry.stream()
                    .map(this::getEntryContentTuple)
                    .forEach(tuple -> {
                        try {
                            zipOutputStream.putNextEntry(tuple.getEntry());
                            tuple.getContent().sendTo(zipOutputStream);
                            zipOutputStream.closeEntry();
                        } catch (IOException e) {
                            throw new MCRException("Error while writing ZipFile!");
                        }
                    });
                zipOutputStream.finish();
            }

            return Files.newInputStream(tempZip, StandardOpenOption.DELETE_ON_CLOSE);
        }

        private MCRZipEntryContentTuple getEntryContentTuple(Element xmlEntry) {
            final String fileName = xmlEntry.getAttributeValue("fileName");
            final List<Element> children = xmlEntry.getChildren();
            if (children.isEmpty() && xmlEntry.getText().length()==0) {
                LOGGER.warn( "Zip Entry of " + fileName + " is Empty!");
                return new MCRZipEntryContentTuple(new ZipEntry(fileName), new MCRByteContent(new byte[0]));
            }
            final String type = Optional.ofNullable(xmlEntry.getAttributeValue("type")).orElse("xml");
            switch (type){
                case "text":
                    return new MCRZipEntryContentTuple(new ZipEntry(fileName), new MCRStringContent(xmlEntry.getText()));
                default:
                    return new MCRZipEntryContentTuple(new ZipEntry(fileName), new MCRJDOMContent(children.get(0).clone()));
            }
        }
    }

    private static class MCRZipEntryContentTuple {

        private ZipEntry entry;

        private MCRContent content;

        MCRZipEntryContentTuple(ZipEntry entry, MCRContent content) {
            this.entry = entry;
            this.content = content;
        }

        public ZipEntry getEntry() {
            return entry;
        }

        public MCRContent getContent() {
            return content;
        }
    }
}
