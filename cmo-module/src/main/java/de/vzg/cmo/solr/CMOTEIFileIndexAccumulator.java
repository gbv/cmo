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

package de.vzg.cmo.solr;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Collection;
import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.function.Consumer;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.solr.common.SolrInputDocument;
import org.jdom2.Content;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.Namespace;
import org.jdom2.Text;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathExpression;
import org.jdom2.xpath.XPathFactory;
import org.mycore.common.content.MCRPathContent;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.solr.index.file.MCRSolrFileIndexAccumulator;

/**
 * Extracts the searchable parts of a CMO TEI text edition into the solr document of the file.
 * <p>
 * The accumulator only touches XML files whose root element is {@code tei:TEI}, every other file is left
 * untouched. All fields it produces are prefixed with {@value #FIELD_PREFIX}, so they never collide with the
 * fields of the metadata (MEI/MODS) documents.
 * <p>
 * Besides the fields for the single TEI elements the accumulator fills three bundles which mirror the search
 * mask of the text edition:
 * <dl>
 *   <dt>{@code tei.text}</dt>
 *   <dd>everything of the standard search: title, notes, authors, editors, metre, incipit, head and lyrics</dd>
 *   <dt>{@code tei.text.apparatus}</dt>
 *   <dd>the critical apparatus and the annotations: lemma, readings, annotation and provenance notes</dd>
 *   <dt>{@code tei.lyrics.primary}</dt>
 *   <dd>the primary text of the piece: incipit, head and the main part of the lyrics</dd>
 * </dl>
 *
 * @see <a href="https://github.com/gbv/cmo/issues/296">CMO issue 296</a>
 */
public class CMOTEIFileIndexAccumulator implements MCRSolrFileIndexAccumulator {

    /**
     * Prefix of every solr field which is filled by this accumulator.
     */
    public static final String FIELD_PREFIX = "tei.";

    private static final Logger LOGGER = LogManager.getLogger();

    private static final Namespace TEI_NAMESPACE = Namespace.getNamespace("tei", "http://www.tei-c.org/ns/1.0");

    private static final String TEI_ROOT_ELEMENT = "TEI";

    private static final String XML_EXTENSION = ".xml";

    /**
     * {@code @ana} of the segments which carry the main part of the lyrics.
     */
    private static final String ANA_MAIN_PART_LYRICS = "mainPartLyrics";

    /**
     * {@code @xml:id} of the {@code tei:metDecl} which declares the named metrical feet.
     */
    private static final String MET_DECL_FEET = "feet";

    /**
     * {@code @xml:id} of the {@code tei:metDecl} which declares the named metres (bahir).
     */
    private static final String MET_DECL_VEZIN = "vezin";

    /**
     * {@code @type} of the note which names the lyricist. It belongs to the annotations of the edition.
     */
    private static final String NOTE_TYPE_LYRICIST = "lyricist";

    /**
     * Replacement for the characters which are not allowed in the dynamic part of a solr field name.
     */
    private static final char FIELD_NAME_REPLACEMENT = '_';

    /**
     * The attributes which may carry a reference to another object.
     */
    private static final List<String> REFERENCE_ATTRIBUTES = List.of("ref", "target", "source", "wit", "corresp");

    /**
     * {@code @type} of the notes which name the bahir and the metrical feet of the piece. Both carry the ids of
     * the declared {@code tei:metSym}s in their {@code @corresp}.
     */
    private static final String NOTE_TYPE_BAHIR = "bahir";

    private static final String NOTE_TYPE_METER = "meter";

    /**
     * Marks the part of a URI which holds the classification, followed by the classification and the category.
     * The CMO terminology states them as path segments, the CMO API separates the category by a {@code #}.
     */
    private static final List<String> CLASSIFICATION_MARKERS = List.of("/terminology/", "/classifications/");

    /**
     * Separates the classification from the category in a solr category value, as MyCoRe states it.
     */
    private static final char CATEGORY_SEPARATOR = ':';

