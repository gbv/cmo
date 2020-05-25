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


  <xsl:template match="mei:pubStmt" mode="metadataView">
    <xsl:comment>mei/pubStmt.xsl > mei:pubStmt</xsl:comment>

    <xsl:apply-templates select="mei:publisher" mode="metadataView" />
    <xsl:apply-templates select="mei:pubPlace" mode="metadataView" />
    <xsl:apply-templates select="mei:date" mode="metadataView" />

  </xsl:template>


  <xsl:template match="mei:publisher" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.publisher'" />
      <xsl:with-param name="content">
        <xsl:value-of select="." />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:pubPlace" mode="metadataView">
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.pubPlace'" />
      <xsl:with-param name="content">
        <xsl:value-of select="mei:geogName" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:date" mode="metadataView">
    <xsl:variable name="displayDate">
      <xsl:call-template name="getDisplayDate">
        <xsl:with-param name="dateNode" select="." />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="isoDate">
      <xsl:choose>
        <xsl:when test="@isodate">
          <xsl:value-of select="@isodate" />
        </xsl:when>
        <xsl:when test="@notbefore and @notafter">
          <xsl:value-of select="concat(@notbefore, '-', @notafter)" />
        </xsl:when>
        <xsl:when test="@notbefore">
          <xsl:value-of select="concat(@notbefore, '-?')" />
        </xsl:when>
        <xsl:when test="@notafter">
          <xsl:value-of select="concat('?-', @notafter)" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="local-name(..)='creation'">
          <xsl:value-of select="'editor.label.creation.date'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'editor.label.publishingDate'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="$label" />
      <xsl:with-param name="content">
        <time>
          <xsl:attribute name="datetime"><xsl:value-of select="$isoDate" /></xsl:attribute>
          <xsl:attribute name="title"><xsl:value-of select="$isoDate" /></xsl:attribute>
          <xsl:value-of select="$displayDate" />
        </time>
        <xsl:text> (</xsl:text>
        <xsl:value-of select="@calendar" />
        <xsl:text>)</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="getDisplayDate">
    <xsl:param name="dateNode" />
    <xsl:choose>
      <xsl:when test="$dateNode/text()">
        <xsl:value-of select="$dateNode/text()"/>
      </xsl:when>
      <xsl:when test="$dateNode/@isodate">
        <xsl:value-of select="$dateNode/@isodate"/>
      </xsl:when>
      <xsl:when test="$dateNode/@startdate and $dateNode/@enddate">
        <xsl:value-of select="concat($dateNode/@startdate, '-', $dateNode/@enddate)"/>
      </xsl:when>
      <xsl:when test="$dateNode/@notbefore and $dateNode/@notafter">
        <xsl:value-of select="concat($dateNode/@notbefore, '-', $dateNode/@notafter)"/>
      </xsl:when>
      <xsl:when test="$dateNode/@notbefore">
        <xsl:value-of select="concat($dateNode/@notbefore, '-?')"/>
      </xsl:when>
      <xsl:when test="$dateNode/@notafter">
        <xsl:value-of select="concat('?-', $dateNode/@notafter)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
