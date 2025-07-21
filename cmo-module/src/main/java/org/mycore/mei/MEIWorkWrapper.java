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
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.IDENTIFIER);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.TITLE);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.KEY);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.MENSURATION);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.METER);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.TEMPO);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.INCIP);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.OTHER_CHAR);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CREATION);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.HISTORY);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.LANG_USAGE);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.PERF_MEDIUM);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.PERF_DURATION);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.AUDIENCE);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CONTENTS);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CONTEXT);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.BIBL_LIST);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.NOTES_STMT);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CLASSIFICATION);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.EXPRESSION_LIST);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.COMPONENT_GRP);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.RELATION_LIST);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.EXT_META);
    }

    @Override
    public String getWrappedElementName() {
        return "work";
    }

    @Override
    protected boolean isElementRelevant(Element element) {
        boolean relevantForMe = element.getName().equals(MEIElementConstants.TITLE);
        return relevantForMe || super.isElementRelevant(element);
    }

    @Override
    protected int getRankOf(Element topLevelElement) {
        return TOP_LEVEL_ELEMENT_ORDER.indexOf(topLevelElement.getName());
    }
}