    /**
     * Divides the metrical feet inside a {@code tei:l/@real}. It is a structural marker, not a syllable, so it
     * is left out of the list of the metrical symbols of a piece.
     */
    private static final char FOOT_DIVIDER = '|';

    private static final XPathFactory XPATH_FACTORY = XPathFactory.instance();

    private static final XPathExpression<Element> TITLES = elements("//tei:title[not(tei:title)]");

    private static final XPathExpression<Element> TITLE_TRANSCRIPTIONS =
        elements("//tei:title[@type='titleTranscription']");

    private static final XPathExpression<Element> IDNOS = elements(
        "//tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:idno | //tei:text//tei:msIdentifier/tei:idno");

    private static final XPathExpression<Element> WITNESSES = elements("//tei:listWit/tei:witness");

    private static final XPathExpression<Element> AUTHORS = elements("//tei:titleStmt/tei:author");

    private static final XPathExpression<Element> EDITORS = elements("//tei:titleStmt/tei:editor");

    private static final XPathExpression<Element> TYPED_NOTES = elements("//tei:note[@type]");

    private static final XPathExpression<Element> ANNOTATION_NOTES =
        elements("//tei:back/tei:div[@type='annotations']//tei:note");

    private static final XPathExpression<Element> PROVENANCE_NOTES =
        elements("//tei:back/tei:div[@type='provenance']//tei:note");

    private static final XPathExpression<Element> MET_DECLS = elements("//tei:encodingDesc/tei:metDecl");

    private static final XPathExpression<Element> VERSE_GROUPS = elements("//tei:lg[@rhyme]");

    private static final XPathExpression<Element> VERSE_LINES = elements("//tei:l[@real]");

    private static final XPathExpression<Element> RUBRICS = elements("//tei:rubric");

    private static final XPathExpression<Element> INCIPITS = elements("//tei:incipit");

    private static final XPathExpression<Element> HEADS = elements("//tei:head");

    private static final XPathExpression<Element> LINE_SEGMENTS = elements("//tei:l/tei:seg[@ana]");

    private static final XPathExpression<Element> STAGES = elements("//tei:l/tei:stage");

    private static final XPathExpression<Element> SUPPLIED = elements("//tei:supplied");

    private static final XPathExpression<Element> LEMMATA = elements("//tei:app/tei:lem");

    private static final XPathExpression<Element> READINGS = elements("//tei:app/tei:rdg");

    private static final XPathExpression<Element> LANGUAGES = elements("//tei:langUsage/tei:language");

    private static final XPathExpression<Element> CITE_MILESTONES = elements("//tei:milestone[@unit='cite']");

    private static final XPathExpression<Element> VERSE_GROUP_METRES = elements("//tei:lg[@decls]");

    private static final XPathExpression<Element> CLASSIFIED_NOTES = elements("//tei:teiHeader//tei:note[@type]");

    private static final XPathExpression<Element> LOCI = elements("//tei:msItem/tei:locus");

    private static final XPathExpression<Element> MS_ITEMS = elements("//tei:msItem[@n]");

    @Override
    public void accumulate(SolrInputDocument document, Path filePath, BasicFileAttributes attributes)
        throws IOException {
        if (!isXMLFile(filePath)) {
            return;
        }

        Document teiDocument;
        try {
            teiDocument = new MCRPathContent(filePath).asXML();
        } catch (JDOMException e) {
            LOGGER.warn(() -> "Could not parse " + filePath + " as XML, skipping TEI indexing.", e);
            return;
        }

        if (!isTEIDocument(teiDocument)) {
            return;
        }

        LOGGER.debug("Indexing TEI text edition {}", filePath);
        accumulate(document, teiDocument);
    }

