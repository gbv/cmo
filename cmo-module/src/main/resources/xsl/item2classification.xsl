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

<!--
 This stylesheet converts items from cmo-project (_index folder) to MyCoRe classifications
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0" version="1.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:noNamespaceSchemaLocation="MCRClassification.xsd">

  <xsl:output indent="yes" />

  <!-- replace language here -->
  <xsl:variable name="lang" select="'en'" />

  <xsl:template match="/">
    <mycoreclass ID="{tei:list/@xml:id}" xsi:noNamespaceSchemaLocation="MCRClassification.xsd">
      <label xml:lang="{$lang}" text="{tei:list/@xml:id}"></label> <!-- replace class id here-->
      <categories>
        <xsl:apply-templates select="tei:list/tei:item" />
      </categories>
    </mycoreclass>
  </xsl:template>


  <xsl:template match="tei:item[text()]">
    <category ID="{@xml:id}">
      <label xml:lang="{$lang}">
        <xsl:if test="tei:p/text()">
          <xsl:attribute name="description">
            <xsl:value-of select="tei:p/text()" />
          </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="text">
              <xsl:value-of select="tei:idno/text()" />
        </xsl:attribute>
      </label>
      <xsl:apply-templates select="tei:list"/>
    </category>

  </xsl:template>


</xsl:stylesheet>
