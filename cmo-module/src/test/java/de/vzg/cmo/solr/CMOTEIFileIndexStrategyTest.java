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

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.nio.file.attribute.BasicFileAttributes;

import org.junit.Before;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TemporaryFolder;

/**
 * The strategy only reads the file itself, so the test works on plain files and needs no MyCoRe configuration.
 * The delegate is handed in, {@link CMOTEIFileIndexStrategy#DELEGATE_PROPERTY} is only read by the constructor
 * without arguments, which the indexer uses.
 */
public class CMOTEIFileIndexStrategyTest {

    private static final String TEI_FILE = "/TEI/cmo_tei_edition.xml";

    @Rule
    public TemporaryFolder folder = new TemporaryFolder();

    private CMOTEIFileIndexStrategy strategy;

    /** Answers what MyCoRe would answer for a file which is not a TEI text edition. */
    private boolean delegateAnswer;

    @Before
    public void createStrategy() {
        delegateAnswer = true;
        strategy = new CMOTEIFileIndexStrategy((file, attrs) -> delegateAnswer);
    }

    @Test
    public void teiEditionIsSentWithoutContent() throws IOException {
        Path file = copyResource(TEI_FILE, "NE204_pieceno144_transformed_cmo.xml");
        assertFalse("a TEI text edition must not be sent to the extracting update handler", check(file));
    }

    /**
     * The TEI files of the editions are UTF-16 with a byte order mark, and the parser has to take the encoding
     * from there, because the strategy reads the file without knowing it.
     */
    @Test
    public void teiEditionInUTF16IsRecognized() throws IOException {
        String tei = "<?xml version=\"1.0\" encoding=\"UTF-16\"?>"
            + "<TEI xmlns=\"http://www.tei-c.org/ns/1.0\"><teiHeader/></TEI>";
        Path file = folder.newFile("utf16.xml").toPath();
        Files.write(file, addByteOrderMark(tei.getBytes(StandardCharsets.UTF_16BE)));

        assertFalse("a TEI text edition in UTF-16 must be recognized as well", check(file));
    }

    @Test
    public void otherXmlIsLeftToTheDelegate() throws IOException {
        Path file = folder.newFile("mei.xml").toPath();
        Files.writeString(file, "<mei xmlns=\"http://www.music-encoding.org/ns/mei\"><music/></mei>");

        delegateAnswer = true;
        assertTrue("the delegate decides about a file which is no TEI text edition", check(file));
        delegateAnswer = false;
        assertFalse("the delegate decides about a file which is no TEI text edition", check(file));
    }

    /**
     * A TEI element of another namespace, the ODD of the project for example, is no text edition of the corpus.
     */
    @Test
    public void teiOfAnotherNamespaceIsLeftToTheDelegate() throws IOException {
        Path file = folder.newFile("other.xml").toPath();
        Files.writeString(file, "<TEI xmlns=\"http://example.org/tei\"><teiHeader/></TEI>");

        assertTrue(check(file));
    }

    @Test
    public void otherFilesAreLeftToTheDelegate() throws IOException {
        Path file = folder.newFile("scan.tiff").toPath();
        Files.write(file, new byte[] { 0x49, 0x49, 0x2a, 0x00 });

        delegateAnswer = false;
        assertFalse("an image is not read at all, the delegate decides about it", check(file));
    }

    /**
     * Only the root element decides, so a file which breaks behind it still counts as a text edition. The export
     * of the corpus holds some of those, and they are better off without the extraction as well: the accumulator
     * cannot read them, so the file document stays without TEI fields either way.
     */
    @Test
    public void editionWhichBreaksBehindTheRootElementStaysAnEdition() throws IOException {
        Path file = folder.newFile("broken.xml").toPath();
        Files.writeString(file, "<TEI xmlns=\"http://www.tei-c.org/ns/1.0\"><teiHeader>");

        assertFalse(check(file));
    }

    /**
     * A file which is broken before its root element cannot be judged and must not fail the indexing of the
     * derivate.
     */
    @Test
    public void unreadableXmlIsLeftToTheDelegate() throws IOException {
        Path file = folder.newFile("garbage.xml").toPath();
        Files.writeString(file, "no xml at all");

        assertTrue(check(file));
    }

    private boolean check(Path file) throws IOException {
        BasicFileAttributes attrs = Files.readAttributes(file, BasicFileAttributes.class);
        return strategy.check(file, attrs);
    }

    private Path copyResource(String resource, String fileName) throws IOException {
        Path file = folder.newFile(fileName).toPath();
        try (InputStream in = getClass().getResourceAsStream(resource)) {
            assertNotNull("test file " + resource + " is missing", in);
            Files.copy(in, file, StandardCopyOption.REPLACE_EXISTING);
        }
        return file;
    }

    private static byte[] addByteOrderMark(byte[] content) {
        byte[] withMark = new byte[content.length + 2];
        withMark[0] = (byte) 0xFE;
        withMark[1] = (byte) 0xFF;
        System.arraycopy(content, 0, withMark, 2, content.length);
        return withMark;
    }

}
