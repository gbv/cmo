<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xlink" version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <xsl:variable name="defLang">
    <xsl:value-of select="//mei:langUsage/mei:language[not(contains(@xml:id,'-'))]/@xml:id" />
  </xsl:variable>

  <xsl:template match="mei:date[@notbefore|@notafter]">
    <xsl:copy>
      <xsl:attribute name="approx">true</xsl:attribute>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:date[@startdate|@enddate]">
    <xsl:copy>
      <xsl:attribute name="range">true</xsl:attribute>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@calendar">
    <xsl:attribute name="calendar">
      <xsl:value-of select="concat('cmo_calendar:', .)" />
    </xsl:attribute>
  </xsl:template>

  <!-- xsl:template match="mei:title/@type">
    <xsl:attribute name="type">
      <xsl:value-of select="concat('cmo_titleType:', .)" />
    </xsl:attribute>
  </xsl:template -->

  <!-- xsl:template match="mei:title/@xml:lang">
    <xsl:attribute name="xml:lang">
      <xsl:value-of select="concat('rfc4646:', .)" />
    </xsl:attribute>
  </xsl:template -->

  <xsl:template match="mei:title[not(@xml:lang)]">
    <xsl:copy>
      <xsl:attribute name="xml:lang">
        <xsl:value-of select="$defLang" />
      </xsl:attribute>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:respStmt[mei:resp/text()='Printer']">
    <mei:printer>
      <xsl:value-of select="mei:corpName" />
    </mei:printer>
  </xsl:template>

  <xsl:template match="mei:language">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="contains(@xml:id, '-')">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="concat('iso15924:', @xml:id)" />
          </xsl:attribute>
          <xsl:attribute name="authority">
            <xsl:value-of select="'iso15924'" />
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="concat('rfc4646:', @xml:id)" />
          </xsl:attribute>
          <xsl:attribute name="authority">
            <xsl:value-of select="'rfc4646'" />
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:classification">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:for-each select="mei:classCode">
        <xsl:variable name="classID" select="concat('#', @xml:id)" />
        <xsl:variable name="authority" select="substring-after(@authURI, 'classifications/')" />
        <xsl:for-each select="../mei:termList[@classcode=$classID]/mei:term">
          <classEntry>
            <xsl:attribute name="authority">
              <xsl:value-of select="$authority" />
            </xsl:attribute>
            <xsl:value-of select="$authority" />
            <xsl:text>:</xsl:text>
            <xsl:value-of select="." />
          </classEntry>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:tempo">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:value-of select="concat('cmo_tempo:', .)"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>