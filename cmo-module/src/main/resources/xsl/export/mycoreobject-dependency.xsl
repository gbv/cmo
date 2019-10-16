<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:export="http://www.corpus-musicae-ottomanicae.de/ns/export"
                version="3.0"
>

  <!--
    This stylesheets prepares a object to be used with pull-dependencies.xsl.
  -->

  <xsl:template match="/mycoreobject">
    <export:export>
      <export:dependency id="{@ID}" resolved="false" />
    </export:export>
  </xsl:template>

</xsl:stylesheet>