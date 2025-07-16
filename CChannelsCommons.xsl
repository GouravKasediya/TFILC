<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document   : CChannelsCommons.xsl
    Created on : April 20, 2016, 7:59 PM
    Description:
        Extraction of transformation for the following tags that is used
        on almost all mapping scripts.
        - Documents Receiveds
        - Embedded Items
        - Event Notificationss
        - Linked Licenses
        - Contract Details
        - Standbys and Guarantees (Undertaking Off) Renewals
        - Local Undertaking Renewals
        - Invoice
        - Finance
        - Amendment Instructions
        - Request Header
-->
<xsl:stylesheet version="2.0"
                xmlns:m="urn:messages.service.ti.apps.tiplus2.misys.com"
                xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
                xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                exclude-result-prefixes="core params">
                
 <xsl:variable name="FCCVersion"><xsl:value-of select="params:getFCCVersion()" /></xsl:variable>
 <xsl:variable name="FCCPatch"><xsl:value-of select="params:getFCCPatch()" /></xsl:variable>
 <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
 <xsl:variable name="FTIPatch"><xsl:value-of select="params:getFTIPatch()" /></xsl:variable>
  
  <!-- DocumentsReceiveds -->
  <xsl:template name="documents-received">
  <m:DocumentsReceiveds>
    <xsl:for-each select="attachments/attachment">
      <xsl:if test="doc_id and (doc_id != '')">
        <m:DocumentsReceived>
          <m:DocID><xsl:value-of select="doc_id" /></m:DocID>
          <m:DMSID><xsl:value-of select="dms_id" /></m:DMSID>
          <m:DocType>GEN</m:DocType>
          <m:Description><xsl:value-of select="file_name" /></m:Description>
          <m:FirstMail><xsl:value-of select="FirstMail" /></m:FirstMail>
          <m:SecondMail><xsl:value-of select="SecondMail" /></m:SecondMail>
          <m:MailingTotal><xsl:value-of select="Total" /></m:MailingTotal>
        </m:DocumentsReceived>
      </xsl:if>
    </xsl:for-each>
  </m:DocumentsReceiveds>  
  </xsl:template>
  
  
  <!-- EmbeddedItemss -->
  <xsl:template name="embedded-items"> 
  <m:EmbeddedItemss>
    <xsl:for-each select="attachments/attachment">
      <xsl:if test="(not(doc_id) or (doc_id = '')) and (file_attachment and (file_attachment != ''))">
        <m:EmbeddedItems>
          <m:ID><xsl:value-of select="attachment_id" /></m:ID>
          <m:DocType>GEN</m:DocType>
          <m:Description><xsl:value-of select="title" /></m:Description>
          <m:FileName><xsl:value-of select="file_name" /></m:FileName>
          <m:DataStream><xsl:value-of select="file_attachment" /></m:DataStream>
          <m:MimeType><xsl:value-of select="core:getMimeType(mime_type, file_name)" /></m:MimeType>
        </m:EmbeddedItems>
      </xsl:if>
    </xsl:for-each>
  </m:EmbeddedItemss>   
  </xsl:template>

  <xsl:template name="mt-mx-address">
    <xsl:param name="party"/>
    <xsl:param name="xsiNilAttribute" select="false()"/>
    <xsl:if test="$party/town_name">
      <xsl:element name="c:MXAddress">
        <xsl:element name="c:Name">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/name"/></xsl:element>
        <xsl:element name="c:Department">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/department"/></xsl:element>
        <xsl:element name="c:SubDepartment">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/sub_department"/></xsl:element>
        <xsl:element name="c:StreetName">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/street_name"/></xsl:element>
        <xsl:element name="c:BuildingNumber">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/building_number"/></xsl:element>
        <xsl:element name="c:BuildingName">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/building_name"/></xsl:element>
        <xsl:element name="c:Floor">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/floor"/></xsl:element>
        <xsl:element name="c:PostBox">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/post_box"/></xsl:element>
        <xsl:element name="c:Room">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/room"/></xsl:element>
        <xsl:element name="c:PostCode">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/post_code"/></xsl:element>
        <xsl:element name="c:TownName">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/town_name"/></xsl:element>
        <xsl:element name="c:TownLocationName">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/town_location_name"/></xsl:element>
        <xsl:element name="c:DistrictName">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/district_name"/></xsl:element>
        <xsl:element name="c:CountrySubDivision">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/country_sub_division"/></xsl:element>
        <xsl:element name="c:Country">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/country"/></xsl:element>
        <xsl:element name="c:AddressLine1">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/hybrid_line_1"/></xsl:element>
        <xsl:element name="c:AddressLine2">
          <xsl:if test="$xsiNilAttribute"><xsl:attribute name="xsi:nil" select="'true'"/></xsl:if>
          <xsl:value-of select="$party/hybrid_line_2"/></xsl:element>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  <!--  EventNotifications_CorporateContact -->
  <xsl:template name="corporate-contact">
  <xsl:if test="normalize-space(additional_field[@name='releaser_phone']) != '' or normalize-space(additional_field[@name='releaser_email']) != ''">
    <m:EventNotifications>
      <m:MessageData>
        <xsl:value-of select="concat('Name: ', additional_field[@name='releaser_first_name'], ' ',additional_field[@name='releaser_last_name'], '&#10;')" />
        <xsl:value-of select="concat('Phone no.: ', additional_field[@name='releaser_phone'], '&#10;')" />
        <xsl:value-of select="concat('Email: ', additional_field[@name='releaser_email'])" />
      </m:MessageData>
      <m:MessageDescription>Corporate Contact</m:MessageDescription>
      <m:MessageInfo>Additional information</m:MessageInfo>
      <m:Actioned>Y</m:Actioned>
    </m:EventNotifications>
  </xsl:if>
  
  <xsl:if test="(releaser_phone and normalize-space(releaser_phone) != '') or (releaser_email and normalize-space(releaser_email) != '')">
    <m:EventNotifications>
      <m:MessageData>
        <xsl:value-of select="concat('Name: ', releaser_first_name, ' ', releaser_last_name, '&#10;')" />
        <xsl:value-of select="concat('Phone no.: ', releaser_phone, '&#10;')" />
        <xsl:value-of select="concat('Email: ', releaser_email)" />
      </m:MessageData>
      <m:MessageDescription>Corporate Contact</m:MessageDescription>
      <m:MessageInfo>Additional information</m:MessageInfo>
      <m:Actioned>N</m:Actioned>
    </m:EventNotifications>
  </xsl:if>
  </xsl:template>
  
  
  <!--  EventNotifications_AttachedDocumentMessage -->
  <xsl:template name="attached-document-message">

  <xsl:variable name="m:AttachedDocumentMessage" select="'This transaction contains attachments. You should connect to Trade Portal.'" />
  <xsl:if test="params:getSetInstructionsToGAP() = 'Y' and contains (free_format_text, $m:AttachedDocumentMessage)">
    <m:EventNotifications>
      <m:MessageData><xsl:value-of select="$m:AttachedDocumentMessage" /></m:MessageData>
      <m:MessageDescription>Message Text</m:MessageDescription>
      <m:MessageInfo>Additional Information</m:MessageInfo>
      <m:Actioned>Y</m:Actioned>
    </m:EventNotifications>
  </xsl:if>
  </xsl:template>

  <!--  EventNotifications_SendAttachmentsBy -->
  <xsl:template name="send-attachments-by">

  <xsl:if test="send_attachments_by != ''">
    <m:EventNotifications>
      <m:MessageData>
        <xsl:value-of select="concat(send_attachments_by, '&#10;')" />
        <xsl:value-of select="if (send_attachments_by = 'OTHR') then send_attachments_by_other else ''" />
      </m:MessageData>
      <m:MessageDescription>Send Attachments By</m:MessageDescription>
      <m:MessageInfo>Additional Information</m:MessageInfo>
      <m:Actioned>Y</m:Actioned>
    </m:EventNotifications>
  </xsl:if>
  </xsl:template>

  <!--  EventNotifications_NoDataStream-->
  <xsl:template name="attachment-notification">
  <xsl:for-each select="attachments/attachment">
     <xsl:if test="(not(doc_id) or (doc_id = '')) and (not(file_attachment) or (file_attachment = ''))">
       <m:EventNotifications>
         <m:MessageData>Exported file path: <xsl:value-of select="exported_file_path" /></m:MessageData>
         <m:MessageDescription>File Attachment</m:MessageDescription>
         <m:MessageInfo>Actual file was not sent to FTI. Please refer to the exported file path that was received via this gateway message.</m:MessageInfo>
         <m:Actioned>N</m:Actioned>
       </m:EventNotifications>
     </xsl:if>
  </xsl:for-each>
  </xsl:template>
  
  
  
  <!--Collection Drafts -->
  <xsl:template name="collection-drafts">
    <m:CollectionDraftss>
      <xsl:choose>
        <xsl:when test="$FCCVersion &gt; 62 or ($FCCVersion = 62 and $FCCPatch &gt;= 4)">
          <xsl:for-each select="payment_tenors/payment_tenor">
           <xsl:if test= "amend_status != '04'">
            <m:CollectionDrafts>
              <m:DraftAmount><xsl:value-of select="payment_amt"/></m:DraftAmount>
              <m:DraftCurrency><xsl:value-of select="payment_cur_code"/></m:DraftCurrency>
              <m:DraftRelease><xsl:value-of select="if (tenor_type = '01') then 'P'
                                                    else if (tenor_type = '02') then 'A'
                                                    else if (tenor_type = '03') then 'V'
                                                    else ''" /></m:DraftRelease>
              <m:DraftId><xsl:value-of select="tenor_id" /></m:DraftId>
              <m:DraftDetails><xsl:value-of select="draft_text"/> </m:DraftDetails>
              <m:TenorDays><xsl:value-of select="tenor_days" /></m:TenorDays>
              <m:TenorPeriod><xsl:value-of select="tenor_period" /></m:TenorPeriod>
              <m:FromAfter><xsl:value-of select="tenor_from_after" /></m:FromAfter>
              <xsl:choose>
                  <xsl:when test="tenor_type = '01'">
                     <m:TenorFrom><xsl:value-of select="if (tenor_days_type_sight != 'O') then tenor_days_type_sight
                                                        else ''" /></m:TenorFrom>
                     <m:TenorText><xsl:value-of select="if (tenor_days_type_sight = 'O') then tenor_type_details_sight
                                                        else ''" /></m:TenorText>
                  
                  </xsl:when>
                  <xsl:otherwise>
                     <m:TenorFrom><xsl:value-of select="if (tenor_days_type != 'O') then tenor_days_type
                                                       else ''" /></m:TenorFrom>
                     <m:TenorText><xsl:value-of select="if (tenor_days_type = 'O') then tenor_type_details
                                                        else ''" /></m:TenorText>
                  </xsl:otherwise>
              </xsl:choose>
              <m:TenorBaseDate><xsl:value-of select="if (tenor_base_date and tenor_base_date != '') then core:dateFormatCCToTIPlus(tenor_base_date) else ''" /></m:TenorBaseDate>
              <m:TenorMaturityDate><xsl:value-of select="if (maturity_date != '') then core:dateFormatCCToTIPlus(maturity_date) else ''" /></m:TenorMaturityDate>
              <xsl:if test="$FTIVersion &gt; 210 or ($FTIVersion = 210 and $FTIPatch &gt;= 4)">
                <m:InternalIdentifier><xsl:value-of select="payment_tenor_id"/></m:InternalIdentifier>
              </xsl:if>
            </m:CollectionDrafts>
           </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <m:CollectionDrafts>
            <m:DraftAmount><xsl:value-of select="tnx_amt" /></m:DraftAmount>
            <m:DraftCurrency><xsl:value-of select="tnx_cur_code" /></m:DraftCurrency>
            <m:DraftRelease><xsl:value-of select="if (tenor_type = '01') then 'P'
                                                  else if (tenor_type = '02') then 'A'
                                                  else if (tenor_type = '03') then 'V'
                                                  else ''" />
            </m:DraftRelease>
            <m:DraftId><xsl:value-of select="tenor_id" /></m:DraftId>
            <m:TenorDays><xsl:value-of select="tenor_days" /></m:TenorDays>
            <m:TenorPeriod><xsl:value-of select="tenor_period" /></m:TenorPeriod>
            <m:FromAfter><xsl:value-of select="tenor_from_after" /></m:FromAfter>
            <m:TenorFrom><xsl:value-of select="if (tenor_days_type != 'O') then tenor_days_type else''" /></m:TenorFrom>
            <m:TenorText><xsl:value-of select="if (tenor_days_type = 'O') then tenor_type_details else ''" /></m:TenorText>
            <m:TenorBaseDate><xsl:value-of select="if (tenor_base_date and tenor_base_date != '') then core:dateFormatCCToTIPlus(tenor_base_date) else ''" /></m:TenorBaseDate>
            <m:TenorMaturityDate><xsl:value-of select="if (tenor_maturity_date != '') then core:dateFormatCCToTIPlus(tenor_maturity_date) else ''" /></m:TenorMaturityDate>
          </m:CollectionDrafts>
        </xsl:otherwise>
      </xsl:choose>
    </m:CollectionDraftss>
  </xsl:template>
  <!-- LicenseDetails -->
  <xsl:template name="linked-licenses">
  <xsl:variable name="allocatedCurrency">
    <xsl:value-of select="if (product_code = 'BG' or product_code = 'SI') then bg_cur_code
                          else if (product_code = 'LC') then lc_cur_code
                          else if (product_code = 'EC') then tnx_cur_code
                          else ''" /></xsl:variable>
  <m:LicenseDetails>
  <xsl:for-each select="linked_licenses/license">
    <m:LicenseDetail>
      <m:OurReference><xsl:value-of select="bo_ref_id" /></m:OurReference>
      <m:EBankMasterRef><xsl:value-of select="ls_ref_id" /></m:EBankMasterRef>
      <m:Number><xsl:value-of select="ls_number" /></m:Number>
      <m:AllocatedAmount><xsl:value-of select="ls_allocated_amt" /></m:AllocatedAmount>
      <m:AllocatedCurrency><xsl:value-of select="$allocatedCurrency" /></m:AllocatedCurrency>
    </m:LicenseDetail>
  </xsl:for-each>
  </m:LicenseDetails>
  </xsl:template>
  
  
  <!--  EventNotifications_LicenseDetails -->
  <xsl:template name="linked-licenses-GAP">
  <xsl:variable name="allocatedCurrency">
    <xsl:value-of select="if (product_code = 'BG' or product_code = 'SI') then bg_cur_code
                          else if (product_code = 'LC') then lc_cur_code
                          else if (product_code = 'EC') then tnx_cur_code
                          else ''" /></xsl:variable>
  <xsl:for-each select="linked_licenses/license">
    <m:EventNotifications>
      <m:MessageData>
        <xsl:value-of select="if (bo_ref_id != '') then concat('Portal Reference ID: ', ls_ref_id, '&#10;') else ''" />
        <xsl:value-of select="if (ls_ref_id != '') then concat('Back Office Reference ID: ', bo_ref_id, '&#10;') else ''" />
        <xsl:value-of select="if (ls_number != '') then concat('License Number: ', ls_number, '&#10;') else ''" />
        <xsl:value-of select="if (ls_allocated_amt != '') then concat('License Allocated Amount: ', ls_allocated_amt, '&#10;') else ''" />
        <xsl:value-of select="if ($allocatedCurrency != '') then concat('License Allocated Currency: ', $allocatedCurrency, '&#10;') else ''" />
      </m:MessageData>
      <m:MessageDescription>Linked License Details</m:MessageDescription>
      <m:MessageInfo>Additional information</m:MessageInfo>
      <m:Actioned>N</m:Actioned>
     </m:EventNotifications>
  </xsl:for-each>
  </xsl:template>
  
  
  <!-- ContractDetails -->
  <xsl:template name="contract-details">
  <m:ContractDetails>
    <c:ReferenceCode><xsl:value-of select="contract_ref" /></c:ReferenceCode>
    <c:ReferenceNarrative><xsl:value-of select="contract_narrative" /></c:ReferenceNarrative>
    <c:ReferenceDate><xsl:value-of select="if (contract_date and contract_date != '') then core:dateFormatCCToTIPlus(contract_date) else ''" /></c:ReferenceDate>
    <c:TenderClosingDate><xsl:value-of select="if (tender_expiry_date and tender_expiry_date != '') then core:dateFormatCCToTIPlus(tender_expiry_date) else ''" /></c:TenderClosingDate>
    <c:TotalOrderAmount>
      <c:Amount><xsl:value-of select="contract_amt" /></c:Amount>
      <c:Currency><xsl:value-of select="contract_cur_code" /></c:Currency>
    </c:TotalOrderAmount>
    <c:GuaranteeValuePercent><xsl:value-of select="contract_pct" /></c:GuaranteeValuePercent>
  </m:ContractDetails>
  </xsl:template>
  
  
  <!--  EventNotifications_ContractDetails -->
  <xsl:template name="contract-details-GAP">
  <xsl:variable name="m:ContractDetails" >
    <xsl:value-of select="if (contract_ref != '') then concat('Contract Reference: ', contract_ref, '&#10;') else ''" />
    <xsl:value-of select="if (contract_narrative != '') then concat('Contract Narrative: ', core:getFormattedNarrative(contract_narrative), '&#10;') else ''" />
    <xsl:value-of select="if (contract_date != '') then concat('Contract Date: ', core:dateFormatCCToTIPlus(contract_date), '&#10;') else ''" />
    <xsl:value-of select="if (tender_expiry_date != '') then concat('Tender Expiry Date: ', core:dateFormatCCToTIPlus(tender_expiry_date), '&#10;') else ''" />
    <xsl:value-of select="if (contract_amt != '') then concat('Contract Amount: ', contract_amt, '&#10;') else ''" />
    <xsl:value-of select="if (contract_cur_code != '') then concat('Contract Currency: ', contract_cur_code, '&#10;') else ''" />
    <xsl:value-of select="if (contract_pct != '') then concat('Percentage Covered: ', contract_pct, '&#10;') else ''" />
  </xsl:variable>
  <m:EventNotifications>
    <m:MessageData><xsl:value-of select="if ($m:ContractDetails != '') then concat('Contract Details:', '&#10;', $m:ContractDetails) else ''" /></m:MessageData>
    <m:MessageDescription>Contract Details</m:MessageDescription>
    <m:MessageInfo>Additional Information</m:MessageInfo>
    <m:Actioned>N</m:Actioned>
  </m:EventNotifications>
  </xsl:template>
  
  
  <!--  Standbys and Guarantees (Undertaking Off) Renewals -->
  <xsl:template name="renewal">
  <m:Renewal>
    <xsl:if test="renew_flag = 'Y' or additional_field//renew_flag = 'Y'">
      <c:Advise><xsl:value-of select="if (advise_renewal_flag) then advise_renewal_flag else additional_field//advise_renewal_flag" /></c:Advise>
      <c:AdviseNoticeDays><xsl:value-of select="if (advise_renewal_flag = 'Y' or additional_field//advise_renewal_flag = 'Y') then advise_renewal_days_nb else additional_field//advise_renewal_days_nb"/></c:AdviseNoticeDays>
      <c:CalendarDate><xsl:value-of select="if ((renew_on_code = '02' or additional_field//renew_on_code='02') and (renewal_calendar_date and renewal_calendar_date != '')) then core:dateFormatCCToTIPlus(renewal_calendar_date)
                                            else if ((renew_on_code = '02' or additional_field//renew_on_code='02') and (additional_field//renewal_calendar_date and additional_field//renewal_calendar_date != '')) then core:dateFormatCCToTIPlus(additional_field//renewal_calendar_date)
                                            else '' "/></c:CalendarDate>
      <c:RenewalDate><xsl:value-of select="if ((renew_on_code='01' or additional_field//renew_on_code='01') and (exp_date and exp_date != '')) then core:dateFormatCCToTIPlus(exp_date)
                                           else if ((renew_on_code='01' or additional_field//renew_on_code='01') and (additional_field//exp_date and additional_field//exp_date != '')) then core:dateFormatCCToTIPlus(additional_field//exp_date)
                                           else '' "/></c:RenewalDate>
      <c:RenewalWhen><xsl:value-of select="if (renew_on_code = '01' or additional_field//renew_on_code = '01') then 'E'
                                           else if (renew_on_code = '02' or additional_field//renew_on_code = '02') then 'C'
                                           else '' "/></c:RenewalWhen>
      <c:RenewForPeriod>
        <c:TenorDays><xsl:value-of select="if (renew_for_nb) then renew_for_nb else additional_field//renew_for_nb" /></c:TenorDays>
        <c:TenorPeriod><xsl:value-of select="if (renew_for_period) then renew_for_period else additional_field//renew_for_period" /></c:TenorPeriod>
      </c:RenewForPeriod>
      <c:RollingRenewal>
        <c:CancellationNotice><xsl:value-of select="if (rolling_cancellation_days) then rolling_cancellation_days else additional_field//rolling_cancellation_days" /></c:CancellationNotice>
        <xsl:if test="rolling_renew_on_code = '03' or additional_field//rolling_renew_on_code = '03'">
          <c:EveryPEriod>
            <c:Unit><xsl:value-of select="if (rolling_renew_for_period) then rolling_renew_for_period else additional_field//rolling_renew_for_period" /></c:Unit>
            <c:Number><xsl:value-of select="if (rolling_renew_for_nb) then rolling_renew_for_nb else additional_field//rolling_renew_for_nb" /></c:Number>
            <c:DayInMonth><xsl:value-of select="if (rolling_day_in_month) then rolling_day_in_month else additional_field//rolling_day_in_month" /></c:DayInMonth>
          </c:EveryPEriod>
        </xsl:if>
        <c:NumberOf><xsl:value-of select="if (rolling_renewal_nb) then rolling_renewal_nb else additional_field//rolling_renewal_nb" /></c:NumberOf>
        <c:RenewOn><xsl:value-of select="if (rolling_renew_on_code = '01' or additional_field//rolling_renew_on_code = '01') then 'X'
                                         else if (rolling_renew_on_code = '03' or additional_field//rolling_renew_on_code = '03') then 'V'
                                         else '' "/></c:RenewOn>
        <c:AdjustedFinalExpiryDate><xsl:value-of select="if (final_expiry_date and (final_expiry_date != '')) then core:dateFormatCCToTIPlus(final_expiry_date)
                                                         else if (additional_field//final_expiry_date and (additional_field//final_expiry_date != '')) then core:dateFormatCCToTIPlus(additional_field//final_expiry_date)
                                                         else '' "/></c:AdjustedFinalExpiryDate>
      </c:RollingRenewal>
      <c:IsRollingRenewal><xsl:value-of select="if (rolling_renewal_flag) then rolling_renewal_flag else additional_field//rolling_renewal_flag" /></c:IsRollingRenewal>
      <c:UseAmount><xsl:value-of select="if (renew_amt_code = '01' or additional_field//renew_amt_code = '01') then 'O'
                                         else if (renew_amt_code = '02' or additional_field//renew_amt_code = '02') then 'C'
                                         else '' "/></c:UseAmount>
    </xsl:if>
    <c:RenewalOn><xsl:value-of select="if (renew_flag) then renew_flag else additional_field//renew_flag" /></c:RenewalOn>
  </m:Renewal>
  </xsl:template>

  <!--  Undertaking Renewal Details -->
  <xsl:template name="undertaking-renewal-details">
    <c:RenewalDetails>
      <xsl:variable name="isRenewalTypeChanged" select="(renewal_type != '' and (renewal_type != additional_field[@name='original_details']/bg_tnx_record/renewal_type))"/>
      <xsl:if test="renew_flag = 'N'">
        <c:Renewal>
          <c:Advise>N</c:Advise>
          <c:RenewalOn>N</c:RenewalOn>
        </c:Renewal>
      </xsl:if>
      <xsl:if test="((renewal_type = '02' or (not(renewal_type) and additional_field[@name='original_details']/bg_tnx_record/renewal_type = '02')))">
        <c:Renewal>
          <c:Advise><xsl:value-of select="if (advise_renewal_flag) then advise_renewal_flag
                                          else if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/advise_renewal_flag
                                          else ''"/></c:Advise>
          <c:AdviseNoticeDays><xsl:value-of select="if (advise_renewal_days_nb) then advise_renewal_days_nb
                                                    else if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/advise_renewal_days_nb
                                                    else ''"/></c:AdviseNoticeDays>
          <c:CalendarDate><xsl:value-of select="if (renewal_calendar_date != '') then core:dateFormatCCToTIPlus(renewal_calendar_date)
                                                else if ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renewal_calendar_date != '') then core:dateFormatCCToTIPlus(additional_field[@name='original_details']/bg_tnx_record/renewal_calendar_date)
                                                else ''"/></c:CalendarDate>
          <c:IsRollingRenewal><xsl:value-of select="if (renew_flag = 'Y' or (not(renew_flag) and additional_field[@name='original_details']/bg_tnx_record/renew_flag = 'Y')) then 'Y' else ''"/></c:IsRollingRenewal>
          <xsl:choose>
            <xsl:when test="narrative_cancellation">
              <c:NonExtensionNotificationDetails xsi:nil="true"><xsl:value-of select="narrative_cancellation"/></c:NonExtensionNotificationDetails>
            </xsl:when>
            <xsl:otherwise>
              <c:NonExtensionNotificationDetails><xsl:value-of select="if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/narrative_cancellation
                                                                       else ''"/></c:NonExtensionNotificationDetails>
            </xsl:otherwise>
          </xsl:choose>
          <c:RenewForPeriod>
            <c:PeriodNumber><xsl:value-of select="if (renew_for_nb) then renew_for_nb
                                                  else additional_field[@name='original_details']/bg_tnx_record/renew_for_nb"/></c:PeriodNumber>
            <c:PeriodUnit><xsl:value-of select="if (renew_for_period) then renew_for_period
                                                else additional_field[@name='original_details']/bg_tnx_record/renew_for_period"/></c:PeriodUnit>
          </c:RenewForPeriod>
          <c:RenewalDate><xsl:value-of select="if ((renew_on_code = '01' or additional_field[@name='original_details']/bg_tnx_record/renew_on_code = '01') and exp_date != '') then core:dateFormatCCToTIPlus(exp_date)
                                               else if ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renew_on_code = '01' and additional_field[@name='original_details']/bg_tnx_record/exp_date != '') then core:dateFormatCCToTIPlus(additional_field[@name='original_details']/bg_tnx_record/exp_date)
                                               else if ((renew_on_code = '02' or additional_field[@name='original_details']/bg_tnx_record/renew_on_code = '02') and renewal_calendar_date != '') then core:dateFormatCCToTIPlus(renewal_calendar_date)
                                               else if ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renew_on_code = '02' and additional_field[@name='original_details']/bg_tnx_record/renewal_calendar_date != '') then core:dateFormatCCToTIPlus(additional_field[@name='original_details']/bg_tnx_record/renewal_calendar_date)
                                               else ''"/></c:RenewalDate>
          <c:RenewalOn><xsl:value-of select="renew_flag"/></c:RenewalOn>
          <c:RenewalWhen><xsl:value-of select="if (renew_on_code = '01' or ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renew_on_code = '01')) then 'E'
                                               else if (renew_on_code = '02' or ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renew_on_code = '02')) then 'C'
                                               else '' "/></c:RenewalWhen>
          <c:RollingRenewal>
            <c:CancellationNotice><xsl:value-of select="if (rolling_cancellation_days != '') then rolling_cancellation_days
                                                        else if (rolling_cancellation_days and additional_field[@name='original_details']/bg_tnx_record/rolling_cancellation_days != '') then '0'
                                                        else if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/rolling_cancellation_days
                                                        else ''"/></c:CancellationNotice>
            <xsl:if test="rolling_renew_on_code = '02' or (not(rolling_renew_on_code) and additional_field[@name='original_details']/bg_tnx_record/rolling_renew_on_code = '02')">
              <c:EveryPeriod>
                <c:PeriodNumber><xsl:value-of select="if (rolling_renew_for_nb) then rolling_renew_for_nb
                                                      else additional_field[@name='original_details']/bg_tnx_record/rolling_renew_for_nb"/></c:PeriodNumber>
                <c:PeriodUnit><xsl:value-of select="if (rolling_renew_for_period) then rolling_renew_for_period
                                                    else additional_field[@name='original_details']/bg_tnx_record/rolling_renew_for_period"/></c:PeriodUnit>
                <xsl:if test="((rolling_renew_for_period != 'D' and rolling_renew_for_period != 'W') or
                              (additional_field[@name='original_details']/bg_tnx_record/rolling_renew_for_period != 'D' and additional_field[@name='original_details']/bg_tnx_record/rolling_renew_for_period != 'W'))">
                  <c:DayInMonth><xsl:value-of select="if (rolling_day_in_month != '') then rolling_day_in_month
                                                      else if (rolling_day_in_month and additional_field[@name='original_details']/bg_tnx_record/rolling_day_in_month != '') then '0'
                                                      else additional_field[@name='original_details']/bg_tnx_record/rolling_day_in_month"/></c:DayInMonth>
                </xsl:if>
              </c:EveryPeriod>
            </xsl:if>
            <c:NumberOf><xsl:value-of select="if (rolling_renewal_nb) then rolling_renewal_nb
                                              else if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/rolling_renewal_nb
                                              else ''"/></c:NumberOf>
            <c:RenewOn><xsl:value-of select="if (rolling_renew_on_code = '01') then 'X'
                                             else if (rolling_renew_on_code = '02') then 'V'
                                             else ''"/></c:RenewOn>
            <xsl:choose>
              <xsl:when test="final_expiry_date">
                <c:AdjustedFinalExpiryDate xsi:nil="true"><xsl:value-of select="if (final_expiry_date != '') then core:dateFormatCCToTIPlus(final_expiry_date)
                                                                                else ''"/></c:AdjustedFinalExpiryDate>
              </xsl:when>
              <xsl:otherwise>
                <c:AdjustedFinalExpiryDate><xsl:value-of select="if ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/final_expiry_date != '') then core:dateFormatCCToTIPlus(additional_field[@name='original_details']/bg_tnx_record/final_expiry_date)
                                                                 else ''"/></c:AdjustedFinalExpiryDate>
              </xsl:otherwise>
            </xsl:choose>
          </c:RollingRenewal>
          <c:UseAmount><xsl:value-of select="if (renew_amt_code = '01' or ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renew_amt_code = '01')) then 'O'
                                             else if (renew_amt_code = '02' or ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renew_amt_code = '02')) then 'C'
                                             else ''"/></c:UseAmount>
        </c:Renewal>
      </xsl:if>
      <xsl:if test="variation != ''">
        <c:Reduction>
          <c:Advise><xsl:value-of select="variation/advise_flag"/></c:Advise>
          <c:AdviseNoticeDays><xsl:value-of select="variation/advise_reduction_days"/></c:AdviseNoticeDays>
          <c:AmountOrPercent>
            <xsl:variable name="variationPercent" select="variation/variation_lines/variation_line_item[1]/percent"/>
            <c:Amount><xsl:value-of select="if (not($variationPercent) or $variationPercent = '') then core:getTIAmount(variation/variation_lines/variation_line_item[1]/amount) else ''"/></c:Amount>
            <c:Percent><xsl:value-of select="$variationPercent"/></c:Percent>
          </c:AmountOrPercent>
          <c:IsIncrease><xsl:value-of select="if (variation/variation_lines/variation_line_item[1]/operation = '01') then 'Y' else 'N'"/></c:IsIncrease>
          <c:IsRegular><xsl:value-of select="if (variation/type = '01') then 'Y' else 'N'"/></c:IsRegular>
          <c:MaxIncreases><xsl:value-of select="variation/maximum_nb_days"/></c:MaxIncreases>
          <c:Period>
            <c:PeriodNumber><xsl:value-of select="variation/frequency"/></c:PeriodNumber>
            <xsl:variable name="variation_period" select="variation/period" />
            <c:PeriodUnit><xsl:value-of select="$variation_period"/></c:PeriodUnit>
            <c:DayInMonth><xsl:value-of select="if ($variation_period != 'D' and $variation_period != 'W') then variation/day_in_month else ''"/></c:DayInMonth>
          </c:Period>
          <c:StartDate><xsl:value-of select="if (variation/variation_lines/variation_line_item[1]/first_date != '') then core:dateFormatCCToTIPlus(variation/variation_lines/variation_line_item[1]/first_date) else ''"/></c:StartDate>
          <xsl:if test="(variation/type = '02')">
            <c:IrregularAmounts>
              <xsl:for-each select="variation/variation_lines/variation_line_item">
                <c:IrregularAmount>
                  <c:Amount><xsl:value-of select="if (not(percent) or (percent = '')) then core:getTIAmount(amount) else ''"/></c:Amount>
                  <c:Date><xsl:value-of select="if (first_date != '') then core:dateFormatCCToTIPlus(first_date) else ''"/></c:Date>
                  <c:IsIncrease><xsl:value-of select="if (operation = '01') then 'Y' else 'N'"/></c:IsIncrease>
                  <c:Percent><xsl:value-of select="percent"/></c:Percent>
                </c:IrregularAmount>
              </xsl:for-each>
            </c:IrregularAmounts>
          </xsl:if>
        </c:Reduction>
      </xsl:if>
      <xsl:if test="(renewal_type = '01' or (not(renewal_type) and additional_field[@name='original_details']/bg_tnx_record/renewal_type = '01'))">
        <c:RegularRenewal>
          <c:Advise><xsl:value-of select="if (advise_renewal_flag) then advise_renewal_flag
                                          else if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/advise_renewal_flag
                                          else ''"/></c:Advise>
          <c:AdviseNoticeDays><xsl:value-of select="if (advise_renewal_days_nb) then advise_renewal_days_nb
                                                    else if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/advise_renewal_days_nb
                                                    else ''"/></c:AdviseNoticeDays>
          <c:EveryPeriod>
            <c:PeriodNumber><xsl:value-of select="if (renew_for_nb) then renew_for_nb
                                                  else additional_field[@name='original_details']/bg_tnx_record/renew_for_nb"/></c:PeriodNumber>
            <c:PeriodUnit><xsl:value-of select="if (renew_for_period) then renew_for_period
                                                else additional_field[@name='original_details']/bg_tnx_record/renew_for_period"/></c:PeriodUnit>
            <xsl:if test="((renew_for_period != 'D' and renew_for_period != 'W') or
                          (additional_field[@name='original_details']/bg_tnx_record/renew_for_period != 'D' and additional_field[@name='original_details']/bg_tnx_record/renew_for_period != 'W'))">
              <c:DayInMonth><xsl:value-of select="if (rolling_day_in_month != '') then rolling_day_in_month
                                                  else if (rolling_day_in_month and additional_field[@name='original_details']/bg_tnx_record/rolling_day_in_month != '') then '0'
                                                  else additional_field[@name='original_details']/bg_tnx_record/rolling_day_in_month"/></c:DayInMonth>
            </xsl:if>
          </c:EveryPeriod>
          <c:ExtensionDetails><xsl:value-of select="if (renew_on_code = '01' or (not(renew_on_code) and additional_field[@name='original_details']/bg_tnx_record/renew_on_code = '01')) then 'Extension on expiry'
                                                    else if (renewal_calendar_date != '') then concat('Extension on ', core:dateFormatCCToTIPlus(renewal_calendar_date))
                                                    else if (not(renewal_calendar_date) and additional_field[@name='original_details']/bg_tnx_record/renewal_calendar_date != '') then concat('Extension on ', core:dateFormatCCToTIPlus(additional_field[@name='original_details']/bg_tnx_record/renewal_calendar_date))
                                                    else ''"/></c:ExtensionDetails>
          <xsl:choose>
            <xsl:when test="narrative_cancellation">
              <c:NonExtensionNotificationDetails xsi:nil="true"><xsl:value-of select="narrative_cancellation"/></c:NonExtensionNotificationDetails>
            </xsl:when>
            <xsl:otherwise>
              <c:NonExtensionNotificationDetails><xsl:value-of select="if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/narrative_cancellation
                                                                       else ''"/></c:NonExtensionNotificationDetails>
            </xsl:otherwise>
          </xsl:choose>
          <c:NotificationDays><xsl:value-of select="if (rolling_cancellation_days != '') then rolling_cancellation_days
                                                    else if (rolling_cancellation_days and additional_field[@name='original_details']/bg_tnx_record/rolling_cancellation_days != '') then '0'
                                                    else if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/rolling_cancellation_days
                                                    else ''"/></c:NotificationDays>
          <c:NumberOfRenewals><xsl:value-of select="if (rolling_renewal_nb) then rolling_renewal_nb
                                                    else if ($isRenewalTypeChanged) then additional_field[@name='original_details']/bg_tnx_record/rolling_renewal_nb
                                                    else ''"/></c:NumberOfRenewals>
          <c:RenewFor><xsl:value-of select="if (renew_flag = 'Y' or (not(renew_flag) and additional_field[@name='original_details']/bg_tnx_record/renew_flag = 'Y')) then 'O' else ''"/></c:RenewFor>
          <c:UseAmount><xsl:value-of select="if (renew_amt_code = '01' or ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renew_amt_code = '01')) then 'O'
                                             else if (renew_amt_code = '02' or ($isRenewalTypeChanged and additional_field[@name='original_details']/bg_tnx_record/renew_amt_code = '02')) then 'C'
                                             else ''"/></c:UseAmount>
        </c:RegularRenewal>
      </xsl:if>
    </c:RenewalDetails>
  </xsl:template>

  <!--  Client Wording -->
  <xsl:template name="client-wording">
   <xsl:if test="(prod_stat_code='98') or (prod_stat_code = ('78', '79') and sub_tnx_type_code = ('88', '89'))">
    <m:EventNotifications>
      <m:MessageData>
      <xsl:value-of select="if (prod_stat_code = '98') then 'Provisional wording has been submitted for review.'
                            else if (prod_stat_code = '78' and sub_tnx_type_code = '89') then 'Provisional wording has been rejected by applicant.'
                            else if (prod_stat_code = '78' and sub_tnx_type_code = '88') then 'Provisional wording has been approved by applicant.'
                            else if (prod_stat_code = '79' and sub_tnx_type_code = '89') then 'Final wording has been rejected by applicant.'
                            else if (prod_stat_code = '79' and sub_tnx_type_code = '88') then 'Final wording has been approved by applicant.'
                            else '' "/>
      </m:MessageData>
      <m:MessageDescription>
      <xsl:value-of select="if (prod_stat_code = '98') then 'Provisional wording has been submitted'
                            else if (prod_stat_code = '78' and sub_tnx_type_code = '89') then 'Provisional wording has been - REJECTED'
                            else if (prod_stat_code = '78' and sub_tnx_type_code = '88') then 'Provisional wording has been - APPROVED'
                            else if (prod_stat_code = '79' and sub_tnx_type_code = '89') then 'Final wording has been - REJECTED'
                            else if (prod_stat_code = '79' and sub_tnx_type_code = '88') then 'Final wording has been - APPROVED'
                            else '' "/>
      </m:MessageDescription>
      <m:MessageInfo>
      <xsl:value-of select="if ((prod_stat_code='98') or
                               ((prod_stat_code='78' and (sub_tnx_type_code = ('88', '89'))) or
                               (prod_stat_code='79' and sub_tnx_type_code='89')))
                                 then 'Review any attachments and amend the final wording/provisional wording flags before completing the event'
                            else if (prod_stat_code='79' and sub_tnx_type_code='88') then 'Review any attachments and amend the provisional wording flag before completing the event'
                            else '' "/>
      </m:MessageInfo>
      <m:Actioned>N</m:Actioned>
    </m:EventNotifications>
    </xsl:if>
  </xsl:template>
  
  <!--  Invoice Array -->
  <xsl:template name="invoices">
    <m:Invoices>
      <xsl:variable name="anchorpartyRole"><xsl:value-of select="if (fscm_program/anchorparty_role = '01') then 'Buyer'
                                                                 else if (fscm_program/anchorparty_role = '02') then 'Seller'
                                                                 else ''" /></xsl:variable>
      <m:Programme><xsl:value-of select="fscm_program/program_code" /></m:Programme>
      <m:Seller><xsl:value-of select="if ($anchorpartyRole = 'Seller') then core:getCustomerFromReference(seller_reference) else static_beneficiary/abbv_name" /></m:Seller>
      <m:Buyer><xsl:value-of select="if ($anchorpartyRole = 'Buyer') then core:getCustomerFromReference(buyer_reference) else static_beneficiary/abbv_name" /></m:Buyer>
      <m:AnchorParty><xsl:value-of select="if ($anchorpartyRole = 'Buyer') then core:getCustomerFromReference(buyer_reference)
                                           else if ($anchorpartyRole = 'Seller') then core:getCustomerFromReference(seller_reference)
                                           else ''" /></m:AnchorParty>
      <m:InvoiceNumber><xsl:value-of select="issuer_ref_id" /></m:InvoiceNumber>
      <m:IssueDate><xsl:value-of select="core:dateFormatCCToTIPlus(iss_date)" /></m:IssueDate>
      <m:OutstandingAmount><xsl:value-of select="if (($FCCVersion &gt; 60) or ($FCCVersion = 60 and $FCCPatch &gt;= 5)) then liab_total_net_amt 
                                                 else liab_total_amt" /></m:OutstandingAmount>
      <m:OutstandingAmountCurrency><xsl:value-of select="liab_total_cur_code" /></m:OutstandingAmountCurrency>
      <m:EBankFinanceMasterRef><xsl:value-of select="ref_id" /></m:EBankFinanceMasterRef>
      <m:EBankFinanceEventRef><xsl:value-of select="tnx_id" /></m:EBankFinanceEventRef>
    </m:Invoices>
  </xsl:template>
  
  <!-- Bulk Payment Invoice Array -->
  <xsl:template name="invoices_bp">
    <m:Invoice>
      <xsl:variable name="anchorpartyRole"><xsl:value-of select="if (fscm_program/anchorparty_role = '01') then 'Buyer'
                                                                 else if (fscm_program/anchorparty_role = '02') then 'Seller'
                                                                 else ''" /></xsl:variable>
      <m:Programme><xsl:value-of select="fscm_program/program_code" /></m:Programme>
      <m:Seller><xsl:value-of select="if ($anchorpartyRole = 'Seller') then core:getCustomerFromReference(seller_reference) else static_beneficiary/abbv_name" /></m:Seller>
      <m:Buyer><xsl:value-of select="if ($anchorpartyRole = 'Buyer') then core:getCustomerFromReference(buyer_reference) else static_beneficiary/abbv_name" /></m:Buyer>
      <m:AnchorParty><xsl:value-of select="if ($anchorpartyRole = 'Buyer') then core:getCustomerFromReference(buyer_reference)
                                           else if ($anchorpartyRole = 'Seller') then core:getCustomerFromReference(seller_reference)
                                           else ''" /></m:AnchorParty>
      <m:MasterReference><xsl:value-of select="bo_ref_id" /></m:MasterReference>
      <m:IssueDate><xsl:value-of select="core:dateFormatCCToTIPlus(iss_date)" /></m:IssueDate>
      <xsl:choose>
        <xsl:when test="cn_linked_flag = 'Y'">
          <xsl:choose>
            <xsl:when test="fscm_program/finance_debit_party = '02'">
              <m:DiscountedInvoiceAmount><xsl:value-of select="liab_total_net_amt"/></m:DiscountedInvoiceAmount>
              <m:DiscountedInvoiceAmountCurrency><xsl:value-of select="liab_total_net_cur_code"/></m:DiscountedInvoiceAmountCurrency>
              <m:OutstandingFinanceRepaymentAmount><xsl:value-of select="outstanding_repayment_amt"/></m:OutstandingFinanceRepaymentAmount>
              <m:OutstandingFinanceRepaymentAmountCurrency><xsl:value-of select="outstanding_repayment_cur_code"/></m:OutstandingFinanceRepaymentAmountCurrency>
            </xsl:when>
            <xsl:otherwise>
              <m:OutstandingAmount><xsl:value-of select="outstanding_repayment_amt"/></m:OutstandingAmount>
              <m:OutstandingAmountCurrency><xsl:value-of select="outstanding_repayment_cur_code"/></m:OutstandingAmountCurrency>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <m:OutstandingAmount><xsl:value-of select="liab_total_amt"/></m:OutstandingAmount>
          <m:OutstandingAmountCurrency><xsl:value-of select="liab_total_cur_code"/></m:OutstandingAmountCurrency>
        </xsl:otherwise>
      </xsl:choose>
    </m:Invoice>
  </xsl:template>
  
  <!-- Finance Array -->
  <xsl:template name="finance">
    <m:Finance>
      <xsl:variable name="anchorpartyRole"><xsl:value-of select="if (fscm_program/anchorparty_role = '01') then 'Buyer'
                                                                 else if (fscm_program/anchorparty_role = '02') then 'Seller'
                                                                 else ''" /></xsl:variable>
      <xsl:variable name="financeAmount"><xsl:value-of select="if ((($FCCVersion &gt; 60) or ($FCCVersion = 60 and $FCCPatch &gt;= 7)) and (fscm_program/finance_debit_party = '01')) then finance_amt
                                                                 else outstanding_repayment_amt" /></xsl:variable>
      <xsl:variable name="financeAmountCurrency"><xsl:value-of select="if ((($FCCVersion &gt; 60) or ($FCCVersion = 60 and $FCCPatch &gt;= 7)) and (fscm_program/finance_debit_party = '01')) then finance_cur_code
                                                                 else outstanding_repayment_cur_code" /></xsl:variable>
      <m:Programme><xsl:value-of select="fscm_program/program_code" /></m:Programme>
      <m:Seller><xsl:value-of select="if ($anchorpartyRole = 'Seller') then core:getCustomerFromReference(seller_reference) else static_beneficiary/abbv_name" /></m:Seller>
      <m:Buyer><xsl:value-of select="if ($anchorpartyRole = 'Buyer') then core:getCustomerFromReference(buyer_reference) else static_beneficiary/abbv_name" /></m:Buyer>
      <m:AnchorParty><xsl:value-of select="if ($anchorpartyRole = 'Buyer') then core:getCustomerFromReference(buyer_reference)
                                           else if ($anchorpartyRole = 'Seller') then core:getCustomerFromReference(seller_reference)
                                           else ''" /></m:AnchorParty>
      <m:MasterReference><xsl:value-of select="fin_bo_ref_id" /></m:MasterReference>
      <m:StartDate><xsl:value-of select="if (fin_date != '') then core:dateFormatCCToTIPlus(fin_date) else ''" /></m:StartDate>
      <m:OutstandingAmount><xsl:value-of select="$financeAmount" /></m:OutstandingAmount>
      <m:OutstandingAmountCurrency><xsl:value-of select="$financeAmountCurrency" /></m:OutstandingAmountCurrency>
      <m:SettlementAmount><xsl:value-of select="$financeAmount" /></m:SettlementAmount>
      <m:SettlementAmountCurrency><xsl:value-of select="$financeAmountCurrency" /></m:SettlementAmountCurrency>
      <m:EBankEventRef><xsl:value-of select="tnx_id" /></m:EBankEventRef>
      <m:EBankMasterXRef><xsl:value-of select="ref_id" /></m:EBankMasterXRef>
    </m:Finance>
  </xsl:template>
  
  <!-- Amendment Instruction -->
  <xsl:template name="amendment-instruction">
    <c:Instruction>
      <c:Type><xsl:value-of select="if (operation = 'ADD') then 'A'
                                    else if (operation = 'DELETE') then 'D'
                                    else ''" /></c:Type>
      <c:Text><xsl:value-of select="text" /></c:Text>
    </c:Instruction>
  </xsl:template>

  <!-- Request Header -->
  <xsl:template name="RequestHeader" xmlns="urn:control.services.tiplus2.misys.com">
    <xsl:param name="service"            select="'TI'"/>
    <xsl:param name="operation"/>
    <xsl:param name="name"               select="params:getGWUSER()"/>
    <xsl:param name="password"           select="params:getGWUSER()"/>
    <xsl:param name="certificate"        select="'XXX'"/>
    <xsl:param name="digest"             select="'XXX'"/>
    <xsl:param name="replyFormat"        select="'NONE'"/>
    <xsl:param name="sourceSystem"/>
    <xsl:param name="noRepair"           select="'N'"/>
    <xsl:param name="noOverride"         select="'N'"/>
    <xsl:param name="correlationId"      select="'NONE'"/>
    <xsl:param name="transactionControl" select="'NONE'"/>
      <RequestHeader>
        <Service><xsl:value-of select="$service"/></Service>
        <Operation><xsl:value-of select="$operation"/></Operation>
        <Credentials>
          <Name><xsl:value-of select="$name" /></Name>
          <Password><xsl:value-of select="$password" /></Password>
          <Certificate><xsl:value-of select="$certificate"/></Certificate>
          <Digest><xsl:value-of select="$digest"/></Digest>
        </Credentials>
        <ReplyFormat><xsl:value-of select="$replyFormat"/></ReplyFormat>
        <SourceSystem><xsl:value-of select="$sourceSystem" /></SourceSystem>
        <NoRepair><xsl:value-of select="$noRepair"/></NoRepair>
        <NoOverride><xsl:value-of select="$noOverride"/></NoOverride>
        <CorrelationId><xsl:value-of select="$correlationId"/></CorrelationId>
        <TransactionControl><xsl:value-of select="$transactionControl"/></TransactionControl>
      </RequestHeader>
  </xsl:template>
</xsl:stylesheet>