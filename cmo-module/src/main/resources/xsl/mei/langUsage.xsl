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
  xmlns:classification="xalan://org.mycore.mei.classification.MCRMEIClassificationSupport"
  exclude-result-prefixes="xalan xlink acl i18n mei classification" version="1.0">

  <xsl:template match="mei:langUsage" mode="metadataView">
    <xsl:comment>mei/langUsage.xsl > mei:langUsage</xsl:comment>

    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.language'" />
      <xsl:with-param name="content">
        <ul class="list-unstyled">
          <xsl:for-each select="mei:language">
            <li>
              <xsl:choose>
                <xsl:when test="@auth and @xml:id">
                  <xsl:value-of select="classification:getLabelOfLanguage(.)" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="." />
                  <xsl:message>WARNING: OBJECT HAS MEI:LANGUAGE BUT NO AUTH AND ID</xsl:message>
                </xsl:otherwise>
              </xsl:choose>
            </li>
          </xsl:for-each>
        </ul>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


</xsl:stylesheet>
