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

import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import org.jdom2.Element;
import org.mycore.mei.classification.MCRMEIClassificationSupport;

public class MEIExpressionWrapper extends MEIWrapper {

    private static final List<String> TOP_LEVEL_ELEMENT_ORDER = new ArrayList<>();

    private static final String FIRST_CLASS_IN_TITLE = "cmo_makamler";

    private static final String SECOND_CLASS_IN_TITLE = "cmo_musictype";

    static {
        TOP_LEVEL_ELEMENT_ORDER.add("identifier");
        TOP_LEVEL_ELEMENT_ORDER.add("title");
        TOP_LEVEL_ELEMENT_ORDER.add("arranger");
        TOP_LEVEL_ELEMENT_ORDER.add("author");
        TOP_LEVEL_ELEMENT_ORDER.add("composer");
        TOP_LEVEL_ELEMENT_ORDER.add("contributor");
        TOP_LEVEL_ELEMENT_ORDER.add("editor");
        TOP_LEVEL_ELEMENT_ORDER.add("funder");
        TOP_LEVEL_ELEMENT_ORDER.add("librettist");
        TOP_LEVEL_ELEMENT_ORDER.add("lyricist");
        TOP_LEVEL_ELEMENT_ORDER.add("sponsor");

        TOP_LEVEL_ELEMENT_ORDER.add("key");
        TOP_LEVEL_ELEMENT_ORDER.add("mesuration");
        TOP_LEVEL_ELEMENT_ORDER.add("meter");
        TOP_LEVEL_ELEMENT_ORDER.add("tempo");
        TOP_LEVEL_ELEMENT_ORDER.add("incip");

        TOP_LEVEL_ELEMENT_ORDER.add("otherChar");

        TOP_LEVEL_ELEMENT_ORDER.add("creation");
        TOP_LEVEL_ELEMENT_ORDER.add("history");
        TOP_LEVEL_ELEMENT_ORDER.add("langUsage");
        TOP_LEVEL_ELEMENT_ORDER.add("perfMedium");
        TOP_LEVEL_ELEMENT_ORDER.add("perfDuration");
        TOP_LEVEL_ELEMENT_ORDER.add("extent");
        TOP_LEVEL_ELEMENT_ORDER.add("scoreFormat");
        TOP_LEVEL_ELEMENT_ORDER.add("contents");
        TOP_LEVEL_ELEMENT_ORDER.add("context");
        TOP_LEVEL_ELEMENT_ORDER.add("biblList");
        TOP_LEVEL_ELEMENT_ORDER.add("notesStmt");
        TOP_LEVEL_ELEMENT_ORDER.add("classification");
        TOP_LEVEL_ELEMENT_ORDER.add("componentGrp");
        TOP_LEVEL_ELEMENT_ORDER.add("relationList");
        TOP_LEVEL_ELEMENT_ORDER.add("extMeta");

    }

    public MEIExpressionWrapper(Element root) {
        super(root);
    }

    @Override
    public String getWrappedElementName() {
        return "expression";
    }

    @Override
    protected boolean isElementRelevant(Element element) {
        final boolean isTitleElement = element.getName().equals("title");
        if (isTitleElement) {
            boolean singleTitle = element.getParentElement().getChildren("title", MEI_NAMESPACE).size() <= 1;
            return singleTitle || element.getTextTrim().length() > 0;
        }

        return super.isElementRelevant(element);
    }

    @Override
    public void fixElements() {
        super.fixElements();
        cleanTitle();
    }

    public void cleanTitle() {
        final Element root = this.getRoot();

        final List<Element> titles = root.getChildren("title", MEI_NAMESPACE);
        final List<Element> titlesToRemove = titles.stream()
            .filter(t -> "placeholder".equals(t.getAttributeValue("type")) ||
                "uniform".equals(t.getAttributeValue("type")) ||
                t.getTextTrim().length() == 0)
            .collect(Collectors.toList());
        titlesToRemove.forEach(this.getRoot()::removeContent);

        // create uniform title
        final String firstClassURL = this.getClassification().keySet().stream()
            .filter(k -> k.endsWith(FIRST_CLASS_IN_TITLE)).findFirst().get();
        final String makkamTitlePart = this.getClassification().get(firstClassURL)
            .stream()
            .findFirst()
            .map(makkam -> MCRMEIClassificationSupport.getStdClassLabel(firstClassURL, makkam))
            .orElseGet(() -> "");

        final String secondClassURL = this.getClassification().keySet().stream()
            .filter(k -> k.endsWith(SECOND_CLASS_IN_TITLE)).findFirst().get();
        final String musictypeTitlePart = this.getClassification()
            .get(secondClassURL).stream()
            .findFirst()
            .map(makkam -> MCRMEIClassificationSupport.getClassLabel(secondClassURL, makkam))
            .orElseGet(() -> "");

        final Element title = new Element("title", MEI_NAMESPACE);
        title.setAttribute("type", "uniform");
        title.setText(String.join(" ", makkamTitlePart, musictypeTitlePart));
        root.addContent(title);

    }

    @Override
    protected int getRankOf(Element topLevelElement) {
        return TOP_LEVEL_ELEMENT_ORDER.indexOf(topLevelElement.getName());
    }
}
