<?xml version="1.0" encoding="UTF-8"?>
<!--
  Renders a CMO TEI text edition (edition_tei derivate) into a self-contained HTML
  fragment. The fragment is loaded lazily into the edition tab of the object page via
  the MCRDerivateContentTransformerServlet (see layout/viewer.xsl).

  This stylesheet is XSLT 3.0 and is executed with Saxon (see the TEI-cmoedition
  content transformer in mycore.properties). Because the output method is "html" the
  layout template is not applied and a bare fragment is produced.

  Standard MyCoRe includes:
    * resource:xslt/default-parameters.xsl -> the common parameters (WebApplicationBaseURL,
      CurrentLang, ServletsBaseURL, ...)
    * xslInclude:functions                 -> the mcr* xsl functions, most importantly
      mcri18n:translate for the i18n message lookup

  The rendering surfaces the semantically relevant regions of the TEI document:
    * titleStmt/title (with all children) -> edition metadata shown before the text
    * seriesStmt              -> the editors, resolved from the @resp / @corresp ids
    * sourceDesc/listWit      -> the sources behind the sigla, each linked to its object
    * encodingDesc/metDecl    -> metrical structure, shown as tooltips on the verses
    * text/body div lyrics    -> the actual edited text with hoverable annotation spans
    * text/back               -> the critical apparatus (provenance, readings, notes)

  Cross references to other CMO objects (#cmo_source_..., #cmo_mods_...,
  #cmo_expression_...) are turned into links to the object page, external targets
  become real links.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:cmo="http://www.corpus-musicae-ottomanicae.de/ns/tei"
                xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0"
                exclude-result-prefixes="#all"
                version="3.0">

  <xsl:output method="html" indent="no" omit-xml-declaration="yes" />

  <!--
    default-parameters.xsl provides WebApplicationBaseURL / CurrentLang / ServletsBaseURL,
    functions/i18n.xsl provides mcri18n:translate. Both are referenced by their real
    classpath location (xslt/): the xslInclude:functions alias cannot be used here because
    CMO sets MCR.Layout.Transformer.Factory.XSLFolder=xsl, so it would look the mcr
    functions up under the (non existing) xsl/functions/ instead of xslt/functions/.
  -->
  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="resource:xslt/functions/i18n.xsl" />

  <xsl:variable name="root" select="/" />
  <xsl:variable name="header" select="/TEI/teiHeader" />
  <xsl:variable name="titleStmt" select="$header/fileDesc/titleStmt" />

  <!-- resolves any element carrying an xml:id (editors, witnesses, metrical symbols) -->
  <xsl:key name="byId" match="*[@xml:id]" use="@xml:id" />

  <!-- true if the (possibly '#' prefixed) string is a CMO object identifier -->
  <xsl:function name="cmo:isObjectId" as="xs:boolean">
    <xsl:param name="s" as="xs:string?" />
    <xsl:sequence select="matches(replace(string($s), '^#', ''), '^cmo_[a-z]+_\d+$')" />
  </xsl:function>

  <!-- classifies a link target so ref/persName can render the right kind of link -->
  <xsl:function name="cmo:linkKind" as="xs:string">
    <xsl:param name="target" as="xs:string?" />
    <xsl:variable name="t" select="normalize-space(string($target))" />
    <xsl:sequence select="if ($t = '') then 'none'
                          else if (cmo:isObjectId($t)) then 'object'
                          else if (starts-with($t, 'http') or starts-with($t, 'mailto:')) then 'external'
                          else if (starts-with($t, '#')) then 'anchor'
                          else 'external'" />
  </xsl:function>

  <!-- builds the href for a link target (object page url or the target unchanged) -->
  <xsl:function name="cmo:href" as="xs:string">
    <xsl:param name="target" as="xs:string?" />
    <xsl:variable name="t" select="normalize-space(string($target))" />
    <xsl:sequence select="if (cmo:isObjectId($t))
                          then concat($WebApplicationBaseURL, 'receive/', replace($t, '^#', ''))
                          else $t" />
  </xsl:function>

  <!-- resolves an id reference (e.g. #ND) to the readable name of the editor / person -->
  <xsl:function name="cmo:resolveName" as="xs:string?">
    <xsl:param name="ref" as="xs:string?" />
    <xsl:variable name="el" select="key('byId', replace(normalize-space(string($ref)), '^#', ''), $root)[1]" />
    <xsl:sequence select="if (empty($el)) then ()
                          else if ($el/persName) then normalize-space($el/persName[1])
                          else if ($el/orgName) then normalize-space($el/orgName[1])
                          else if ($el/name/persName) then normalize-space($el/name[1]/persName[1])
                          else normalize-space($el)" />
  </xsl:function>

  <!-- resolves one or more metrical references (e.g. '#hezec1') to 'value (pattern)' -->
  <xsl:function name="cmo:resolveMet" as="xs:string?">
    <xsl:param name="refs" as="xs:string?" />
    <xsl:variable name="parts" as="xs:string*">
      <xsl:for-each select="tokenize(normalize-space(string($refs)), '\s+')[. != '']">
        <xsl:variable name="el" select="key('byId', replace(., '^#', ''), $root)[1]" />
        <xsl:if test="$el/self::metSym or $el/self::metDecl">
          <xsl:variable name="val" select="normalize-space(string($el/@value))" />
          <xsl:variable name="txt" select="normalize-space($el)" />
          <xsl:sequence select="if ($val != '' and $txt != '' and $txt != $val)
                                then concat($val, ' (', $txt, ')')
                                else if ($val != '') then $val
                                else $txt" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:sequence select="if (exists($parts)) then string-join($parts, ' / ') else ()" />
  </xsl:function>

  <!-- the annotation id shared by a body span and its apparatus entries -->
  <xsl:function name="cmo:annoId" as="xs:string">
    <xsl:param name="ref" as="xs:string?" />
    <xsl:sequence select="replace(replace(normalize-space(string($ref)), '^#', ''), '[se]$', '')" />
  </xsl:function>

  <xsl:function name="cmo:appId" as="xs:string">
    <xsl:param name="ref" as="xs:string?" />
    <xsl:param name="kind" as="xs:string" />
    <xsl:sequence select="concat('cmo-app-', $kind, '-', cmo:annoId($ref))" />
  </xsl:function>

  <!-- translates a message key, falling back to the given text when the key is unknown -->
  <xsl:function name="cmo:i18n" as="xs:string">
    <xsl:param name="key" as="xs:string" />
    <xsl:param name="fallback" as="xs:string" />
    <xsl:variable name="t" select="mcri18n:translate($key)" />
    <xsl:sequence select="if ($t = '' or starts-with($t, '???')) then $fallback else $t" />
  </xsl:function>

  <!-- resolves a witness reference (#cmo_source_...) to its CMO siglum via the listWit -->
  <xsl:function name="cmo:witSiglum" as="xs:string">
    <xsl:param name="ref" as="xs:string" />
    <xsl:variable name="id" select="replace(normalize-space($ref), '^#', '')" />
    <xsl:variable name="wit" select="key('byId', $id, $root)[self::witness][1]" />
    <xsl:variable name="siglum" select="normalize-space($wit/idno[@type = 'CMO'][1])" />
    <xsl:sequence select="if ($siglum != '') then $siglum else $id" />
  </xsl:function>

  <!-- ============================ root ============================ -->

  <xsl:template match="/TEI">
    <div class="cmo-tei-edition">
      <xsl:call-template name="editionHeader" />
      <xsl:apply-templates select="text/body/div[@type = 'newPieceStart']" />
      <xsl:apply-templates select="text/body/div[@type = ('blockLyricsTranscription', 'blockLyricsReconstructed')]" />
      <xsl:apply-templates select="text/body//note[@type = 'lyricist']" mode="pieceNote" />
      <xsl:call-template name="apparatus" />
      <xsl:call-template name="witnessList" />
      <xsl:call-template name="editionFooter" />
    </div>
  </xsl:template>

  <!-- ============================ header ============================ -->

  <xsl:template name="editionHeader">
    <xsl:variable name="titleWrap" select="$titleStmt/title[1]" />
    <div class="cmo-tei-header">
      <dl class="cmo-tei-meta">
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.meta.makam')" />
          <xsl:with-param name="nodes" select="$titleWrap/note[@type = 'makamTranscription']/node()" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.meta.usul')" />
          <xsl:with-param name="nodes" select="$titleWrap/note[@type = 'usulTranscription']/node()" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.meta.musicGenre')" />
          <xsl:with-param name="nodes" select="$titleWrap/note[@type = 'genreTranscription']" />
          <xsl:with-param name="separator" select="', '" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.meta.textGenre')" />
          <xsl:with-param name="nodes" select="$titleWrap/note[@type = 'poeticGenre']" />
          <xsl:with-param name="separator" select="', '" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.meta.textForm')" />
          <xsl:with-param name="nodes" select="$titleWrap/note[@type = 'poeticForm']" />
          <xsl:with-param name="separator" select="', '" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.meta.bahir')" />
          <xsl:with-param name="nodes" select="$titleWrap/note[@type = 'bahir']/node()" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.meta.metre')" />
          <xsl:with-param name="nodes" select="$titleWrap/note[@type = 'meter']/node()" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.meta.lyricist')" />
          <xsl:with-param name="nodes" select="$titleStmt/author[@role = 'lyricist']/persName" />
        </xsl:call-template>
        <xsl:call-template name="editorsRow" />
      </dl>
    </div>
  </xsl:template>

  <!-- lists the editors, resolving the seriesStmt name behind each @corresp as tooltip -->
  <xsl:template name="editorsRow">
    <xsl:if test="$titleStmt/editor">
      <dt>
        <xsl:value-of select="mcri18n:translate('cmo.tei.meta.editors')" />
      </dt>
      <dd>
        <xsl:for-each select="$titleStmt/editor">
          <xsl:if test="position() &gt; 1">
            <xsl:text> · </xsl:text>
          </xsl:if>
          <xsl:variable name="resolved" select="cmo:resolveName(@corresp)" />
          <xsl:variable name="roleLabel"
                        select="if (@role != '')
                                then cmo:i18n(concat('cmo.tei.role.', lower-case(@role)), @role)
                                else ''" />
          <span class="cmo-tei-editor">
            <xsl:if test="$roleLabel != '' or $resolved">
              <xsl:attribute name="tabindex">0</xsl:attribute>
              <xsl:attribute name="role">button</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="normalize-space(.)" />
            <xsl:if test="$roleLabel != '' or $resolved">
              <span class="cmo-tei-pop-src" hidden="hidden">
                <xsl:if test="$roleLabel != ''">
                  <span class="cmo-tei-pop-head">
                    <xsl:value-of select="$roleLabel" />
                  </span>
                </xsl:if>
                <xsl:if test="$resolved">
                  <span class="cmo-tei-pop-body">
                    <xsl:value-of select="$resolved" />
                  </span>
                </xsl:if>
              </span>
            </xsl:if>
          </span>
        </xsl:for-each>
      </dd>
    </xsl:if>
  </xsl:template>

  <!-- renders one term/definition pair, but only if the value carries content -->
  <xsl:template name="metaRow">
    <xsl:param name="label" as="xs:string" />
    <xsl:param name="nodes" as="node()*" />
    <xsl:param name="separator" as="xs:string" select="''" />
    <xsl:if test="normalize-space(string-join($nodes ! string(.), '')) != ''">
      <dt>
        <xsl:value-of select="$label" />
      </dt>
      <dd lang="ota">
        <xsl:for-each select="$nodes">
          <xsl:if test="position() &gt; 1 and $separator != ''">
            <xsl:value-of select="$separator" />
          </xsl:if>
          <xsl:apply-templates select="if ($separator != '') then node() else ." mode="inline" />
        </xsl:for-each>
      </dd>
    </xsl:if>
  </xsl:template>

  <!-- ======================= source / piece ======================= -->

  <xsl:template match="div[@type = 'newPieceStart']">
    <xsl:variable name="item" select="msDesc/msContents/msItem" />
    <div class="cmo-tei-source">
      <h3 class="cmo-tei-section-heading">
        <xsl:value-of select="mcri18n:translate('cmo.tei.source')" />
      </h3>
      <dl class="cmo-tei-meta">
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.source.manuscript')" />
          <xsl:with-param name="nodes" select="msDesc/msIdentifier/idno/node()" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.source.pieceNumber')" />
          <xsl:with-param name="nodes" select="$item/rubric[@type = 'pieceNumber']/node()" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.source.folio')" />
          <xsl:with-param name="nodes" select="$item/locus/node()" />
        </xsl:call-template>
        <xsl:call-template name="metaRow">
          <xsl:with-param name="label" select="mcri18n:translate('cmo.tei.source.incipit')" />
          <xsl:with-param name="nodes" select="$item/incipit/node()" />
        </xsl:call-template>
      </dl>
    </div>
  </xsl:template>

  <!-- ========================== lyrics ============================= -->

  <xsl:template match="div[@type = ('blockLyricsTranscription', 'blockLyricsReconstructed')]">
    <div class="cmo-tei-lyrics">
      <xsl:if test="@type = 'blockLyricsReconstructed'">
        <xsl:attribute name="class">cmo-tei-lyrics cmo-tei-lyrics-reconstructed</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="dir">
        <xsl:choose>
          <xsl:when test="contains(@rend, 'direction:rtl')">rtl</xsl:when>
          <xsl:otherwise>ltr</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="@type = 'blockLyricsReconstructed'">
        <p class="cmo-tei-lyrics-tag">
          <xsl:value-of select="mcri18n:translate('cmo.tei.lyrics.reconstructed')" />
        </p>
      </xsl:if>
      <xsl:if test="head">
        <h3 class="cmo-tei-lyrics-head" lang="ota">
          <xsl:for-each select="head">
            <xsl:call-template name="flow" />
          </xsl:for-each>
        </h3>
      </xsl:if>
      <xsl:apply-templates select="lg" />
    </div>
  </xsl:template>

  <xsl:template match="lg">
    <xsl:variable name="met" select="cmo:resolveMet(@decls)" />
    <div class="cmo-tei-lg">
      <xsl:if test="@rhyme or $met">
        <div class="cmo-tei-lg-info">
          <xsl:if test="@rhyme">
            <span class="cmo-tei-rhyme">
              <span class="cmo-tei-info-label">
                <xsl:value-of select="mcri18n:translate('cmo.tei.rhyme')" />
              </span>
              <span class="cmo-tei-info-value">
                <xsl:value-of select="@rhyme" />
              </span>
            </span>
          </xsl:if>
          <xsl:if test="$met">
            <span class="cmo-tei-met">
              <span class="cmo-tei-info-label">
                <xsl:value-of select="mcri18n:translate('cmo.tei.metre')" />
              </span>
              <span class="cmo-tei-info-value">
                <xsl:value-of select="$met" />
              </span>
            </span>
          </xsl:if>
        </div>
      </xsl:if>
      <xsl:apply-templates select="l" />
    </div>
  </xsl:template>

  <xsl:template match="l">
    <p class="cmo-tei-line" lang="ota">
      <span class="cmo-tei-line-no">
        <xsl:if test="@n[number(.) mod 2 = 0]">
          <xsl:value-of select="@n" />
        </xsl:if>
      </span>
      <span class="cmo-tei-line-body">
        <span class="cmo-tei-line-text">
          <xsl:call-template name="flow" />
        </span>
        <xsl:if test="@real">
          <span class="cmo-tei-meter" tabindex="0" role="button">
            <span class="cmo-tei-pop-src" hidden="hidden">
              <span class="cmo-tei-pop-head">
                <xsl:value-of select="mcri18n:translate('cmo.tei.meta.metre')" />
              </span>
              <span class="cmo-tei-pop-body">
                <code class="cmo-tei-mono">
                  <xsl:value-of select="@real" />
                </code>
              </span>
            </span>
          </span>
        </xsl:if>
      </span>
    </p>
  </xsl:template>

  <!-- final per-piece notes (e.g. lyricist attribution) -->
  <xsl:template match="note[@type = 'lyricist']" mode="pieceNote">
    <p class="cmo-tei-piece-note" lang="ota">
      <xsl:call-template name="flow" />
    </p>
  </xsl:template>

  <!-- ======================== apparatus ============================ -->

  <xsl:template name="apparatus">
    <xsl:variable name="provenance" select="/TEI/text/back/div[@type = 'provenance']/app" />
    <xsl:variable name="readings" select="/TEI/text/back/div[@type = 'readings']/app" />
    <xsl:variable name="annotations" select="/TEI/text/back/div[@type = 'annotations']/app" />
    <xsl:if test="$provenance or $readings or $annotations">
      <div class="cmo-tei-apparatus">
        <h3 class="cmo-tei-section-heading">
          <xsl:value-of select="mcri18n:translate('cmo.tei.apparatus')" />
        </h3>
        <xsl:if test="$provenance">
          <div class="cmo-tei-app-group">
            <h4 class="cmo-tei-app-heading">
              <xsl:value-of select="mcri18n:translate('cmo.tei.apparatus.provenance')" />
            </h4>
            <xsl:for-each select="$provenance">
              <div class="cmo-tei-app-entry" data-anno="{cmo:annoId(@from)}" id="{cmo:appId(@from, 'prov')}">
                <span class="cmo-tei-lemma" lang="ota">
                  <xsl:value-of select="lem" />
                </span>
                <span class="cmo-tei-app-note">
                  <xsl:for-each select="note">
                    <xsl:call-template name="flow" />
                  </xsl:for-each>
                </span>
              </div>
            </xsl:for-each>
          </div>
        </xsl:if>
        <xsl:if test="$readings">
          <div class="cmo-tei-app-group">
            <h4 class="cmo-tei-app-heading">
              <xsl:value-of select="mcri18n:translate('cmo.tei.apparatus.readings')" />
            </h4>
            <dl class="cmo-tei-readings">
              <xsl:for-each select="$readings">
                <div class="cmo-tei-app-entry" data-anno="{cmo:annoId(@from)}" id="{cmo:appId(@from, 'rdg')}">
                  <dt class="cmo-tei-lemma" lang="ota">
                    <xsl:value-of select="lem" />
                  </dt>
                  <xsl:for-each select="rdg">
                    <xsl:variable name="hasPop" select="@type or normalize-space(@wit) != ''" />
                    <dd class="cmo-tei-rdg" lang="ota">
                      <xsl:if test="$hasPop">
                        <xsl:attribute name="tabindex">0</xsl:attribute>
                        <xsl:attribute name="role">button</xsl:attribute>
                      </xsl:if>
                      <xsl:call-template name="flow" />
                      <xsl:if test="$hasPop">
                        <span class="cmo-tei-pop-src" hidden="hidden">
                          <span class="cmo-tei-pop-head">
                            <xsl:value-of select="mcri18n:translate('cmo.tei.apparatus.readings')" />
                          </span>
                          <span class="cmo-tei-pop-body">
                            <xsl:if test="@type">
                              <xsl:value-of select="cmo:i18n(concat('cmo.tei.reading.', @type), @type)" />
                            </xsl:if>
                            <xsl:if test="normalize-space(@wit) != ''">
                              <span class="cmo-tei-pop-sub">
                                <xsl:value-of select="mcri18n:translate('cmo.tei.reading.witnesses')" />
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="string-join(
                                    for $w in tokenize(normalize-space(@wit), '\s+')[. != '']
                                    return cmo:witSiglum($w), ' &#183; ')" />
                              </span>
                            </xsl:if>
                          </span>
                        </span>
                      </xsl:if>
                    </dd>
                  </xsl:for-each>
                </div>
              </xsl:for-each>
            </dl>
          </div>
        </xsl:if>
        <xsl:if test="$annotations">
          <div class="cmo-tei-app-group">
            <h4 class="cmo-tei-app-heading">
              <xsl:value-of select="mcri18n:translate('cmo.tei.apparatus.annotations')" />
            </h4>
            <xsl:for-each select="$annotations">
              <div class="cmo-tei-app-entry" data-anno="{cmo:annoId(@from)}" id="{cmo:appId(@from, 'anno')}">
                <span class="cmo-tei-lemma" lang="ota">
                  <xsl:value-of select="lem" />
                </span>
                <span class="cmo-tei-app-note">
                  <xsl:for-each select="note">
                    <xsl:call-template name="flow" />
                  </xsl:for-each>
                </span>
              </div>
            </xsl:for-each>
          </div>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ====================== witness / sigla ======================= -->

  <xsl:template name="witnessList">
    <xsl:variable name="witnesses" select="$header/fileDesc/sourceDesc/listWit/witness" />
    <xsl:if test="$witnesses">
      <div class="cmo-tei-witnesses">
        <h3 class="cmo-tei-section-heading">
          <xsl:value-of select="mcri18n:translate('cmo.tei.witnesses')" />
        </h3>
        <dl class="cmo-tei-witness-list">
          <xsl:for-each select="$witnesses">
            <xsl:variable name="siglum" select="normalize-space(idno[@type = 'CMO'][1])" />
            <xsl:variable name="msId" select="msDesc/msIdentifier" />
            <xsl:variable name="catalogUri" select="biblFull//sourceDesc/bibl/ref[@type = 'uri'][1]" />
            <dt class="cmo-tei-siglum" id="cmo-wit-{@xml:id}">
              <xsl:choose>
                <xsl:when test="cmo:isObjectId(@xml:id)">
                  <a class="cmo-tei-ref cmo-tei-ref-object" href="{cmo:href(@xml:id)}">
                    <xsl:value-of select="if ($siglum != '') then $siglum else @xml:id" />
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="if ($siglum != '') then $siglum else @xml:id" />
                </xsl:otherwise>
              </xsl:choose>
            </dt>
            <dd class="cmo-tei-witness-desc">
              <xsl:variable name="titleDesc"
                            select="normalize-space(biblFull//titleStmt/title[@type = ('desc', 'alt')][1])" />
              <xsl:if test="$titleDesc != ''">
                <span class="cmo-tei-witness-title" lang="ota">
                  <xsl:value-of select="$titleDesc" />
                </span>
                <xsl:text> </xsl:text>
              </xsl:if>
              <span class="cmo-tei-witness-loc">
                <xsl:value-of select="normalize-space(string-join(
                    ($msId/repository, $msId/settlement, $msId/country, $msId/idno) ! normalize-space(.),
                    ', '))" />
              </span>
              <xsl:if test="$catalogUri">
                <xsl:text> </xsl:text>
                <a class="cmo-tei-ref cmo-tei-ref-ext" href="{normalize-space($catalogUri)}"
                   target="_blank" rel="noopener noreferrer">
                  <span class="fas fa-external-link-alt"></span>
                  <span class="cmo-tei-pop-src" hidden="hidden">
                    <span class="cmo-tei-pop-body">
                      <xsl:value-of select="mcri18n:translate('cmo.tei.witnesses.catalogue')" />
                    </span>
                  </span>
                </a>
              </xsl:if>
            </dd>
          </xsl:for-each>
        </dl>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ========================== footer ============================ -->

  <xsl:template name="editionFooter">
    <xsl:variable name="pub" select="$header/fileDesc/publicationStmt" />
    <xsl:variable name="ed" select="$header/fileDesc/editionStmt/edition" />
    <xsl:if test="$pub or $ed">
      <div class="cmo-tei-edition-info">
        <xsl:if test="$ed">
          <span class="cmo-tei-edition-part">
            <xsl:value-of select="normalize-space($ed)" />
          </span>
        </xsl:if>
        <xsl:if test="$pub/publisher">
          <span class="cmo-tei-edition-part">
            <xsl:value-of select="normalize-space($pub/publisher)" />
            <xsl:if test="$pub/date">
              <xsl:value-of select="concat(', ', normalize-space($pub/date))" />
            </xsl:if>
          </span>
        </xsl:if>
        <xsl:if test="$pub/availability/licence">
          <span class="cmo-tei-edition-part">
            <a class="cmo-tei-ref cmo-tei-ref-ext" href="{normalize-space($pub/availability/licence/@target)}"
               target="_blank" rel="noopener noreferrer">
              <xsl:value-of select="normalize-space($pub/availability/licence)" />
            </a>
          </span>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <!-- ============== inline flow content with annotations ============== -->

  <!--
    Renders the mixed content of the context node. Runs delimited by a pair of
    anchors (<anchor xml:id="wNNNs"/> ... <anchor xml:id="wNNNe"/>) are wrapped into a
    hoverable annotation span whose data-anno matches the critical apparatus entries.
  -->
  <xsl:template name="flow">
    <xsl:for-each-group select="node()" group-starting-with="anchor[matches(@xml:id, 's$')]">
      <xsl:choose>
        <xsl:when test="self::anchor[matches(@xml:id, 's$')]">
          <xsl:variable name="aid" select="replace(@xml:id, 's$', '')" />
          <xsl:variable name="grp" select="current-group()" />
          <xsl:variable name="end" select="($grp[self::anchor[@xml:id = concat($aid, 'e')]])[1]" />
          <span class="cmo-tei-anno" data-anno="{$aid}" tabindex="0">
            <xsl:apply-templates mode="inline"
              select="$grp[not(self::anchor)][if (exists($end)) then (. &lt;&lt; $end) else true()]" />
          </span>
          <xsl:if test="exists($end)">
            <xsl:apply-templates mode="inline" select="$grp[not(self::anchor)][. &gt;&gt; $end]" />
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="inline" select="current-group()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="text()" mode="inline">
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="seg" mode="inline">
    <xsl:variable name="kind" as="xs:string">
      <xsl:choose>
        <xsl:when test="@ana = 'mainPartLyrics'">main</xsl:when>
        <xsl:when test="@ana = 'terennüm'">terennum</xsl:when>
        <xsl:when test="@ana = 'instruction'">instruction</xsl:when>
        <xsl:otherwise>other</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <span class="cmo-tei-seg cmo-tei-seg-{$kind}">
      <xsl:call-template name="flow" />
    </span>
  </xsl:template>

  <!-- stage directions (mükerrer, miyānḫāne, ...) shown as small inline badges -->
  <xsl:template match="stage" mode="inline">
    <span class="cmo-tei-stage cmo-tei-stage-{(@type, 'other')[1]}">
      <xsl:call-template name="flow" />
    </span>
  </xsl:template>

  <!--
    Editorial addition: the supplied text is wrapped in square brackets ([...]) and a popup
    names the reason (@reason) and the responsible editor (@resp), both resolved to readable text.
  -->
  <xsl:template match="supplied" mode="inline">
    <xsl:variable name="who" select="cmo:resolveName(@resp)" />
    <span class="cmo-tei-supplied" tabindex="0" role="button">
      <span class="cmo-tei-supplied-bracket">[</span>
      <xsl:call-template name="flow" />
      <span class="cmo-tei-supplied-bracket">]</span>
      <span class="cmo-tei-pop-src" hidden="hidden">
        <span class="cmo-tei-pop-head">
          <xsl:value-of select="mcri18n:translate('cmo.tei.supplied')" />
        </span>
        <span class="cmo-tei-pop-body">
          <xsl:if test="@reason != ''">
            <xsl:value-of select="cmo:i18n(concat('cmo.tei.supplied.reason.', @reason), @reason)" />
          </xsl:if>
          <xsl:if test="$who">
            <span class="cmo-tei-pop-sub">
              <xsl:value-of select="$who" />
            </span>
          </xsl:if>
        </span>
      </span>
    </span>
  </xsl:template>

  <!--
    References become links: to the object page, to an external site, or plain. In the
    apparatus the sigla refs are glued to the preceding word in the source, so a space
    is inserted when the previous text sibling does not already end in whitespace.
  -->
  <xsl:template match="ref" mode="inline">
    <xsl:variable name="prev" select="preceding-sibling::node()[1]" />
    <xsl:if test="$prev/self::text() and normalize-space($prev) != '' and not(matches($prev, '\s$'))">
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:variable name="kind" select="cmo:linkKind(@target)" />
    <xsl:choose>
      <xsl:when test="$kind = 'object'">
        <a class="cmo-tei-ref cmo-tei-ref-object" href="{cmo:href(@target)}">
          <xsl:call-template name="flow" />
        </a>
      </xsl:when>
      <xsl:when test="$kind = 'external'">
        <a class="cmo-tei-ref cmo-tei-ref-ext" href="{normalize-space(@target)}"
           target="_blank" rel="noopener noreferrer">
          <xsl:call-template name="flow" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="cmo-tei-ref">
          <xsl:call-template name="flow" />
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="persName" mode="inline">
    <xsl:choose>
      <xsl:when test="cmo:linkKind(@ref) = 'external'">
        <a class="cmo-tei-ref cmo-tei-ref-ext" href="{normalize-space(@ref)}"
           target="_blank" rel="noopener noreferrer">
          <xsl:call-template name="flow" />
        </a>
      </xsl:when>
      <xsl:otherwise>
        <span class="cmo-tei-persname">
          <xsl:call-template name="flow" />
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- emphasis / rendered inline markup -->
  <xsl:template match="hi" mode="inline">
    <span class="cmo-tei-hi">
      <xsl:call-template name="flow" />
    </span>
  </xsl:template>

  <!-- stray anchors and milestones carry no visible text -->
  <xsl:template match="anchor | milestone" mode="inline" />

  <!-- fallback: keep the text of any other inline element -->
  <xsl:template match="*" mode="inline">
    <xsl:call-template name="flow" />
  </xsl:template>

</xsl:stylesheet>
