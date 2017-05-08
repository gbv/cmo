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


  <xsl:template match="mei:persName[@nymref]" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:persName[@nymref]</xsl:comment>
    <xsl:call-template name="objectLink">
      <xsl:with-param name="obj_id" select="@nymref" />
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="mei:author" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:author</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.author'" />
      <xsl:with-param name="content">
        <xsl:apply-templates mode="metadataView" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:composer" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:composer</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.composer'" />
      <xsl:with-param name="content">
        <xsl:apply-templates mode="metadataView" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:lyricist" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:lyricist</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.lyricist'" />
      <xsl:with-param name="content">
        <xsl:apply-templates mode="metadataView" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="showPersonDates">
    <xsl:comment>mei/persName.xsl > mei:date</xsl:comment>
    <xsl:call-template name="metadataLabelContent">
      <xsl:with-param name="label" select="'editor.label.lifeData'" />
      <xsl:with-param name="content">
        <dl>
          <xsl:for-each select="//mei:date[count(. | key('dateByType', @type)[1]) = 1]">
            <xsl:sort select="@type" />
            <dt>
              <xsl:value-of select="i18n:translate(concat('editor.label.lifeData.',@type))" />
            </dt>
            <dd>
              <ul>
                <xsl:for-each select="key('dateByType', @type)">
                  <li>
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
                    <xsl:if test="string-length(text()) &gt; 0">
                      <xsl:value-of select="text()" />
                    </xsl:if>
                    <xsl:text>(</xsl:text>
                    <xsl:call-template name="objectLink">
                      <xsl:with-param select="@source" name="obj_id" />
                    </xsl:call-template>
                    <xsl:text>; </xsl:text>
                    <a href="http://quellen-perspectivia.net/en/cmo/{@source}">
                      <xsl:value-of select="@label" />
                    </a>
                    <xsl:text>)</xsl:text>
                  </li>
                </xsl:for-each>
              </ul>
            </dd>
          </xsl:for-each>
        </dl>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template match="mei:name" mode="metadataView">
    <xsl:comment>mei/persName.xsl > mei:name</xsl:comment>
    <xsl:call-template name="metadataTextContent">
      <xsl:with-param name="text">
        <xsl:value-of select="i18n:translate('editor.label.name')" />
        <xsl:if test="@type">
          <xsl:value-of select="concat('[', @type, ']')" />
        </xsl:if>
      </xsl:with-param>
      <xsl:with-param name="content">
        <xsl:value-of select="text()" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
