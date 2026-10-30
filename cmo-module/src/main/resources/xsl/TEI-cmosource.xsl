<?xml version="1.0" encoding="UTF-8"?>
<!--
  Renders the raw XML of a derivate main file (e.g. a CMO TEI edition) into a
  self-contained, pretty printed and syntax highlighted HTML fragment. The fragment
  is loaded lazily into the "(XML)" tab of the object page via the
  MCRDerivateContentTransformerServlet (see layout/viewer.xsl).

  The stylesheet walks the source tree and emits <span> elements carrying css classes
  for tags, attributes, values, text and comments. The colouring itself lives in
  scss/cmo/_tei.scss. No external JavaScript highlighter is needed.

  This stylesheet is XSLT 3.0 and is executed with Saxon (see the TEI-cmosource
  content transformer in mycore.properties). Because the output method is "html" the
  layout template is not applied and a bare fragment is produced.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cmo="http://www.corpus-musicae-ottomanicae.de/ns/tei"
                exclude-result-prefixes="xs cmo"
                version="3.0">

  <xsl:output method="html" indent="no" omit-xml-declaration="yes" />

  <!-- one indentation step is two spaces, repeated per nesting depth -->
  <xsl:function name="cmo:indent" as="xs:string">
    <xsl:param name="depth" as="xs:integer" />
    <xsl:sequence select="string-join((1 to $depth) ! '  ', '')" />
  </xsl:function>

  <xsl:template match="/">
    <div class="cmo-xml-source">
      <pre class="cmo-xml"><code><xsl:apply-templates
          select="node()[not(self::text())]" mode="xml" /></code></pre>
    </div>
  </xsl:template>

  <!-- ============================ elements ============================ -->

  <xsl:template match="*" mode="xml">
    <xsl:param name="depth" as="xs:integer" select="0" />
    <xsl:param name="inline" as="xs:boolean" select="false()" />

    <!-- mixed content: an element that also holds significant text is kept on one
         line so the original (possibly meaningful) whitespace is preserved -->
    <xsl:variable name="mixed" as="xs:boolean" select="exists(text()[normalize-space()])" />
    <xsl:variable name="hasContent" as="xs:boolean"
                  select="exists(node()[not(self::text()[not(normalize-space())])])" />
    <xsl:variable name="block" as="xs:boolean"
                  select="not($inline) and exists(*) and not($mixed)" />

    <xsl:if test="not($inline)">
      <xsl:value-of select="cmo:indent($depth)" />
    </xsl:if>
    <span class="cmo-xml-punct">&lt;</span>
    <span class="cmo-xml-tag">
      <xsl:value-of select="name()" />
    </span>
    <xsl:call-template name="namespaces" />
    <xsl:apply-templates select="@*" mode="xml" />
    <xsl:choose>
      <xsl:when test="not($hasContent)">
        <span class="cmo-xml-punct">/&gt;</span>
      </xsl:when>
      <xsl:when test="$block">
        <span class="cmo-xml-punct">&gt;</span>
        <xsl:text>&#10;</xsl:text>
        <xsl:apply-templates select="node()[not(self::text())]" mode="xml">
          <xsl:with-param name="depth" select="$depth + 1" />
        </xsl:apply-templates>
        <xsl:value-of select="cmo:indent($depth)" />
        <span class="cmo-xml-punct">&lt;/</span>
        <span class="cmo-xml-tag">
          <xsl:value-of select="name()" />
        </span>
        <span class="cmo-xml-punct">&gt;</span>
      </xsl:when>
      <xsl:otherwise>
        <!-- inline content: keep text nodes and render child elements inline -->
        <span class="cmo-xml-punct">&gt;</span>
        <xsl:apply-templates select="node()" mode="xml">
          <xsl:with-param name="inline" select="true()" />
        </xsl:apply-templates>
        <span class="cmo-xml-punct">&lt;/</span>
        <span class="cmo-xml-tag">
          <xsl:value-of select="name()" />
        </span>
        <span class="cmo-xml-punct">&gt;</span>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="not($inline)">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- namespace declarations, emitted only where they differ from the parent -->
  <xsl:template name="namespaces">
    <xsl:variable name="e" select="." />
    <xsl:variable name="pe" select="../self::*" />
    <xsl:for-each select="in-scope-prefixes($e)[. != 'xml']">
      <xsl:sort select="." />
      <xsl:variable name="pfx" select="string(.)" />
      <xsl:variable name="uri" select="namespace-uri-for-prefix($pfx, $e)" />
      <xsl:variable name="parentUri"
                    select="if (exists($pe)) then namespace-uri-for-prefix($pfx, $pe) else ()" />
      <xsl:if test="empty($pe) or not($uri = $parentUri)">
        <xsl:text> </xsl:text>
        <span class="cmo-xml-attr-name">
          <xsl:value-of select="if ($pfx = '') then 'xmlns' else concat('xmlns:', $pfx)" />
        </span>
        <span class="cmo-xml-punct">=</span>
        <span class="cmo-xml-attr-value">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="$uri" />
          <xsl:text>"</xsl:text>
        </span>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- ========================== attributes =========================== -->

  <xsl:template match="@*" mode="xml">
    <xsl:text> </xsl:text>
    <span class="cmo-xml-attr-name">
      <xsl:value-of select="name()" />
    </span>
    <span class="cmo-xml-punct">=</span>
    <span class="cmo-xml-attr-value">
      <xsl:text>"</xsl:text>
      <xsl:value-of select="." />
      <xsl:text>"</xsl:text>
    </span>
  </xsl:template>

  <!-- ===================== text, comments, PIs ======================= -->

  <xsl:template match="text()" mode="xml">
    <span class="cmo-xml-text">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <xsl:template match="comment()" mode="xml">
    <xsl:param name="depth" as="xs:integer" select="0" />
    <xsl:param name="inline" as="xs:boolean" select="false()" />
    <xsl:if test="not($inline)">
      <xsl:value-of select="cmo:indent($depth)" />
    </xsl:if>
    <span class="cmo-xml-comment">
      <xsl:text>&lt;!--</xsl:text>
      <xsl:value-of select="." />
      <xsl:text>--&gt;</xsl:text>
    </span>
    <xsl:if test="not($inline)">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="processing-instruction()" mode="xml">
    <xsl:param name="depth" as="xs:integer" select="0" />
    <xsl:param name="inline" as="xs:boolean" select="false()" />
    <xsl:if test="not($inline)">
      <xsl:value-of select="cmo:indent($depth)" />
    </xsl:if>
    <span class="cmo-xml-pi">
      <xsl:text>&lt;?</xsl:text>
      <xsl:value-of select="name()" />
      <xsl:text> </xsl:text>
      <xsl:value-of select="." />
      <xsl:text>?&gt;</xsl:text>
    </span>
    <xsl:if test="not($inline)">
      <xsl:text>&#10;</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
