<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY nbsp  "&#160;" >
    ]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                xmlns:math="http://exslt.org/math"
                xmlns:classification="xalan://org.mycore.mei.classification.MCRMEIClassificationSupport"
                xmlns:meiUtil="xalan://org.mycore.mei.MEIUtils"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="xlink mei math classification meiUtil exsl" version="1.0"
>
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:include href="copynodes.xsl" />
  <xsl:key name="classentry-by-authority" match="//mei:classification/classEntry" use="@authority" />

  <xsl:template match="mei:date">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="@approx='true'">
          <xsl:apply-templates select="@type|@source|@notbefore|@notafter|@calendar|@label|node()" />
        </xsl:when>
        <xsl:when test="@range='true'">
          <xsl:apply-templates select="@type|@source|@startdate|@enddate|@calendar|@label|node()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="@type|@source|@isodate|@calendar|@label|node()" />
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
      <xsl:value-of select="substring-after(., 'rfc5646:')" />
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

      <xsl:if test="starts-with(@xml:id , 'rfc5646:')">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="substring-after(@xml:id, 'rfc5646:')" />
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

  <xsl:template match="mei:classification">
    <mei:classification>
      <xsl:for-each select="classEntry[@authority and
        count(. | key('classentry-by-authority',@authority)[1])=1]">
        <xsl:variable name="classid" select="@authority" />
        <mei:termList class="https://www.corpus-musicae-ottomanicae.de/api/v1/classifications/{$classid}">
          <xsl:for-each select="../classEntry[@authority = $classid]">
            <mei:term>
              <xsl:value-of select="substring-after(., concat($classid, ':'))" />
            </mei:term>
          </xsl:for-each>
        </mei:termList>
      </xsl:for-each>
    </mei:classification>
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
    <xsl:apply-templates mode="convert" select="meiUtil:decodeDescContent(text())/node()" />
  </xsl:template>


  <xsl:template match="*" mode="convert">
    <!-- remove elements -->
  </xsl:template>

  <xsl:template match="text()" mode="convert">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="br" mode="convert">
    <mei:lb/>
  </xsl:template>

  <xsl:template match="a" mode="convert">
    <xsl:variable name="id" select="substring-after(@href, concat($WebApplicationBaseURL, 'receive/'))" />
    <xsl:choose>
      <xsl:when test="contains($id, '_mods_')">
        <xsl:element name="mei:bibl">
          <xsl:attribute name="target"><xsl:value-of select="$id"/></xsl:attribute>
          <xsl:value-of select="text()" />
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($id, '_source_')">
        <xsl:element name="mei:ref">
          <xsl:attribute name="target"><xsl:value-of select="$id"/></xsl:attribute>
          <xsl:value-of select="text()" />
        </xsl:element>
      </xsl:when>
      <xsl:when test="contains($id, '_person_')">
        <xsl:element name="mei:persName">
          <xsl:attribute name="nymref"><xsl:value-of select="$id"/></xsl:attribute>
          <xsl:value-of select="text()" />
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:template match="mei:tempo">
    <xsl:variable name="type" select="substring-before(text(), ':')"/>
    <xsl:variable name="value" select="substring-after(text(), ':')"/>
    <xsl:copy>
      <xsl:attribute name="type">
        <xsl:value-of select="$type"/>
      </xsl:attribute>
      <xsl:value-of select="$value"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
