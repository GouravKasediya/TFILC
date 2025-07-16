<?xml version="1.0" encoding="UTF-8"?>
<!--
  TFILCBTB inherits the TFILCAPP template. This script performs two transformations:
    first, it applies the TFILCAPP template similar to lc_tnx_record_to_TFILCAPP
    then, uses the result of the first to match the tag where the TFILCBTB-exclusive tag will be placed
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xmlns:m="urn:messages.service.ti.apps.tiplus2.misys.com"
  xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params">

  <!-- Apply template for second pass using result from the first pass -->
  <xsl:template match="lc_tnx_record">
    <xsl:apply-templates select="$firstPassResult" mode="secondPass"/>
  </xsl:template>

  <xsl:variable name="firstPassResult">
    <xsl:apply-templates select="lc_tnx_record" mode="firstPass"/>
  </xsl:variable>

  <!-- First transformation: Transform it to similar to TFILCAPP -->
  <xsl:template name="lc_tnx_record_to_TFILCBTB" match="lc_tnx_record" mode="firstPass">
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                    xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                    xmlns="urn:control.services.tiplus2.misys.com">

      <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>

      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFILCBTB</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>

      <m:TFILCBTB>
        <xsl:call-template name="TFILCAPP">
          <xsl:with-param name="ftiVersion" select="$FTIVersion"/>
        </xsl:call-template>
        <xsl:call-template name="cached-fields"/>
        <!-- <xsl:call-template name="extra-data" /> -->
        <!-- <xsl:call-template name="customisation-fields" />  -->
      </m:TFILCBTB>
    </ServiceRequest>
  </xsl:template>

  <!--
    Copy fields to be used for the second pass
    Attribute from="first-pass" differentiates this from customization's cached_fields
  -->
  <xsl:template name="cached-fields">
    <cached_fields from="first-pass">
      <xsl:copy-of select="additional_field[@name='parent_bo_ref_id']" />
    </cached_fields>
  </xsl:template>

  <!-- Identity template -->
  <xsl:template match="node()|@*" mode="secondPass">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*" mode="secondPass"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="m:AutoCreateFollowOnEvent" mode="secondPass">
    <xsl:copy-of select="."/>
    <xsl:variable name="cachedFields" as="element()*" select="../cached_fields " />
    <m:BackToBackDetails>
      <c:ParentLCReference><xsl:value-of select="$cachedFields/additional_field[@name='parent_bo_ref_id']"/></c:ParentLCReference>
    </m:BackToBackDetails>
  </xsl:template>

  <!-- Remove the cached field from the first pass -->
  <xsl:template match="cached_fields[@from = 'first-pass']" mode="secondPass"/>

  <!-- <xsl:include href="../custom/incoming/lc_tnx_record_to_TFILCBTB_custom.xsl" /> -->
  <xsl:include href="templates/TFILCAPP.xsl" />
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>