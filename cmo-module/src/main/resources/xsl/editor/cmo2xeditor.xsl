<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:cmo="http://cmo.gbv.de/cmo"
  xmlns:exslt="http://exslt.org/common"
  exclude-result-prefixes="xsl cmo i18n exslt">

  <xsl:include href="copynodes.xsl" />
  <xsl:include href="coreFunctions.xsl" />

  <xsl:template match="cmo:textfield.nobind">
    <div class="form-group">
      <div class="row">
        <label class="col-md-4 col-form-label">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6 {@divClass}">
          <input id="{@id}" type="text" class="form-control {@inputClass}" name="">
            <xsl:copy-of select="@placeholder" />
            <xsl:copy-of select="@autocomplete" />
          </input>
        </div>
        <div class="col-md-2">
          <xsl:if test="string-length(@help-text) &gt; 0">
            <xsl:call-template name="cmo-helpbutton" />
          </xsl:if>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cmo:textfield">
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <xsl:variable name="xed-val-marker">{$xed-validation-marker}</xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">

            <xsl:choose>
              <xsl:when test="@bind">
                <xed:bind xpath="{@bind}">
                  <xsl:call-template name="cmo-textfield" />
                </xed:bind>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="cmo-textfield" />
              </xsl:otherwise>
            </xsl:choose>
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <xsl:variable name="xed-val-marker">{$xed-validation-marker}</xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">
            <xsl:call-template name="cmo-textfield" />
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cmo:subselectWrapper">
    <div data-subselect="{@query}">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <xsl:template match="cmo:subselectTrigger">
    <a tabindex="0" class="btn btn-light info-button" role="button"
       title="{i18n:translate('cmo.help.search')}" data-subselect-trigger="">
      <i class="fas fa-search"></i>
    </a>
  </xsl:template>

  <!--
   cmo:mixedContent
   label="editor.label.annot"
   help-text="{i18n:cmo.help.annot}"
   query='(category.top:"cmo_kindOfData:source" OR cmoType:person) AND objectType:source'
   repeat-buttons="true"
   type="cmo_annotType"
   xpath="."
   />
  -->
  <xsl:template match="cmo:mixedContent">
    <div class="form-group" data-insert-subselect='{@query}'>
      <div class="row">
        <label class="col-md-4 col-form-label form-inline">
          <xed:output i18n="{@label}"/>
          <xsl:if test="@type">
            <xed:text>&#160;</xed:text>
            <xed:bind xpath="@type">
              <select class="form-control">
                <xed:include uri="xslStyle:items2options:classification:editor:1:children:{@type}"/>
              </select>
            </xed:bind>
          </xsl:if>
        </label>
        <div class="col-md-6">
          <xed:bind xpath="{@xpath}">
            <input type="text" data-subselect-target="id"/>
          </xed:bind>
        </div>
        <div class="col-md-2">
          <span class="pmud-button" data-subselect-trigger="true">
            <a tabindex="0" class="btn btn-light info-button" role="button" data-toggle="popover"
               data-placement="right">
              <i class="fas fa-search"></i>
            </a>
          </span>
          <xsl:if test="@repeat-buttons = 'true'">
            <span class="pmud-button">
              <xed:controls>insert</xed:controls>
            </span>
            <span class="pmud-button">
              <xed:controls>remove</xed:controls>
            </span>
            <span class="pmud-button">
              <xed:controls>up</xed:controls>
            </span>
            <span class="pmud-button">
              <xed:controls>down</xed:controls>
            </span>
          </xsl:if>
          <span class="pmud-button">
            <a tabindex="0" class="btn btn-light info-button" role="button" data-toggle="popover"
               data-placement="right"
               data-content="{@help-text}">
              <i class="fas fa-info"></i>
            </a>
          </span>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cmo:textarea">
    <xsl:variable name="xed-val-marker">{$xed-validation-marker}</xsl:variable>
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <div class="form-group {@class} {$xed-val-marker}">
            <div class="row">
              <xsl:choose>
                <xsl:when test="@bind">
                  <xed:bind xpath="{@bind}">
                    <label class="col-md-4 col-form-label form-inline">
                      <xed:output i18n="{@label}" />
                      <xsl:if test="@type">
                        <xsl:text>&#160;</xsl:text>
                        <xed:bind xpath="@type">
                          <select class="form-control">
                            <xed:include uri="xslStyle:items2options:classification:editor:1:children:{@type}" />
                          </select>
                        </xed:bind>
                      </xsl:if>
                    </label>
                    <div class="col-md-6">
                      <textarea class="form-control" data-on-screen-keyboard="true">
                        <xsl:copy-of select="@rows" />
                        <xsl:copy-of select="@placeholder" />
                      </textarea>
                    </div>
                    <div class="col-md-2">
                      <xsl:if test="string-length(@help-text) &gt; 0">
                        <xsl:call-template name="cmo-helpbutton" />
                      </xsl:if>
                      <xsl:call-template name="cmo-pmud" />
                    </div>
                  </xed:bind>
                </xsl:when>
                <xsl:otherwise>
                  <label class="col-md-4 col-form-label form-inline">
                    <xed:output i18n="{@label}" />
                    <xsl:if test="@type">
                      <xsl:text>&#160;</xsl:text>
                      <xed:bind xpath="@type">
                        <select class="form-control">
                          <xed:include uri="xslStyle:items2options:classification:editor:1:children:{@type}" />
                        </select>
                      </xed:bind>
                    </xsl:if>
                  </label>
                  <div class="col-md-6">
                    <textarea class="form-control" data-on-screen-keyboard="true">
                      <xsl:copy-of select="@rows" />
                      <xsl:copy-of select="@placeholder" />
                    </textarea>
                  </div>
                  <div class="col-md-2">
                    <xsl:if test="string-length(@help-text) &gt; 0">
                      <xsl:call-template name="cmo-helpbutton" />
                    </xsl:if>
                    <xsl:call-template name="cmo-pmud" />
                  </div>
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <div class="form-group {@class} {$xed-val-marker}">
            <div class="row">
              <label class="col-md-4 col-form-label form-inline">
                <xed:output i18n="{@label}" />
                <xsl:if test="@type">
                  <xsl:text>&#160;</xsl:text>
                  <xed:bind xpath="@type">
                    <select class="form-control">
                      <xed:include uri="xslStyle:items2options:classification:editor:1:children:{@type}" />
                    </select>
                  </xed:bind>
                </xsl:if>
              </label>
              <div class="col-md-6">
                <textarea class="form-control" data-on-screen-keyboard="true">
                  <xsl:copy-of select="@rows" />
                  <xsl:copy-of select="@placeholder" />
                </textarea>
              </div>
              <div class="col-md-2">
                <xsl:if test="string-length(@help-text) &gt; 0">
                  <xsl:call-template name="cmo-helpbutton" />
                </xsl:if>
                <xsl:if test="@pmud = 'true'">
                  <xsl:call-template name="cmo-pmud" />
                </xsl:if>
              </div>
            </div>
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cmo:selectClassification">
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <xsl:variable name="xed-val-marker">{$xed-validation-marker}</xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">
            <div class="row">
              <label class="col-md-4 col-form-label">
                <xed:output i18n="{@label}" />
              </label>
              <div class="col-md-6">
                <div class="controls">
                  <xsl:choose>
                    <xsl:when test="@bind">
                      <xed:bind xpath="{@bind}">
                        <select class="form-control form-control-inline">
                          <option value="">
                            <xed:output i18n="editor.select" />
                          </option>
                          <xed:include
                            uri="xslStyle:items2options:classification:editorComplete:-1:children:{@classification}" />
                        </select>
                      </xed:bind>
                    </xsl:when>
                    <xsl:otherwise>
                      <select class="form-control form-control-inline">
                        <option value="">
                          <xed:output i18n="editor.select" />
                        </option>
                        <xed:include
                          uri="xslStyle:items2options:classification:editorComplete:-1:children:{@classification}" />
                      </select>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
              </div>
              <div class="col-md-2">
                <xsl:if test="string-length(@help-text) &gt; 0">
                  <xsl:call-template name="cmo-helpbutton" />
                </xsl:if>
                <xsl:call-template name="cmo-pmud" />
              </div>
              <xsl:call-template name="cmo-required" />
            </div>
          </div>
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <xsl:variable name="xed-val-marker">{$xed-validation-marker}</xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">
            <div class="row">
              <label class="col-md-4 col-form-label">
                <xed:output i18n="{@label}" />
              </label>
              <div class="col-md-6">
                <div class="controls">
                  <select class="form-control form-control-inline">
                    <option value="">
                      <xed:output i18n="editor.select" />
                    </option>
                    <xed:include
                      uri="xslStyle:items2options:classification:editorComplete:-1:children:{@classification}" />
                  </select>
                </div>
              </div>
              <div class="col-md-2">
                <xsl:if test="string-length(@help-text) &gt; 0">
                  <xsl:call-template name="cmo-helpbutton" />
                </xsl:if>
              </div>
              <xsl:call-template name="cmo-required" />
            </div>
          </div>
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cmo:nameLinkField">
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <xed:bind xpath="mei:persName">
            <xsl:variable name="xed-val-marker">{$xed-validation-marker}</xsl:variable>
            <div data-subselect='(category.top:"cmo_kindOfData:source" OR cmoType:person) AND objectType:person'
                 class="form-group {@class} {$xed-val-marker}">
              <div class="row">
                <!-- start -->
                <label class="col-md-4 col-form-label form-inline">
                  <xsl:if test="@label">
                    <xed:output i18n="{@label}" />
                  </xsl:if>
                </label>
                <div class="col-md-6">
                  <input id="{@id}" type="text" data-subselect-target="name" class="form-control">
                    <xsl:copy-of select="@placeholder" />
                  </input>
                </div>
                <div class="col-md-2">
                  <xsl:if test="string-length(@help-text) &gt; 0">
                    <xsl:call-template name="cmo-helpbutton" />
                  </xsl:if>
                  <xsl:call-template name="cmo-pmud" />
                </div>
                <!-- end -->
              </div>
              <div class="row">
                <xed:bind xpath="@nymref">
                  <label class="col-md-4 col-form-label form-inline">
                    <xed:output i18n="editor.label.nameLink" />
                  </label>
                  <div class="col-md-6">
                    <input type="text" class="form-control" data-subselect-target="id"
                           placeholder="cmo_person_00000434" />
                  </div>
                  <div class="col-md-2">
                    <span class="pmud-button">
                      <a tabindex="0" class="btn btn-light info-button" role="button" data-toggle="popover"
                         data-placement="right" data-content="{i18n:translate('cmo.help.nameLink')}">
                        <i class="fas fa-info"></i>
                      </a>
                      <a tabindex="0" class="btn btn-light info-button" role="button"
                         title="{i18n:translate('cmo.help.search')}" data-subselect-trigger="">
                        <i class="fas fa-search"></i>
                    </a>
                    </span>
                  </div>
                </xed:bind>
              </div>
            </div>
          </xed:bind>
          <xsl:call-template name="cmo-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <xed:bind xpath="mei:persName">
            <xsl:variable name="xed-val-marker">{$xed-validation-marker}</xsl:variable>
            <div class="form-group {@class} {$xed-val-marker}">
              <div class="row">
                <xsl:call-template name="cmo-textfield" />
              </div>
            </div>
            <xed:bind xpath="@nymref">
              <div class="row">
                <label class="col-md-4 col-form-label form-inline">
                  <xed:output i18n="editor.label.nameLink" />
                </label>
                <div class="col-md-6">
                  <input type="text" class="form-control" placeholder="cmo_person_00000434" />
                </div>
                <div class="col-md-2">
                  <a tabindex="0" class="btn btn-light info-button" role="button" data-toggle="popover"
                     data-placement="right" data-content="{i18n:translate('cmo.help.nameLink')}">
                    <i class="fas fa-info"></i>
                  </a>
                </div>
              </div>
            </xed:bind>
          </xed:bind>
          <xsl:call-template name="cmo-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cmo:isoApproxDate">
    <xsl:variable name="xed-val-marker">{$xed-validation-marker}</xsl:variable>
    <div class="form-group {@class} {$xed-val-marker}">
      <div class="row">
        <label class="col-md-4 col-form-label">
          <xed:output i18n="{@label}" />
        </label>
        <div class="col-md-6">
          <div class="form-inline" data-toggleDate="true">
            <xed:bind xpath="@range" initially="false" default="false">
              <div class="checkbox">
                <label>
                  <input class="cmo_toggleRange" type="checkbox" value="true" />
                  <xed:output i18n="editor.label.rangeDate" />
                </label>
              </div>
            </xed:bind>
            <xed:bind xpath="@approx" initially="false" default="false">
              <div class="checkbox">
                <label>
                  <input class="cmo_toggleApprox" type="checkbox" value="true" />
                  <xed:output i18n="editor.label.approxDate" />
                </label>
              </div>
            </xed:bind>
            <xed:bind xpath="@isodate">
              <input type="text" placeholder="YYYY-MM-DD" class="cmoIsodate form-control date" />
            </xed:bind>
            <div class="cmoApproxBox input-group form-inline input-daterange" style="display:none;">
              <xed:bind xpath="@notbefore">
                <input type="text" placeholder="YYYY-MM-DD"
                       class="cmo_notbefore form-control cmo_dateInput" />
              </xed:bind>
              <label class="input-group-addon"><xsl:text> - </xsl:text></label>
              <xed:bind xpath="@notafter">
                <input type="text" placeholder="YYYY-MM-DD"
                       class="cmo_notafter form-control cmo_dateInput" />
              </xed:bind>
            </div>
            <div class="cmoRangeBox input-group form-inline input-daterange" style="display:none;">
              <xed:bind xpath="@startdate">
                <input type="text" placeholder="YYYY-MM-DD"
                       class="cmo_startdate form-control cmo_dateInput" />
              </xed:bind>
              <label class="input-group-addon"><xsl:text> - </xsl:text></label>
              <xed:bind xpath="@enddate">
                <input type="text" placeholder="YYYY-MM-DD"
                       class="cmo_enddate form-control cmo_dateInput" />
              </xed:bind>
            </div>
          </div>
        </div>
        <div class="col-md-2">
          <xsl:if test="string-length(@help-text) &gt; 0">
            <xsl:call-template name="cmo-helpbutton" />
          </xsl:if>
        </div>
        <xsl:call-template name="cmo-required" />
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cmo:mods-name">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xed:repeat xpath="mods:name[@type='personal'  or not(@type) or (@type='corporate')]" min="1" max="100">
      <xed:bind xpath="@type" initially="personal"/>
      <fieldset class="personExtended_box">
        <div class="cmo-fieldset-modsName hiddenDetail">
          <xed:bind xpath="mods:displayForm"> <!-- Move down to get the "required" validation right -->
            <div class="form-group {@class} {$xed-val-marker}">
              <div class="row">
                <xed:bind xpath=".."> <!-- Move up again after validation marker is set -->
                  <div class="col-md-4">
                    <xed:bind xpath="mods:role/mods:roleTerm[@authority='marcrelator'][@type='code']" initially="aut">
                      <select class="form-control form-control-inline cmo-form-select">
                        <xsl:apply-templates select="*" />
                      </select>
                    </xed:bind>
                  </div>
                  <div class="col-md-6 center-vertical">
                    <xed:include uri="xslStyle:editor/cmo2xeditor:webapp:editor/editor-includes-mods.xed" ref="person.fields.noHidden" />
                    <span class="fas fa-chevron-up expand-item" title="{i18n:translate('cmo.mods.help.expand')}" aria-hidden="true"></span>
                  </div>
                  <div class="col-md-2">
                    <xsl:if test="string-length(@help-text) &gt; 0">
                      <xsl:call-template name="cmo-helpbutton" />
                    </xsl:if>
                    <xsl:call-template name="cmo-pmud" />
                  </div>
                  <xsl:call-template name="cmo-required" />
                </xed:bind>
              </div>
            </div>
         </xed:bind>
        </div>
        <div class="cmo-fieldset-content personExtended-container d-none">
          <xed:include uri="xslStyle:editor/cmo2xeditor:webapp:editor/editor-includes-mods.xed" ref="nameType" />
          <xed:include uri="xslStyle:editor/cmo2xeditor:webapp:editor/editor-includes-mods.xed" ref="namePart.repeated" />
          <xed:include uri="xslStyle:editor/cmo2xeditor:webapp:editor/editor-includes-mods.xed" ref="person.affiliation" />
          <xed:include uri="xslStyle:editor/cmo2xeditor:webapp:editor/editor-includes-mods.xed" ref="nameIdentifier.repeated" />
        </div>
      </fieldset>
    </xed:repeat>
  </xsl:template>


  <xsl:template name="cmo-textfield">
    <div class="row">
      <label class="col-md-4 col-form-label form-inline">
        <xsl:if test="@label">
          <xed:output i18n="{@label}" />
        </xsl:if>
        <xsl:if test="@type">
          <xsl:text>&#160;</xsl:text>
          <xed:bind xpath="@type">
            <select class="form-control">
              <xed:include uri="xslStyle:items2options:classification:editor:1:children:{@type}" />
            </select>
          </xed:bind>
        </xsl:if>
        <xsl:if test="@textLabel">
          <xsl:text>&#160;</xsl:text>
          <xed:bind xpath="@label">
            <input type="text" class="form-control" style="width: 100px;" />
          </xed:bind>
        </xsl:if>
        <xsl:if test="@textLabelFixed">
          <xed:bind xpath="@label">
            <input type="hidden" style="display:none" value="{@textLabelFixed}" />
          </xed:bind>
        </xsl:if>
        <xsl:if test="@textLabelOptions">
          <xsl:variable name="optionValues">
            <xsl:call-template name="Tokenizer">
              <xsl:with-param name="string" select="@textLabelOptions" />
              <xsl:with-param name="delimiter" select="'|'" />
            </xsl:call-template>
          </xsl:variable>
          <xsl:text>&#160;</xsl:text>
          <xed:bind xpath="@label">
            <select class="form-control" style="width: 100px;">
              <option value="">
                <xed:output i18n="editor.select" />
              </option>
              <xsl:for-each select="exslt:node-set($optionValues)/token">
                <option value="{.}">
                  <xsl:value-of select="."/>
                </option>
              </xsl:for-each>
            </select>
          </xed:bind>
        </xsl:if>
        <xsl:if test="@lang">
          <xsl:text>&#160;</xsl:text>
          <xed:bind xpath="@xml:lang">
            <select class="form-control" style="width: 150px;">
              <option value="">
                <xed:output i18n="editor.select.optional" />
              </option>
              <xed:include uri="xslStyle:items2options:classification:editor:1:children:{@lang}" />
            </select>
          </xed:bind>
        </xsl:if>
      </label>
      <div class="col-md-6">
        <xsl:choose>
          <xsl:when test="@rootBind">
            <xed:bind xpath="{@rootBind}">
              <input id="{@id}" type="text" data-on-screen-keyboard="true" class="form-control">
                <xsl:if test="@autocomplete">
                  <xsl:attribute name="data-autocomplete-field"><xsl:value-of select="@autocomplete" /></xsl:attribute>
                </xsl:if>
                <xsl:call-template name="addSubselectTarget"/>
                <xsl:copy-of select="@placeholder" />
              </input>
            </xed:bind>
          </xsl:when>
          <xsl:otherwise>
            <input id="{@id}" type="text" data-on-screen-keyboard="true" class="form-control">
              <xsl:if test="@autocomplete">
                <xsl:attribute name="data-autocomplete-field"><xsl:value-of select="@autocomplete" /></xsl:attribute>
              </xsl:if>
              <xsl:call-template name="addSubselectTarget"/>
              <xsl:copy-of select="@placeholder" />
            </input>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="col-md-2">
        <xsl:if test="string-length(@help-text) &gt; 0">
          <xsl:call-template name="cmo-helpbutton" />
        </xsl:if>
        <xsl:if test="@repeat = 'true'">
          <xsl:call-template name="cmo-pmud" />
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="addSubselectTarget">
    <xsl:if test="@subselect-target">
      <xsl:attribute name="data-subselect-target">
        <xsl:value-of select="@subselect-target"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>


  <xsl:template name="cmo-required">
    <xsl:if test="@required='true'">
      <xed:validate required="true" display="global">
        <xsl:value-of select="i18n:translate(@required-i18n)" />
      </xed:validate>
    </xsl:if>
  </xsl:template>

  <xsl:template name="cmo-helpbutton">
    <span class="pmud-button">
      <a tabindex="0" class="btn btn-light info-button" role="button" data-toggle="popover" data-placement="right"
         data-content="{@help-text}">
        <i class="fas fa-info"></i>
      </a>
    </span>
  </xsl:template>

  <xsl:template match="cmo:pmud">
    <div class="col-md-2 {@class}">
      <xsl:call-template name="cmo-pmud" />
    </div>
  </xsl:template>

  <xsl:template match="cmo:help-pmud">
    <div class="col-md-2 {@class}">
      <xsl:if test="string-length(@help-text) &gt; 0">
        <xsl:call-template name="cmo-helpbutton" />
      </xsl:if>
      <xsl:if test="@subselect-trigger">
        <span class="pmud-button">
          <button class="btn btn-light" role="button"
                  title="{i18n:translate('cmo.help.search')}" data-subselect-trigger="">
            <i class="fas fa-search"></i>
          </button>
        </span>
      </xsl:if>
      <xsl:if test="@pmud='true'">
        <xsl:call-template name="cmo-pmud" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="cmo-pmud">
    <span class="pmud-button">
      <xed:controls>insert</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>remove</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>up</xed:controls>
    </span>
    <span class="pmud-button">
      <xed:controls>down</xed:controls>
    </span>
  </xsl:template>


</xsl:stylesheet>
