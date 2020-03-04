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
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <xsl:template match="mei:titleStmt" mode="metadataView">
    <xsl:call-template name="printTitle">
      <xsl:with-param name="parentElement" select="." />
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="printTitle" >
    <xsl:param name="parentElement" />

    <xsl:comment>mei/titleStmt.xsl > printTitle</xsl:comment>
    <xsl:variable name="titleTypeClass">
      <xsl:choose>
        <xsl:when test="count($parentElement/ancestor-or-self::mei:expression)&gt;0">
          <xsl:value-of select="'cmo_titleTypeExpression'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'cmo_titleType'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="$parentElement/mei:title[string-length(text()) &gt; 0]">
      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="style">
          <xsl:if test="position() &gt; 1"><xsl:value-of select="'cmo_noBorder'" /></xsl:if>
        </xsl:with-param>
        <xsl:with-param name="label">
          <xsl:if test="position() = 1"><xsl:value-of select="'editor.label.title'" /></xsl:if>
        </xsl:with-param>
        <xsl:with-param name="type">
          <xsl:variable name="type" select="@type" />
          <xsl:call-template name="printClassLabel2">
            <xsl:with-param name="classID" select="$titleTypeClass"/>
            <xsl:with-param name="categID" select="$type" />
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="content">
          <xsl:apply-templates select="." mode="metadataView" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>

    <xsl:if test="//mei:termList[contains(@class,'cmo_makamler')]">
      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="label" select="'editor.label.standardizedTerm'" />
        <xsl:with-param name="content">
          <xsl:for-each select="$parentElement[count(mei:classification)&gt;0 or //mei:classification]">
            <xsl:call-template name="printStandardizedTerm"  />
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:apply-templates select="$parentElement/mei:author" mode="metadataView" />
    <xsl:apply-templates select="$parentElement/mei:composer" mode="metadataView" />
    <xsl:apply-templates select="$parentElement/mei:lyricist" mode="metadataView" />
    <xsl:apply-templates select="$parentElement/mei:editor" mode="metadataView" />
    <xsl:apply-templates select="$parentElement/mei:respStmt" mode="metadataView" />

  </xsl:template>

  <xsl:template match="mei:title" mode="metadataView">
    <xsl:comment>mei/titleStmt.xsl > mei:title</xsl:comment>
    <span class="cmo_titleStmt"><xsl:value-of select="text()" /> </span>
  </xsl:template>

</xsl:stylesheet>
