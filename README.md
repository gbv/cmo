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
 - configure you solr server url in `~/.mycore/cmo/mycore.properties`
 - put cmo war file from `cmo-webapp/target` in your servlet container (e.g. tomcat 8)
 - start your application and visit it e.g. at http://localhost:8080/cmo
 