    /**
     * Adds all TEI fields of the given TEI document to the given solr document. The document is expected to be a
     * CMO text edition, {@link #accumulate(SolrInputDocument, Path, BasicFileAttributes)} makes sure of that.
     *
     * @param document    the solr document of the TEI file
     * @param teiDocument the parsed TEI file
     */
    public void accumulate(SolrInputDocument document, Document teiDocument) {
        Set<String> standardSearch = new LinkedHashSet<>();
        Set<String> apparatusSearch = new LinkedHashSet<>();
        Set<String> primaryLyrics = new LinkedHashSet<>();

        accumulateHeader(document, teiDocument, standardSearch);
        accumulateProsody(document, teiDocument, standardSearch);
        accumulateText(document, teiDocument, standardSearch, primaryLyrics);
        accumulateApparatus(document, teiDocument, apparatusSearch);
        accumulateReferences(document, teiDocument);

        addField(document, FIELD_PREFIX + "text", standardSearch);
        addField(document, FIELD_PREFIX + "text.apparatus", apparatusSearch);
        addField(document, FIELD_PREFIX + "lyrics.primary", primaryLyrics);
    }

    /**
     * Adds the bibliographic fields of the {@code tei:teiHeader}: titles, identifiers, witnesses, authors,
     * editors, notes and languages.
     */
    private void accumulateHeader(SolrInputDocument document, Document teiDocument, Set<String> standardSearch) {
        standardSearch.addAll(addField(document, FIELD_PREFIX + "title", textValues(TITLES, teiDocument)));
        addField(document, FIELD_PREFIX + "title.transcription", textValues(TITLE_TRANSCRIPTIONS, teiDocument));
        standardSearch.addAll(addField(document, FIELD_PREFIX + "idno", textValues(IDNOS, teiDocument)));

        Set<String> witnesses = new LinkedHashSet<>();
        Set<String> witnessIds = new LinkedHashSet<>();
        for (Element witness : WITNESSES.evaluate(teiDocument)) {
            witnesses.addAll(textValues(witness.getChildren("idno", TEI_NAMESPACE)));
            addValue(witnessIds, witness.getAttributeValue("id", Namespace.XML_NAMESPACE));
        }
        standardSearch.addAll(addField(document, FIELD_PREFIX + "witness", witnesses));
        addField(document, FIELD_PREFIX + "witness.id", witnessIds);

        Set<String> authors = new LinkedHashSet<>();
        Set<String> authorRefs = new LinkedHashSet<>();
        for (Element author : AUTHORS.evaluate(teiDocument)) {
            List<Element> persNames = author.getChildren("persName", TEI_NAMESPACE);
            Collection<String> names = textValues(persNames);
            authors.addAll(names);
            persNames.forEach(persName -> addValue(authorRefs, persName.getAttributeValue("ref")));
            String role = author.getAttributeValue("role");
            if (role != null && !role.isBlank()) {
                String roleName = toFieldNamePart(role);
                addField(document, FIELD_PREFIX + "author." + roleName, names);
                // how certain the editors are about this attribution, 1 is certain, everything below is not
                Set<String> certainty = new LinkedHashSet<>();
                addValue(certainty, author.getAttributeValue("cert"));
                addField(document, FIELD_PREFIX + "cert." + roleName, certainty);
            }
        }
        standardSearch.addAll(addField(document, FIELD_PREFIX + "author", authors));
        addField(document, FIELD_PREFIX + "author.ref", authorRefs);

        standardSearch.addAll(addField(document, FIELD_PREFIX + "editor", textValues(EDITORS, teiDocument)));

        Set<String> notes = new LinkedHashSet<>();
        for (Element note : TYPED_NOTES.evaluate(teiDocument)) {
            String text = textOf(note);
            if (text.isEmpty()) {
                continue;
            }
            notes.add(text);
            document.addField(FIELD_PREFIX + "note." + toFieldNamePart(note.getAttributeValue("type")), text);
        }
        standardSearch.addAll(addField(document, FIELD_PREFIX + "note", notes));

        // the tei:langUsage sits inside the tei:witness, so it states the language of the source, while the
        // language of the piece itself is stated on its transcribed title
        Set<String> witnessLanguages = new LinkedHashSet<>();
        LANGUAGES.evaluate(teiDocument)
            .forEach(language -> addValue(witnessLanguages, language.getAttributeValue("ident")));
        addField(document, FIELD_PREFIX + "language.witness", witnessLanguages);

        Set<String> textLanguages = new LinkedHashSet<>();
        TITLE_TRANSCRIPTIONS.evaluate(teiDocument)
            .forEach(title -> addValue(textLanguages, title.getAttributeValue("lang", Namespace.XML_NAMESPACE)));
        addField(document, FIELD_PREFIX + "language.text", textLanguages);

        accumulateCategories(document, teiDocument);
    }

