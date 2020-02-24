package org.mycore.mei.migration;

import java.text.Normalizer;
import java.util.HashMap;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.jdom2.Document;
import org.jdom2.Element;
import org.mycore.common.MCRConstants;
import org.mycore.common.MCRException;
import org.mycore.datamodel.classifications2.MCRCategory;
import org.mycore.datamodel.classifications2.MCRCategoryID;
import org.mycore.datamodel.classifications2.MCRLabel;

public class CMOClassificationIDPatch {

    private final List<String> preveredLabelPriority =
        Stream.of("en", "tr", "de")
            .collect(Collectors.toList());

    private Document resultDocument;

    private HashMap<String, String> resultMap = new HashMap<>();

    private String rootID;

    private HashMap<String, MCRCategoryID> alreadyPresentID = new HashMap<>();

    public static String withoutDiacritics(String s) {
        // Decompose any ş into s and combining-,.
        String s2 = Normalizer.normalize(s, Normalizer.Form.NFD);
        return s2.replaceAll("[^\\p{ASCII}]", "");
    }

    public void fixClassification(MCRCategory root) {
        rootID = root.getId().getRootID();

        final Element rootElement = new Element("mycoreclass");
        rootElement.setAttribute("noNamespaceSchemaLocation","MCRClassification.xsd", MCRConstants.XSI_NAMESPACE);
        rootElement.setAttribute("ID", rootID);
        resultDocument = new Document(rootElement);
        root.getLabels().stream().map(this::createLabelElement).forEach(rootElement::addContent);

        final Element categories = new Element("categories");
        root.getChildren().stream().map(category -> this.fixCategory(category, true, null)).forEach(categories::addContent);
        rootElement.addContent(categories);

    }

    private Element createLabelElement(MCRLabel mcrLabel) {
        final Element label = new Element("label");
        Optional.ofNullable(mcrLabel.getDescription()).ifPresent(descr -> label.setAttribute("description", descr));
        Optional.ofNullable(mcrLabel.getLang())
            .ifPresent(lang -> label.setAttribute("lang", lang, MCRConstants.XML_NAMESPACE));
        Optional.ofNullable(mcrLabel.getText()).ifPresent(text -> label.setAttribute("text", text));
        return label;
    }

    private Element fixCategory(MCRCategory category, boolean firstLevel, String assignedID) {
        boolean useCounting = ("cmo_makamler".equals(rootID) || "cmo_usuler".equals(rootID)) && !firstLevel;
        final Element categoryElement = new Element("category");
        final Set<MCRLabel> labels = category.getLabels();
        labels.stream().map(this::createLabelElement).forEach(categoryElement::addContent);
        final Optional<String> labelToUseForID = labels.stream()
            .sorted(
                (l1, l2) -> preveredLabelPriority.indexOf(l2.getLang()) - preveredLabelPriority
                    .indexOf(l1.getLang()))
            .map(MCRLabel::getText)
            .findFirst();

        final MCRCategoryID oldID = category.getId();
        if (labelToUseForID.isEmpty()) {
            throw new MCRException("No label found for category with id " + oldID.toString());
        }

        final String newID;
        if(useCounting) {
            newID  = assignedID;
        } else {
            newID = withoutDiacritics(labelToUseForID.get()).replace(' ', '_');

        }

        if (alreadyPresentID.containsKey(newID)) {
            throw new MCRException(
                "The id " + newID + " generated from " + oldID.toString() + " is already present with "
                    + alreadyPresentID.get(newID).toString());
        }

        alreadyPresentID.put(newID, oldID);
        resultMap.put(oldID.toString(), rootID + ":" + newID);
        categoryElement.setAttribute("ID", newID);

        List<MCRCategory> children = category.getChildren();
        for (int i = 0; i < children.size(); i++) {
            MCRCategory child = children.get(i);
            Element element = fixCategory(child, false, newID+ "_" + i);
            categoryElement.addContent(element);
        }

        return categoryElement;

    }

    public Document getResultDocument() {
        return resultDocument;
    }

    public HashMap<String, String> getResultMap() {
        return resultMap;
    }

    public String getRootID() {
        return rootID;
    }
}
