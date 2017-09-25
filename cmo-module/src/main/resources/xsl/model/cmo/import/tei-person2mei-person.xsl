<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~  This file is part of ***  M y C o R e  ***
  ~  See http://www.mycore.de/ for details.
  ~
  ~  This program is free software; you can use it, redistribute it
  ~  and / or modify it under the terms of the GNU General Public License
  ~  (GPL) as published by the Free Software Foundation; either version 2
  ~  of the License or (at your option) any later version.
  ~
  ~  This program is distributed in the hope that it will be useful, but
  ~  WITHOUT ANY WARRANTY; without even the implied warranty of
  ~  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~  GNU General Public License for more details.
  ~
  ~  You should have received a copy of the GNU General Public License
  ~  along with this program, in a file called gpl.txt or license.txt.
  ~  If not, write to the Free Software Foundation Inc.,
  ~  59 Temple Place - Suite 330, Boston, MA  02111-1307 USA
  ~
  -->
<!--
  This Stylesheet converts a tei:person to mei:person
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                version="1.0">

  <xsl:output indent="yes" />

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="/tei:person">
    <mei:persName>
      <xsl:apply-templates select="@xml:id" />
      <xsl:apply-templates select="tei:idno" />
      <xsl:apply-templates select="tei:persName" />
      <xsl:apply-templates select="tei:birth" />
      <xsl:apply-templates select="tei:death" />
      <xsl:apply-templates select="tei:list/tei:item" />
    </mei:persName>
  </xsl:template>

  <xsl:template match="@xml:id">
    <mei:identifier type="cmo_intern">
      <xsl:value-of select="." />
    </mei:identifier>
  </xsl:template>

  <xsl:template match="tei:idno">
    <mei:identifier type="{@type}">
      <xsl:value-of select="." />
    </mei:identifier>
  </xsl:template>

  <xsl:template match="tei:persName">
    <xsl:for-each select="tei:ref">
      <mei:name>
        <xsl:if test="../@type">
          <xsl:attribute name="type">
            <xsl:value-of select="translate(../@type,'/','-')" />
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="source">
            <xsl:value-of select="@target" />
        </xsl:attribute>
        <xsl:attribute name="label">
          <xsl:value-of select="text()" />
        </xsl:attribute>
        <xsl:value-of select="../text()" />
      </mei:name>
    </xsl:for-each>
    <xsl:if test="count(tei:ref)&lt;1">
      <mei:name>
        <xsl:if test="../@type">
          <xsl:attribute name="type">
            <xsl:value-of select="translate(@type,'/','-')" />
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="text()" />
      </mei:name>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:death|tei:birth">
    <xsl:variable name="type" select="local-name()" />

    <xsl:for-each select="tei:date">
      <mei:date type="{$type}" calendar="gregorian">
        <xsl:if test="@notBefore">
          <xsl:attribute name="notbefore">
            <xsl:value-of select="@notBefore" />
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@notAfter">
          <xsl:attribute name="notafter">
            <xsl:value-of select="@notAfter" />
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@from or @to or @when">
          <xsl:choose>
            <xsl:when test="@from and @to">
              <xsl:attribute name="notbefore">
                <xsl:value-of select="@from" />
              </xsl:attribute>
              <xsl:attribute name="notafter">
                <xsl:value-of select="@to" />
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="@from">
              <xsl:attribute name="isodate">
                <xsl:value-of select="@from" />
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="@to">
              <xsl:attribute name="isodate">
                <xsl:value-of select="@to" />
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="tei:ref/@target">
          <xsl:attribute name="source">
            <xsl:value-of select="tei:ref/@target" />
          </xsl:attribute>
          <xsl:if test="tei:ref/text()">
            <xsl:attribute name="label">
              <xsl:value-of select="tei:ref/text()" />
            </xsl:attribute>
          </xsl:if>
        </xsl:if>
        <xsl:if test="string-length(text()) &gt; 0">
          <xsl:value-of select="text()" />
        </xsl:if>
      </mei:date>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:list/tei:item">
    <xsl:if test="text()">
      <mei:annot>
        <xsl:if test="tei:ref/@target">
          <xsl:attribute name="source">
            <xsl:value-of select="tei:ref/@target" />
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="tei:ref/text()">
          <xsl:attribute name="label">
            <xsl:value-of select="tei:ref/text()" />
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="text()" />
      </mei:annot>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
