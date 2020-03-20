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


  <xsl:template match="mei:history" mode="metadataView">
    <xsl:comment>mei/history.xsl > mei:history</xsl:comment>
    <xsl:if test="mei:eventList/mei:event">
      <xsl:call-template name="metadataLabelContent">
        <xsl:with-param name="label" select="'editor.label.history'" />
        <xsl:with-param name="content">

          <dl>
            <xsl:for-each select="mei:eventList/mei:event">
              <xsl:comment>mei/history.xsl > mei:event</xsl:comment>
              <dt>
                <xsl:value-of select="mei:head" />
              </dt>
              <dd>
                <ul class="list-unstyled">
                  <!-- TODO: mode "metadataViewHistory" does'nt exist atm -->
                  <xsl:if test="string-length(mei:persName) &gt; 0"><li><xsl:apply-templates select="mei:persName" mode="metadataViewHistory" /></li></xsl:if>
                  <xsl:if test="string-length(mei:geogName) &gt; 0"><li><xsl:apply-templates select="mei:geogName" mode="metadataViewHistory" /></li></xsl:if>
                  <xsl:if test="string-length(mei:date) &gt; 0"><li><xsl:apply-templates select="mei:date" mode="metadataViewHistory" /></li></xsl:if>
                </ul>
                <xsl:if test="string-length(mei:p) &gt; 0">
                  <p>
                    <xsl:value-of select="mei:p" />
                  </p>
                </xsl:if>
                <xsl:if test="string-length(mei:desc) &gt; 0">
                  <p>
                    <xsl:apply-templates select="mei:desc/node()" mode="printDesc" />
                  </p>
                </xsl:if>
              </dd>
            </xsl:for-each>
          </dl>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:persName" mode="metadataViewHistory">
    <xsl:apply-templates select="." mode="printDesc" />
  </xsl:template>

  <xsl:template match="mei:geogName" mode="metadataViewHistory">
    <xsl:value-of select="text()" />
  </xsl:template>

  <xsl:template match="mei:date" mode="metadataViewHistory">
    <xsl:call-template name="getDisplayDate">
      <xsl:with-param name="dateNode" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="mei:ref|mei:bibl|mei:persName" mode="printDesc">
    <a>
      <xsl:if test="@target|@nymref">
        <xsl:attribute name="href">
          <xsl:value-of select="concat($WebApplicationBaseURL, 'receive/', @target|@nymref)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:value-of select="text()"/>
    </a>
  </xsl:template>

</xsl:stylesheet>
