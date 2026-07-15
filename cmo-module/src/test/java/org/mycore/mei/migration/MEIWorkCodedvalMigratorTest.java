package org.mycore.mei.migration;

import java.io.IOException;
import java.util.Map;

import org.jdom2.JDOMException;
import org.junit.Test;

public class MEIWorkCodedvalMigratorTest extends MEIMigratorTestBase {

    private static final String BASE_URL = "https://127.0.0.1/";

    @Override protected Map<String, String> getTestProperties() {
        final Map<String, String> testProperties = super.getTestProperties();
        testProperties.put("MCR.baseurl", BASE_URL);
        return testProperties;
    }

    @Test
    public void migrate() throws IOException, JDOMException {
        testWith("work_2_old.xml","work_2_new.xml", new MEIWorkCodedvalMigrator());
    }
}
