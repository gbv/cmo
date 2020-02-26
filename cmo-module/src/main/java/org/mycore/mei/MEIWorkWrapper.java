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

package org.mycore.mei;

import java.util.ArrayList;
import java.util.List;

import org.jdom2.Element;

public class MEIWorkWrapper extends MEIWrapper {

    public MEIWorkWrapper(Element root) {
        super(root);
    }

    private static final List<String> TOP_LEVEL_ELEMENT_ORDER = new ArrayList<>();

    static {
        TOP_LEVEL_ELEMENT_ORDER.add("identifier");
        TOP_LEVEL_ELEMENT_ORDER.add("titleStmt");
        TOP_LEVEL_ELEMENT_ORDER.add("key");
        TOP_LEVEL_ELEMENT_ORDER.add("mensuration");
        TOP_LEVEL_ELEMENT_ORDER.add("meter");
        TOP_LEVEL_ELEMENT_ORDER.add("tempo");
        TOP_LEVEL_ELEMENT_ORDER.add("incip");
        TOP_LEVEL_ELEMENT_ORDER.add("otherChar");
        TOP_LEVEL_ELEMENT_ORDER.add("creation");
        TOP_LEVEL_ELEMENT_ORDER.add("history");
        TOP_LEVEL_ELEMENT_ORDER.add("langUsage");
        TOP_LEVEL_ELEMENT_ORDER.add("perfMedium");
        TOP_LEVEL_ELEMENT_ORDER.add("perfDuration");
        TOP_LEVEL_ELEMENT_ORDER.add("audience");
        TOP_LEVEL_ELEMENT_ORDER.add("contents");
        TOP_LEVEL_ELEMENT_ORDER.add("context");
        TOP_LEVEL_ELEMENT_ORDER.add("biblList");
        TOP_LEVEL_ELEMENT_ORDER.add("notesStmt");
        TOP_LEVEL_ELEMENT_ORDER.add("classification");
        TOP_LEVEL_ELEMENT_ORDER.add("expressionList");
        TOP_LEVEL_ELEMENT_ORDER.add("componentGrp");
        TOP_LEVEL_ELEMENT_ORDER.add("relationList");
        TOP_LEVEL_ELEMENT_ORDER.add("extMeta");
    }

    @Override
    public String getWrappedElementName() {
        return "work";
    }

    @Override
    protected boolean isElementRelevant(Element element) {
        boolean relevantForMe = element.getName().equals("title");
        return relevantForMe || super.isElementRelevant(element);
    }

    @Override
    protected int getRankOf(Element topLevelElement) {
        return TOP_LEVEL_ELEMENT_ORDER.indexOf(topLevelElement.getName());
    }
}
