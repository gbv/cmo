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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Collection;
import java.util.List;

import org.apache.solr.common.SolrInputDocument;
import org.jdom2.Document;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;
import org.junit.Before;
import org.junit.Test;
import org.mycore.common.MCRTestCase;

/**
 * Runs as an {@link MCRTestCase}, because the accumulator asks {@link org.mycore.datamodel.metadata.MCRObjectID}
 * whether a reference is an object id, and that needs the configured object types of the cmo module.
 */
public class CMOTEIFileIndexAccumulatorTest extends MCRTestCase {

    private static final String TEST_FILE = "/TEI/cmo_tei_edition.xml";

    private SolrInputDocument document;

    @Before
    public void accumulateTestFile() throws JDOMException, IOException {
        Document teiDocument;
        try (InputStream in = getClass().getResourceAsStream(TEST_FILE)) {
            assertNotNull("test file " + TEST_FILE + " is missing", in);
            teiDocument = new SAXBuilder().build(in);
        }
        document = new SolrInputDocument();
        new CMOTEIFileIndexAccumulator().accumulate(document, teiDocument);
    }

    @Test
    public void headerFields() {
        assertContains("tei.title", "Semāʿī Ḥāfıẓ Rifʿat");
        assertContains("tei.title.transcription", "Semāʿī Ḥāfıẓ Rifʿat");
        assertContains("tei.idno", "TR-Iüne 204-2, Piece no. 144, Ms. page no. 190");
        assertContains("tei.author", "Sermüezzin Rifʼat Bey");
        assertContains("tei.author.composer", "Sermüezzin Rifʼat Bey");
        assertContains("tei.author.ref",
            "https://corpus-musicae-ottomanicae.de/receive/cmo_person_00000225");
        assertContains("tei.editor", "Dr. Neslihan Demirkol");
        assertContains("tei.witness", "NE204");
        assertContains("tei.witness.id", "cmo_source_00000030");
        assertContains("tei.language.witness", "ota-Arab");
    }

    /**
     * The ids of the linked objects must be indexed as plain MyCoRe ids, so they can be joined with the
     * documents of those objects. The reference itself is a URL or a fragment.
     */
    @Test
    public void referenceFields() {
        assertContains("tei.ref.person", "cmo_person_00000225");
        assertContains("tei.ref.person.composer", "cmo_person_00000225");
        assertContains("tei.ref.source", "cmo_source_00000030");
        assertContains("tei.ref.source", "cmo_expression_00005685");
        assertContains("tei.ref.mods", "cmo_mods_00000719");
        assertContains("tei.ref", "cmo_person_00000225");
        assertContains("tei.ref", "cmo_source_00000092");
        assertContains("tei.ref", "cmo_mods_00000719");
    }

    /**
     * A GND or an ORCID is not a MyCoRe object, it must not end up in the reference fields.
     */
    @Test
    public void referencesWithoutObjectId() {
        assertNotContains("tei.ref", "122654099");
        assertNotContains("tei.ref", "0000-0002-8602-1704");
    }

    @Test
    public void notesAreIndexedByType() {
        assertContains("tei.note.makamTranscription", "Ṣabā");
        assertContains("tei.note.usulStandardized", "Aksak semâî");
        assertContains("tei.note.genreTranscription", "Semāʿī");
        assertContains("tei.note.bahir", "Hezec");
        assertContains("tei.note", "Ṣabā");
    }

    @Test
    public void prosodyFields() {
        assertContains("tei.feet", "mef’ûlü");
        assertContains("tei.feet.pattern", "--u|");
        assertContains("tei.vezin", "Hezec 1");
        assertContains("tei.vezin.pattern", "--u|u--u|u--u|u--|");
        assertContains("tei.rhyme", "a-a-b-a");
        assertContains("tei.real", "--u|u-Iu|uI-u|UI-|");
    }

    /**
     * The metSym ids identify the metre and the feet independently of how their name is spelled. They are
     * stated by the verse group and by the bahir and meter notes.
     */
    @Test
    public void prosodyIds() {
        assertContains("tei.vezin.id", "hezec1");
        assertContains("tei.feet.id", "mefulu");
        assertContains("tei.feet.id", "mefailu");
        assertContains("tei.feet.id", "feulun");
    }

