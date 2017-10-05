<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="http://www.mycore.org/"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:mcrmods="xalan://org.mycore.mods.classification.MCRMODSClassificationSupport"
                xmlns:mcrxml="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:mcrdataurl="xalan://org.mycore.datamodel.common.MCRDataURL"
                xmlns:mcrid="xalan://org.mycore.datamodel.metadata.MCRObjectID" xmlns:exslt="http://exslt.org/common"
                exclude-result-prefixes="mcrmods mcrid xlink mcr mcrxml mcrdataurl exslt" version="1.0"
>

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="mods-utils.xsl"/>
  <xsl:include href="coreFunctions.xsl"/>
  
  <!-- create value URI using valueURIxEditor and authorityURI -->
  <xsl:template match="@valueURIxEditor">
    <xsl:choose>
      <xsl:when test="starts-with(., 'http://d-nb.info/gnd/')">
        <mods:nameIdentifier type="gnd" typeURI="http://d-nb.info/gnd/">
          <xsl:value-of select="substring-after(., 'http://d-nb.info/gnd/')" />
        </mods:nameIdentifier>
      </xsl:when>
      <xsl:when test="starts-with(., 'http://www.viaf.org/')">
        <mods:nameIdentifier type="viaf" typeURI="http://www.viaf.org/">
          <xsl:value-of select="substring-after(., 'http://www.viaf.org/')" />
        </mods:nameIdentifier>
      </xsl:when>
      <xsl:when test="starts-with(../@authorityURI, 'http://d-nb.info/gnd/')">
        <xsl:attribute name="valueURI">
          <xsl:value-of select="concat(../@authorityURI,.)" />
        </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="valueURI">
          <xsl:value-of select="concat(../@authorityURI,'#',substring-after(.,':'))" />
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="mods:nameIdentifier[@type=preceding-sibling::mods:nameIdentifier/@type or contains(../@valueURIxEditor, @type)]">
    <xsl:message>
      <xsl:value-of select="concat('Skipping ',@type,' identifier: ',.,' due to previous declaration.')" />
    </xsl:message>
  </xsl:template>

  <xsl:template match="mods:nameIdentifier">
    <xsl:variable name="type" select="@type"></xsl:variable>
    <xsl:variable name="curi"
      select="document(concat('classification:metadata:all:children:','nameIdentifier',':',$type))/mycoreclass/categories/category[@ID=$type]/label[@xml:lang='x-uri']/@text" />
    <!-- if no typeURI defined in classification, we used the default -->
    <xsl:variable name="uri">
      <xsl:choose>
        <xsl:when test="string-length($curi) = 0">
          <xsl:value-of select="@typeURI" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$curi" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <mods:nameIdentifier type="{$type}" typeURI="{$uri}">
      <xsl:value-of select="." />
    </mods:nameIdentifier>
  </xsl:template>
  
  <xsl:template match="mods:name/mods:displayForm">
    <xsl:variable name="etalShortcut">
      |etal|et al|et.al.|u.a.|ua|etc|u.s.w.|usw|...
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="contains($etalShortcut,.)">
        <mods:etal />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mods:name">
    <xsl:copy>
      <xsl:copy-of select="@*[name()!='simpleEditor' and name()!='valueURIxEditor']" />
      <xsl:if test="@valueURIxEditor">
        <xsl:attribute name="valueURI">
          <xsl:value-of select="concat(@authorityURI,'#',@valueURIxEditor)" />
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@simpleEditor">
          <xsl:copy-of select="node()[name()!='mods:namePart']" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="node()" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="(not(mods:namePart[@type='family']) or @simpleEditor)  and mods:displayForm and @type='personal'">
        <xsl:call-template name="mods.seperateName">
          <xsl:with-param name="displayForm" select="mods:displayForm" />
        </xsl:call-template>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  
  <!-- In editor, all variants of page numbers are edited in a single text field -->
  <xsl:template match="mods:part/mods:extent[@unit='pages']" xmlns:pages="xalan://org.mycore.mods.MCRMODSPagesHelper">
    <xsl:copy-of select="pages:buildExtentPagesNodeSet(mods:list/text())" />
  </xsl:template>
</xsl:stylesheet>