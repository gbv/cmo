<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:math="http://exslt.org/math"
  exclude-result-prefixes="xlink mei math" version="1.0"
>

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="editor/mei-node-utils.xsl" />

  <xsl:template match="mei:date">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="@approx">
          <xsl:apply-templates select="@notbefore|@notafter|@calendar|@label|node()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@isodate|@calendar|@label|node()" />
        </xsl:otherwise>
      </xsl:choose>

    </xsl:copy>
  </xsl:template>

  <xsl:template match="@calendar">
    <xsl:attribute name="calendar">
      <xsl:value-of select="substring-after(., 'cmo_calendar:')" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="mei:title/@type">
    <xsl:attribute name="type">
      <xsl:value-of select="substring-after(., 'cmo_titleType:')" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="mei:language/@xml:id">
    <xsl:attribute name="xml:id">
      <xsl:value-of select="substring-after(., 'rfc4646:')" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="classEntry">

    <xsl:variable name="classcode">
      <xsl:value-of select="concat(generate-id(.),'-',(floor(math:random()*100000) mod 100000) + 1)" />
    </xsl:variable>

    <mei:classCode authority="{@authority}" xml:id="{$classcode}"/>
    <mei:termList classcode="#{$classcode}">
      <mei:term>
        <xsl:value-of select="substring-after(., concat(@authority, ':'))" />
      </mei:term>
    </mei:termList>
  </xsl:template>


</xsl:stylesheet>