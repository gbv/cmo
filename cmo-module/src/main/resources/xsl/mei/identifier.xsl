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
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">

  <!-- TODO: how to display publisher, pubPlace and Date -->
  <xsl:template match="mei:identifier" mode="metadataView">
    <xsl:comment>mei/identifier.xsl > mei:identifier</xsl:comment>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="@type">
          <xsl:value-of select="concat('editor.label.identifier.',@type)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'editor.label.identifier'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="$label" />
      <xsl:with-param name="content">
        <xsl:choose>
          <xsl:when test="@type='GND'">
            <a href="http://d-nb.info/gnd/{text()}" target="_blank"><xsl:value-of select="text()" /></a>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="text()" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


</xsl:stylesheet>