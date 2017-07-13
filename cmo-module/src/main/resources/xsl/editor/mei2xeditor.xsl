<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xlink mei" version="1.0"
>

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mei-node-utils.xsl" />

  <xsl:template match="mei:date[@notbefore|@notafter]">
    <xsl:copy>
      <xsl:attribute name="approx">true</xsl:attribute>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@calendar">
    <xsl:attribute name="calendar">
      <xsl:value-of select="concat('cmo_calendar:', .)" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="mei:title/@type">
    <xsl:attribute name="type">
      <xsl:value-of select="concat('cmo_titleType:', .)" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="mei:language/@xml:id">
    <xsl:attribute name="xml:id">
      <xsl:value-of select="concat('rfc4646:', .)" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="mei:classification">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:for-each select="mei:classCode">
        <xsl:variable name="classID" select="concat('#', @xml:id)" />
        <classEntry>
          <xsl:attribute name="authority">
            <xsl:value-of select="@authority" />
          </xsl:attribute>
          <xsl:value-of select="@authority" />
          <xsl:text>:</xsl:text>
          <xsl:value-of select="../mei:termList[@classcode=$classID]/mei:term" />
        </classEntry>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>