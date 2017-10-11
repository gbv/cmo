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


  <xsl:include href="import-util.xsl" />

  <xsl:template match='@*|node()'>
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="//mei:titleStmt[not(mei:title)]">
    <xsl:copy>
      <mei:title type="placeholder">
        <xsl:value-of select="'N/A'" />
      </mei:title>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:language[@xml:id]">
    <xsl:copy>
      <xsl:attribute name="authority">
        <xsl:call-template name="detectClassification">
          <xsl:with-param name="lang" select="@xml:id" />
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="xml:id">
        <xsl:call-template name="convertLanguage">
          <xsl:with-param name="lang" select="@xml:id" />
        </xsl:call-template>
      </xsl:attribute>
      <xsl:apply-templates select="@*[not(name()='xml:id')]|node()" />
    </xsl:copy>
  </xsl:template>


</xsl:stylesheet>
