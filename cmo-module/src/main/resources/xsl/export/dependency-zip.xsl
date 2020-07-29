<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:export="http://www.corpus-musicae-ottomanicae.de/ns/export"
                xmlns:zip="http://mycore.de/ns/zip"
                version="3.0"
>


  <xsl:template match="/export:export">
    <zip:zip>
      <xsl:for-each select="export:dependency">
        <zip:entry fileName="{@id}.xml">
          <xsl:copy-of select="*" />
        </zip:entry>
      </xsl:for-each>
    </zip:zip>
  </xsl:template>

</xsl:stylesheet>