    /**
     * Adds the classifications of the piece as {@code <classification>:<category>}, taken from the terminology
     * links of the notes of the {@code tei:teiHeader}. Only the notes for the music genre and for the poetic
     * form and genre carry such a link, the makam and usul notes state their term as text only.
     */
    private void accumulateCategories(SolrInputDocument document, Document teiDocument) {
        Set<String> categories = new LinkedHashSet<>();
        for (Element note : CLASSIFIED_NOTES.evaluate(teiDocument)) {
            for (Element reference : note.getDescendants(Filters.element("ref", TEI_NAMESPACE))) {
                String category = toCategory(reference.getAttributeValue("target"));
                if (category != null) {
                    categories.add(category);
                    int separator = category.indexOf(CATEGORY_SEPARATOR);
                    document.addField(FIELD_PREFIX + "category." + category.substring(0, separator),
                        category.substring(separator + 1));
                }
            }
        }
        addField(document, FIELD_PREFIX + "category", categories);
    }

    /**
     * Adds the ids of the MyCoRe objects the edition links to, so a search mask can join the file document
     * with the documents of those objects. The generic field {@code tei.ref} holds every id which appears in
     * the file, the fields below it hold the ids per kind of link:
     * <ul>
     *   <li>{@code tei.ref.person} and {@code tei.ref.person.<role>} for the composers and lyricists, so a
     *       query can join the person objects, for example to filter by their date of death</li>
     *   <li>{@code tei.ref.source} for the witnesses of the {@code tei:listWit} and of the single readings</li>
     *   <li>{@code tei.ref.mods} for the mods object the edition belongs to</li>
     * </ul>
     */
    private void accumulateReferences(SolrInputDocument document, Document teiDocument) {
        Set<String> allReferences = new LinkedHashSet<>();

        Set<String> persons = new LinkedHashSet<>();
        for (Element author : AUTHORS.evaluate(teiDocument)) {
            Set<String> ids = new LinkedHashSet<>();
            for (Element persName : author.getChildren("persName", TEI_NAMESPACE)) {
                addObjectIds(ids, persName.getAttributeValue("ref"));
            }
            persons.addAll(ids);
            String role = author.getAttributeValue("role");
            if (role != null && !role.isBlank()) {
                addField(document, FIELD_PREFIX + "ref.person." + toFieldNamePart(role), ids);
            }
        }
        addField(document, FIELD_PREFIX + "ref.person", persons);

        Set<String> sources = new LinkedHashSet<>();
        WITNESSES.evaluate(teiDocument)
            .forEach(witness -> addObjectIds(sources, witness.getAttributeValue("id", Namespace.XML_NAMESPACE)));
        READINGS.evaluate(teiDocument).forEach(reading -> addObjectIds(sources, reading.getAttributeValue("wit")));
        addField(document, FIELD_PREFIX + "ref.source", sources);

        Set<String> modsObjects = new LinkedHashSet<>();
        CITE_MILESTONES.evaluate(teiDocument)
            .forEach(milestone -> addObjectIds(modsObjects, milestone.getAttributeValue("source")));
        addField(document, FIELD_PREFIX + "ref.mods", modsObjects);

        collectObjectIds(teiDocument.getRootElement(), allReferences);
        addField(document, FIELD_PREFIX + "ref", allReferences);
    }

