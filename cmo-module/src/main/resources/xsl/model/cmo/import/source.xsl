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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mei="http://www.music-encoding.org/ns/mei"
                version="1.0">

  <xsl:output indent="yes" />

  <xsl:template match='@*|node()'>
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
  </xsl:template>

  <xsl:template match='@*|node()' mode="copy">
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:provenance">
  </xsl:template>

  <xsl:template match="mei:eventList/mei:event/mei:p">
    <mei:desc>
      <xsl:apply-templates select='@*|node()' />
    </mei:desc>
  </xsl:template>

  <xsl:template match="mei:source">
    <mei:source>
      <xsl:if test="mei:physDesc/mei:provenance">
        <mei:history>
          <xsl:apply-templates select="mei:physDesc/mei:provenance/mei:eventList" mode="copy"/>
        </mei:history>
      </xsl:if>
      <xsl:apply-templates select='@*|node()' />
    </mei:source>
  </xsl:template>

  <xsl:template match="//mei:titleStmt[not(mei:title)]">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="../mei:identifier">
          <mei:title>
            <xsl:value-of select="../mei:identifier" />
          </mei:title>
        </xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">Could not find a title to insert!</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
