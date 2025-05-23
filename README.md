# Corpus Musicae Ottomanicae (CMO)

This MyCoRe application is under construction.

For project details visit https://www.uni-muenster.de/CMO-Edition/

More information about MyCoRe are available at http://www.mycore.org

## Installation Instructions

 - clone repository
 - run `mvn clean install`
 - unzip cmo-cli to user defined cli directory
 - change to cli directory
 - run `bin/cmo.sh create configuration directory`
 - you now have a config dir `~/.mycore/cmo`
 - configure your database connection in `~/.mycore/cmo/resources/META-INF/persistence.xml`
 - perhaps you need to download a driver to `~/.mycore/cmo/lib/`
 - run cli command `bin/cmo.sh process config/setup-commands.txt` to load default data
 - Go to cmo-webapp
 - Install solr with the command: `mvn solr-runner:copyHome solr-runner:installSolrPlugins`
 - Run solr with the command `mvn solr-runner:start` (End with mvn solr-runner:stop)
 - Run Tomcat with the command: `mvn org.codehaus.cargo:cargo-maven3-plugin:run` (End with ctrl+c)
 - Fast rebuild and Jetty restart `mvn clean install -pl cmo-module && mvn clean install org.codehaus.cargo:cargo-maven3-plugin:run -pl cmo-webapp` (End with ctrl+c)

## Update

 - to update solr run `mvn solr-runner:stop solr-runner:copyHome solr-runner:start`


## Clear data in database before reimport

```sql
DELETE FROM MCRLINKHREF WHERE 1=1;
DELETE FROM MCRMETAHISTORY WHERE 1=1;
DELETE FROM MCRCATEGORYLINK WHERE OBJECTTYPE='expression'
                                  or OBJECTTYPE='source'
                                  or OBJECTTYPE='work'
                                  or OBJECTTYPE='mods'
                                  or OBJECTTYPE='person';
```

## FOP Settings for PDF export
Its maybe required to store a fop.xml in the folder ~/.mycore/cmo/resources/ to support the right font rendering. See fop.xml in project.

## Debug

The project uses webpack to bundle typescript. To Debug change the mode in cmo-module/webpack.config.js to 'development'. 