    /**
     * Adds the metrical fields: the named feet and metres of the {@code tei:metDecl}s together with their
     * syllable patterns, the rhyme scheme of the verse groups and the scansion of the single verse lines.
     */
    private void accumulateProsody(SolrInputDocument document, Document teiDocument, Set<String> standardSearch) {
        for (Element metDecl : MET_DECLS.evaluate(teiDocument)) {
            String metDeclId = metDecl.getAttributeValue("id", Namespace.XML_NAMESPACE);
            String field;
            if (MET_DECL_FEET.equals(metDeclId)) {
                field = FIELD_PREFIX + MET_DECL_FEET;
            } else if (MET_DECL_VEZIN.equals(metDeclId)) {
                field = FIELD_PREFIX + MET_DECL_VEZIN;
            } else {
                continue;
            }

            List<Element> metSyms = metDecl.getChildren("metSym", TEI_NAMESPACE);
            Set<String> names = new LinkedHashSet<>();
            metSyms.forEach(metSym -> addValue(names, metSym.getAttributeValue("value")));
            standardSearch.addAll(addField(document, field, names));
            standardSearch.addAll(addField(document, field + ".pattern", textValues(metSyms)));
        }

        // ids of the metSyms the piece actually uses, stated by the verse groups and by the bahir and meter
        // notes; they identify the metre and the feet independently of how their name is written
        Set<String> vezinIds = new LinkedHashSet<>();
        Set<String> feetIds = new LinkedHashSet<>();
        VERSE_GROUP_METRES.evaluate(teiDocument)
            .forEach(lg -> forEachReference(lg.getAttributeValue("decls"),
                metre -> addValue(vezinIds, stripReferenceMarker(metre))));
        for (Element note : TYPED_NOTES.evaluate(teiDocument)) {
            String type = note.getAttributeValue("type");
            Set<String> target = NOTE_TYPE_BAHIR.equals(type) ? vezinIds : NOTE_TYPE_METER.equals(type)
                ? feetIds
                : null;
            if (target != null) {
                forEachReference(note.getAttributeValue("corresp"),
                    metSym -> addValue(target, stripReferenceMarker(metSym)));
            }
        }
        addField(document, FIELD_PREFIX + MET_DECL_VEZIN + ".id", vezinIds);
        addField(document, FIELD_PREFIX + MET_DECL_FEET + ".id", feetIds);

        Set<String> rhymes = new LinkedHashSet<>();
        VERSE_GROUPS.evaluate(teiDocument).forEach(lg -> addValue(rhymes, lg.getAttributeValue("rhyme")));
        standardSearch.addAll(addField(document, FIELD_PREFIX + "rhyme", rhymes));

        Set<String> scansions = new LinkedHashSet<>();
        Set<String> symbols = new LinkedHashSet<>();
        for (Element line : VERSE_LINES.evaluate(teiDocument)) {
            String scansion = line.getAttributeValue("real");
            addValue(scansions, scansion);
            addSymbols(symbols, scansion);
        }
        standardSearch.addAll(addField(document, FIELD_PREFIX + "real", scansions));
        addField(document, FIELD_PREFIX + "real.symbol", symbols);
    }

    /**
     * Adds every metrical symbol of the given scansion to the given collection, so a search mask can offer the
     * deviations from the standard, like the lengthening {@code I} or the shortening {@code Z}, for selection.
     * The meaning of a symbol is declared by the {@code tei:metDecl} of the file.
     */
    private static void addSymbols(Collection<String> symbols, String scansion) {
        if (scansion == null) {
            return;
        }
        for (int i = 0; i < scansion.length(); i++) {
            char symbol = scansion.charAt(i);
            if (symbol != FOOT_DIVIDER && !Character.isWhitespace(symbol)) {
                symbols.add(String.valueOf(symbol));
            }
        }
    }

