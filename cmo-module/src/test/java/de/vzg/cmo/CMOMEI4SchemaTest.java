package de.vzg.cmo;

import java.io.IOException;
import java.io.InputStream;
import java.util.Objects;

import javax.xml.XMLConstants;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;

import org.jdom2.Document;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.transform.JDOMSource;
import org.junit.Ignore;
import org.junit.Test;
import org.mycore.common.MCRClassTools;
import org.xml.sax.SAXException;

@Ignore
public class CMOMEI4SchemaTest {

    @Test
    public void testSchema() throws IOException, SAXException, JDOMException {
        final ClassLoader cl = CMOMEI4SchemaTest.class.getClassLoader();
        final Document build;

        try (InputStream is = cl.getResourceAsStream("MEI/schema-4.0-test.xml")) {
            build = new SAXBuilder().build(is);
        }

        SchemaFactory schemaFactory = SchemaFactory.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
        final Schema schema = schemaFactory
            .newSchema(Objects.requireNonNull(MCRClassTools.getClassLoader().getResource(
                "schema/mei-4.0-all_anyStart.xsd")));

        schema.newValidator().validate(new JDOMSource(build));
    }
}
