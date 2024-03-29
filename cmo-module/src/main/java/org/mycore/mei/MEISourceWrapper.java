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

package org.mycore.mei;

import java.util.ArrayList;
import java.util.List;

import org.jdom2.Attribute;
import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

public class MEISourceWrapper extends MEIWrapper {

    private static final List<String> TOP_LEVEL_ELEMENT_ORDER = new ArrayList<>();

    private static final XPathExpression<Element> RELATION_XPATH = XPathFactory.instance()
        .compile(".//mei:relation", Filters.element(), null, MEI_NAMESPACE);

    static {
        TOP_LEVEL_ELEMENT_ORDER.add("identifier");
        TOP_LEVEL_ELEMENT_ORDER.add("titleStmt");
        TOP_LEVEL_ELEMENT_ORDER.add("editionStmt");
        TOP_LEVEL_ELEMENT_ORDER.add("pubStmt");
        TOP_LEVEL_ELEMENT_ORDER.add("physDesc");
        TOP_LEVEL_ELEMENT_ORDER.add("physLoc");
        TOP_LEVEL_ELEMENT_ORDER.add("creation");
        TOP_LEVEL_ELEMENT_ORDER.add("seriesStmt");
        TOP_LEVEL_ELEMENT_ORDER.add("history");
        TOP_LEVEL_ELEMENT_ORDER.add("langUsage");
        TOP_LEVEL_ELEMENT_ORDER.add("contents");
        TOP_LEVEL_ELEMENT_ORDER.add("biblList");
        TOP_LEVEL_ELEMENT_ORDER.add("notesStmt");
        TOP_LEVEL_ELEMENT_ORDER.add("classification");
        TOP_LEVEL_ELEMENT_ORDER.add("itemList");
        TOP_LEVEL_ELEMENT_ORDER.add("componentGrp");
        TOP_LEVEL_ELEMENT_ORDER.add("componentList");
        TOP_LEVEL_ELEMENT_ORDER.add("relationList");
    }

    public MEISourceWrapper(Element sourceRoot) {
        super(sourceRoot);
    }

    protected int getRankOf(Element topLevelElement) {
        return TOP_LEVEL_ELEMENT_ORDER.indexOf(topLevelElement.getName());
    }

    @Override
    public void normalize() {
        final List<Element> relationList = RELATION_XPATH.evaluate(this.getRoot());

        relationList.forEach(relation -> {
            final Attribute label = relation.getAttribute("label");
            if (label != null) {
                relation.removeAttribute(label);
            }
        });

        super.normalize();
    }

    @Override
    public String getWrappedElementName() {
        return "source";
    }

}
