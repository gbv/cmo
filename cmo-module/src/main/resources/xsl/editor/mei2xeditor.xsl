<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY nbsp  "&#160;" >
    ]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:meiUtil="xalan://org.mycore.mei.MEIUtils"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="xlink meiUtil exsl" version="1.0"
>

  <xsl:param name="WebApplicationBaseURL" />

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
      <xsl:value-of select="concat('rfc5646:', .)" />
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

  <xsl:template match="mei:title[@type='uniform']">
    <xsl:comment>deleted uniform title</xsl:comment>
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
          <xsl:attribute name="auth">
            <xsl:value-of select="'iso15924'" />
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="concat('rfc5646:', @xml:id)" />
          </xsl:attribute>
          <xsl:attribute name="auth">
            <xsl:value-of select="'rfc5646'" />
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:classification">
    <xsl:copy>
      <xsl:for-each select="mei:termList">
        <xsl:variable name="classificationID" select="substring-after(@class, 'classifications/')" />
        <xsl:for-each select="mei:term">
          <classEntry authority="{$classificationID}">
            <xsl:value-of select="$classificationID" />
            <xsl:text>:</xsl:text>
            <xsl:value-of select="." />
          </classEntry>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:desc">
    <mei:desc>
      <xsl:call-template name="convertMEIToHTML" />
    </mei:desc>
  </xsl:template>

  <xsl:template match="mei:annot[local-name(..) ='person' or local-name(..) ='notesStmt']">
    <mei:annot type="{@type}">
      <xsl:call-template name="convertMEIToHTML" />
    </mei:annot>

  </xsl:template>
  <xsl:template name="convertMEIToHTML">
    <xsl:variable name="converted">
      <xsl:apply-templates select="node()" mode="convert" />
    </xsl:variable>
    <xsl:value-of select="meiUtil:encodeDescContent(exsl:node-set($converted))" />

  </xsl:template>

  <xsl:template match="mei:bibl|mei:ref|mei:persName" mode="convert">
    <a class="inserted" href="{concat($WebApplicationBaseURL, 'receive/')}{@target|@nymref}"><xsl:value-of select="text()" /></a>
  </xsl:template>
  
  <xsl:template match="mei:lb"  mode="convert"><br/></xsl:template>

  <xsl:template match="mei:tempo">
    <xsl:copy>
      <xsl:value-of select="concat(@type,':', text())"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()" mode="convert">
    <xsl:value-of select="."/>
  </xsl:template>

</xsl:stylesheet>
