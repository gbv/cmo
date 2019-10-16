<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:export="http://www.corpus-musicae-ottomanicae.de/ns/export"
                version="3.0"
>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template match="mycoreobject[count(metadata/def.modsContainer/modsContainer) &gt; 0]">
    <xsl:apply-templates select="metadata/def.modsContainer/modsContainer/*" />
  </xsl:template>

</xsl:stylesheet>