    /**
     * Adds the text of the edition: rubric, incipit, head, the lyrics split into main part and terennüm, the
     * performance instructions and the parts which were supplied by the editors.
     */
    private void accumulateText(SolrInputDocument document, Document teiDocument, Set<String> standardSearch,
        Set<String> primaryLyrics) {
        standardSearch.addAll(addField(document, FIELD_PREFIX + "rubric", textValues(RUBRICS, teiDocument)));

        // where the piece stands in its source: the number of the item and the pages it covers
        Set<String> pieceNumbers = new LinkedHashSet<>();
        MS_ITEMS.evaluate(teiDocument).forEach(item -> addValue(pieceNumbers, item.getAttributeValue("n")));
        addField(document, FIELD_PREFIX + "piece", pieceNumbers);

        Set<String> pages = new LinkedHashSet<>();
        for (Element locus : LOCI.evaluate(teiDocument)) {
            addValue(pages, locus.getAttributeValue("from"));
            addValue(pages, locus.getAttributeValue("to"));
        }
        addField(document, FIELD_PREFIX + "page", pages);

        Collection<String> incipits = addField(document, FIELD_PREFIX + "incipit", textValues(INCIPITS, teiDocument));
        standardSearch.addAll(incipits);
        primaryLyrics.addAll(incipits);

        Collection<String> heads = addField(document, FIELD_PREFIX + "head", textValues(HEADS, teiDocument));
        standardSearch.addAll(heads);
        primaryLyrics.addAll(heads);

        Set<String> mainLyrics = new LinkedHashSet<>();
        Set<String> otherLyrics = new LinkedHashSet<>();
        for (Element segment : LINE_SEGMENTS.evaluate(teiDocument)) {
            String text = textOf(segment);
            if (text.isEmpty()) {
                continue;
            }
            if (ANA_MAIN_PART_LYRICS.equals(segment.getAttributeValue("ana"))) {
                mainLyrics.add(text);
            } else {
                otherLyrics.add(text);
            }
        }
        Collection<String> lyrics = addField(document, FIELD_PREFIX + "lyrics", mainLyrics);
        standardSearch.addAll(lyrics);
        primaryLyrics.addAll(lyrics);
        standardSearch.addAll(addField(document, FIELD_PREFIX + "terennum", otherLyrics));

        Set<String> stages = new LinkedHashSet<>();
        Set<String> stageTypes = new LinkedHashSet<>();
        for (Element stage : STAGES.evaluate(teiDocument)) {
            addValue(stages, textOf(stage));
            addValue(stageTypes, stage.getAttributeValue("type"));
        }
        standardSearch.addAll(addField(document, FIELD_PREFIX + "stage", stages));
        addField(document, FIELD_PREFIX + "stage.type", stageTypes);

        addField(document, FIELD_PREFIX + "supplied", textValues(SUPPLIED, teiDocument));
    }

    /**
     * Adds the critical apparatus and the annotations: the lemma, the readings with their type and their
     * witnesses and the notes of the provenance and the annotation section.
     */
    private void accumulateApparatus(SolrInputDocument document, Document teiDocument, Set<String> apparatusSearch) {
        apparatusSearch.addAll(addField(document, FIELD_PREFIX + "lem", textValues(LEMMATA, teiDocument)));

        Set<String> readings = new LinkedHashSet<>();
        Set<String> readingTypes = new LinkedHashSet<>();
        Set<String> readingWitnesses = new LinkedHashSet<>();
        for (Element reading : READINGS.evaluate(teiDocument)) {
            addValue(readings, textOf(reading));
            addValue(readingTypes, reading.getAttributeValue("type"));
            forEachReference(reading.getAttributeValue("wit"),
                witness -> addValue(readingWitnesses, stripReferenceMarker(witness)));
        }
        apparatusSearch.addAll(addField(document, FIELD_PREFIX + "rdg", readings));
        addField(document, FIELD_PREFIX + "rdg.type", readingTypes);
        addField(document, FIELD_PREFIX + "rdg.wit", readingWitnesses);

        apparatusSearch
            .addAll(addField(document, FIELD_PREFIX + "annotation", textValues(ANNOTATION_NOTES, teiDocument)));
        apparatusSearch
            .addAll(addField(document, FIELD_PREFIX + "provenance", textValues(PROVENANCE_NOTES, teiDocument)));

        // the lyricist is stated as an annotation of the edition, so it is part of the apparatus search
        for (Element note : TYPED_NOTES.evaluate(teiDocument)) {
            if (NOTE_TYPE_LYRICIST.equals(note.getAttributeValue("type"))) {
                addValue(apparatusSearch, textOf(note));
            }
        }
    }

