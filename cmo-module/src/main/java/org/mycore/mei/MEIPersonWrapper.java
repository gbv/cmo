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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.naming.OperationNotSupportedException;

import org.jdom2.Element;
import org.mycore.mei.classification.MCRMEIAuthorityInfo;

public class MEIPersonWrapper extends MEIWrapper {

    private static final List<String> TOP_LEVEL_ELEMENT_ORDER = new ArrayList<>();

    static {
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.ADD_NAME);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.FAM_NAME);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.FORE_NAME);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.GEN_NAME);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.NAME_LINK);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.ROLE_NAME);
        TOP_LEVEL_ELEMENT_ORDER.add(MEIElementConstants.ANNOT);
    }

    public MEIPersonWrapper(Element root) {
        super(root);
    }

    @Override
    public String getWrappedElementName() {
        return "persName";
    }

    @Override
    protected int getRankOf(Element topLevelElement) {
        return TOP_LEVEL_ELEMENT_ORDER.indexOf(topLevelElement.getName());
    }

    @Override public HashMap<String, List<String>> getClassification() {
        return new HashMap<>();
    }

    @Override
    public void setClassification(HashMap<String, List<String>> classificationMap) throws OperationNotSupportedException {
        throw new OperationNotSupportedException("A person can not have a classification!");
    }

    @Override public HashMap<MCRMEIAuthorityInfo, List<String>> getClassificationOld() {
        return new HashMap<>();
    }

    @Override
    public void setClassificationOld(Map<MCRMEIAuthorityInfo, List<String>> classificationMap) throws OperationNotSupportedException {
        throw new OperationNotSupportedException("A person can not have a classification!");
    }
}
