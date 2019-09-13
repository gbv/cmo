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
  xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xsL="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="xalan xlink acl i18n mei" version="1.0">


  <xsl:template match="mei:notesStmt | mei:persName" mode="printAnnot">
    <xsl:comment>mei/notesStmt.xsl > mei:notesStmt</xsl:comment>
    <xsl:for-each select="mei:annot">
      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="style">
          <xsl:if test="position() &gt; 1"><xsl:value-of select="'cmo_noBorder'" /></xsl:if>
        </xsl:with-param>
        <xsl:with-param name="label">
          <xsl:if test="position() = 1"><xsl:value-of select="'editor.label.annot'" /></xsl:if>
        </xsl:with-param>
        <xsl:with-param name="type">
          <xsl:variable name="type" select="@type" />
          <xsl:call-template name="printClassLabel2">
            <xsl:with-param name="classID" select="'cmo_annotType'" />
            <xsl:with-param name="categID" select="$type" />
          </xsl:call-template>
        </xsl:with-param>
        <xsl:with-param name="content">
          <xsl:comment><xsl:value-of select="name(..)" /></xsl:comment>
          <xsl:choose>
            <xsl:when test="local-name(..)='persName'">
              <xsl:call-template name="printAnnot" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="node()" mode="printAnnot" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mei:ref|mei:bibl|mei:persName" mode="printAnnot">
    <a href="{$WebApplicationBaseURL}receive/{@target|@nymref}">
      <xsl:apply-templates select="text()" mode="printAnnot" />
    </a>
  </xsl:template>

  <xsl:template match="mei:lb" mode="printAnnot">
    <br />
  </xsl:template>

  <xsl:template name="printAnnot">
    <xsl:value-of select="." />
    <xsl:if test="@source">
      <small> (<xsl:call-template name="objectLink"><xsl:with-param select="@source" name="obj_id" /></xsl:call-template>,
        <xsl:value-of select="@label" />)</small>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>