    private static boolean isXMLFile(Path filePath) {
        Path fileName = filePath.getFileName();
        return fileName != null && fileName.toString().toLowerCase(Locale.ROOT).endsWith(XML_EXTENSION);
    }

    private static boolean isTEIDocument(Document document) {
        if (!document.hasRootElement()) {
            return false;
        }
        Element root = document.getRootElement();
        return TEI_ROOT_ELEMENT.equals(root.getName())
            && TEI_NAMESPACE.getURI().equals(root.getNamespaceURI());
    }

    /**
     * Adds every value to the given field of the solr document and returns the added values, so they can be
     * collected in one of the bundles.
     */
    private static Collection<String> addField(SolrInputDocument document, String field, Collection<String> values) {
        values.forEach(value -> document.addField(field, value));
        return values;
    }

    private static void addValue(Collection<String> values, String value) {
        if (value != null) {
            String normalized = normalize(value);
            if (!normalized.isEmpty()) {
                values.add(normalized);
            }
        }
    }

    private static Collection<String> textValues(XPathExpression<Element> xpath, Document document) {
        return textValues(xpath.evaluate(document));
    }

    private static Collection<String> textValues(Collection<Element> elements) {
        Set<String> values = new LinkedHashSet<>();
        elements.forEach(element -> addValue(values, textOf(element)));
        return values;
    }

    /**
     * Returns the text of the given element including the text of all descendants. Empty elements like
     * {@code tei:anchor} are replaced by a blank, because the whitespace around them is not part of the TEI
     * source, but the words they separate are two words in the printed edition.
     */
    private static String textOf(Element element) {
        StringBuilder text = new StringBuilder();
        appendText(element, text);
        return normalize(text.toString());
    }

    private static void appendText(Element element, StringBuilder text) {
        List<Content> content = element.getContent();
        if (content.isEmpty()) {
            text.append(' ');
            return;
        }
        for (Content child : content) {
            if (child instanceof Text textNode) {
                text.append(textNode.getText());
            } else if (child instanceof Element childElement) {
                appendText(childElement, text);
            }
        }
    }

    /**
     * Collapses every run of whitespace into a single blank and removes the leading and trailing one.
     */
    private static String normalize(String value) {
        StringBuilder normalized = new StringBuilder(value.length());
        boolean pendingBlank = false;
        for (int i = 0; i < value.length(); i++) {
            char character = value.charAt(i);
            if (Character.isWhitespace(character)) {
                pendingBlank = !normalized.isEmpty();
            } else {
                if (pendingBlank) {
                    normalized.append(' ');
                    pendingBlank = false;
                }
                normalized.append(character);
            }
        }
        return normalized.toString();
    }

    private static String stripReferenceMarker(String reference) {
        return reference.startsWith("#") ? reference.substring(1) : reference;
    }

    /**
     * Hands every single reference of the given attribute value to the given consumer. One attribute may hold
     * several references separated by whitespace, as {@code tei:rdg/@wit} does.
     */
    private static void forEachReference(String value, Consumer<String> consumer) {
        if (value == null) {
            return;
        }
        int start = 0;
        for (int i = 0; i <= value.length(); i++) {
            if (i == value.length() || Character.isWhitespace(value.charAt(i))) {
                if (i > start) {
                    consumer.accept(value.substring(start, i));
                }
                start = i + 1;
            }
        }
    }

