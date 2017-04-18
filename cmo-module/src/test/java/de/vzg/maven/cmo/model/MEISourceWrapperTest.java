/*
 *  This file is part of ***  M y C o R e  ***
 *  See http://www.mycore.de/ for details.
 *
 *  This program is free software; you can use it, redistribute it
 *  and / or modify it under the terms of the GNU General Public License
 *  (GPL) as published by the Free Software Foundation; either version 2
 *  of the License or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program, in a file called gpl.txt or license.txt.
 *  If not, write to the Free Software Foundation Inc.,
 *  59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 *
 */

/*
 *  This file is part of ***  M y C o R e  ***
 *  See http://www.mycore.de/ for details.
 *
 *  This program is free software; you can use it, redistribute it
 *  and / or modify it under the terms of the GNU General Public License
 *  (GPL) as published by the Free Software Foundation; either version 2
 *  of the License or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful, but
 *  WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program, in a file called gpl.txt or license.txt.
 *  If not, write to the Free Software Foundation Inc.,
 *  59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
 *
 */

package de.vzg.maven.cmo.model;

import de.vzg.cmo.model.MEISourceWrapper;
import de.vzg.cmo.model.MEIUtils;

import java.io.IOException;
import java.io.InputStream;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.filter.Filters;
import org.jdom2.input.SAXBuilder;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class MEISourceWrapperTest {

    private static final Logger LOGGER = LogManager.getLogger();

    private Document doc;

    @Before
    public void setUp() {
        try (InputStream is = MEISourceWrapperTest.class.getClassLoader().getResourceAsStream("test_source.xml")) {
            doc = new SAXBuilder().build(is);

        } catch (JDOMException | IOException e) {
            LOGGER.error(e);
        }
    }

    @Test
    public void orderTopLevelElement() throws Exception {
        Element rootElement = doc.getRootElement();
        new MEISourceWrapper(rootElement).orderTopLevelElement();
        LOGGER.info(new XMLOutputter(Format.getPrettyFormat()).outputString(rootElement));
        Assert.assertEquals("langUsage", rootElement.getChildren().get(4).getName());
    }
    private static final XPathExpression<Element> classificationXpath = XPathFactory.instance()
        .compile("//mei:classification", Filters.element(), null, MEIUtils.MEI_NAMESPACE);


}
