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

package de.vzg.cmo.model;

import static de.vzg.cmo.model.CMODOIMetadataService.ALLOWED_MEI_TYPES_PROPERTY;

import de.vzg.maven.cmo.model.MEISourceWrapperTest;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;
import java.util.Optional;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.XMLOutputter;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.common.MCRJPATestCase;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.mei.MEIUtils;
import org.mycore.mei.MEIWrapper;
import org.mycore.pi.MCRPIMetadataService;
import org.mycore.pi.MCRPersistentIdentifier;
import org.mycore.pi.doi.MCRDigitalObjectIdentifier;
import org.mycore.pi.exceptions.MCRPersistentIdentifierException;

public class CMODOIMetadataServiceTest extends MCRJPATestCase {

    private static final Logger LOGGER = LogManager.getLogger();

    private static final String METADATA_TEST_SERVICE = "MetadataTestService";

    private MCRObject object;

    private CMODOIMetadataService testService;

    private MCRDigitalObjectIdentifier exampleDOI;

    @Before
    @Override
    public void setUp() throws Exception {
        super.setUp();
        try (InputStream is = MEISourceWrapperTest.class.getClassLoader()
            .getResourceAsStream("test_source_object.xml")) {
            object = new MCRObject(new SAXBuilder().build(is));
        } catch (JDOMException | IOException e) {
            LOGGER.error(e);
            throw e;
        }

        testService = (CMODOIMetadataService) MCRConfiguration2
            .getInstanceOf("MCR.PI.MetadataService." + METADATA_TEST_SERVICE).get();

        exampleDOI = new MCRDigitalObjectIdentifier("10.5072", "01-2018-00009") {
        };
    }

    @Test
    public void insertIdentifier() throws MCRPersistentIdentifierException {
        testService.insertIdentifier(exampleDOI, object, "");
        Assert.assertEquals("DOI in document should equal!", "10.5072/01-2018-00009",
            MEIWrapper.getWrapper(object).getRoot().getChildren("identifier", MEIUtils.MEI_NAMESPACE).stream()
                .filter(el -> el.getAttributeValue("type").equals("doi")).findAny().get().getTextTrim());
    }

    @Test
    public void removeIdentifier() throws MCRPersistentIdentifierException {
        insertIdentifier();
        testService.removeIdentifier(exampleDOI, object, "");
        Assert.assertFalse(new XMLOutputter().outputString(object.createXML()).contains("10.5072/01-2018-00009"));
    }

    @Test
    public void getIdentifier() throws MCRPersistentIdentifierException {
        insertIdentifier();
        Optional<MCRPersistentIdentifier> identifier = testService.getIdentifier(this.object, "");
        Assert.assertEquals("returned DOI should equal!", "10.5072/01-2018-00009", identifier.get().asString());
    }

    @Override
    protected Map<String, String> getTestProperties() {
        Map<String, String> testProperties = super.getTestProperties();

        testProperties.put("MCR.PI.MetadataService." + METADATA_TEST_SERVICE, CMODOIMetadataService.class.getName());
        testProperties.put("MCR.PI.MetadataService." + METADATA_TEST_SERVICE + ".Prefix", "10.5072/01-");
        testProperties.put("MCR.PI.MetadataService." + METADATA_TEST_SERVICE + "." + ALLOWED_MEI_TYPES_PROPERTY,
            "expression,source");

        return testProperties;
    }
}
