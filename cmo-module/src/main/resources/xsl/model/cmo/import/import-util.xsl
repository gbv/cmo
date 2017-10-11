<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="convertLanguage">
    <xsl:param name="lang" />
    <xsl:message><xsl:value-of select="$lang" /></xsl:message>
    <xsl:choose>
      <xsl:when test="$lang='tur'">
        <xsl:value-of select="'tr'"/>
      </xsl:when>
      <xsl:when test="$lang='ara'">
        <xsl:value-of select="'ar'"/>
      </xsl:when>
      <xsl:when test="$lang='fra'">
        <xsl:value-of select="'fr'"/>
      </xsl:when>
      <xsl:when test="$lang='ell'">
        <xsl:value-of select="'el'"/>
      </xsl:when>
      <xsl:when test="$lang='eng'">
        <xsl:value-of select="'en'"/>
      </xsl:when>
      <xsl:when test="$lang='fas'">
        <xsl:value-of select="'fa'"/>
      </xsl:when>
      <xsl:when test="$lang='hye'">
        <xsl:value-of select="'hy'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lang" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="detectClassification">
    <xsl:param name="lang" />
    <xsl:choose>
      <xsl:when test="contains('tur ara fra ell eng fas hye ota tr ar fr el hy fa de en', $lang)">
        <xsl:value-of select="'rfc4646'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'iso15924'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
