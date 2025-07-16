<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params">
  
  <xsl:template match="lc_tnx_record">
    <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                    xmlns:m='urn:messages.service.ti.apps.tiplus2.misys.com'
                    xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                    xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                    xmlns="urn:control.services.tiplus2.misys.com">
      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFILCPYR</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFILCPYR>
        <m:Context>
          <c:Customer><xsl:value-of select="core:getCustomerFromReference(applicant_reference)" /></c:Customer>
          <c:OurReference><xsl:value-of select="bo_ref_id" /></c:OurReference>
          <c:TheirReference><xsl:value-of select="cust_ref_id" /></c:TheirReference>
          <c:BehalfOfBranch><xsl:value-of select="core:getBOBFromReference(applicant_reference)" /></c:BehalfOfBranch>
        </m:Context>
        <!-- DocumentsReceived -->
        <xsl:call-template name="documents-received" />
        <m:EventNotificationss>
          <!-- ContactDetails -->
          <xsl:call-template name="corporate-contact" />
          <!-- NoDataStream -->
          <xsl:call-template name="attachment-notification" />
          <!--  <xsl:call-template name="customisation-eventnotifications" /> -->
        </m:EventNotificationss>
        <!-- EmbeddedItems -->
        <xsl:call-template name="embedded-items" />
        <m:ClaimId><xsl:value-of select="bo_tnx_id" /></m:ClaimId>
        <m:Sender>
          <c:Customer><xsl:value-of select="core:getCustomer(applicant_reference)" /></c:Customer>
          <c:Reference><xsl:value-of select="cust_ref_id" /></c:Reference>
        </m:Sender>
        <m:ResponseType><xsl:value-of select="if (sub_tnx_type_code = '08' or sub_tnx_type_code = '62') then 'A'
                                              else if (sub_tnx_type_code = '09' or sub_tnx_type_code = '63') then 'R'
                                              else ''" /></m:ResponseType>
        <m:ResponseDetails><xsl:value-of select="if (sub_tnx_type_code = '08' or sub_tnx_type_code = '62') then free_format_text else ''" />
        </m:ResponseDetails>
        <m:RefusalDetails><xsl:value-of select="if (sub_tnx_type_code = '09' or sub_tnx_type_code = '63') then free_format_text else ''" /></m:RefusalDetails>
        <m:eBankMasterRef><xsl:value-of select="ref_id" /></m:eBankMasterRef>
        <m:eBankEventRef><xsl:value-of select="tnx_id" /></m:eBankEventRef>
        <!-- <xsl:call-template name="extra-data" />  -->
        <!-- <xsl:call-template name="customisation-fields" /> -->
      </m:TFILCPYR>
    </ServiceRequest>
  </xsl:template>

  <!--  <xsl:include href="../custom/incoming/lc_tnx_record_to_TFILCPYR_custom.xsl" />  -->
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>