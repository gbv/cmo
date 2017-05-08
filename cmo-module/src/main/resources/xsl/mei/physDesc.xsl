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

  <!-- TODO: display this -->
  <xsl:template match="mei:physDesc" mode="metadataView">
    <xsl:comment>mei/physDesc.xsl > mei:physDesc</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.physDesc'" />
      <xsl:with-param name="content">
        <dl>
          <xsl:if test="mei:dimensions">
            <dt>Dimensions:</dt>
            <dd><xsl:value-of select="mei:dimensions" /></dd>
          </xsl:if>
          <xsl:if test="mei:extent">
            <dt>Extent:</dt>
            <dd><xsl:value-of select="mei:extent" /></dd>
          </xsl:if>
          <!-- xsl:if test="mei:script">
            <dt>Script:</dt>
            <dd><xsl:value-of select="mei:script" /></dd>
          </xsl:if -->
          <xsl:if test="mei:physMedium">
            <dt>Used materials:</dt>
            <dd>
              <ul>
                <xsl:for-each select="mei:physMedium">
                  <li><xsl:value-of select="concat(., ' (', @label, ')')" /></li>
                </xsl:for-each>
              </ul>
            </dd>
          </xsl:if>
        </dl>
      </xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="label" select="'editor.label.condition'" />
        <xsl:with-param name="content">
          <xsl:value-of select="mei:condition" />
        </xsl:with-param>
      </xsl:call-template>

      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="label" select="'editor.label.handList'" />
        <xsl:with-param name="content">
          <ul>
            <xsl:for-each select="mei:handList/mei:hand">
              <li>
                <xsl:value-of select="concat(@medium, ': ', .)" />
                <xsl:text> (</xsl:text>
                <xsl:call-template name="objectLink">
                  <xsl:with-param select="@resp" name="obj_id" />
                </xsl:call-template>
                <xsl:text>)</xsl:text>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:with-param>
      </xsl:call-template>

  </xsl:template>


</xsl:stylesheet>
