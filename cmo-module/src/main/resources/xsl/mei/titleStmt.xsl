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

  <xsl:include href="mei-utils.xsl" />

  <xsl:template match="mei:titleStmt" mode="metadataView">
    <xsl:comment>mei/titleStmt.xsl > mei:titleStmt</xsl:comment>
    <xsl:if test="mei:title">
      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="label" select="'editor.label.title'" />
        <xsl:with-param name="content">
          <xsl:apply-templates select="mei:title[@type='main']" mode="metadataView" />
          <xsl:apply-templates select="mei:title[@type='sub']" mode="metadataView" />
          <xsl:apply-templates select="mei:title[@type='desc']" mode="metadataView"/>
          <xsl:apply-templates select="mei:title[not(contains('main,sub,desc', @type))]" mode="metadataView" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <xsl:if test="//mei:classification[mei:classCode[contains(@authURI,'cmo_makamler')]]">
      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="label" select="'editor.label.standardizedTerm'" />
        <xsl:with-param name="content">
          <xsl:call-template name="printStandardizedTerm" />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    
    <xsl:apply-templates select="mei:author" mode="metadataView" />
    <xsl:apply-templates select="mei:composer" mode="metadataView" />
    <xsl:apply-templates select="mei:editor" mode="metadataView" />
    <xsl:apply-templates select="mei:respStmt" mode="metadataView" />
  </xsl:template>

  <xsl:template match="mei:title" mode="metadataView">
    <xsl:comment>mei/titleStmt.xsl > mei:title</xsl:comment>
    <span class="cmo_titleStmt"><xsl:value-of select="text()" /> </span>
    <small>(<xsl:value-of select="@type" />)</small>
    <br />
  </xsl:template>

</xsl:stylesheet>
