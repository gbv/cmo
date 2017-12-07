<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:math="http://exslt.org/math"
                xmlns:classification="xalan://org.mycore.mei.classification.MCRMEIClassificationSupport"
                exclude-result-prefixes="xlink mei math classification" version="1.0"
>

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mei:date">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="@approx">
          <xsl:apply-templates select="@notbefore|@notafter|@calendar|@label|node()" />
        </xsl:when>
        <xsl:when test="@range">
          <xsl:apply-templates select="@startdate|@enddate|@calendar|@label|node()" />
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

  <!-- xsl:template match="mei:title/@type">
    <xsl:attribute name="type">
      <xsl:value-of select="substring-after(., 'cmo_titleType:')" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="mei:title/@xml:lang">
    <xsl:attribute name="xml:lang">
      <xsl:value-of select="substring-after(., 'rfc4646:')" />
    </xsl:attribute>
  </xsl:template -->

  <xsl:template match="mei:printer">
    <mei:respStmt>
      <mei:resp>Printer</mei:resp>
      <mei:corpName>
        <xsl:value-of select="." />
      </mei:corpName>
    </mei:respStmt>
  </xsl:template>

  <xsl:template match="mei:language[@xml:id]">
    <xsl:copy>
      <xsl:apply-templates select="@*" />

      <xsl:if test="starts-with(@xml:id , 'rfc4646:')">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="substring-after(@xml:id, 'rfc4646:')" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="starts-with(@xml:id, 'iso15924:')">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="substring-after(@xml:id, 'iso15924:')" />
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="@xml:id" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="classEntry">

    <xsl:variable name="classcode">
      <xsl:value-of select="concat(generate-id(.),'-',(floor(math:random()*100000) mod 100000) + 1)" />
    </xsl:variable>

    <mei:classCode authURI="http://www.corpus-musicae-ottomanicae.de/api/v1/classifications/{@authority}" xml:id="{$classcode}" />
    <mei:termList classcode="#{$classcode}">
      <mei:term>
        <xsl:value-of select="substring-after(., concat(@authority, ':'))" />
      </mei:term>
    </mei:termList>
  </xsl:template>


</xsl:stylesheet>
