<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
  xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
  exclude-result-prefixes="core params">

  <xsl:template match="lc_tnx_record">
    <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
    <xsl:variable name="SWIFT2018" select="params:getSWIFT2018()" />
    <ServiceRequest xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
                    xmlns:m='urn:messages.service.ti.apps.tiplus2.misys.com'
                    xmlns:c="urn:common.service.ti.apps.tiplus2.misys.com"
                    xmlns:x="urn:custom.service.ti.apps.tiplus2.misys.com"
                    xmlns="urn:control.services.tiplus2.misys.com">
      <xsl:call-template name="RequestHeader">
        <xsl:with-param name="operation">TFILCAMN</xsl:with-param>
        <xsl:with-param name="sourceSystem" select="if ($FTIVersion >= 28) then params:getFCCSourceSystem() else ''"/>
      </xsl:call-template>
      <m:TFILCAMN>
        <xsl:variable name="mapAddressLine4" select="additional_field[@name='original_details']/lc_tnx_record/adv_send_mode != '01' and params:getMapAddressLine4() = 'Y'"/>
        <m:Context>
          <c:Customer><xsl:value-of select="core:getCustomerFromReference(applicant_reference)" /></c:Customer>
          <c:OurReference><xsl:value-of select="if (bo_ref_id != '' and tnx_type_code = '03') then bo_ref_id else '' " /></c:OurReference>
          <c:TheirReference><xsl:value-of select="cust_ref_id" /></c:TheirReference>
          <c:BehalfOfBranch><xsl:value-of select="core:getBOBFromReference(applicant_reference)" /></c:BehalfOfBranch>
        </m:Context>
        <!-- DocumentsReceiveds -->
        <xsl:call-template name="documents-received" />
        <m:EventNotificationss>
          <!--  EventNotifications: Contact details -->
          <xsl:call-template name="corporate-contact" />
          <xsl:if test ="additional_field[@name='last_ship_date'] != '' and last_ship_date ='' ">
            <m:EventNotifications>
              <m:MessageData>Please clear the shipment date field manually.</m:MessageData>
              <m:MessageDescription>Shipment date</m:MessageDescription>
              <m:MessageInfo>Additional information</m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <xsl:if test="additional_field[@name='narrative_shipment_period'] != '' and narrative_shipment_period = '' ">
            <m:EventNotifications>
              <m:MessageData>Please clear the shipment period field manually.</m:MessageData>
              <m:MessageDescription>Shipment period</m:MessageDescription>
              <m:MessageInfo>Additional information</m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <xsl:if test="string(core:hasAttachedDocumentMessage(free_format_text)) = 'true'">
            <m:EventNotifications>
              <m:MessageData>This transaction contains attachments. You should connect to Misys Portal.</m:MessageData>
              <m:MessageDescription>Instructions from Applicant</m:MessageDescription>
              <m:MessageInfo></m:MessageInfo>
              <m:Actioned>Y</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <xsl:if test="adv_send_mode = '99'">
            <m:EventNotifications>
              <m:MessageData><xsl:value-of select="adv_send_mode_text"/></m:MessageData>
              <m:MessageDescription>Send via other method</m:MessageDescription>
              <m:MessageInfo>Additional Information</m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <xsl:if test="$FTIVersion &lt; 28 and amd_no != ''">
            <m:EventNotifications>
              <m:MessageData><xsl:value-of select="amd_no" /></m:MessageData>
              <m:MessageDescription>Amendment number</m:MessageDescription>
              <m:MessageInfo></m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <xsl:if test="tnx_type_code = '13' and sub_tnx_type_code ='03'">
            <m:EventNotifications>
              <m:MessageData>Customer reference has been set by Applicant.</m:MessageData>
              <m:MessageDescription>Special amendment type</m:MessageDescription>
              <m:MessageInfo></m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <xsl:if test="$SWIFT2018 = 'N' and cfm_chrg_brn_by_code != ''">
            <m:EventNotifications>
              <m:MessageData><xsl:value-of select="if (cfm_chrg_brn_by_code = '01') then 'Applicant'
                                                   else if (cfm_chrg_brn_by_code = '02') then 'Beneficiary'
                                                   else ''" /></m:MessageData>
              <m:MessageDescription>Confirmation Charges</m:MessageDescription>
              <m:MessageInfo></m:MessageInfo>
              <m:Actioned>N</m:Actioned>
            </m:EventNotifications>
          </xsl:if>
          <!-- LicenseDetailsGAP -->
          <xsl:if test="$FTIVersion and $FTIVersion &lt;= 25">
            <xsl:call-template name="linked-licenses-GAP" />
          </xsl:if>
          <!-- NoDataStream -->
          <xsl:call-template name="attachment-notification" />
          <!--  <xsl:call-template name="customisation-eventnotifications" /> -->
        </m:EventNotificationss>
        <!-- EmbeddedItemss -->
        <xsl:call-template name="embedded-items" />
        <m:MasterRef><xsl:value-of select="bo_ref_id" /></m:MasterRef>
        <xsl:if test="string(core:hasAttachedDocumentMessage(free_format_text)) = 'false'">
          <m:ApplicantInstructions><xsl:value-of select="free_format_text" /></m:ApplicantInstructions>
        </xsl:if>
        <m:Beneficiary>
          <c:LegalEntityIdentifier><xsl:value-of select="beneficiary_lei" /></c:LegalEntityIdentifier>
          <xsl:if test="beneficiary_name or beneficiary_address_line_1 or beneficiary_address_line_2 or beneficiary_dom or beneficiary_reference or beneficiary_country or beneficiary_address_line_4">
            <c:NameAddress><xsl:value-of select="if ($mapAddressLine4) then core:constructNameAndAddress(if (not(beneficiary_name)) then //beneficiary_name else beneficiary_name,
                                                                              if (not(beneficiary_address_line_1)) then //beneficiary_address_line_1 else beneficiary_address_line_1,
                                                                              if (not(beneficiary_address_line_2)) then //beneficiary_address_line_2 else beneficiary_address_line_2,
                                                                              if (not(beneficiary_dom)) then //beneficiary_dom else beneficiary_dom,
                                                                              if (not(beneficiary_address_line_4)) then //beneficiary_address_line_4 else beneficiary_address_line_4)
                                                 else core:constructNameAndAddress(if (not(beneficiary_name)) then //beneficiary_name else beneficiary_name,
                                                                                   if (not(beneficiary_address_line_1)) then //beneficiary_address_line_1 else beneficiary_address_line_1,
                                                                                   if (not(beneficiary_address_line_2)) then //beneficiary_address_line_2 else beneficiary_address_line_2,
                                                                                   if (not(beneficiary_dom)) then //beneficiary_dom else beneficiary_dom)" /></c:NameAddress>
            <c:Reference><xsl:value-of select="if (not(beneficiary_reference)) then //beneficiary_reference else beneficiary_reference" /></c:Reference>
            <c:Country><xsl:value-of select="if (not(beneficiary_country)) then //beneficiary_country else beneficiary_country" /></c:Country>
          </xsl:if>
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="beneficiary_address" />
            <xsl:with-param name="xsiNilAttribute" select="true()" />
          </xsl:call-template>
        </m:Beneficiary>
        <xsl:if test="$SWIFT2018 = 'Y'">
          <m:ConfirmationDetails>
            <c:ConfirmationCharges><xsl:value-of select="if (cfm_chrg_brn_by_code = '01') then 'A'
                                                         else if (cfm_chrg_brn_by_code = '02') then 'B'
                                                         else '' " /></c:ConfirmationCharges>
              <c:RequestedConfirmationParty>
                <c:Customer><xsl:value-of select="requested_confirmation_party/abbv_name" /></c:Customer>
                <c:LegalEntityIdentifier><xsl:value-of select="requested_confirmation_party/lei_code" /></c:LegalEntityIdentifier>
                <c:NameAddress><xsl:value-of select="if ($mapAddressLine4) then core:constructNameAndAddress(requested_confirmation_party/name, requested_confirmation_party/address_line_1, requested_confirmation_party/address_line_2, requested_confirmation_party/dom, requested_confirmation_party/address_line_4)
                                                     else core:constructNameAndAddress(requested_confirmation_party/name, requested_confirmation_party/address_line_1, requested_confirmation_party/address_line_2, requested_confirmation_party/dom)" /></c:NameAddress>
                <c:SwiftAddress><xsl:value-of select="requested_confirmation_party/iso_code" /></c:SwiftAddress>
                <c:Reference><xsl:value-of select="requested_confirmation_party/reference" /></c:Reference>
                <c:Contact><xsl:value-of select="requested_confirmation_party/contact_name" /></c:Contact>
                <c:ZipCode><xsl:value-of select="requested_confirmation_party/zipcode" /></c:ZipCode>
                <c:Telephone><xsl:value-of select="requested_confirmation_party/phone" /></c:Telephone>
                <c:FaxNumber><xsl:value-of select="requested_confirmation_party/fax" /></c:FaxNumber>
                <c:TelexNumber><xsl:value-of select="requested_confirmation_party/telex" /></c:TelexNumber>
                <c:Email><xsl:value-of select="requested_confirmation_party/web_address" /></c:Email>
                <xsl:call-template name="mt-mx-address">
                  <xsl:with-param name="party" select="requested_confirmation_party" />
                </xsl:call-template>
              </c:RequestedConfirmationParty>
            <c:RequestedConfirmationPartyRole><xsl:value-of select="if (req_conf_party_flag = 'Advise Thru Bank') then 'THB'
                                                                    else if (req_conf_party_flag = 'Advising Bank') then 'ADV'
                                                                    else if (req_conf_party_flag = 'Other') then 'OTH'
                                                                    else ''" /></c:RequestedConfirmationPartyRole>
          </m:ConfirmationDetails>
        </xsl:if>
        <m:IssueBy><xsl:value-of select="params:getTIAdviceMethod(adv_send_mode)" /></m:IssueBy>
        <m:LCAmount>
          <c:Amount><xsl:value-of select="lc_amt" /></c:Amount>
          <c:Currency><xsl:value-of select="lc_cur_code" /></c:Currency>
        </m:LCAmount>
        <m:LCAmountSpec>
          <c:Qualifier><xsl:value-of select="if (max_cr_desc_code != '' ) then
                                               (if (max_cr_desc_code = '3') then 'N' else 'O')
                                             else '' " /></c:Qualifier>
          <c:Min><xsl:value-of select="neg_tol_pct" /></c:Min>
          <c:Max><xsl:value-of select="pstv_tol_pct" /></c:Max>
        </m:LCAmountSpec>
        <m:Revocable><xsl:value-of select="if ($SWIFT2018 = 'Y' or irv_flag = 'Y' or irv_flag = '') then 'N' else 'Y'" /></m:Revocable>
        <m:Confirmation><xsl:value-of select="if (cfm_inst_code = '01') then 'C'
                                              else if (cfm_inst_code = '02') then 'M'
                                              else if (cfm_inst_code = '03') then 'W'
                                              else ''" />
        </m:Confirmation>
        <m:Revolving>
          <c:Revolving><xsl:value-of select="if (revolving_flag) then revolving_flag else additional_field//revolving_flag" /></c:Revolving>
          <c:Cumulative><xsl:value-of select="if (cumulative_flag) then cumulative_flag else additional_field//cumulative_flag" /></c:Cumulative>
          <c:Period><xsl:value-of select="if (revolve_period and revolve_frequency) then concat(revolve_period, ' ', revolve_frequency)
                                          else if (revolve_period and additional_field//revolve_frequency) then concat(revolve_period, ' ', additional_field//revolve_frequency)
                                          else if (additional_field//revolve_period and revolve_frequency) then concat(additional_field//revolve_period, ' ', revolve_frequency)
                                          else if (additional_field//revolve_period and additional_field//revolve_frequency) then concat(additional_field//revolve_period, ' ', additional_field//revolve_frequency)
                                          else '' " /></c:Period>
          <c:Revolutions><xsl:value-of select="if (revolve_time_no) then revolve_time_no else additional_field//revolve_time_no" /></c:Revolutions>
          <c:NextDate><xsl:value-of select="if (next_revolve_date and next_revolve_date != '') then core:dateFormatCCToTIPlus(next_revolve_date)
                                            else if (additional_field//next_revolve_date and additional_field//next_revolve_date != '') then core:dateFormatCCToTIPlus(additional_field//next_revolve_date)
                                            else '' " /></c:NextDate>
          <c:NoticeDays><xsl:value-of select="if (notice_days) then notice_days else additional_field//notice_days" /></c:NoticeDays>
          <c:ChargeToFirstPeriod><xsl:value-of select="if (charge_upto = 'p' or additional_field//charge_upto = 'p') then 'Y'
                                                       else if (charge_upto = 'e' or additional_field//charge_upto = 'e') then 'N'
                                                       else ''" /></c:ChargeToFirstPeriod>
        </m:Revolving>
        <m:Transferable><xsl:value-of select="if (ntrf_flag = 'Y') then 'N'
                                              else if (ntrf_flag = 'N') then 'Y'
                                              else ''" /></m:Transferable>
        <m:ExpiryDate><xsl:value-of select="if (exp_date and exp_date != '') then core:dateFormatCCToTIPlus(exp_date) else '' " /></m:ExpiryDate>
        <m:ApplicationDate><xsl:value-of select="if (appl_date and appl_date != '') then core:dateFormatCCToTIPlus(appl_date) else '' " /></m:ApplicationDate>
        <m:IssueDate><xsl:value-of select="if (iss_date and iss_date != '') then core:dateFormatCCToTIPlus(iss_date) else ''" /></m:IssueDate>
        <m:ExpiryPlace><xsl:value-of select="expiry_place" /></m:ExpiryPlace>
        <m:TermsOfPayment>
          <xsl:variable name="availableBy" select="if (cr_avl_by_code != '') then cr_avl_by_code else additional_field//cr_avl_by_code " />
          <xsl:variable name="tenorType" select="if ((tenor_days != '') or (tenor_period != '') or (tenor_from_after != '') or (tenor_days_type != '') or (tenor_type_details != '')) then 'PERIOD'
                                                 else if (tenor_maturity_date != '') then 'MATURITY'
                                                 else ''" />
          <xsl:if test="$availableBy = ('02', '03', '04')">
            <xsl:if test="$tenorType = 'PERIOD'">
              <xsl:if test="((tenor_days != '') or (tenor_period != ''))">
                <c:Tenor>
                  <c:TenorDays><xsl:value-of select="if (tenor_days != '') then tenor_days else additional_field//tenor_days" /></c:TenorDays>
                  <c:TenorPeriod><xsl:value-of select="if (tenor_period != '') then tenor_period else additional_field//tenor_period" /></c:TenorPeriod>
                </c:Tenor>
              </xsl:if>
              <c:FromAfter><xsl:value-of select="if (tenor_from_after != '') then tenor_from_after else ''" /></c:FromAfter>
              <c:TenorFrom><xsl:value-of select="if (tenor_days_type != '') then params:getTITenorFrom(tenor_days_type) else ''" /></c:TenorFrom>
              <xsl:variable name="isTenorDaysTypeOther" select="if (tenor_days_type = '99' or (not(tenor_days_type) and additional_field//tenor_days_type = '99')) then 'Y' else 'N'" />
              <c:TenorText><xsl:value-of select="if (tenor_days_type = '08') then 'Arrival and Inspection of Goods'
                                                 else if ($isTenorDaysTypeOther = 'Y' and tenor_type_details != '') then tenor_type_details
                                                 else ''" /></c:TenorText>
            </xsl:if>
            <xsl:if test="$tenorType = 'MATURITY'">
              <c:TenorMaturityDate><xsl:value-of select="if (tenor_maturity_date != '') then core:dateFormatCCToTIPlus(tenor_maturity_date)
                                                         else '' " /></c:TenorMaturityDate>
            </xsl:if>
          </xsl:if>
          <c:MixedPayDtls><xsl:value-of select="draft_term" /></c:MixedPayDtls>
          <xsl:variable name="draweeBank" select="drawee_details_bank/name" />
          <xsl:if test="$draweeBank != ''">
            <xsl:choose>
              <xsl:when test="$draweeBank = 'Issuing Bank'"><c:DraftsDrawnOn>I</c:DraftsDrawnOn></xsl:when>
              <xsl:when test="$draweeBank = 'Advising Bank'"><c:DraftsDrawnOn>A</c:DraftsDrawnOn></xsl:when>
              <xsl:when test="$draweeBank = ('Reimbursing Bank', 'Reimbursing')"><c:DraftsDrawnOn>R</c:DraftsDrawnOn></xsl:when>
              <xsl:when test="$draweeBank = 'Ourselves'">
                <c:DraftsDrawnOn>S</c:DraftsDrawnOn>
                <c:DraftsDrawnOnBank><xsl:value-of select = "$draweeBank" /></c:DraftsDrawnOnBank>
              </xsl:when>
              <xsl:otherwise>
                <c:DraftsDrawnOn>O</c:DraftsDrawnOn>
                <c:DraftsDrawnOnBank><xsl:value-of select = "$draweeBank" /></c:DraftsDrawnOnBank>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <c:AvailableBy><xsl:value-of select="params:getTIAvailableBy(cr_avl_by_code)" /></c:AvailableBy>
        </m:TermsOfPayment>
        <xsl:variable name="availableWithBankName" select="upper-case(credit_available_with_bank/name)" />
        <xsl:variable name="availableWithBankAddress" select="credit_available_with_bank/address_line_1" />
        <xsl:variable name="availableWithBankDetails" select="if ($mapAddressLine4) then core:constructNameAndAddress(credit_available_with_bank/name, credit_available_with_bank/address_line_1, credit_available_with_bank/address_line_2, credit_available_with_bank/dom, credit_available_with_bank/address_line_4)
                                                              else core:constructNameAndAddress(credit_available_with_bank/name, credit_available_with_bank/address_line_1, credit_available_with_bank/address_line_2, credit_available_with_bank/dom)" />
        <m:AvailableWith>
          <xsl:variable name="availableWithBankNameType" select="if ($availableWithBankName != '') then
                                                                   if ($availableWithBankName = 'ISSUING BANK') then 'I'
                                                                   else if ($availableWithBankName = 'ANY BANK') then 'W'
                                                                   else if ($availableWithBankName = 'ADVISING BANK') then 'A'
                                                                   else if ($availableWithBankName = 'OURSELVES') then 'S'
                                                                   else if ($availableWithBankName = 'ADVISE THRU BANK') then 'H'
                                                                   else 'O'
                                                                 else ''" />
          <c:Type><xsl:value-of select="$availableWithBankNameType" /></c:Type>
          <c:Bank><xsl:value-of select="if ($availableWithBankNameType = 'O') then $availableWithBankDetails else ''" /></c:Bank>
          <xsl:if test="$availableWithBankNameType = 'O'">
            <c:LegalEntityIdentifier><xsl:value-of select="credit_available_with_bank/lei_code" /></c:LegalEntityIdentifier>
          </xsl:if>
          <c:City><xsl:value-of select="if ($availableWithBankName = 'Any Bank in (city)') then $availableWithBankAddress else '' " /></c:City>
          <c:Ctry><xsl:value-of select="if ($availableWithBankName = 'Any Bank in (country)') then $availableWithBankAddress else '' " /></c:Ctry>
          <xsl:if test="($availableWithBankNameType = 'O')">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="credit_available_with_bank" />
            </xsl:call-template>
          </xsl:if>
        </m:AvailableWith>
        <xsl:if test="ship_from"><m:ShipmentFrom xsi:nil="true"><xsl:value-of select="ship_from" /></m:ShipmentFrom></xsl:if>
        <xsl:if test="ship_to"><m:ShipmentTo xsi:nil="true"><xsl:value-of select="ship_to" /></m:ShipmentTo></xsl:if>
        <m:ShipmentDate><xsl:value-of select="if (last_ship_date and last_ship_date != '') then core:dateFormatCCToTIPlus(last_ship_date) else '' " /></m:ShipmentDate>
        <m:ShipmentPeriod><xsl:value-of select="narrative_shipment_period" /></m:ShipmentPeriod>
        <m:TransShipment><xsl:value-of select="if ($SWIFT2018 = 'Y') then core:getSWIFT2018TransOrPartShipment(tran_ship_detl)
                                               else core:getTransOrPartShipment(tran_ship_detl)" /></m:TransShipment>
        <m:PartShipment><xsl:value-of select="if ($SWIFT2018 = 'Y') then core:getSWIFT2018TransOrPartShipment(part_ship_detl)
                                              else core:getTransOrPartShipment(part_ship_detl)" /></m:PartShipment>
        <m:Incoterm><xsl:value-of select="inco_term" /></m:Incoterm>
        <m:IncoPlace><xsl:value-of select="inco_place" /></m:IncoPlace>
        <m:PresentationDays><xsl:value-of select="period_presentation_days" /></m:PresentationDays>
        <m:PresentationPeriod><xsl:value-of select="narrative_period_presentation" /></m:PresentationPeriod>
        <m:Goods>
          <xsl:value-of select="if ( not(narrative_description_goods/amend) ) then narrative_description_goods
                                else if (narrative_description_goods/amend[1]/operation = 'REPALL')
                                  then narrative_description_goods/amend/text
                                else ''" />
        </m:Goods>
        <m:Documents>
          <xsl:value-of select="if ( not(narrative_documents_required/amend) ) then narrative_documents_required
                                else if (narrative_documents_required/amend[1]/operation = 'REPALL')
                                  then narrative_documents_required/amend/text
                                else ''" />
        </m:Documents>
        <xsl:variable name="additionalConditions">
          <xsl:if test="$SWIFT2018 = 'Y'">
            <xsl:value-of select="if (narrative_full_details != '') then concat(narrative_full_details, '&#10;') else ''" />
            <xsl:value-of select="if (narrative_payment_instructions != '') then concat(narrative_payment_instructions, '&#10;') else ''" />
          </xsl:if>
          <xsl:value-of select="narrative_additional_instructions" />
        </xsl:variable>
        <m:AdditionalConditions>
          <xsl:value-of select="if ( not(narrative_additional_instructions/amend) ) then $additionalConditions
                                else if (narrative_additional_instructions/amend[1]/operation = 'REPALL')
                                  then narrative_additional_instructions/amend/text
                                else ''" />
        </m:AdditionalConditions>
        <xsl:if test="$SWIFT2018 = 'Y'">
          <m:SpecialPaymentConditions>
            <c:ForBeneficiary>
              <xsl:value-of select="if ( not(narrative_special_beneficiary/amend) ) then narrative_special_beneficiary
                                    else if (narrative_special_beneficiary/amend[1]/operation = 'REPALL')
                                      then narrative_special_beneficiary/amend/text
                                    else ''" />
            </c:ForBeneficiary>
            <c:ForReceivingBank>
              <xsl:value-of select="if ( not(narrative_special_recvbank/amend) ) then narrative_special_recvbank
                                    else if (narrative_special_recvbank/amend[1]/operation = 'REPALL')
                                      then narrative_special_recvbank/amend/text
                                    else ''" />
             </c:ForReceivingBank>
          </m:SpecialPaymentConditions>
        </xsl:if>
        <m:IssuanceChgsFor><xsl:value-of select="if (open_chrg_brn_by_code = '01') then 'A'
                                                 else if (open_chrg_brn_by_code = '02') then 'B'
                                                 else ''" /></m:IssuanceChgsFor>
        <m:OverseasChgsFor><xsl:value-of select="if (corr_chrg_brn_by_code = '01') then 'A'
                                                 else if (corr_chrg_brn_by_code = '02') then 'B'
                                                 else ''" /></m:OverseasChgsFor>
        <m:AddAmountText><xsl:value-of select="narrative_additional_amount" /></m:AddAmountText>
        <m:ChargeAccount><xsl:value-of select="fee_act_no" /></m:ChargeAccount>
        <m:PrincipalAccount><xsl:value-of select="principal_act_no" /></m:PrincipalAccount>
        <m:eBankMasterRef><xsl:value-of select="ref_id" /></m:eBankMasterRef>
        <m:eBankEvent><xsl:value-of select="tnx_id" /></m:eBankEvent>
        <xsl:variable name="RulesCode" select="params:getSIRulesCode(applicable_rules)" />
        <xsl:if test="$RulesCode = ('E', 'P', 'I', 'U', 'C', 'O')">
          <m:ApplcableRules><xsl:value-of select="$RulesCode" /></m:ApplcableRules>
          <m:ApplcableRulesNarrative><xsl:value-of select="applicable_rules_text"/></m:ApplcableRulesNarrative>
        </xsl:if>
        <xsl:if test="ship_loading"><m:PortOfLoading xsi:nil="true"><xsl:value-of select="ship_loading" /></m:PortOfLoading></xsl:if>
        <xsl:if test="ship_discharge"><m:PortOfDischarge xsi:nil="true"><xsl:value-of select="ship_discharge" /></m:PortOfDischarge></xsl:if>
        <m:InstructionsToPayingBank><xsl:value-of select="if($SWIFT2018 = 'Y') then narrative_payment_instructions else ''" /></m:InstructionsToPayingBank>
        <!-- LicenseDetails -->
        <xsl:if test="$FTIVersion and $FTIVersion &gt;= 27">
          <xsl:call-template name="linked-licenses" />
        </xsl:if>
        <m:Sender>
          <c:Customer><xsl:value-of select="core:getCustomer(applicant_reference)" /></c:Customer>
        </m:Sender>
        <m:IncreaseAmount>
          <xsl:if test="sub_tnx_type_code='01'">
            <c:Amount><xsl:value-of select="tnx_amt" /></c:Amount>
            <c:Currency><xsl:value-of select="tnx_cur_code" /></c:Currency>
          </xsl:if>
        </m:IncreaseAmount>
        <m:DecreaseAmount>
          <xsl:if test="sub_tnx_type_code='02'">
            <c:Amount><xsl:value-of select="tnx_amt" /></c:Amount>
            <c:Currency><xsl:value-of select="tnx_cur_code" /></c:Currency>
          </xsl:if>
        </m:DecreaseAmount>
        <xsl:if test="$FTIVersion and $FTIVersion &gt;= 28">
          <m:AmendmentDetails>
            <c:AmendmentNumber><xsl:value-of select="amd_no" /></c:AmendmentNumber>
            <xsl:if test="$SWIFT2018 = 'Y'">
              <c:AmendmentChargesBy>
                <c:Code><xsl:value-of select="if (amd_chrg_brn_by_code = '01') then 'A'
                                              else if (amd_chrg_brn_by_code = '02') then 'B'
                                              else if (amd_chrg_brn_by_code = '07') then 'O'
                                              else ''" /></c:Code>
                <c:OtherText><xsl:value-of select="narrative_amend_charges_other" /></c:OtherText>
              </c:AmendmentChargesBy>
            </xsl:if>
          </m:AmendmentDetails>
        </xsl:if>
        <m:AmendmentNarrative><xsl:value-of select="if (tnx_type_code = '13' and sub_tnx_type_code='03') then concat('New customer reference added: ', cust_ref_id)
                                                    else amd_details " /></m:AmendmentNarrative>
        <m:AmendDate><xsl:value-of select="if ($FTIVersion and $FTIVersion &gt;= 25 and amd_date !='') then core:dateFormatCCToTIPlus(amd_date) else ''" /></m:AmendDate>
        <m:LCMasterGoodsAmendments>
          <xsl:if test="narrative_description_goods/amend and narrative_description_goods/amend[1]/operation != 'REPALL'">
            <c:GoodsDescriptionAmendmentInstructions>
              <xsl:for-each select="narrative_description_goods/amend">
                <xsl:call-template name="amendment-instruction" />
              </xsl:for-each>
            </c:GoodsDescriptionAmendmentInstructions>
          </xsl:if>
          <xsl:if test="narrative_documents_required/amend and narrative_documents_required/amend[1]/operation != 'REPALL'">
            <c:DocumentsRequiredAmendmentInstructions>
              <xsl:for-each select="narrative_documents_required/amend">
                <xsl:call-template name="amendment-instruction" />
              </xsl:for-each>
            </c:DocumentsRequiredAmendmentInstructions>
          </xsl:if>
          <xsl:if test="narrative_additional_instructions/amend and narrative_additional_instructions/amend[1]/operation != 'REPALL'">
            <c:AdditionalConditionsAmendmentInstructions>
              <xsl:for-each select="narrative_additional_instructions/amend">
                <xsl:call-template name="amendment-instruction" />
              </xsl:for-each>
            </c:AdditionalConditionsAmendmentInstructions>
          </xsl:if>
        </m:LCMasterGoodsAmendments>
        <xsl:if test="$SWIFT2018 = 'Y'">
        <m:SpecialPaymentConditionsAmendments>
          <xsl:if test="narrative_special_beneficiary/amend and narrative_special_beneficiary/amend[1]/operation != 'REPALL'">
            <c:ForBeneficiaryAmendmentInstructions>
              <xsl:for-each select="narrative_special_beneficiary/amend">
                <xsl:call-template name="amendment-instruction" />
              </xsl:for-each>
            </c:ForBeneficiaryAmendmentInstructions>
          </xsl:if>
          <xsl:if test="narrative_special_recvbank/amend and narrative_special_recvbank/amend[1]/operation != 'REPALL'">
            <c:ForReceivingBankAmendmentInstructions>
              <xsl:for-each select="narrative_special_recvbank/amend">
                <xsl:call-template name="amendment-instruction" />
              </xsl:for-each>
            </c:ForReceivingBankAmendmentInstructions>
          </xsl:if>
        </m:SpecialPaymentConditionsAmendments>
        </xsl:if>
        <xsl:if test="for_account_flag = 'Y'">
          <m:ApplicantBank>
            <c:Customer><xsl:value-of select="alt_applicant_name"/></c:Customer>
            <c:LegalEntityIdentifier><xsl:value-of select="alt_applicant_lei" /></c:LegalEntityIdentifier>
            <xsl:if test="not(alt_applicant_address/town_name)">
              <c:NameAddress><xsl:value-of select="if ($mapAddressLine4) then core:constructNameAndAddress(if (not(alt_applicant_name)) then additional_field//alt_applicant_name else alt_applicant_name,
                                                                                                           if (not(alt_applicant_address_line_1)) then additional_field//alt_applicant_address_line_1 else alt_applicant_address_line_1,
                                                                                                           if (not(alt_applicant_address_line_2)) then additional_field//alt_applicant_address_line_2 else alt_applicant_address_line_2,
                                                                                                           if (not(alt_applicant_dom)) then additional_field//alt_applicant_dom else alt_applicant_dom,
                                                                                                           if (not(alt_applicant_address_line_4)) then additional_field//alt_applicant_address_line_4 else alt_applicant_address_line_4)
                                                   else core:constructNameAndAddress(if (not(alt_applicant_name)) then additional_field//alt_applicant_name else alt_applicant_name,
                                                                                     if (not(alt_applicant_address_line_1)) then additional_field//alt_applicant_address_line_1 else alt_applicant_address_line_1,
                                                                                     if (not(alt_applicant_address_line_2)) then additional_field//alt_applicant_address_line_2 else alt_applicant_address_line_2,
                                                                                     if (not(alt_applicant_dom)) then additional_field//alt_applicant_dom else alt_applicant_dom)" /></c:NameAddress>
            </xsl:if>
            <c:Reference><xsl:value-of select="cust_ref_id" /></c:Reference>
            <c:Country><xsl:value-of select="alt_applicant_country" /></c:Country>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="alt_applicant_address" />
            </xsl:call-template>
          </m:ApplicantBank>
        </xsl:if>
        <xsl:if test="for_account_flag = 'N'">
          <m:ApplicantBank xsi:nil="true">
            <c:Customer xsi:nil="true" require-nil="true"/>
          </m:ApplicantBank>
        </xsl:if>
        <!-- <xsl:call-template name="extra-data" />  -->
        <!-- <xsl:call-template name="customisation-fields" /> -->
      </m:TFILCAMN>
    </ServiceRequest>
  </xsl:template>

  <!--  <xsl:include href="../custom/incoming/lc_tnx_record_to_TFILCAMN_custom.xsl" />  -->
  <xsl:include href="../commons/CChannelsCommons.xsl" />
</xsl:stylesheet>
