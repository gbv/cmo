<?xml version="1.0" encoding="UTF-8"?>
<!--
  Renders a CMO TEI text edition (edition_tei derivate) into a self-contained HTML
  fragment. The fragment is loaded lazily into the edition tab of the object page via
  the MCRDerivateContentTransformerServlet (see layout/viewer.xsl).

  This stylesheet is XSLT 3.0 and is executed with Saxon (see the TEI-cmoedition
  content transformer in mycore.properties). Because the output method is "html" the
  layout template is not applied and a bare fragment is produced.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cmo="http://www.corpus-musicae-ottomanicae.de/ns/tei"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="xs cmo"
                version="3.0">

  <xsl:output method="html" indent="no" omit-xml-declaration="yes" />

  <!-- current interface language, provided by MyCoRe; falls back to German -->
  <xsl:param name="CurrentLang" select="'de'" />

  <!-- selects the label matching the current language (de / en / tr) -->
  <xsl:function name="cmo:l" as="xs:string">
    <xsl:param name="de" as="xs:string" />
    <xsl:param name="en" as="xs:string" />
    <xsl:param name="tr" as="xs:string" />
    <xsl:sequence select="if ($CurrentLang = 'en') then $en
                          else if ($CurrentLang = 'tr') then $tr
                          else $de" />
  </xsl:function>

  <xsl:variable name="header" select="/TEI/teiHeader" />
  <xsl:variable name="titleStmt" select="$header/fileDesc/titleStmt" />

  <xsl:template match="/TEI">
    <div class="cmo-tei-edition">
      <xsl:call-template name="editionHeader" />
      <xsl:apply-templates select="text/body/div[@type = 'newPieceStart']" />
      <xsl:apply-templates select="text/body/div[@type = 'blockLyricsTranscription']" />
      <xsl:apply-templates select="text/body//note[@type = 'lyricist']" mode="pieceNote" />
      <xsl:call-template name="apparatus" />
    </div>
  </xsl:template>

  <!-- ============================ header ============================ -->

  <xsl:template name="editionHeader">
    <!-- plain divs on purpose: the page has global CSS for <header> and <section> -->
    <div class="cmo-tei-header">
      <h2 class="cmo-tei-title" lang="ota">
        <xsl:value-of select="$titleStmt/title/title[@type = 'titleTranscription']" />
      </h2>
      <dl class="cmo-tei-meta">
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Makam', 'Makam', 'Makam')" />
          <xsl:with-param name="value" select="$titleStmt/title/note[@type = 'makamTranscription']" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Usul', 'Usul', 'Usul')" />
          <xsl:with-param name="value" select="$titleStmt/title/note[@type = 'usulTranscription']" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Gattung', 'Genre', 'Tür')" />
          <xsl:with-param name="value"
                          select="string-join($titleStmt/title/note[@type = 'genreTranscription']
                                              ! normalize-space(.), ', ')" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Bahir', 'Bahir', 'Bahir')" />
          <xsl:with-param name="value" select="$titleStmt/title/note[@type = 'bahir']" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Metrum', 'Meter', 'Vezin')" />
          <xsl:with-param name="value" select="$titleStmt/title/note[@type = 'meter']" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Signatur', 'Shelfmark', 'Yer numarası')" />
          <xsl:with-param name="value" select="$titleStmt/title/idno" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Textdichter', 'Lyricist', 'Söz yazarı')" />
          <xsl:with-param name="value" select="$titleStmt/author[@role = 'lyricist']/persName" />
        </xsl:call-template>
        <xsl:if test="$titleStmt/editor">
          <dt>
            <xsl:value-of select="cmo:l('Bearbeitung', 'Editors', 'Editörler')" />
          </dt>
          <dd>
            <xsl:value-of select="string-join($titleStmt/editor, ' · ')" />
          </dd>
        </xsl:if>
      </dl>
    </div>
  </xsl:template>

  <!-- renders one term/definition pair, but only if a value is present -->
  <xsl:template name="metaRow">
    <xsl:param name="label" as="xs:string" />
    <xsl:param name="value" />
    <xsl:if test="normalize-space(string($value)) != ''">
      <dt>
        <xsl:value-of select="$label" />
      </dt>
      <dd lang="ota">
        <xsl:value-of select="normalize-space(string($value))" />
      </dd>
    </xsl:if>
  </xsl:template>

  <!-- ======================= manuscript info ======================= -->

  <xsl:template match="div[@type = 'newPieceStart']">
    <xsl:variable name="item" select="msDesc/msContents/msItem" />
    <div class="cmo-tei-source">
      <h3 class="cmo-tei-section-heading">
        <xsl:value-of select="cmo:l('Quelle', 'Source', 'Kaynak')" />
      </h3>
      <dl class="cmo-tei-meta">
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Handschrift', 'Manuscript', 'El yazması')" />
          <xsl:with-param name="value" select="msDesc/msIdentifier/idno" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Stücknummer', 'Piece number', 'Parça no')" />
          <xsl:with-param name="value" select="$item/rubric[@type = 'pieceNumber']" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Blatt / Seite', 'Folio / page', 'Varak / sayfa')" />
          <xsl:with-param name="value" select="$item/locus" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="cmo:l('Incipit', 'Incipit', 'İncipit')" />
          <xsl:with-param name="value" select="$item/incipit" />
        </xsl:call-template>
      </dl>
    </div>
  </xsl:template>

  <!-- ========================== lyrics ============================= -->

  <xsl:template match="div[@type = 'blockLyricsTranscription']">
    <div class="cmo-tei-lyrics">
      <xsl:attribute name="dir">
        <xsl:choose>
          <xsl:when test="contains(@rend, 'direction:rtl')">rtl</xsl:when>
          <xsl:otherwise>ltr</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="head">
        <h3 class="cmo-tei-lyrics-head" lang="ota">
          <xsl:apply-templates select="head/node()" />
        </h3>
      </xsl:if>
      <xsl:apply-templates select="lg" />
    </div>
  </xsl:template>

  <xsl:template match="lg">
    <div class="cmo-tei-lg">
      <xsl:if test="@rhyme">
        <span class="cmo-tei-rhyme" title="{cmo:l('Reimschema', 'Rhyme scheme', 'Kafiye düzeni')}">
          <xsl:value-of select="@rhyme" />
        </span>
      </xsl:if>
      <xsl:apply-templates select="l" />
    </div>
  </xsl:template>

  <xsl:template match="l">
    <p class="cmo-tei-line" lang="ota">
      <span class="cmo-tei-line-no">
        <xsl:value-of select="@n" />
      </span>
      <span class="cmo-tei-line-text">
        <xsl:apply-templates select="node()" />
      </span>
    </p>
  </xsl:template>

  <xsl:template match="seg">
    <!-- map the (possibly non ASCII) @ana value to a safe css class suffix -->
    <xsl:variable name="kind" as="xs:string">
      <xsl:choose>
        <xsl:when test="@ana = 'mainPartLyrics'">main</xsl:when>
        <xsl:when test="@ana = 'terennüm'">terennum</xsl:when>
        <xsl:when test="@ana = 'instruction'">instruction</xsl:when>
        <xsl:otherwise>other</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <span class="cmo-tei-seg cmo-tei-seg-{$kind}">
      <xsl:apply-templates select="node()" />
    </span>
  </xsl:template>

  <!-- stage directions (mükerrer, miyānḫāne, ...) are shown as small inline badges -->
  <xsl:template match="stage">
    <span class="cmo-tei-stage cmo-tei-stage-{(@type, 'other')[1]}">
      <xsl:apply-templates select="node()" />
    </span>
  </xsl:template>

  <!-- ======================== apparatus ============================ -->

  <xsl:template name="apparatus">
    <xsl:variable name="readings" select="/TEI/text/back/div[@type = 'readings']/app" />
    <xsl:variable name="provenance" select="/TEI/text/back/div[@type = 'provenance']/app" />
    <xsl:if test="$provenance">
      <div class="cmo-tei-apparatus">
        <h3 class="cmo-tei-section-heading">
          <xsl:value-of select="cmo:l('Überlieferung', 'Transmission', 'Aktarım')" />
        </h3>
        <xsl:for-each select="$provenance">
          <p class="cmo-tei-app-note">
            <span class="cmo-tei-lemma" lang="ota">
              <xsl:value-of select="lem" />
            </span>
            <xsl:apply-templates select="note/node()" />
          </p>
        </xsl:for-each>
      </div>
    </xsl:if>
    <xsl:if test="$readings">
      <div class="cmo-tei-apparatus">
        <h3 class="cmo-tei-section-heading">
          <xsl:value-of select="cmo:l('Lesarten', 'Variant readings', 'Nüsha farkları')" />
        </h3>
        <dl class="cmo-tei-readings">
          <xsl:for-each select="$readings">
            <dt class="cmo-tei-lemma" lang="ota">
              <xsl:value-of select="lem" />
            </dt>
            <xsl:for-each select="rdg">
              <dd class="cmo-tei-rdg" lang="ota">
                <xsl:apply-templates select="node()" />
              </dd>
            </xsl:for-each>
          </xsl:for-each>
        </dl>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- final per-piece notes (e.g. lyricist attribution) -->
  <xsl:template match="note[@type = 'lyricist']" mode="pieceNote">
    <p class="cmo-tei-piece-note" lang="ota">
      <xsl:apply-templates select="node()" />
    </p>
  </xsl:template>

  <!-- ==================== inline element handling =================== -->

  <!-- editorial addition -->
  <xsl:template match="supplied">
    <span class="cmo-tei-supplied" title="{cmo:l('Ergänzung des Herausgebers', 'Editorial addition', 'Editör eklemesi')}">
      <xsl:apply-templates select="node()" />
    </span>
  </xsl:template>

  <!-- references: keep the text, they are cross document anchors -->
  <xsl:template match="ref">
    <span class="cmo-tei-ref">
      <xsl:apply-templates select="node()" />
    </span>
  </xsl:template>

  <!-- witness sigla on a variant reading -->
  <xsl:template match="rdg/@wit">
    <!-- handled implicitly, see rdg text; no output here -->
  </xsl:template>

  <!-- anchors only mark word boundaries for the apparatus, drop them -->
  <xsl:template match="anchor" />

  <!-- swallow milestones inside the rendered blocks -->
  <xsl:template match="milestone" />

</xsl:stylesheet>
