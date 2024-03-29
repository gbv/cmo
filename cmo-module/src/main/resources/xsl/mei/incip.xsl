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

  <xsl:template match="mei:incip" mode="metadataView">
    <xsl:comment>mei/incip.xsl > mei:incip</xsl:comment>

    <xsl:for-each select="mei:incipText">
      <xsl:call-template name="metadataContentContent">
        <xsl:with-param name="style">
          <xsl:if test="position() &gt; 1"><xsl:value-of select="'cmo_noBorder'" /></xsl:if>
        </xsl:with-param>
        <xsl:with-param name="content1">
          <xsl:if test="position() = 1">
            <abbr title="{i18n:translate('editor.label.incipText')}">Incipit</abbr>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="type">
          <xsl:if test="@label">
            <xsl:value-of select="@label"/>
          </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="content2">
          <xsl:value-of select="." disable-output-escaping="yes"/>
        </xsl:with-param>
        <xsl:with-param name="content2Arab" select="contains(@xml:lang,'-arab')" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


</xsl:stylesheet>
