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

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:cmo="http://www.corpus-musicae-ottomanicae.de/ns/cmo"
                xmlns:mei="http://www.music-encoding.org/ns/mei">

  <xsl:output indent="yes" />

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:term[text()]">
    <xsl:variable name="classID">
      <xsl:choose>
        <xsl:when test="@cmo:term-type='type of source'">
          <xsl:value-of select="'cmo_sourceType'" />
        </xsl:when>
        <xsl:when test="@cmo:term-type='type of content'">
          <xsl:value-of select="'cmo_sourceType'" />
        </xsl:when>
        <xsl:when test="@cmo:term-type='notation'">
          <xsl:value-of select="'cmo_notationType'" />
        </xsl:when>
        <xsl:when test="@cmo:term-type='genre'">
          <xsl:value-of select="'cmo_musictype'" />
        </xsl:when>
        <xsl:when test="@cmo:term-type='music type'">
          <xsl:value-of select="'cmo_musictype'" />
        </xsl:when>
        <xsl:when test="@cmo:term-type='notation type'">
          <xsl:value-of select="'cmo_notationType'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:message>Cannot find class id
            <xsl:value-of select="@cmo:term-type" />
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="categID">
      <xsl:choose>
        <xsl:when test="@cmo:classLink">
          <xsl:value-of select="@cmo:classLink" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <mei:term analog="{$classID}/{$categID}"></mei:term>
  </xsl:template>

  <xsl:template match="cmo:usul|cmo:makam">
  </xsl:template>

  <xsl:template match="mei:*[cmo:usul or cmo:makam and not(mei:classification)]">
    <xsl:copy>
      <mei:classification>
        <mei:termList>
          <xsl:for-each select="cmo:makam">
            <mei:term analog="cmo_makamler/{@cmo:classLink}"></mei:term>
          </xsl:for-each>

          <xsl:for-each select="cmo:usul">
            <mei:term analog="cmo_usuler/{@cmo:classLink}"></mei:term>
          </xsl:for-each>
        </mei:termList>
      </mei:classification>
      <xsl:apply-templates select="node()" />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="mei:classification/mei:termList">
    <mei:termList>
      <xsl:for-each select="../../cmo:usul">
        <mei:term analog="cmo_usuler/{@cmo:classLink}"></mei:term>
      </xsl:for-each>
      <xsl:for-each select="../../cmo:makam">
        <mei:term analog="cmo_makam/{@cmo:classLink}"></mei:term>
      </xsl:for-each>
      <xsl:apply-templates />
    </mei:termList>
  </xsl:template>


</xsl:stylesheet>
