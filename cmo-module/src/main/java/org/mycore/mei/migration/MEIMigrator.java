package org.mycore.mei.migration;

import java.util.Collections;
import java.util.List;

import org.mycore.mei.MEIWrapper;

public abstract class MEIMigrator implements Comparable<MEIMigrator> {
    public MEIMigrator() {
    }

    public abstract void migrate(MEIWrapper obj);

    public List<Class<? extends MEIMigrator>> getDependencies() {
        return Collections.emptyList();
    }

    @Override
    public int compareTo(MEIMigrator o) {
        final List<Class<? extends MEIMigrator>> myDependencies = getDependencies();
        final List<Class<? extends MEIMigrator>> hisDependencies = o.getDependencies();
        final Class<?> aClass = o.getClass();
        if (myDependencies.contains(aClass)) {
            return -1;
        } else if (hisDependencies.contains(getClass())) {
            return +1;
        }

        return 0;
    }
}
