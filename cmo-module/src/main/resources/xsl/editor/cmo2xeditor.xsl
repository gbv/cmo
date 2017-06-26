<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:cmo="http://cmo.gbv.de/cmo"
  exclude-result-prefixes="xsl cmo i18n">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="cmo:textfield.nobind">
    <div class="form-group">
      <label class="col-md-3 control-label">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6 {@divClass}">
        <input id="{@id}" type="text" class="form-control {@inputClass}" name="">
          <xsl:copy-of select="@placeholder" />
          <xsl:copy-of select="@autocomplete" />
        </input>
      </div>
      <div class="col-md-3">
        <xsl:if test="string-length(@help-text) &gt; 0">
          <xsl:call-template name="cmo-helpbutton" />
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cmo:textfield">
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">
            <xsl:choose>
              <xsl:when test="@bind" >
                <xed:bind xpath="{@bind}" >
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
          <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
          <div class="form-group {@class} {$xed-val-marker}">
            <xsl:call-template name="cmo-textfield" />
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cmo:textarea">
    <xsl:variable name="xed-val-marker" > {$xed-validation-marker} </xsl:variable>
    <xsl:choose>
      <xsl:when test="@repeat = 'true'">
        <xed:repeat xpath="{@xpath}" min="{@min}" max="{@max}">
          <div class="form-group {@class} {$xed-val-marker}">
            <label class="col-md-3 control-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
            <xsl:choose>
              <xsl:when test="@bind" >
                <xed:bind xpath="{@bind}" >
                  <textarea class="form-control">
                    <xsl:copy-of select="@rows" />
                    <xsl:copy-of select="@placeholder" />
                  </textarea>
                </xed:bind>
              </xsl:when>
              <xsl:otherwise>
                <textarea class="form-control">
                  <xsl:copy-of select="@rows" />
                  <xsl:copy-of select="@placeholder" />
                </textarea>
              </xsl:otherwise>
            </xsl:choose>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="cmo-helpbutton" />
              </xsl:if>
              <xsl:call-template name="cmo-pmud" />
            </div>
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:repeat>
      </xsl:when>
      <xsl:otherwise>
        <xed:bind xpath="{@xpath}">
          <div class="form-group {@class} {$xed-val-marker}">
            <label class="col-md-3 control-label">
              <xed:output i18n="{@label}" />
            </label>
            <div class="col-md-6">
              <textarea class="form-control">
                <xsl:copy-of select="@rows" />
                <xsl:copy-of select="@placeholder" />
              </textarea>
            </div>
            <div class="col-md-3">
              <xsl:if test="string-length(@help-text) &gt; 0">
                <xsl:call-template name="cmo-helpbutton" />
              </xsl:if>
              <xsl:if test="@pmud = 'true'">
                <xsl:call-template name="cmo-pmud" />
              </xsl:if>
            </div>
          </div>
          <xsl:call-template name="cmo-required" />
        </xed:bind>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="cmo:dateRange">
    <div class="form-group">
      <label class="col-md-3 control-label ">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6 {@class}" data-type="{@type}">
        <xsl:call-template name="cmo-dateRange"/>
      </div>
      <div class="col-md-3">
        <xsl:if test="string-length(@help-text) &gt; 0">
          <xsl:call-template name="cmo-helpbutton" />
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="cmo:dateRangeInput">
    <div class="{@class}" data-type="{@type}">
      <xsl:call-template name="cmo-dateRange"/>
    </div>
  </xsl:template>




  <xsl:template name="cmo-textfield">
    <label class="col-md-3 control-label ">
      <xsl:if test="@label">
        <xed:output i18n="{@label}" />
      </xsl:if>
    </label>
    <div class="col-md-6">
      <input id="{@id}" type="text" class="form-control">
        <xsl:copy-of select="@placeholder" />
      </input>
    </div>
    <div class="col-md-3">
      <xsl:if test="string-length(@help-text) &gt; 0">
        <xsl:call-template name="cmo-helpbutton" />
      </xsl:if>
      <xsl:if test="@repeat = 'true'">
        <xsl:call-template name="cmo-pmud" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="cmo-dateRange">
    <xsl:variable name="apos">'</xsl:variable>
    <xsl:variable name="xpathSimple" >
      <xsl:value-of select="concat(@xpath,'[not(@point)]')"/>
    </xsl:variable>
    <xsl:variable name="xpathStart" >
      <xsl:value-of select="concat(@xpath,'[@point=', $apos, 'start', $apos, ']')"/>
    </xsl:variable>
    <xsl:variable name="xpathEnd" >
      <xsl:value-of select="concat(@xpath,'[@point=', $apos, 'end', $apos, ']')"/>
    </xsl:variable>
    <xsl:variable name="hiddenclasssimple" >
      <xsl:if test="@onlyRange = 'true' ">hidden</xsl:if>
    </xsl:variable>
    <xsl:variable name="hiddenclassrange" >
      <xsl:if test="not(@onlyRange = 'true')">hidden</xsl:if>
    </xsl:variable>
    <div class="date-format" data-format="simple">
      <div class="date-simple {$hiddenclasssimple} input-group">
        <xed:bind xpath="{$xpathSimple}">
          <input type="text" class="form-control" autocomplete="off">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <xsl:call-template name="date-selectFormat"/>
      </div>
      <div class="date-range input-group {$hiddenclassrange} input-daterange">
        <xed:bind xpath="{$xpathStart}">
          <input type="text" class="form-control startDate" data-point="start">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <span class="glyphicon glyphicon-minus input-group-addon" aria-hidden="true"></span>
        <xed:bind xpath="{$xpathEnd}">
          <input type="text" class="form-control endDate" data-point="end">
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
        <xsl:if test="not(@onlyRange = 'true') ">
          <xsl:call-template name="date-selectFormat"/>
        </xsl:if>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="date-selectFormat">
    <div class="input-group-btn date-selectFormat">
      <button class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="caret"></span><span class="sr-only">Toggle Dropdown</span></button>
      <ul class="dropdown-menu dropdown-menu-right" role="menu">
        <li>
          <a href="#" class="date-simpleOption">
            <xsl:value-of select="i18n:translate('cmo.date.specification')" />
          </a>
        </li>
        <li>
          <a href="#" class="date-rangeOption">
            <xsl:value-of select="i18n:translate('cmo.date.period')" />
          </a>
        </li>
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="cmo-required">
    <xsl:if test="@required='true'">
      <xed:validate required="true" display="global">
        <xsl:value-of select="i18n:translate(@required-i18n)" />
      </xed:validate>
    </xsl:if>
  </xsl:template>

  <xsl:template name="cmo-helpbutton">
    <a tabindex="0" class="btn btn-default info-button" role="button" data-toggle="popover" data-placement="right" data-content="{@help-text}">
      <i class="fa fa-info"></i>
    </a>
  </xsl:template>

  <xsl:template match="cmo:pmud">
    <div class="col-md-3 {@class}">
      <xsl:call-template name="cmo-pmud" />
    </div>
  </xsl:template>

  <xsl:template match="cmo:help-pmud">
    <div class="col-md-3 {@class}">
      <xsl:if test="string-length(@help-text) &gt; 0">
        <xsl:call-template name="cmo-helpbutton" />
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
