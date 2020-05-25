package org.mycore.mei.migration;

import java.io.IOException;
import java.net.URISyntaxException;

import org.jdom2.JDOMException;
import org.junit.Test;
import org.xml.sax.SAXParseException;

public class MEILangUsageMigratorTest extends MEIMigratorTestBase {

    @Test
    public void migrate() throws IOException, JDOMException, SAXParseException, URISyntaxException {
        testWith("expression_2_old.xml","expression_2_new.xml",new MEILangUsageMigrator());
    }
}
