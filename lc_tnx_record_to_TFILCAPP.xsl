<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params">

  <xsl:template match="lc_tnx_record">
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                    xmlns:m="urn:messages.service.ti.apps.tiplus2.misys.com"
                    xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                    xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                    xmlns="urn:control.services.tiplus2.misys.com">

      <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFILCAPP</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFILCAPP>
        <xsl:call-template name="TFILCAPP">
          <xsl:with-param name="ftiVersion" select="$FTIVersion"/>
        </xsl:call-template>
        <!-- <xsl:call-template name="extra-data" />  -->
        <!-- <xsl:call-template name="customisation-fields" /> -->
      </m:TFILCAPP>
    </ServiceRequest>
  </xsl:template>

  <!--  <xsl:include href="../custom/incoming/lc_tnx_record_to_TFILCAPP_custom.xsl" />  -->
  <xsl:include href="templates/TFILCAPP.xsl" />
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>