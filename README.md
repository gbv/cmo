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
 - run cli command `bin/cmo.sh process config/setup-commands.txt` to load default data
 - Go to cmo-webapp
 - Install solr with the command: `mvn solr-runner:copyHome solr-runner:installSolrPlugins`
 - Run solr with the command `mvn solr-runner:start` (End with mvn solr-runner:stop)
 - Run Jetty with the command: `mvn jetty:run` (End with ctrl+c)


## Update

 - to update solr run `mvn solr-runner:stop solr-runner:copyHome solr-runner:start`