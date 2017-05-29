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
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
                xmlns:acl="xalan://org.mycore.access.MCRAccessManager"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                exclude-result-prefixes="xalan xlink acl i18n mei">

  <xsl:template match="mei:respStmt" mode="metadataView">
    <xsl:comment>mei/respStmt.xsl > mei:respStmt</xsl:comment>
    <xsl:variable name="respLabel">
      <xsl:choose>
        <xsl:when test="mei:resp/text() and i18n:exists(concat('editor.label.resp.', mei:resp/text()))">
          <xsl:value-of select="i18n:translate(concat('editor.label.resp.', mei:resp/text()))" />
        </xsl:when>
        <xsl:when test="mei:resp/text()">
          <xsl:value-of select="mei:resp/text()" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="i18n:translate('editor.label.resp')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="metadataTextContent">
      <xsl:with-param name="text" select="$respLabel" />
      <xsl:with-param name="content">
        <xsl:apply-templates select="mei:corpName|mei:geogName" mode="metadataViewText" />
        <xsl:apply-templates select="mei:persName" mode="metadataView" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:corpName" mode="metadataViewText">
    <xsl:comment>mei/respStmt.xsl mei:corpName</xsl:comment>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="mei:geogName" mode="metadataViewText">
    <xsl:comment>mei/respStmt.xsl mei:geogName</xsl:comment>
    <xsl:value-of select="." />
  </xsl:template>

</xsl:stylesheet>
