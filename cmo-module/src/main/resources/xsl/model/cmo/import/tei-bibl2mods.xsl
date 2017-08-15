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
  This stylesheet converts a tei:bibl to mods:mods
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mods="http://www.loc.gov/mods/v3"
                version="3.0">

  <xsl:output indent="yes" />

  <xsl:variable name="ID" select="/tei:bibl/@xml:id" />

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="/tei:bibl">
    <mods:mods>

      <xsl:apply-templates select="tei:title" />
      <xsl:apply-templates select="tei:author" />
      <xsl:apply-templates select="tei:editor" />
      <xsl:apply-templates select="tei:respStmt" />
      <xsl:apply-templates select="@xml:id" />
      <xsl:apply-templates select="tei:idno" />

      <mods:originInfo eventType="publication">
        <xsl:apply-templates select="tei:edition" />
        <xsl:apply-templates select="tei:publisher" />
        <xsl:apply-templates select="tei:pubPlace" />
        <xsl:apply-templates select="tei:date" />
      </mods:originInfo>

      <xsl:apply-templates select="tei:distributor" />
      <xsl:apply-templates select="tei:funder" />
      <xsl:apply-templates select="tei:sponsor" />
      <xsl:apply-templates select="tei:extent" />
      <xsl:apply-templates select="tei:series" />
      <xsl:apply-templates select="tei:ref" />
      <xsl:apply-templates select="tei:note" />
      <xsl:apply-templates select="tei:bibl[@type='in']" />
    </mods:mods>
  </xsl:template>


  <xsl:template match="@xml:id">
    <mods:identifier type="cmo_intern">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="tei:idno">
    <mods:identifier type="{@type}">
      <xsl:value-of select="." />
    </mods:identifier>
  </xsl:template>

  <xsl:template match="tei:author">
    <xsl:choose>
      <xsl:when test="contains(., ';')">
        <xsl:for-each select="tokenize(., ';')">
          <xsl:call-template name="printName">
            <xsl:with-param name="displayName" select="normalize-space(.)" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="printName">
          <xsl:with-param name="displayName" select="normalize-space(.)" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:title">
    <mods:titleInfo>
      <xsl:if test="@xml:lang">
        <xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang" /></xsl:attribute>
      </xsl:if>
      <mods:title><xsl:value-of select="." /></mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template match="tei:respStmt">
    <xsl:apply-templates select="tei:resp[text()='Co-Author']/following-sibling::tei:persName" mode="coauthor" />
    <xsl:apply-templates select="tei:resp[text()='Printer']/following-sibling::tei:orgName" mode="printer" />
  </xsl:template>

  <xsl:template match="tei:respStmt/tei:orgName" mode="printer">
    <xsl:call-template name="printName">
      <xsl:with-param name="displayName" select="." />
      <xsl:with-param name="type" select="'corporate'" />
      <xsl:with-param name="role" select="'prt'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:respStmt/tei:persName" mode="coauthor">
    <xsl:call-template name="printName">
      <xsl:with-param name="displayName" select="." />
      <xsl:with-param name="co-author" select="true()" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:editor">
    <xsl:call-template name="printName">
      <xsl:with-param name="displayName" select="." />
      <xsl:with-param name="role" select="'edt'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:distributor">
    <xsl:call-template name="printName">
      <xsl:with-param name="displayName" select="." />
      <xsl:with-param name="role" select="'dst'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:sponsor">
    <xsl:call-template name="printName">
      <xsl:with-param name="displayName" select="." />
      <xsl:with-param name="role" select="'spn'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:edition">
    <mods:edition><xsl:value-of select="." /></mods:edition>
  </xsl:template>

  <xsl:template match="tei:publisher">
    <mods:publisher><xsl:value-of select="." /></mods:publisher>
  </xsl:template>

  <xsl:template match="tei:pubPlace">
      <mods:place>
        <mods:placeTerm type="text"><xsl:value-of select="." /></mods:placeTerm>
      </mods:place>
  </xsl:template>

  <xsl:template match="tei:date">
    <mods:dateIssued encoding="w3cdtf"><xsl:value-of select="." /></mods:dateIssued>
  </xsl:template>

  <xsl:template match="tei:funder">
    <xsl:call-template name="printName">
      <xsl:with-param name="displayName" select="." />
      <xsl:with-param name="type" select="'corporate'" />
      <xsl:with-param name="role" select="'fnd'" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:extent">
    <mods:physicalDescription>
      <mods:extent><xsl:value-of select="." /></mods:extent>
    </mods:physicalDescription>
  </xsl:template>

  <xsl:template match="tei:series">
    <mods:relatedItem type="series">
      <mods:titleInfo>
        <xsl:if test="@xml:lang">
          <xsl:attribute name="xml:lang"><xsl:value-of select="@xml:lang" /></xsl:attribute>
        </xsl:if>
        <mods:title><xsl:value-of select="." /></mods:title>
      </mods:titleInfo>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template match="tei:ref">
    <mods:location>
      <mods:url>
        <xsl:attribute name="displayLabel"><xsl:value-of select="." /></xsl:attribute>
        <xsl:value-of select="@target" />
      </mods:url>
    </mods:location>
  </xsl:template>

  <xsl:template match="tei:note">
    <mods:note><xsl:value-of select="." /></mods:note>
  </xsl:template>

  <xsl:template match="tei:bibl[@type='in']">
    <mods:relatedItem type="host">
      <mods:part>
        <!-- mods:detail type="issue">
          <mods:number>September</mods:number>
        </mods:detail>
        <mods:detail type="volume">
          <mods:number>77 (2017)</mods:number>
        </mods:detail -->
        <mods:extent unit="pages">
          <mods:list><xsl:value-of select="tei:biblScope" /></mods:list>
        </mods:extent>
      </mods:part>

      <xsl:apply-templates select="tei:title" />
      <xsl:apply-templates select="tei:author" />
      <xsl:apply-templates select="tei:editor" />
      <xsl:apply-templates select="tei:respStmt" />

      <mods:originInfo eventType="publication">
        <xsl:apply-templates select="tei:edition" />
        <xsl:apply-templates select="tei:publisher" />
        <xsl:apply-templates select="tei:pubPlace" />
        <xsl:apply-templates select="tei:date" />
      </mods:originInfo>

      <xsl:apply-templates select="tei:distributor" />
      <xsl:apply-templates select="tei:funder" />
      <xsl:apply-templates select="tei:sponsor" />
      <xsl:apply-templates select="tei:extent" />
      <xsl:apply-templates select="tei:series" />
      <xsl:apply-templates select="tei:ref" />
      <xsl:apply-templates select="tei:note" />
    </mods:relatedItem>
  </xsl:template>


  <xsl:template name="printName">
    <xsl:param name="displayName" />
    <xsl:param name="role" select="'aut'" />
    <xsl:param name="type" select="'personal'" />
    <xsl:param name="co-author" select="false()"></xsl:param>

    <mods:name>
      <xsl:attribute name="type"><xsl:value-of select="$type" /></xsl:attribute>
      <mods:displayForm><xsl:value-of select="$displayName" /></mods:displayForm>
      <mods:role>
        <mods:roleTerm type="code" authority="marcrelator"><xsl:value-of select="$role" /></mods:roleTerm>
        <xsl:if test="$co-author">
          <mods:roleTerm type="text">co-author</mods:roleTerm>
        </xsl:if>
      </mods:role>
      <!-- mods:nameIdentifier type="gnd">TODO: are there identifiers?</mods:nameIdentifier -->
      <xsl:if test="contains($displayName, ', ')">
        <mods:namePart type="family"><xsl:value-of select="substring-before($displayName, ', ')" /></mods:namePart>
        <mods:namePart type="given"><xsl:value-of select="substring-after($displayName, ', ')" /></mods:namePart>
      </xsl:if>
    </mods:name>
  </xsl:template>

  <xsl:template match="*">
    <xsl:message terminate="yes">Not specific handled: <xsl:value-of select="name()" /></xsl:message>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy-of select="." />
  </xsl:template>


</xsl:stylesheet>
