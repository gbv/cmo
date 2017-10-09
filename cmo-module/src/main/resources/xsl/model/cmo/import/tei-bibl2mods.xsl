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
                xmlns:xalan="http://xml.apache.org/xalan"
                xmlns:pageHelper="xalan://org.mycore.mods.MCRMODSPagesHelper"
                xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="mods xalan pageHelper"
                version="1.0">

  <xsl:output indent="yes" />

  <xsl:variable name="ID" select="/tei:bibl/@xml:id" />

  <xsl:template match="/">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="/tei:bibl">
    <mods:mods>

      <xsl:apply-templates select="tei:title[not(@type='sub')]" />
      <xsl:apply-templates select="tei:author" />
      <xsl:apply-templates select="tei:editor" />
      <xsl:apply-templates select="tei:respStmt" />
      <xsl:apply-templates select="@xml:id" />
      <xsl:apply-templates select="tei:idno" />

      <xsl:choose>
        <xsl:when test="tei:bibl[@type='in']">
          <mods:genre valueURI="http://www.corpus-musicae-ottomanicae.de/api/v1/classifications/cmo_genres#article"
                      authorityURI="http://www.corpus-musicae-ottomanicae.de/api/v1/classifications/cmo_genres"
                      type="intern" />
        </xsl:when>
        <xsl:otherwise>
          <mods:genre valueURI="http://www.corpus-musicae-ottomanicae.de/api/v1/classifications/cmo_genres#book"
                      authorityURI="http://www.corpus-musicae-ottomanicae.de/api/v1/classifications/cmo_genres"
                      type="intern" />
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="tei:edition|tei:publisher|tei:pubPlace|tei:date">
        <mods:originInfo eventType="publication">
          <xsl:apply-templates select="tei:edition" />
          <xsl:apply-templates select="tei:publisher" />
          <xsl:apply-templates select="tei:pubPlace" />
          <xsl:apply-templates select="tei:date" />
        </mods:originInfo>
      </xsl:if>

      <xsl:apply-templates select="tei:distributor" />
      <xsl:apply-templates select="tei:funder" />
      <xsl:apply-templates select="tei:sponsor" />
      <xsl:apply-templates select="tei:extent" />
      <xsl:apply-templates select="tei:series" />
      <xsl:apply-templates select="tei:ref" />
      <xsl:apply-templates select="tei:note" />
      <xsl:apply-templates select="tei:bibl[@type='in']" />
      <mods:typeOfResource>text</mods:typeOfResource>
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
        <xsl:variable name="tags">
          <xsl:call-template name="tokenize">
            <xsl:with-param name="pText" select="." />
            <xsl:with-param name="seperator" select="';'" />
          </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="exslt:node-set($tags)/tag">
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
        <xsl:attribute name="xml:lang">
          <xsl:call-template name="convertLanguage">
            <xsl:with-param name="lang" select="@xml:lang" />
          </xsl:call-template>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@type='alt'">
        <xsl:attribute name="type">
          <xsl:value-of select="'alternative'" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@type='main'">
        <xsl:for-each select="../tei:title[@type='sub']">
          <mods:subTitle>
            <xsl:value-of select="text()" />
          </mods:subTitle>
        </xsl:for-each>
      </xsl:if>
      <mods:title>
        <xsl:value-of select="." />
      </mods:title>
    </mods:titleInfo>
  </xsl:template>

  <xsl:template name="tokenize">
    <xsl:param name="pText" />
    <xsl:param name="seperator" />
    <xsl:if test="string-length($pText)&gt;0">
      <tag>
        <xsl:value-of select="substring-before($pText, $seperator)" />
      </tag>
      <xsl:call-template name="tokenize">
        <xsl:with-param name="pText" select="substring-after($pText, $seperator)" />
        <xsl:with-param name="seperator" select="$seperator" />
      </xsl:call-template>
    </xsl:if>
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
    <mods:edition>
      <xsl:value-of select="." />
    </mods:edition>
  </xsl:template>

  <xsl:template match="tei:publisher">
    <mods:publisher>
      <xsl:value-of select="." />
    </mods:publisher>
  </xsl:template>

  <xsl:template match="tei:pubPlace">
    <mods:place>
      <mods:placeTerm type="text">
        <xsl:value-of select="." />
      </mods:placeTerm>
    </mods:place>
  </xsl:template>

  <xsl:template match="tei:date">
    <xsl:choose>
      <xsl:when test="(@notBefore != .) or (@notAfter != .)">
        <mods:dateIssued qualifier="approximate">
          <xsl:if test="@calendar and substring-after(@calendar, '#') != 'gregorian'">
            <xsl:attribute name="transliteration">
              <xsl:value-of select="substring-after(@calendar, '#')" />
            </xsl:attribute>
          </xsl:if>
          <xsl:value-of select="." />
        </mods:dateIssued>
        <mods:dateIssued encoding="w3cdtf" point="start">
          <xsl:value-of select="@notBefore" />
        </mods:dateIssued>
        <mods:dateIssued encoding="w3cdtf" point="end">
          <xsl:value-of select="@notAfter" />
        </mods:dateIssued>
      </xsl:when>
      <xsl:otherwise>
        <mods:dateIssued encoding="w3cdtf">
          <xsl:value-of select="." />
        </mods:dateIssued>
      </xsl:otherwise>
    </xsl:choose>
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
      <mods:extent>
        <xsl:value-of select="." />
      </mods:extent>
    </mods:physicalDescription>
  </xsl:template>

  <xsl:template match="tei:series">
    <mods:relatedItem type="series">
      <mods:titleInfo>
        <xsl:if test="@xml:lang">
          <xsl:attribute name="xml:lang">
            <xsl:call-template name="convertLanguage">
              <xsl:with-param name="lang" select="@xml:lang" />
            </xsl:call-template>
          </xsl:attribute>
        </xsl:if>
        <mods:title>
          <xsl:value-of select="." />
        </mods:title>
      </mods:titleInfo>
    </mods:relatedItem>
  </xsl:template>

  <xsl:template match="tei:ref">
    <mods:location>
      <mods:url>
        <xsl:attribute name="displayLabel">
          <xsl:value-of select="." />
        </xsl:attribute>
        <xsl:value-of select="@target" />
      </mods:url>
    </mods:location>
  </xsl:template>

  <xsl:template match="tei:note">
    <mods:note>
      <xsl:value-of select="." />
    </mods:note>
  </xsl:template>

  <xsl:template name="convertLanguage">
    <xsl:param name="lang" />
    <xsl:choose>
      <xsl:when test="$lang='tur'">
        <xsl:text>tr</xsl:text>
      </xsl:when>
      <xsl:when test="$lang='ara'">
        <xsl:text>ar</xsl:text>
      </xsl:when>
      <xsl:when test="$lang='fra'">
        <xsl:text>fr</xsl:text>
      </xsl:when>
      <xsl:when test="$lang='ell'">
        <xsl:text>el</xsl:text>
      </xsl:when>
      <xsl:when test="$lang='eng'">
        <xsl:text>en</xsl:text>
      </xsl:when>
      <xsl:when test="$lang='fas'">
        <xsl:text>fa</xsl:text>
      </xsl:when>
      <xsl:when test="$lang='hye'">
        <xsl:text>hy</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$lang" />
      </xsl:otherwise>
    </xsl:choose>
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
        <xsl:if test="string-length(tei:biblScope/text()) &gt; 0">
          <xsl:copy-of select="pageHelper:buildExtentPagesNodeSet(tei:biblScope/text())" />
        </xsl:if>
      </mods:part>

      <xsl:apply-templates select="tei:title[not(@type='sub')]" />
      <xsl:apply-templates select="tei:author" />
      <xsl:apply-templates select="tei:editor" />
      <xsl:apply-templates select="tei:respStmt" />

      <xsl:if test="tei:edition|tei:publisher|tei:pubPlace|tei:date">
        <mods:originInfo eventType="publication">
          <xsl:apply-templates select="tei:edition" />
          <xsl:apply-templates select="tei:publisher" />
          <xsl:apply-templates select="tei:pubPlace" />
          <xsl:apply-templates select="tei:date" />
        </mods:originInfo>
      </xsl:if>

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
      <xsl:attribute name="type">
        <xsl:value-of select="$type" />
      </xsl:attribute>
      <mods:displayForm>
        <xsl:value-of select="$displayName" />
      </mods:displayForm>
      <mods:role>
        <mods:roleTerm type="code" authority="marcrelator">
          <xsl:value-of select="$role" />
        </mods:roleTerm>
        <xsl:if test="$co-author">
          <mods:roleTerm type="text">co-author</mods:roleTerm>
        </xsl:if>
      </mods:role>
      <!-- mods:nameIdentifier type="gnd">TODO: are there identifiers?</mods:nameIdentifier -->
      <xsl:if test="contains($displayName, ', ')">
        <mods:namePart type="family">
          <xsl:value-of select="substring-before($displayName, ', ')" />
        </mods:namePart>
        <mods:namePart type="given">
          <xsl:value-of select="substring-after($displayName, ', ')" />
        </mods:namePart>
      </xsl:if>
    </mods:name>
  </xsl:template>

  <xsl:template match="*">
    <xsl:message terminate="yes">Not specific handled:
      <xsl:value-of select="name()" />
    </xsl:message>
  </xsl:template>

  <xsl:template match="@*">
    <xsl:copy-of select="." />
  </xsl:template>


</xsl:stylesheet>