    /**
     * The symbols of the scansion must be selectable one by one, the foot divider is not one of them.
     */
    @Test
    public void metricalSymbols() {
        assertContains("tei.real.symbol", "I");
        assertContains("tei.real.symbol", "U");
        assertContains("tei.real.symbol", "u");
        assertNotContains("tei.real.symbol", "|");
    }

    /**
     * The music genre states its category as a terminology link, the makam does not.
     */
    @Test
    public void classificationFields() {
        assertContains("tei.category", "cmo_genre:semai");
        assertContains("tei.category.cmo_genre", "semai");
    }

    @Test
    public void certaintyAndLanguage() {
        assertContains("tei.cert.composer", "1");
        assertContains("tei.language.text", "ota");
        assertContains("tei.language.witness", "ota-Arab");
    }

    @Test
    public void positionInTheSource() {
        assertContains("tei.piece", "144");
        assertContains("tei.page", "190");
    }

    @Test
    public void textFields() {
        assertContains("tei.rubric", "144");
        assertContains("tei.incipit", "Dildārı görüb naġme-i şehnāz ėdelim gel");
        assertContains("tei.lyrics", "Dildārı görüb naġme-i şehnāz ėdelim gel");
        assertContains("tei.terennum", "ʿömrüm amān cānım āh ėdelim gel");
        assertContains("tei.supplied", "Dildārı görüb naġme-i şehnāz ėdelim gel");
    }

    /**
     * The anchors inside the head must not glue the two words together.
     */
    @Test
    public void anchorsSeparateWords() {
        assertContains("tei.head", "Semāʿī Ḥāfıẓ Rifʿat");
    }

    /**
     * The anchors around a word must not tear the surrounding line apart.
     */
    @Test
    public void anchorsKeepTheLineTogether() {
        assertContains("tei.lyrics", "Muṭrib demidir nāle ve āġāz ėdelim gel");
    }

    @Test
    public void apparatusFields() {
        assertContains("tei.lem", "Semāʿī");
        assertContains("tei.rdg", "Aḳṣaḳ semāʿī Ha");
        assertContains("tei.rdg.type", "variant-reading");
        assertContains("tei.rdg.wit", "cmo_source_00000092");
        assertContains("tei.provenance",
            "The lyrics appear in Ha, page 233 and FAS_MUN_SA, page 11.");
    }

    @Test
    public void standardSearchBundle() {
        assertContains("tei.text", "Semāʿī Ḥāfıẓ Rifʿat");
        assertContains("tei.text", "Dildārı görüb naġme-i şehnāz ėdelim gel");
        assertContains("tei.text", "Ṣabā");
        assertContains("tei.text", "NE204");
        assertNotContains("tei.text", "Aḳṣaḳ semāʿī Ha");
    }

    @Test
    public void apparatusSearchBundle() {
        assertContains("tei.text.apparatus", "Aḳṣaḳ semāʿī Ha");
        assertContains("tei.text.apparatus", "Semāʿī");
    }

    @Test
    public void primaryLyricsBundle() {
        assertContains("tei.lyrics.primary", "Dildārı görüb naġme-i şehnāz ėdelim gel");
        assertContains("tei.lyrics.primary", "Semāʿī Ḥāfıẓ Rifʿat");
        assertNotContains("tei.lyrics.primary", "ʿömrüm amān cānım āh ėdelim gel");
    }

    /**
     * A document without any TEI element must not add a single field, so other XML files stay untouched.
     */
    @Test
    public void documentWithoutTEIElements() throws JDOMException, IOException {
        Document mei = new SAXBuilder()
            .build(new ByteArrayInputStream("<mei xmlns=\"http://www.music-encoding.org/ns/mei\"/>"
                .getBytes(StandardCharsets.UTF_8)));
        SolrInputDocument meiDocument = new SolrInputDocument();
        new CMOTEIFileIndexAccumulator().accumulate(meiDocument, mei);
        assertEquals("no field expected", 0, meiDocument.getFieldNames().size());
    }

    private void assertContains(String field, String value) {
        Collection<Object> values = document.getFieldValues(field);
        assertNotNull("field " + field + " is empty", values);
        assertTrue(field + " does not contain '" + value + "' but " + values, values.contains(value));
    }

    private void assertNotContains(String field, String value) {
        Collection<Object> values = document.getFieldValues(field);
        List<Object> found = values == null ? List.of() : List.copyOf(values);
        assertTrue(field + " unexpectedly contains '" + value + "'", !found.contains(value));
    }

}
