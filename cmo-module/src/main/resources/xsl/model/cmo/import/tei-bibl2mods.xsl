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
  This Stylesheet converts a tei:person to mei:person
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mods="http://www.loc.gov/mods/v3"
                version="1.0">

  <xsl:output indent="yes" />

  <xsl:variable name="ID" select="/tei:bibl/@xml:id" />

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="/tei:bibl">
    <mods:mods>
      <xsl:apply-templates select="@xml:id" />
      <xsl:apply-templates select="*" />
    </mods:mods>
  </xsl:template>


  <xsl:template match="@xml:id">

  </xsl:template>

  <xsl:template match="tei:idno">

  </xsl:template>

  <xsl:template match="tei:author">

  </xsl:template>

  <xsl:template match="tei:title">

  </xsl:template>

  <xsl:template match="tei:respStmt">
    <xsl:apply-templates select="tei:resp" />
    <xsl:apply-templates select="tei:persName" />
    <xsl:apply-templates select="tei:orgName" />

  </xsl:template>

  <xsl:template match="tei:respStmt/tei:orgName">

  </xsl:template>

  <xsl:template match="tei:respStmt/tei:persName">

  </xsl:template>

  <xsl:template match="tei:respStmt/tei:resp">

  </xsl:template>

  <xsl:template match="tei:editor">

  </xsl:template>

  <xsl:template match="tei:edition">

  </xsl:template>

  <xsl:template match="tei:publisher">

  </xsl:template>

  <xsl:template match="tei:pubPlace">

  </xsl:template>

  <xsl:template match="tei:date">

  </xsl:template>

  <xsl:template match="tei:series">

  </xsl:template>


  <xsl:template match="tei:note">

  </xsl:template>

  <xsl:template match="*">
    <xsl:message terminate="yes">Not specific handled:<xsl:value-of select="name()" /></xsl:message>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy-of select="." />
  </xsl:template>


</xsl:stylesheet>
