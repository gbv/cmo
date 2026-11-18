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

package de.vzg.cmo.solr;

import static org.mycore.solr.MCRSolrConstants.SOLR_CONFIG_PREFIX;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Locale;

import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLStreamConstants;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamReader;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.solr.index.strategy.MCRSolrFileStrategy;

/**
 * Keeps the TEI text editions out of the extracting update handler of solr.
 * <p>
 * A file whose content is sent is indexed by {@code /update/extract}: solr receives the bytes of the file, lets
 * tika extract its text, and every field of the file document has to travel as a {@code literal.<field>}
 * parameter of the url. For a TEI text edition that url grows beyond the header limit of the servlet container,
 * because {@link CMOTEIFileIndexAccumulator} puts the whole text of the edition into the document, so nothing
 * is indexed at all. The extraction is not needed either: the accumulator reads the TEI itself and states its
 * text in {@code tei.text} and the fields below it, structured and searchable per element.
 * <p>
 * This strategy therefore answers {@code false} for a TEI file, which makes
 * {@link org.mycore.solr.index.handlers.MCRSolrIndexHandlerFactory} send the file document through the plain
 * update handler instead: the same fields, the accumulators included, but in the body of the request and
 * without the content of the file. Every other file is passed on to the delegate, which is configured in
 * {@value #DELEGATE_PROPERTY} and is the strategy MyCoRe would use without this one.
 *
 * @see <a href="https://github.com/gbv/cmo/issues/296">CMO issue 296</a>
 */
public class CMOTEIFileIndexStrategy implements MCRSolrFileStrategy {

    /**
     * Strategy which decides about all files which are not TEI text editions.
     */
    public static final String DELEGATE_PROPERTY = SOLR_CONFIG_PREFIX + "TEIFileIndexStrategy.Delegate";

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String TEI_NAMESPACE_URI = "http://www.tei-c.org/ns/1.0";

    private static final String TEI_ROOT_ELEMENT = "TEI";

    private static final String XML_EXTENSION = ".xml";

    private final MCRSolrFileStrategy delegate;

    public CMOTEIFileIndexStrategy() {
        this(MCRConfiguration2.getOrThrow(DELEGATE_PROPERTY, MCRConfiguration2::instantiateClass));
    }

    public CMOTEIFileIndexStrategy(MCRSolrFileStrategy delegate) {
        this.delegate = delegate;
    }

    @Override
    public boolean check(Path file, BasicFileAttributes attrs) {
        if (isTEIFile(file)) {
            LOGGER.debug("{} is a TEI text edition, sending its fields without its content.", file);
            return false;
        }
        return delegate.check(file, attrs);
    }

    /**
     * Returns whether the given file is a TEI document, judged by its root element. Only the beginning of the
     * file is read, the element is the first one of it. The encoding does not have to be known beforehand, the
     * parser takes it from the byte order mark or from the xml declaration, which matters here because the TEI
     * files of the editions are UTF-16.
     */
    public static boolean isTEIFile(Path file) {
        if (!isXMLFile(file)) {
            return false;
        }
        try (InputStream input = Files.newInputStream(file)) {
            XMLStreamReader reader = createXMLStreamReader(input);
            try {
                while (reader.hasNext()) {
                    if (reader.next() == XMLStreamConstants.START_ELEMENT) {
                        return TEI_ROOT_ELEMENT.equals(reader.getLocalName())
                            && TEI_NAMESPACE_URI.equals(reader.getNamespaceURI());
                    }
                }
            } finally {
                reader.close();
            }
        } catch (IOException | XMLStreamException e) {
            LOGGER.warn(() -> "Could not read the root element of " + file + ", treating it as no TEI file.", e);
        }
        return false;
    }

    private static XMLStreamReader createXMLStreamReader(InputStream input) throws XMLStreamException {
        // a factory of its own per call, the file visitor of the indexer walks the derivates in several threads
        XMLInputFactory factory = XMLInputFactory.newInstance();
        factory.setProperty(XMLInputFactory.SUPPORT_DTD, Boolean.FALSE);
        factory.setProperty(XMLInputFactory.IS_SUPPORTING_EXTERNAL_ENTITIES, Boolean.FALSE);
        return factory.createXMLStreamReader(input);
    }

    private static boolean isXMLFile(Path file) {
        Path fileName = file.getFileName();
        return fileName != null && fileName.toString().toLowerCase(Locale.ROOT).endsWith(XML_EXTENSION);
    }

}
