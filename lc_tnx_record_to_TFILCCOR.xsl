<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params" >

  <xsl:template match="lc_tnx_record">
    <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                    xmlns:m='urn:messages.service.ti.apps.tiplus2.misys.com'
                    xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                    xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                    xmlns="urn:control.services.tiplus2.misys.com">
      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFILCCOR</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFILCCOR>
        <m:Context>
          <c:Customer><xsl:value-of select="core:getCustomerFromReference(applicant_reference)" /></c:Customer>
          <c:OurReference><xsl:value-of select="bo_ref_id" /></c:OurReference>
          <c:TheirReference><xsl:value-of select="cust_ref_id" /></c:TheirReference>
          <c:BehalfOfBranch><xsl:value-of select="core:getBOBFromReference(applicant_reference)" /></c:BehalfOfBranch>
        </m:Context>
        <!-- DocumentsReceiveds -->
        <xsl:call-template name="documents-received" />
        <m:EventNotificationss>
          <!--  EventNotifications: Contact details -->
          <xsl:call-template name="corporate-contact" />
          <xsl:variable name="hasAttachedDocumentMessage" select="core:hasAttachedDocumentMessage(free_format_text)" />
          <xsl:if test="string($hasAttachedDocumentMessage) = 'true'">
            <m:EventNotifications>
              <m:MessageData>This transaction contains attachments. You should connect to Misys Portal.</m:MessageData>
              <m:MessageDescription>Message Text</m:MessageDescription>
              <m:MessageInfo></m:MessageInfo>
              <m:Actioned>Y</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <!-- NoDataStream -->
          <xsl:call-template name="attachment-notification" />
          <!--  <xsl:call-template name="customisation-eventnotifications" /> -->
        </m:EventNotificationss>
        <!-- EmbeddedItemss -->
        <xsl:call-template name="embedded-items" />
        <m:Sender>
          <c:Customer><xsl:value-of select="core:getCustomer(applicant_reference)" /></c:Customer>
          <c:Reference><xsl:value-of select="cust_ref_id" /></c:Reference>
        </m:Sender>
        <m:CorresType>G</m:CorresType>
        <m:MessageText><xsl:value-of select="free_format_text" /></m:MessageText>
        <m:eBankMasterRef><xsl:value-of select="ref_id" /></m:eBankMasterRef>
        <m:eBankEventRef><xsl:value-of select="tnx_id" /></m:eBankEventRef>
        <!-- <xsl:call-template name="extra-data" />  -->
        <!-- <xsl:call-template name="customisation-fields" /> -->
      </m:TFILCCOR>
    </ServiceRequest>
  </xsl:template>

  <!--  <xsl:include href="../custom/incoming/lc_tnx_record_to_TFILCCOR_custom.xsl" />  -->
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>
