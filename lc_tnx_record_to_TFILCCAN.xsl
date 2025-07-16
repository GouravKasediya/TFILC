<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params">

  <xsl:template match="lc_tnx_record">
    <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()"/></xsl:variable>
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                    xmlns:m='urn:messages.service.ti.apps.tiplus2.misys.com'
                    xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                    xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                    xmlns="urn:control.services.tiplus2.misys.com">
      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFILCCAN</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFILCCAN>
        <m:Context>
          <c:Customer><xsl:value-of select="core:getCustomerFromReference(applicant_reference)"/></c:Customer>
          <c:OurReference><xsl:value-of select="bo_ref_id"/></c:OurReference>
          <c:TheirReference><xsl:value-of select="cust_ref_id"/></c:TheirReference>
          <c:BehalfOfBranch><xsl:value-of select="core:getBOBFromReference(applicant_reference)"/></c:BehalfOfBranch>
        </m:Context>
        <!-- DocumentsReceiveds -->
        <xsl:call-template name="documents-received"/>
        <m:EventNotificationss>
          <!--  EventNotifications: Contact details -->
          <xsl:call-template name="corporate-contact"/>
          <!-- NoDataStream -->
          <xsl:call-template name="attachment-notification"/>
          <!--  <xsl:call-template name="customisation-eventnotifications"/> -->
        </m:EventNotificationss>
        <!-- EmbeddedItemss -->
        <xsl:call-template name="embedded-items"/>
        <m:Sender>
          <c:Customer><xsl:value-of select="core:getCustomer(applicant_reference)"/></c:Customer>
          <c:Reference><xsl:value-of select="cust_ref_id"/></c:Reference>
        </m:Sender>
        <m:CancelInstructions>
          <xsl:value-of select="if (free_format_text != '') then concat('Other information: ',free_format_text, '&#10;') else ''"/>
          <xsl:value-of select="if (exp_date != '') then concat('Expiry date: ',exp_date, '&#10;') else ''"/>
          <xsl:value-of select="if (lc_amt != '') then concat('Amount: ',lc_amt, '&#10;') else ''"/>
          <xsl:value-of select="if (lc_cur_code != '') then concat('Currency: ',lc_cur_code, '&#10;') else ''"/>
          <xsl:value-of select="if (fee_act_no != '') then concat('Charge account number: ',fee_act_no, '&#10;') else ''"/>
          <xsl:value-of select="if (principal_act_no != '') then concat('Principal account number: ',principal_act_no, '&#10;') else ''"/>
        </m:CancelInstructions>
        <m:BenApprovalReq>F</m:BenApprovalReq>
        <m:eBankMasterRef><xsl:value-of select="ref_id"/></m:eBankMasterRef>
        <m:eBankEventRef><xsl:value-of select="tnx_id"/></m:eBankEventRef>
        <!-- <xsl:call-template name="extra-data"/>  -->
        <!-- <xsl:call-template name="customisation-fields"/> -->
      </m:TFILCCAN>
    </ServiceRequest>
  </xsl:template>

  <!--  <xsl:include href="../custom/incoming/lc_tnx_record_to_TFILCCAN_custom.xsl"/>  -->
  <xsl:include href="../commons/CChannelsCommons.xsl"/>
</xsl:stylesheet>