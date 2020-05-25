package org.mycore.mei.migration;

import java.io.IOException;

import org.jdom2.JDOMException;
import org.junit.Test;

public class MEISourceMigratorTest extends MEIMigratorTestBase {

    @Test
    public void migrate() throws IOException, JDOMException {
        testWith("manifestation_old.xml", "manifestation_new.xml", new MEISourceMigrator());
    }

}