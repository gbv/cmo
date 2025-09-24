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

import static org.mycore.mei.MEIAttributeConstants.IS_REALIZATION_OF;
import static org.mycore.mei.MEIUtils.MEI_NAMESPACE;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.jdom2.Element;
import org.mycore.mei.classification.MCRMEIClassificationSupport;

public class MEIExpressionWrapper extends MEIWrapper {

    private static final List<String> TOP_LEVEL_ELEMENT_ORDER = new ArrayList<>();

    private static final String FIRST_CLASS_IN_TITLE = "cmo_makamler";

    private static final String SECOND_CLASS_IN_TITLE = "cmo_musictype";

    static {
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.IDENTIFIER);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.TITLE);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.ARRANGER);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.AUTHOR);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.COMPOSER);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CONTRIBUTOR);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.EDITOR);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.FUNDER);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.LIBRETTIST);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.LYRICIST);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.SPONSOR);

        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.KEY);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.MESURATION);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.METER);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.TEMPO);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.INCIP);

        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.OTHER_CHAR);

        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CREATION);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.HISTORY);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.LANG_USAGE);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.PERF_MEDIUM);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.PERF_DURATION);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.EXTENT);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.SCORE_FORMAT);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CONTENTS);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CONTEXT);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.BIBL_LIST);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.NOTES_STMT);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.CLASSIFICATION);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.COMPONENT_GRP);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.RELATION_LIST);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.EXT_META);

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
        final boolean isTitleElement = element.getName().equals(MEIElementConstants.TITLE);
        if (isTitleElement) {
            boolean singleTitle = element.getParentElement().getChildren(MEIElementConstants.TITLE, MEI_NAMESPACE).size() <= 1;
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
        final Optional<String> firstClassURL = this.getClassification().keySet().stream()
            .filter(k -> k.endsWith(FIRST_CLASS_IN_TITLE)).findFirst();

        final String makkamTitlePart = firstClassURL
                .map(value -> this.getClassification()
                .get(value)
                .stream()
                .findFirst()
                .map(makkam -> MCRMEIClassificationSupport.getStdClassLabel(value, makkam))
                .orElseGet(() -> "")).orElse("");

        final Optional<String> secondClassURL = this.getClassification().keySet().stream()
            .filter(k -> k.endsWith(SECOND_CLASS_IN_TITLE)).findFirst();
        final String musictypeTitlePart = secondClassURL
                .map(s -> this.getClassification()
                .get(s).stream()
                .findFirst()
                .map(makkam -> MCRMEIClassificationSupport.getClassLabel(s, makkam))
                .orElseGet(() -> "")).orElse("");

        final Element title = new Element("title", MEI_NAMESPACE);
        title.setAttribute("type", "uniform");
        title.setText(String.join(" ", makkamTitlePart, musictypeTitlePart));
        root.addContent(title);

    }

    @Override
    protected int getRankOf(Element topLevelElement) {
        return TOP_LEVEL_ELEMENT_ORDER.indexOf(topLevelElement.getName());
    }

    public List<RealizationOf> getRealizations() {
        final Element relationList = this.getElement(MEIElementConstants.RELATION_LIST);
        if (relationList == null) {
            return List.of();
        }
      return relationList.getChildren(MEIElementConstants.RELATION, MEI_NAMESPACE)
            .stream()
            .filter(rel -> IS_REALIZATION_OF.equals(rel.getAttributeValue(MEIAttributeConstants.REL)))
            .map(rel -> new RealizationOf(rel.getAttributeValue(MEIAttributeConstants.TARGET),
                rel.getAttributeValue(MEIAttributeConstants.LABEL)))
            .toList();
    }

    public static record RealizationOf(String target, String label) {
    }
}
