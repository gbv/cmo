package org.mycore.mei.migration;

import java.io.IOException;
import java.io.InputStream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.junit.Assert;
import org.mycore.common.MCRClassTools;
import org.mycore.common.MCRJPATestCase;
import org.mycore.common.xml.MCRXMLHelper;
import org.mycore.mei.MEIWrapper;

public class MEIMigratorTestBase extends MCRJPATestCase {

    private static final Logger LOGGER = LogManager.getLogger();

    protected Document getDocument(String name) throws IOException, JDOMException {
        try(InputStream is = MCRClassTools.getClassLoader().getResourceAsStream("MEI/migration/"+name)){
            return new SAXBuilder().build(is);
        }
    }

    protected void testWith(String old, String nevv, MEIMigrator migrator) throws IOException, JDOMException {
        final Document mei4Expected = getDocument(nevv);
        final Document mei3 = getDocument(old);

        final MEIWrapper wrapper = MEIWrapper.getWrapper(mei3.getRootElement());

        migrator.migrate(wrapper);
        final Element exptected = mei4Expected.getRootElement();
        final Element actual = wrapper.getRoot();
        final boolean match = MCRXMLHelper.deepEqual(exptected, actual);

        if(!match){
            final XMLOutputter outputter = new XMLOutputter(Format.getPrettyFormat());
            LOGGER.warn(outputter.outputString(exptected));
            LOGGER.warn(outputter.outputString(actual));
        }

        Assert.assertTrue(match);
    }
}
