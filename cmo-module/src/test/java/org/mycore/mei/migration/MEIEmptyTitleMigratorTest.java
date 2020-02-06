package org.mycore.mei.migration;

import java.io.IOException;

import org.jdom2.JDOMException;
import org.junit.Test;
import org.mycore.common.MCRTestCase;

import static org.junit.Assert.*;

public class MEIEmptyTitleMigratorTest extends MEIMigratorTestBase {

    @Test
    public void migrate() throws IOException, JDOMException {
        testWith("work_1_old.xml","work_1_new.xml",new MEIEmptyTitleMigrator());
    }
}