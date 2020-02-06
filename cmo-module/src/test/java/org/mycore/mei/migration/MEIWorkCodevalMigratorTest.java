package org.mycore.mei.migration;

import java.io.IOException;
import java.util.Map;

import org.jdom2.JDOMException;
import org.junit.Test;

public class MEIWorkCodevalMigratorTest extends MEIMigratorTestBase {

    @Override protected Map<String, String> getTestProperties() {
        final Map<String, String> testProperties = super.getTestProperties();
        testProperties.put("MCR.baseurl","https://corpus-musicae-ottomanicae.de/");
        return testProperties;
    }

    @Test
    public void migrate() throws IOException, JDOMException {
        testWith("work_2_old.xml","work_2_new.xml",new MEIWorkCodevalMigrator());
    }
}