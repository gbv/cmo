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

  <!--
  Classifications always look like so this Snipped can be used to output them.
  <mei:classification xmlns:mei="http://www.music-encoding.org/ns/mei">
    <mei:classCode authority="cmo_sourceType" xml:id="id3b34b0f0"/>
    <mei:termList classcode="#id3b34b0f0">
      <mei:term>st-96023048-4</mei:term>
    </mei:termList>
    <mei:classCode authority="cmo_contentType" xml:id="id19d3771a"/>
    <mei:termList classcode="#id19d3771a">
      <mei:term>ct-99837941-9</mei:term>
    </mei:termList>
    <mei:classCode authority="cmo_notationType" xml:id="id346972d7"/>
    <mei:termList classcode="#id346972d7">
      <mei:term>nt-26270991-1</mei:term>
    </mei:termList>
  </mei:classification>
  -->
  <xsl:template match="mei:classification" mode="metadataView">
    <xsl:comment>mei/classification.xsl > mei:classification</xsl:comment>
    <xsl:if test="mei:termList/mei:term">
      <xsl:for-each select="mei:classCode[not(contains(@authURI, 'cmo_kindOfData'))]">
        <xsl:variable name="classCodeID" select="@xml:id" />
        <xsl:call-template name="metadataTextContent">
          <xsl:with-param name="text" select="classification:getRootClassLabel(.)" />
          <xsl:with-param name="content">
            <ul class="list-unstyled">
              <xsl:for-each
                select="../mei:termList[@classcode=concat('#', $classCodeID)]/mei:term">
                <li>
                  <xsl:value-of select="classification:getClassLabel(.)" />
                </li>
              </xsl:for-each>
            </ul>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
