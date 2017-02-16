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

package de.vzg.cmo.model;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.function.Consumer;

import org.jdom2.Element;

public abstract class MEIWrapper {

    private final Element root;

    public MEIWrapper(Element root) {
        String rootName = root.getName();
        if (!getWrappedElementName().equals(rootName)) {
            throw new IllegalArgumentException(rootName + " is can not be wrapped by " + this.getClass().toString());
        }
        this.root = root;
    }

    public abstract String getWrappedElementName();

    public Element getRoot() {
        return root;
    }

    protected abstract int getRankOf(Element topLevelElement);

    public void orderTopLevelElement() {
        Consumer<Element> elementConsumer = (Consumer<Element>) this.root::removeContent;
        Comparator<Element> sortFn = (e1, e2) -> getRankOf(e1) - getRankOf(e2);
        new ArrayList<>(this.root.getChildren())
            .stream()
            .peek(elementConsumer)
            .sorted(sortFn)
            .forEach(this.root::addContent);
    }


}