    /**
     * Adds every MyCoRe object id of the given attribute value to the given collection.
     */
    private static void addObjectIds(Collection<String> ids, String value) {
        forEachReference(value, reference -> {
            String objectId = toObjectId(reference);
            if (objectId != null) {
                ids.add(objectId);
            }
        });
    }

    /**
     * Returns the MyCoRe object id of a single reference, or {@code null} if the reference does not point to a
     * MyCoRe object. A reference is either a fragment like {@code #cmo_source_00000030} or a URL like
     * {@code https://corpus-musicae-ottomanicae.de/receive/cmo_person_00000225}, so the id is what follows the
     * last {@code #} and the last {@code /}. Whether that is an id is decided by {@link MCRObjectID}, which
     * also rejects a type that is not configured, so a link to a GND or an ORCID returns null.
     */
    private static String toObjectId(String reference) {
        String candidate = reference.substring(reference.lastIndexOf('#') + 1);
        candidate = candidate.substring(candidate.lastIndexOf('/') + 1);
        return MCRObjectID.isValid(candidate) ? candidate : null;
    }

    /**
     * Returns the classification of the given URI as {@code <classification>:<category>}, or {@code null} if
     * the URI does not point to a classification. Both shapes which appear in the TEI are understood, the
     * terminology URI {@code https://uri.gbv.de/terminology/cmo_genre/semai} and the API URI
     * {@code https://.../classifications/cmo_sourceType#Manuscript}.
     */
    private static String toCategory(String uri) {
        if (uri == null) {
            return null;
        }
        for (String marker : CLASSIFICATION_MARKERS) {
            int start = uri.indexOf(marker);
            if (start < 0) {
                continue;
            }
            String path = uri.substring(start + marker.length());
            int separator = indexOfAny(path, '/', '#');
            if (separator <= 0 || separator == path.length() - 1) {
                continue;
            }
            String classification = path.substring(0, separator);
            String category = path.substring(separator + 1);
            if (indexOfAny(category, '/', '#') < 0) {
                return classification + CATEGORY_SEPARATOR + category;
            }
        }
        return null;
    }

    /**
     * Returns the position of the first occurrence of one of the two characters, or -1 if neither occurs.
     */
    private static int indexOfAny(String value, char first, char second) {
        for (int i = 0; i < value.length(); i++) {
            char character = value.charAt(i);
            if (character == first || character == second) {
                return i;
            }
        }
        return -1;
    }

    /**
     * Collects the MyCoRe object ids of all references of the given element and of all its descendants, so
     * links which are stated somewhere in the text are found as well.
     */
    private static void collectObjectIds(Element element, Collection<String> ids) {
        addObjectIds(ids, element.getAttributeValue("id", Namespace.XML_NAMESPACE));
        for (String attribute : REFERENCE_ATTRIBUTES) {
            addObjectIds(ids, element.getAttributeValue(attribute));
        }
        element.getChildren().forEach(child -> collectObjectIds(child, ids));
    }

    /**
     * Turns a TEI attribute value like {@code persons-institutions} into a part of a solr field name by
     * replacing every character which is not a letter or a digit.
     */
    private static String toFieldNamePart(String value) {
        StringBuilder fieldName = new StringBuilder(value.length());
        for (int i = 0; i < value.length(); i++) {
            char character = value.charAt(i);
            boolean allowed = character >= 'a' && character <= 'z'
                || character >= 'A' && character <= 'Z'
                || character >= '0' && character <= '9';
            if (allowed) {
                fieldName.append(character);
            } else if (fieldName.isEmpty() || fieldName.charAt(fieldName.length() - 1) != FIELD_NAME_REPLACEMENT) {
                fieldName.append(FIELD_NAME_REPLACEMENT);
            }
        }
        return fieldName.toString();
    }

    private static XPathExpression<Element> elements(String xpath) {
        return XPATH_FACTORY.compile(xpath, Filters.element(), Collections.emptyMap(), TEI_NAMESPACE);
    }

}
