package org.mycore.mei.migration;

import java.io.IOException;
import java.net.URISyntaxException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.JDOMException;
import org.junit.Test;
import org.mycore.common.MCRClassTools;
import org.mycore.frontend.cli.MCRClassification2Commands;
import org.xml.sax.SAXParseException;

public class MEIClassificationMigratorTest extends MEIMigratorTestBase {

    private static final Logger LOGGER = LogManager.getLogger();

    @Test
    public void migrate() throws IOException, JDOMException, SAXParseException, URISyntaxException {
        MCRClassification2Commands
            .loadFromURL(MCRClassTools.getClassLoader().getResource("MEI/classification/usuler.xml").toString());
        testWith("classification_old.xml", "classification_new.xml", new MEIClassificationMigrator());
    }
}