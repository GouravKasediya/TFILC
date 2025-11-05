<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
                xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
                xmlns:exsl="http://exslt.org/common"
                exclude-result-prefixes="core params exsl">
  <xsl:template match="tfutidet">
    <bg_tnx_record xsi:noNamespaceSchemaLocation="http://www.neomalogic.com/gtp/interfaces/xsd/iu.xsd"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <xsl:variable name="messageName" select="core:getSourceMessageType(MessageName)"/>
      <xsl:variable name="FCCVersion"><xsl:value-of select="params:getFCCVersion()"/></xsl:variable>
      <xsl:variable name="SWIFT2023"><xsl:value-of select="params:getSWIFT2023()"/></xsl:variable>
      <xsl:variable name="sequence"><xsl:value-of select="if (Sequence != '') then Sequence else '1'"/></xsl:variable>
      <xsl:variable name="isRenewalOrReductionEvents" select="$messageName = ('ARN', 'REN', 'RDI', 'ADI')"/>
      <xsl:variable name="isRejectOrRenewalOrReductionEvents" select="$messageName = ('REJ') or $isRenewalOrReductionEvents"/>
      <xsl:variable name="mapAddressLine4" select="IssueByCode != '4' and not($isRenewalOrReductionEvents) and params:getMapAddressLine4() = 'Y'"/>
      <xsl:variable name="mapAlternateApplicantAsApplicant" select="params:getCCMapAlternateApplicantAsApplicant() = 'Y'
                                                                    and (PrincipalIfNotApplicantPrimeName != '' or PrincipalIfNotApplicantName != '')"/>
      <bo_ref_id><xsl:value-of select="MasterRef"/></bo_ref_id>
      <bo_tnx_id><xsl:value-of select="EventRef"/></bo_tnx_id>
      <claim_cur_code><xsl:value-of select="TotalClaimedCcy"/></claim_cur_code>
      <claim_amt><xsl:value-of select ="core:getCCAmount(TotalClaimedAmt, TotalClaimedAmt)"/></claim_amt>
      <claim_reference><xsl:value-of select="ClaimReference"/></claim_reference>
      <claim_present_date><xsl:value-of select="if (PresentationDate != '') then core:dateFormatTIPlusToCC(PresentationDate, 'PresentationDate') else ''"/></claim_present_date>
      <action_req_code><xsl:value-of select="if ($messageName = 'ACW' and Provisional = 'Y') then '07' else ''"/></action_req_code>
      <tnx_type_code><xsl:value-of select="params:getTransactionTypeCode(MessageName)"/></tnx_type_code>
      <sub_tnx_type_code><xsl:value-of select="if ($messageName = ('AMB', 'AMC', 'AMF', 'AMJ', 'AMK', 'AMP')) then
                                                 if (DecreaseAmount != '') then '02'
                                                 else if (IncreaseAmount != '') then '01'
                                                 else '03'
                                               else if ($messageName = ('ADI', 'RDI')) then
                                                 if (upper-case(Increase) = 'Y') then '01' else '02'
                                               else ''"/></sub_tnx_type_code>
      <xsl:variable name="addReference" select="if ($messageName = ('AMB', 'AMJ', 'AMP')) then
                                                  if (PrincipalRef != '' and substring(AmendNarrative, 31) = PrincipalRef) then 'Y' else 'N'
                                                else ''"/>
      <prod_stat_code><xsl:value-of select="if ($addReference != '') then
                                              if ($addReference = 'Y') then '07'
                                              else '08'
                                            else params:getProductStatCode($messageName, Provisional, FinalWording)"/></prod_stat_code>
      <tnx_stat_code>04</tnx_stat_code>
      <sub_tnx_stat_code><xsl:value-of select="if ($messageName = ('AMB', 'AMC')) then '05'
                                               else ''"/></sub_tnx_stat_code>
      <product_code>BG</product_code>
      <linked_event_reference><xsl:value-of select="LinkedClaimRef" /></linked_event_reference>
      <tnx_val_date xsi:nil="true"><xsl:value-of select="if (TransactionDate != '') then core:dateFormatTIPlusToCC(TransactionDate, 'TransactionDate') else ''"/></tnx_val_date>
      <ref_id><xsl:value-of select="eBankMasterRef"/></ref_id>
      <tnx_id xsi:nil="true"><xsl:value-of select="if (not($messageName = 'ACW' and $sequence = '1')) then eBankEventRef else ''"/></tnx_id>
      <appl_date xsi:nil="true"><xsl:value-of select="if (ApplicationDate != '') then core:dateFormatTIPlusToCC(ApplicationDate, 'ApplicationDate') else ''"/></appl_date>
      <amd_date xsi:nil="true"><xsl:value-of select="if (AmendDate != '') then core:dateFormatTIPlusToCC(AmendDate,'AmendDate') else ''"/></amd_date>
      <amd_no><xsl:value-of select="if ($messageName = ('AMB', 'AMC', 'AMJ', 'AMK') and EventRef != '') then number(substring(EventRef, 4)) 
                                    else if ($messageName = ('AMF', 'AMP') and AmendRef != '') then number(substring(AmendRef, 4)) 
                                    else ''"/></amd_no>   
      <cust_ref_id><xsl:value-of select="if ($messageName = ('ADI', 'RDI')) then ApplicantRef else InstructingPartyRef"/></cust_ref_id>
      <beneficiary_reference><xsl:value-of select="BenRef"/></beneficiary_reference>
      <provisional_status><xsl:value-of select="Provisional"/></provisional_status>
      <xsl:if test="IssueByCode">
        <xsl:variable name="issueByCode"><xsl:value-of select="params:getCCAdviceMethodForProductCode(IssueByCode, 'BG')"/></xsl:variable>
        <adv_send_mode xsi:nil="true"><xsl:value-of select="$issueByCode"/></adv_send_mode>
        <adv_send_mode_text xsi:nil="true"><xsl:value-of select="if ($issueByCode = '99') then IssueByDesc else ''"/></adv_send_mode_text>
      </xsl:if>
      <sub_product_code><xsl:value-of select="FormOfUndertaking"/></sub_product_code>
      <xsl:variable name="referenceID" select="if ($mapAlternateApplicantAsApplicant) then PrincipalID else ApplicantID"/>
      <applicant_abbv_name><xsl:value-of select="$referenceID"/></applicant_abbv_name>
      <xsl:choose>
        <xsl:when test="$mapAlternateApplicantAsApplicant">
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <applicant_name xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeName"/></applicant_name>
              <applicant_address_line_1 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeAddr2"/></applicant_address_line_1>
              <applicant_address_line_2 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeAddr3"/></applicant_address_line_2>
              <applicant_dom xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeAddr4"/></applicant_dom>
              <applicant_address_line_4 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeAddr5"/></applicant_address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <applicant_name xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantName"/></applicant_name>
              <applicant_address_line_1 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantAddr2"/></applicant_address_line_1>
              <applicant_address_line_2 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantAddr3"/></applicant_address_line_2>
              <applicant_dom xsi:nil="true"><xsl:value-of select="core:getDom(PrincipalIfNotApplicantAddr4, PrincipalIfNotApplicantAddr5)"/></applicant_dom>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <applicant_name xsi:nil="true"><xsl:value-of select="ApplicantPrimeName"/></applicant_name>
              <applicant_address_line_1 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr2"/></applicant_address_line_1>
              <applicant_address_line_2 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr3"/></applicant_address_line_2>
              <applicant_dom xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr4"/></applicant_dom>
              <applicant_address_line_4 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr5"/></applicant_address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <applicant_name xsi:nil="true"><xsl:value-of select="ApplicantName"/></applicant_name>
              <applicant_address_line_1 xsi:nil="true"><xsl:value-of select="ApplicantAdr2"/></applicant_address_line_1>
              <applicant_address_line_2 xsi:nil="true"><xsl:value-of select="ApplicantAdr3"/></applicant_address_line_2>
              <applicant_dom xsi:nil="true"><xsl:value-of select="core:getDom(ApplicantAdr4, ApplicantAdr5)"/></applicant_dom>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <applicant_country><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then PrincipalIfNotApplicantCountry else ApplicantCountry"/></applicant_country>
      <applicant_reference><xsl:value-of select="($referenceID, ZoneID, MBE, BehalfOfBranch)" separator="."/></applicant_reference>
      <applicant_address>
        <xsl:choose>
          <xsl:when test="$mapAlternateApplicantAsApplicant">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'PrincipalIfNotApplicant'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'Applicant'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </applicant_address>
      <applicant_lei xsi:nil="true"><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then PrincipalIfNotApplicantLEI else ApplicantLEI"/></applicant_lei>
      <xsl:choose>
        <xsl:when test="$mapAlternateApplicantAsApplicant">
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <alt_applicant_name xsi:nil="true"><xsl:value-of select="ApplicantPrimeName"/></alt_applicant_name>
              <alt_applicant_address_line_1 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr2"/></alt_applicant_address_line_1>
              <alt_applicant_address_line_2 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr3"/></alt_applicant_address_line_2>
              <alt_applicant_dom xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr4"/></alt_applicant_dom>
              <alt_applicant_address_line_4 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr5"/></alt_applicant_address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <alt_applicant_name xsi:nil="true"><xsl:value-of select="ApplicantName"/></alt_applicant_name>
              <alt_applicant_address_line_1 xsi:nil="true"><xsl:value-of select="ApplicantAdr2"/></alt_applicant_address_line_1>
              <alt_applicant_address_line_2 xsi:nil="true"><xsl:value-of select="ApplicantAdr3"/></alt_applicant_address_line_2>
              <alt_applicant_dom xsi:nil="true"><xsl:value-of select="core:getDom(ApplicantAdr4, ApplicantAdr5)"/></alt_applicant_dom>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <alt_applicant_name xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeName"/></alt_applicant_name>
              <alt_applicant_address_line_1 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeAddr2"/></alt_applicant_address_line_1>
              <alt_applicant_address_line_2 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeAddr3"/></alt_applicant_address_line_2>
              <alt_applicant_dom xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeAddr4"/></alt_applicant_dom>
              <alt_applicant_address_line_4 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantPrimeAddr5"/></alt_applicant_address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <alt_applicant_name xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantName"/></alt_applicant_name>
              <alt_applicant_address_line_1 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantAddr2"/></alt_applicant_address_line_1>
              <alt_applicant_address_line_2 xsi:nil="true"><xsl:value-of select="PrincipalIfNotApplicantAddr3"/></alt_applicant_address_line_2>
              <alt_applicant_dom xsi:nil="true"><xsl:value-of select="core:getDom(PrincipalIfNotApplicantAddr4, PrincipalIfNotApplicantAddr5)"/></alt_applicant_dom>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <alt_applicant_country><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then ApplicantCountry else PrincipalIfNotApplicantCountry"/></alt_applicant_country>
      <alt_applicant_address>
        <xsl:choose>
          <xsl:when test="$mapAlternateApplicantAsApplicant">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'Applicant'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'PrincipalIfNotApplicant'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </alt_applicant_address>
      <alt_applicant_lei xsi:nil="true"><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then ApplicantLEI else PrincipalIfNotApplicantLEI"/></alt_applicant_lei>
      <beneficiary_abbv_name><xsl:value-of select="BeneficiaryID"/></beneficiary_abbv_name>
      <xsl:choose>
        <xsl:when test="$mapAddressLine4">
          <beneficiary_name><xsl:value-of select="BeneficiaryPrimeName"/></beneficiary_name>
          <beneficiary_address_line_1 xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeAdr2"/></beneficiary_address_line_1>
          <beneficiary_address_line_2 xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeAdr3"/></beneficiary_address_line_2>
          <beneficiary_dom xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeAdr4"/></beneficiary_dom>
          <beneficiary_address_line_4 xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeAdr5"/></beneficiary_address_line_4>
        </xsl:when>
        <xsl:otherwise>
          <beneficiary_name><xsl:value-of select="BeneficiaryName"/></beneficiary_name>
          <beneficiary_address_line_1 xsi:nil="true"><xsl:value-of select="BeneficiaryAdr2"/></beneficiary_address_line_1> 
          <beneficiary_address_line_2 xsi:nil="true"><xsl:value-of select="BeneficiaryAdr3"/></beneficiary_address_line_2> 
          <beneficiary_dom xsi:nil="true"><xsl:value-of select="core:getDom(BeneficiaryAdr4, BeneficiaryAdr5)"/></beneficiary_dom>  
        </xsl:otherwise>
      </xsl:choose>
      <beneficiary_country><xsl:value-of select="BenCountry"/></beneficiary_country>
      <beneficiary_address>
        <xsl:call-template name="mt-mx-address">
          <xsl:with-param name="party" select="'Beneficiary'"/>
        </xsl:call-template>
      </beneficiary_address>
      <beneficiary_lei xsi:nil="true"><xsl:value-of select="BeneficiaryLEI"/></beneficiary_lei>
      <xsl:if test="not($isRejectOrRenewalOrReductionEvents)">
        <issuing_bank_type_code><xsl:value-of select="if (IssuingBankName != '' and OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then '02'
                                                      else '01'"/></issuing_bank_type_code>
      </xsl:if>
      <xsl:variable name="productTypeCode">
        <xsl:value-of select="if (params:getFTIVersion() = '28' or OurRequestTypeCodeSend = ('ISSU', 'ISUA')) then params:getFCCUTProductType(ProductTypeCode)
                              else params:getFCCLocalUTProductType(ProductTypeCode)"/>
      </xsl:variable>
      <bg_type_code><xsl:value-of select="$productTypeCode"/></bg_type_code>
      <bg_type_details xsi:nil="true"><xsl:value-of select="if ($productTypeCode = '99') then ProductTypeLongName else ''"/></bg_type_details>
      <iss_date_type_code><xsl:value-of select="if (IssueDate != '') then '99'
                                                else ''"/></iss_date_type_code>
      <iss_date_type_details><xsl:value-of select="if (IssueDate != '') then core:dateFormatTIPlusToCC(IssueDate, 'IssueDate')
                                                   else ''"/></iss_date_type_details>
      <iss_date xsi:nil="true"><xsl:value-of select="if (IssueDate != '') then core:dateFormatTIPlusToCC(IssueDate, 'IssueDate')
                                                     else ''"/></iss_date>
      <cu_effective_date_type_code><xsl:value-of select="if (IssueDateSend != '') then '99'
                                                         else ''"/></cu_effective_date_type_code>
      <cu_effective_date_type_details><xsl:value-of select="if (IssueDateSend != '') then 
                                                               core:dateFormatTIPlusToCC(IssueDateSend, 'IssueDateSend')
                                                            else ''"/></cu_effective_date_type_details>
      <exp_date_type_code><xsl:value-of select="if (ExpiryType = 'Y') then '01'
                                                else if (ExpiryType = 'N') then '02'
                                                else if (ExpiryType = 'C') then '03'
                                                else ''"/></exp_date_type_code>
      <xsl:choose>
        <xsl:when test="ExpiryType = 'Y'">
          <xsl:if test="not($isRenewalOrReductionEvents)">
            <approx_expiry_date xsi:nil="true"><xsl:value-of select="if (ApproxExpiryDate != '') then core:dateFormatTIPlusToCC(ApproxExpiryDate, 'ApproxExpiryDate') else ''"/></approx_expiry_date>
          </xsl:if>
        </xsl:when>
        <xsl:when test="ExpiryType = 'N'">
          <exp_date xsi:nil="true"><xsl:value-of select="if (ExpiryDate != '') then core:dateFormatTIPlusToCC(ExpiryDate, 'ExpiryDate') else ''"/></exp_date>
        </xsl:when>
        <xsl:when test="ExpiryType = 'C'">
          <projected_expiry_date xsi:nil="true"><xsl:value-of select="if (ExpiryDate != '') then core:dateFormatTIPlusToCC(ExpiryDate, 'ExpiryDate') else ''"/></projected_expiry_date>
          <exp_event xsi:nil="true"><xsl:value-of select="ExpiryCondition"/></exp_event>
        </xsl:when>
      </xsl:choose>
      <bg_cur_code><xsl:value-of select="Currency"/></bg_cur_code>
      <bg_amt><xsl:value-of select="core:getCCAmount(Amount, Currency)"/></bg_amt>
      <tnx_cur_code><xsl:value-of select="TnxCurrency"/></tnx_cur_code>
      <tnx_amt><xsl:value-of select="if (IncreaseAmount != '') then core:getCCAmount(IncreaseAmount, TnxCurrency)
                                     else if (DecreaseAmount != '') then core:getCCAmount(DecreaseAmount, TnxCurrency)
                                     else core:getCCAmount(TnxAmount, TnxCurrency)" /></tnx_amt>
      <bg_liab_amt><xsl:value-of select="core:getCCAmount(LiabAmount, LiabCurrency)"/></bg_liab_amt>
      <bg_outstanding_amt><xsl:value-of select="core:getCCAmount(OutstandingAmount, OutstandingCcy)"/></bg_outstanding_amt>
      <bg_available_amt><xsl:value-of select="core:getCCAmount(AvailableAmt, AvailableCcy)"/></bg_available_amt>
      <open_chrg_brn_by_code><xsl:value-of select="if (upper-case(IssuanceChgsFor) = 'A') then '01'
                                                   else if (upper-case(IssuanceChgsFor) = 'B') then '02'
                                                   else ''"/></open_chrg_brn_by_code>
      <corr_chrg_brn_by_code><xsl:value-of select="if (upper-case(OverseasChgsFor) = 'A') then '01'
                                                   else if (upper-case(OverseasChgsFor) = 'B') then '02'
                                                   else ''"/></corr_chrg_brn_by_code>
      <!-- Local Undertaking Renewals -->
      <xsl:call-template name="undertaking-renewals"/>
      <contract_ref><xsl:value-of select="ReferenceCode"/></contract_ref>
      <contract_narrative><xsl:value-of select="ReferenceNarrative"/></contract_narrative>
      <contract_date><xsl:value-of select="if (ReferenceDate != '') then core:dateFormatTIPlusToCC(ReferenceDate, 'ReferenceDate') else ''"/></contract_date>
      <tender_expiry_date><xsl:value-of select="if (TenderClosingDate != '') then core:dateFormatTIPlusToCC(TenderClosingDate, 'TenderClosingDate') else ''"/></tender_expiry_date>
      <contract_cur_code><xsl:value-of select="TotalOrderCurrency"/></contract_cur_code>
      <contract_amt><xsl:value-of select="core:getCCAmount(TotalOrderAmount, TotalOrderCurrency)"/></contract_amt>
      <contract_pct><xsl:value-of select="GuaranteeValuePercent"/></contract_pct>
      <bg_rule xsi:nil="true"><xsl:value-of select="if (ApplicableRule != '') then
                                                      if (ApplicableRule = 'URDG') then '06'
                                                      else if (ApplicableRule = 'ISPR') then '07'
                                                      else if (ApplicableRule = 'NONE') then '09'
                                                      else if (ApplicableRule = 'UCPR') then '10'
                                                      else '99'
                                                    else ''"/></bg_rule>
      <bg_rule_other xsi:nil="true"><xsl:value-of select="ApplicableRuleOther"/></bg_rule_other>
      <text_language><xsl:value-of select="if (TextOfUndtWordingsLanguage != '') then
                                             if (TextOfUndtWordingsLanguage = ('AR', 'FR')) then lower-case(TextOfUndtWordingsLanguage)
                                             else if (TextOfUndtWordingsLanguage = 'EN') then 'us'
                                             else if (TextOfUndtWordingsLanguage = 'GB') then 'en'
                                             else '*'
                                           else ''"/></text_language>
      <text_language_other><xsl:value-of select="TextOfUndtWordingsLanguage"/></text_language_other>
      <bg_text_type_code><xsl:value-of select="if (TextOfUndtWordingsTypeCode = 'S') then '01'
                                               else if (TextOfUndtWordingsTypeCode = 'B') then '02'
                                               else if (TextOfUndtWordingsTypeCode = 'A') then '03'
                                               else '04'"/></bg_text_type_code>
      <bg_text_type_details><xsl:value-of select="TextOfUndtWordingsType"/></bg_text_type_details>
      <principal_act_no xsi:nil="true"><xsl:value-of select="PrincipalAccount"/></principal_act_no>
      <fee_act_no xsi:nil="true"><xsl:value-of select="ChargeAccount"/></fee_act_no>
      <xsl:if test="DeliveryToCollectionByCode">
        <delivery_to xsi:nil="true"><xsl:value-of select="if (DeliveryToCollectionByCode != '') then
                                                            if (DeliveryToCollectionByCode = 'BENE') then '03'
                                                            else '04'
                                                          else ''"/></delivery_to>
        <delivery_to_other xsi:nil="true"><xsl:value-of select="if ($SWIFT2023 = 'Y') then DeliveryToNarrative
                                                                else if (DeliveryToCollectionByCode = 'OTHR') then DeliveryParty
                                                                else ''"/></delivery_to_other>
      </xsl:if>
      <purpose><xsl:value-of select="if (OurRequestTypeCodeSend = ('ISSU', 'ISUA')) then '01'
                                     else if (OurRequestTypeCodeSend = ('ICCA', 'ISCA', 'ISCO')) then '02'
                                     else if (OurRequestTypeCodeSend = 'ICCO') then '03'
                                     else ''"/></purpose>
      <bg_transfer_indicator><xsl:value-of select="TransferIndicator"/></bg_transfer_indicator>
      <bg_conf_instructions><xsl:value-of select="if (ConfirmationInstructions = 'C') then '01'
                                                  else if (ConfirmationInstructions = 'M') then '02'
                                                  else '03'"/></bg_conf_instructions>
      <bei_code><xsl:value-of select="BenSWIFTBIC"/></bei_code>
      <bg_tolerance_positive_pct><xsl:value-of select="PercentagePlus"/></bg_tolerance_positive_pct>
      <bg_tolerance_negative_pct><xsl:value-of select="PercentageMinus"/></bg_tolerance_negative_pct>
      <conf_chrg_brn_by_code xsi:nil="true"><xsl:value-of select="if (upper-case(ConfirmationCharges) = 'A') then '01'
                                                                  else if (upper-case(ConfirmationCharges) = 'B') then '02'
                                                                  else ''"/></conf_chrg_brn_by_code>
      <cancellation_req_flag><xsl:value-of select="RequestFromCorporateToCancel"/></cancellation_req_flag>
      <xsl:if test="GoverningLawCountryCode">
        <bg_govern_country xsi:nil="true"><xsl:value-of select="GoverningLawCountryCode"/></bg_govern_country>
        <xsl:if test="$SWIFT2023 = 'Y'">
          <bg_govern_country_subdiv xsi:nil="true"><xsl:value-of select="GoverningLawCountrySubDiv"/></bg_govern_country_subdiv>
        </xsl:if>
        <bg_govern_text xsi:nil="true"><xsl:value-of select="GoverningLawText"/></bg_govern_text>
      </xsl:if>
      <delv_org_undertaking xsi:nil="true"><xsl:value-of select="if (DeliveryOfUndertakingCode != '') then
                                                                   if (DeliveryOfUndertakingCode = 'COLL') then '01'
                                                                   else if (DeliveryOfUndertakingCode = 'COUR') then '02'
                                                                   else if (DeliveryOfUndertakingCode = 'MAIL') then '03'
                                                                   else if (DeliveryOfUndertakingCode = 'MESS') then '04'
                                                                   else if (DeliveryOfUndertakingCode = 'REGM') then '05'
                                                                   else '99'
                                                                 else ''"/></delv_org_undertaking>
      <delv_org_undertaking_text xsi:nil="true"><xsl:value-of select="DeliveryOfUndertakingOther"/></delv_org_undertaking_text>
      <credit_available_with_bank xsi:nil="true">
        <xsl:choose>
          <xsl:when test="AvailableWith = ('F', 'H', 'I', 'O')">
            <xsl:if test="not(AvailableWithBankMXName) or AvailableWithBankMXName =''">
              <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then AvailableWithBankPrimeName
                                                         else AvailableWithBankName"/></name>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$mapAddressLine4">
                <address_line_1 xsi:nil="true"><xsl:value-of select="AvailableWithBankPrimeAdr2"/></address_line_1>
                <address_line_2 xsi:nil="true"><xsl:value-of select="AvailableWithBankPrimeAdr3"/></address_line_2>
                <dom xsi:nil="true"><xsl:value-of select="AvailableWithBankPrimeAdr4"/></dom>
                <address_line_4 xsi:nil="true"><xsl:value-of select="AvailableWithBankPrimeAdr5"/></address_line_4>
              </xsl:when>
              <xsl:otherwise>
                <address_line_1 xsi:nil="true"><xsl:value-of select="AvailableWithBankAdr2"/></address_line_1>
                <address_line_2 xsi:nil="true"><xsl:value-of select="AvailableWithBankAdr3"/></address_line_2>
                <dom xsi:nil="true"><xsl:value-of select="AvailableWithBankAdr4"/></dom>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'AvailableWithBank'"/>
            </xsl:call-template>
            <lei_code xsi:nil="true"><xsl:value-of select="AvailableWithBankLEI"/></lei_code>
          </xsl:when>
          <xsl:otherwise>
            <name xsi:nil="true"><xsl:value-of select="if (AvailableWith = 'A') then 'Advising Bank'
                                                       else if (AvailableWith = 'S') then 'Issuing Bank'
                                                       else if (AvailableWith = 'T') then 'Any Bank in (city)'
                                                       else if (AvailableWith = 'U') then 'Any Bank in (country)'
                                                       else if (AvailableWith = 'W') then 'Any Bank'
                                                       else if (AvailableWith = 'H') then 'Advise Thru Bank'
                                                       else ''"/></name>
            <address_line_1 xsi:nil="true"><xsl:value-of select="if (AvailableWith = 'T') then AvailableWithCity
                                                                 else if (AvailableWith = 'U') then AvailableWithCtry
                                                                 else ''"/></address_line_1>
            <address_line_2 xsi:nil="true"/>
            <dom xsi:nil="true"/>
          </xsl:otherwise>
        </xsl:choose>
      </credit_available_with_bank>
      <xsl:if test="Trade = 'Y'">
        <xsl:variable name="partShipment" select="PartShipment"/>
        <xsl:if test="$partShipment != ''">
          <part_ship_detl><xsl:value-of select="if ($partShipment = 'Conditional (See additional conditions)') then 'CONDITIONAL'
                                                else upper-case($partShipment)"/></part_ship_detl>
        </xsl:if>
        <xsl:variable name="transShipment" select="TransShipment"/>
        <xsl:if test="$transShipment != ''">
          <tran_ship_detl><xsl:value-of select="if ($transShipment = 'Conditional (See additional conditions)') then 'CONDITIONAL'
                                                else upper-case($transShipment)"/></tran_ship_detl>
        </xsl:if>
      </xsl:if>
      <ship_from xsi:nil="true"><xsl:value-of select="ShipmentFrom"/></ship_from>
      <ship_loading xsi:nil="true"><xsl:value-of select="PortOfLoading"/></ship_loading>
      <ship_discharge xsi:nil="true"><xsl:value-of select="PortOfDischarge"/></ship_discharge>
      <ship_to xsi:nil="true"><xsl:value-of select="ShipmentTo"/></ship_to>
      <inco_term xsi:nil="true"><xsl:value-of select="Incoterm"/></inco_term>
      <inco_place xsi:nil="true"><xsl:value-of select="Incoplace"/></inco_place>
      <last_ship_date xsi:nil="true"><xsl:value-of select="if (ShipmentDate != '' and ShipmentPeriodAll = '') then core:dateFormatTIPlusToCC(ShipmentDate, 'ShipmentDate') else ''"/></last_ship_date>
      <narrative_shipment_period xsi:nil="true"><xsl:value-of select="core:getFormattedNarrative(ShipmentPeriodAll)"/></narrative_shipment_period>
      <xsl:if test="not($isRenewalOrReductionEvents or $messageName='REJ')">
        <period_presentation_days xsi:nil="true"><xsl:value-of select="PresentationPeriodDays"/></period_presentation_days>
        <narrative_period_presentation xsi:nil="true"><xsl:value-of select="core:getFormattedNarrative(PresentationPeriodText)"/></narrative_period_presentation>
        <bg_demand_indicator xsi:nil="true"><xsl:value-of select="if (PartialDrawingsFlag = 'N' and MultipleDrawingsFlag = 'N') then 'NMPT'
                                                                  else if (PartialDrawingsFlag = 'Y' and MultipleDrawingsFlag = 'N') then 'NMLT'
                                                                  else if (PartialDrawingsFlag = 'N' and MultipleDrawingsFlag = 'Y') then 'NPRT'
                                                                  else if (PartialDrawingsFlag = 'Y' and MultipleDrawingsFlag = 'Y') then 'PMPT'
                                                                  else ''"/></bg_demand_indicator>
      </xsl:if>
      <!-- Variation for Reduction/Increase of Local Undertaking -->
      <xsl:call-template name="variation-local-undertaking"/>
      <xsl:if test="OurRequestTypeCodeSend = ('ISCO', 'ICCO', 'ISCA', 'ICCA')">
        <cu_sub_product_code><xsl:value-of select="FormOfUndertakingSend"/></cu_sub_product_code>
        <cu_type_code><xsl:value-of select="params:getFCCUTProductType(ProductTypeCodeSend)"/></cu_type_code>
        <cu_exp_date_type_code><xsl:value-of select="if (ExpiryTypeSend = 'Y') then '01'
                                                     else if (ExpiryTypeSend = 'N') then '02'
                                                     else if (ExpiryTypeSend = 'C') then '03'
                                                     else ''"/></cu_exp_date_type_code>
        <xsl:choose>
          <xsl:when test="ExpiryTypeSend = 'Y'">
            <xsl:if test="not($isRenewalOrReductionEvents)">
              <cu_approx_expiry_date xsi:nil="true"><xsl:value-of select="if (ApproxExpiryDateSend != '') then core:dateFormatTIPlusToCC(ApproxExpiryDateSend, 'ApproxExpiryDateSend') else ''"/></cu_approx_expiry_date>
            </xsl:if>
          </xsl:when>
          <xsl:when test="ExpiryTypeSend = 'N'">
            <cu_exp_date xsi:nil="true"><xsl:value-of select="if (ExpiryDateSend != '') then core:dateFormatTIPlusToCC(ExpiryDateSend, 'ExpiryDateSend') else ''"/></cu_exp_date>
          </xsl:when>
          <xsl:when test="ExpiryTypeSend = 'C'">
            <cu_projected_expiry_date xsi:nil="true"><xsl:value-of select="if (ExpiryDateSend != '') then core:dateFormatTIPlusToCC(ExpiryDateSend, 'ExpiryDateSend') else ''"/></cu_projected_expiry_date>
            <cu_exp_event xsi:nil="true"><xsl:value-of select="ExpiryConditionSend"/></cu_exp_event>
          </xsl:when>
        </xsl:choose>
        <cu_cur_code><xsl:value-of select="CurrencySend"/></cu_cur_code>
        <cu_amt><xsl:value-of select="core:getCCAmount(AmountSend, CurrencySend)"/></cu_amt>
        <cu_tnx_cur_code><xsl:value-of select="if (DecreaseAmountCurrencySend != '') then DecreaseAmountCurrencySend
                                               else if (IncreaseAmountCurrencySend != '') then IncreaseAmountCurrencySend
                                               else TnxCurrencySend"/></cu_tnx_cur_code>
        <cu_tnx_amt><xsl:value-of select="if (DecreaseAmountSend != '') then core:getCCAmount(DecreaseAmountSend, DecreaseAmountCurrencySend)
                                          else if (IncreaseAmountSend != '') then core:getCCAmount(IncreaseAmountSend, IncreaseAmountCurrencySend)
                                          else core:getCCAmount(TnxAmountSend, TnxCurrencySend)"/></cu_tnx_amt>
        <cu_available_amt><xsl:value-of select="core:getCCAmount(AvailableAmt, AvailableCcy)"/></cu_available_amt>
        <cu_tolerance_positive_pct><xsl:value-of select="PercentagePlusSend"/></cu_tolerance_positive_pct>
        <cu_tolerance_negative_pct><xsl:value-of select="PercentageMinusSend"/></cu_tolerance_negative_pct>
        <!-- Counter Undertaking Renewal - Start -->
        <xsl:variable name="isRegularCalendarDaysSend" select="if (((upper-case(RenewalBasisTypeSend) = 'REGULAR RENEWAL') and (upper-case(RegularRenewOnTypeSend) = 'CALENDAR DAYS'))) then 'Y' else ''"/>
        <cu_renew_flag xsi:nil="true"><xsl:value-of select="RenewalSend"/></cu_renew_flag>
        <cu_renewal_type xsi:nil="true"><xsl:value-of select="if (upper-case(RenewalBasisTypeSend) = 'REGULAR RENEWAL') then '01'
                                                              else if (upper-case(RenewalBasisTypeSend) = 'FIRST RENEWAL/ROLLING RENEWAL') then '02'
                                                              else ''"/></cu_renewal_type>
        <cu_renew_on_code xsi:nil="true"><xsl:value-of select="if ((upper-case(RenewalBasisTypeSend) = 'FIRST RENEWAL/ROLLING RENEWAL') and RenewalOnExpirySend = 'Y') then '01'
                                                               else if ($isRegularCalendarDaysSend = 'Y' or RenewalOnCalendarDateSend = 'Y') then '02'
                                                               else ''"/></cu_renew_on_code>
        <cu_renew_for_nb xsi:nil="true"><xsl:value-of select="if ($isRegularCalendarDaysSend = 'Y') then RenewalCalendarDaysSend
                                                              else core:getFirstArrayIndex(RenewForSend)"/></cu_renew_for_nb>
        <cu_renew_for_period xsi:nil="true"><xsl:value-of select="if ($isRegularCalendarDaysSend = 'Y') then 'D'
                                                                  else if (((upper-case(RenewalBasisTypeSend) = 'REGULAR RENEWAL') and (upper-case(RegularRenewOnTypeSend) = 'OTHER'))) then core:getRenewForPeriod(RegularRenewForSend)
                                                                  else core:getRenewForPeriod(RenewForSend)"/></cu_renew_for_period>
        <cu_advise_renewal_flag xsi:nil="true"><xsl:value-of select="AdviseRenewalSend"/></cu_advise_renewal_flag>
        <cu_advise_renewal_days_nb xsi:nil="true"><xsl:value-of select="AdviseRenewalNoticeDaysSend"/></cu_advise_renewal_days_nb>
        <cu_final_expiry_date xsi:nil="true"><xsl:value-of select="if (AdjustedFinalExpiryDateSend != '') then core:dateFormatTIPlusToCC(AdjustedFinalExpiryDateSend, 'AdjustedFinalExpiryDateSend')
                                                                   else if (FinalExpiryDateSend != '') then core:dateFormatTIPlusToCC(FinalExpiryDateSend, 'FinalExpiryDateSend')
                                                                   else ''"/></cu_final_expiry_date>
        <cu_renew_amt_code xsi:nil="true"><xsl:value-of select="if (RenewalSend = 'Y') then
                                                                  if (RenewalAmountOnSend = 'Original') then '01'
                                                                  else if (RenewalAmountOnSend = 'Current') then '02'
                                                                  else ''
                                                                else ''"/></cu_renew_amt_code>
        <cu_rolling_cancellation_days xsi:nil="true"><xsl:value-of select="RollingRenewalCancellationNoticeSend"/></cu_rolling_cancellation_days>
        <xsl:if test="upper-case(RollingRenewalSend) = 'Y'">
          <cu_renewal_calendar_date xsi:nil="true"><xsl:value-of select="if (RenewalCalendarDateSend != '') then core:dateFormatTIPlusToCC(RenewalCalendarDateSend,'RenewalCalendarDateSend') else ''"/></cu_renewal_calendar_date>
          <cu_rolling_renewal_flag xsi:nil="true"><xsl:value-of select="RollingRenewalSend"/></cu_rolling_renewal_flag>
          <cu_rolling_renewal_nb xsi:nil="true"><xsl:value-of select="RollingRenewalNumberSend"/></cu_rolling_renewal_nb>
          <xsl:variable name="rollingRenewalForPeriodSend" select="core:getRenewForPeriod(RollingRenewalForSend)"/>
          <cu_rolling_day_in_month xsi:nil="true"><xsl:value-of select="if ($rollingRenewalForPeriodSend = ('M', 'Q', 'Y')) then core:getRollingDayInMonth(RollingRenewalForSend) else ''"/></cu_rolling_day_in_month>
          <cu_rolling_renew_for_period xsi:nil="true"><xsl:value-of select="$rollingRenewalForPeriodSend"/></cu_rolling_renew_for_period>
          <cu_rolling_renew_for_nb xsi:nil="true"><xsl:value-of select="core:getFirstArrayIndex(RollingRenewalForSend)"/></cu_rolling_renew_for_nb>
          <cu_rolling_renew_on_code xsi:nil="true"><xsl:value-of select="if (upper-case(RollingRenewalOnSend) = 'EXPIRY')then '01'
                                                                         else if (upper-case(RollingRenewalOnSend) = 'EVERY') then '02'
                                                                         else ''"/></cu_rolling_renew_on_code>
        </xsl:if>
        <!-- Counter Undertaking Renewal - End -->
        <cu_rule xsi:nil="true"><xsl:value-of select="if (ApplicableRuleSend != '') then
                                                        if (ApplicableRuleSend = 'URDG') then '06'
                                                        else if (ApplicableRuleSend = 'ISPR') then '07'
                                                        else if (ApplicableRuleSend = 'NONE') then '09'
                                                        else if (ApplicableRuleSend = 'UCPR') then '10'
                                                        else '99'
                                                      else ''"/></cu_rule>
        <cu_rule_other><xsl:value-of select="ApplicableRuleOtherSend"/></cu_rule_other>
        <xsl:if test="GoverningLawCountryCodeSend">
          <cu_govern_country xsi:nil="true"><xsl:value-of select="GoverningLawCountryCodeSend"/></cu_govern_country>
          <xsl:if test="$SWIFT2023 = 'Y'">
            <cu_govern_country_subdiv xsi:nil="true"><xsl:value-of select="GoverningLawCountrySubDivSend"/></cu_govern_country_subdiv>
          </xsl:if>
          <cu_govern_text xsi:nil="true"><xsl:value-of select="GoverningLawTextSend"/></cu_govern_text>
        </xsl:if>
        <xsl:if test="not($isRenewalOrReductionEvents or $messageName='REJ')">
          <cu_demand_indicator xsi:nil="true"><xsl:value-of select="if (MultipleDrawingsFlagSend = 'N' and PartialDrawingsFlagSend = 'N') then 'NMPT'
                                                                  else if (MultipleDrawingsFlagSend = 'Y' and PartialDrawingsFlagSend = 'N') then 'NPRT'
                                                                  else if (MultpleDrawingsFlagSend = 'N' and PartialDrawingsFlagSend = 'Y') then 'NMLT'
                                                                  else if (PartialDrawingsFlagSend = 'Y' and MultipleDrawingsFlagSend = 'Y') then 'PMPT'
                                                                  else ''"/></cu_demand_indicator>
        </xsl:if>
        <cu_beneficiary>
          <abbv_name><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankID
                                           else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankID
                                           else ''"/></abbv_name>
          <xsl:if test="(OurRequestTypeCodeSend = ('ICCO', 'ICCA') and (not(FinalIssuingBankMXName) or FinalIssuingBankMXName = ''))">
            <name><xsl:value-of select="if ($mapAddressLine4) then FinalIssuingBankPrimeName else FinalIssuingBankName"/></name>
          </xsl:if>
          <xsl:if test="(OurRequestTypeCodeSend = ('ISCO', 'ISCA') and (not(IssuingBankNameMXName) or IssuingBankNameMXName = ''))">
            <name><xsl:value-of select="if ($mapAddressLine4) then IssuingBankPrimeName else IssuingBankName"/></name>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <address_line_1><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankPrimeAdr2
                                                    else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankPrimeAdr2
                                                    else ''"/></address_line_1>
              <address_line_2><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankPrimeAdr3
                                                    else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankPrimeAdr3
                                                    else ''"/></address_line_2>
              <dom><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankPrimeAdr4
                                         else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankPrimeAdr4
                                         else ''"/></dom>
              <address_line_4><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankPrimeAdr5
                                                    else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankPrimeAdr5
                                                    else ''"/></address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <address_line_1><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankAdr2
                                                    else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankAdr2
                                                    else ''"/></address_line_1>
              <address_line_2><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankAdr3
                                                    else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankAdr3
                                                    else ''"/></address_line_2>
              <dom><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then core:getDom(FinalIssuingBankAdr4, FinalIssuingBankAdr5)
                                         else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then core:getDom(IssuingBankAdr4, IssuingBankAdr5)
                                         else ''"/></dom>
            </xsl:otherwise>
          </xsl:choose>
          <reference><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankRef
                                           else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankRef
                                           else ''"/></reference>
          <country><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankCountryCode
                                         else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankCountryCode
                                         else ''"/></country>
          <iso_code><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankSWIFTBIC
                                          else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankSWIFTBIC
                                          else ''"/></iso_code>
          <xsl:if test="(OurRequestTypeCodeSend = ('ICCO', 'ICCA'))">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'FinalIssuingBank'"/>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="(OurRequestTypeCodeSend = ('ISCO', 'ISCA'))">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'IssuingBank'"/>
            </xsl:call-template>
          </xsl:if>
          <lei_code><xsl:value-of select="if (OurRequestTypeCodeSend = ('ICCO', 'ICCA')) then FinalIssuingBankLEI
                                          else if (OurRequestTypeCodeSend = ('ISCO', 'ISCA')) then IssuingBankLEI
                                          else ''"/></lei_code>
        </cu_beneficiary>
        <!-- Counter Reduction/Increase - Start -->
        <cu_variation>
          <xsl:if test="RegularRedIncSend">
            <type xsi:nil="true"><xsl:value-of select="if (RegularRedIncSend = 'Y') then '01'
                                                       else if (IrregularRedIncSend = 'Y') then '02'
                                                       else ''"/></type>
          </xsl:if>
          <advise_flag><xsl:value-of select="AdviseRedIncSend"/></advise_flag>
          <advise_reduction_days><xsl:value-of select="AdviseRedIncNoticeDaysSend"/></advise_reduction_days>
          <maximum_nb_days><xsl:value-of select="if (MaximumIncreaseSend != '') then MaximumIncreaseSend
                                                 else if (MaximumDecreaseSend != '') then MaximumDecreaseSend
                                                 else ''"/></maximum_nb_days>
          <frequency><xsl:value-of select="RedIncFrequencySend"/></frequency>
          <period><xsl:value-of select="if (RedIncFrequencySend != '') then RedIncForPeriodSend else ''"/></period>
          <day_in_month><xsl:value-of select="DayInMonthSend"/></day_in_month>
          <variation_lines>
            <xsl:if test="RegularRedIncSend = 'Y'">
              <variation_line_item>
                <sequence><xsl:value-of select="position()"/></sequence>
                <operation><xsl:value-of select="if (RedIncOperationCodeSend = 'I') then '01'
                                                 else if (RedIncOperationCodeSend = 'R') then '02'
                                                 else ''"/></operation>
                <first_date><xsl:value-of select="if (RedIncFirstDateSend != '') then core:dateFormatTIPlusToCC(RedIncFirstDateSend, 'RedIncFirstDateSend') else ''"/></first_date>
                <xsl:choose>
                  <xsl:when test="RedIncByAmountSend = 'Y'">
                    <amount><xsl:value-of select="core:getCCAmount(RedIncAmountSend, RedIncCurrencySend)"/></amount>
                    <cur_code><xsl:value-of select="RedIncCurrencySend"/></cur_code>
                  </xsl:when>
                  <xsl:otherwise>
                    <percent><xsl:value-of select="core:getFirstArrayIndex(RedIncPercentSend)"/></percent>
                  </xsl:otherwise>
                </xsl:choose>
              </variation_line_item>
            </xsl:if>
            <xsl:if test="IrregularRedIncSend = 'Y'">
              <xsl:for-each select="IrregularRepaymentSchedulesSend">
                <!-- Variation Line Item for Irregular Reduction/Increase -->
                <xsl:call-template name="variation-line-item-irregular"/>
              </xsl:for-each>
            </xsl:if>
          </variation_lines>
        </cu_variation>
        <!-- Counter Reduction/Increase - End -->
        <narrative_additional_amount_cu><xsl:value-of select="AddAmountAndDetailsSend"/></narrative_additional_amount_cu>
        <narrative_cancellation_cu><xsl:value-of select="RollingRenewalCancellationNarrativeSend"/></narrative_cancellation_cu>
        <narrative_undertaking_terms_and_conditions_cu><xsl:value-of select="UndertakingTermsCondSend"/></narrative_undertaking_terms_and_conditions_cu>
        <narrative_presentation_instructions_cu><xsl:value-of select="core:getFormattedNarrative(DocPresentationInstructionSend)"/></narrative_presentation_instructions_cu>
      </xsl:if>
      <cu_credit_available_with_bank xsi:nil="true">
        <xsl:choose>
          <xsl:when test="AvailableWithSend = ('F', 'H', 'I', 'O')">
            <xsl:if test="not(AvailableWithBankSendMXName) or AvailableWithBankSendMXName = ''">
              <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then AvailableWithBankPrimeNameSend else AvailableWithBankNameSend"/></name>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$mapAddressLine4">
                <address_line_1 xsi:nil="true"><xsl:value-of select="AvailableWithBankPrimeAdr2Send"/></address_line_1>
                <address_line_2 xsi:nil="true"><xsl:value-of select="AvailableWithBankPrimeAdr3Send"/></address_line_2>
                <dom xsi:nil="true"><xsl:value-of select="AvailableWithBankPrimeAdr4Send"/></dom>
                <address_line_4 xsi:nil="true"><xsl:value-of select="AvailableWithBankPrimeAdr5Send"/></address_line_4>
              </xsl:when>
              <xsl:otherwise>
                <address_line_1 xsi:nil="true"><xsl:value-of select="AvailableWithBankAdr2Send"/></address_line_1>
                <address_line_2 xsi:nil="true"><xsl:value-of select="AvailableWithBankAdr3Send"/></address_line_2>
                <dom xsi:nil="true"><xsl:value-of select="AvailableWithBankAdr4Send"/></dom>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'AvailableWithBankSend'"/>
            </xsl:call-template>
            <lei_code xsi:nil="true"><xsl:value-of select="AvailableWithBankLEISend"/></lei_code>
          </xsl:when>
          <xsl:otherwise>
            <name xsi:nil="true"><xsl:value-of select="if (AvailableWithSend = 'A') then 'Advising Bank'
                                                       else if (AvailableWithSend = 'S') then 'Issuing Bank'
                                                       else if (AvailableWithSend = 'T') then 'Any Bank in (city)'
                                                       else if (AvailableWithSend = 'U') then 'Any Bank in (country)'
                                                       else if (AvailableWithSend = 'W') then 'Any Bank'
                                                       else ''"/></name>
            <address_line_1 xsi:nil="true"><xsl:value-of select="if (AvailableWithSend = 'T') then AvailableWithCitySend
                                                                 else if (AvailableWithSend = 'U') then AvailableWithCtrySend
                                                                 else ''"/></address_line_1>
            <address_line_2 xsi:nil="true"/>
            <dom xsi:nil="true"/>
          </xsl:otherwise>
        </xsl:choose>
      </cu_credit_available_with_bank>
      <xsl:if test="OurRequestTypeCodeSend = ('ICCO', 'ICCA')">
        <issuing_bank>
          <abbv_name><xsl:value-of select="IssuingBankID"/></abbv_name>
          <xsl:if test="not(IssuingBankMXName) or IssuingBankMXName = ''">
            <name><xsl:value-of select="if ($mapAddressLine4) then IssuingBankPrimeName else IssuingBankName"/></name>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <address_line_1><xsl:value-of select="IssuingBankPrimeAdr2"/></address_line_1>
              <address_line_2><xsl:value-of select="IssuingBankPrimeAdr3"/></address_line_2>
              <dom><xsl:value-of select="IssuingBankPrimeAdr4"/></dom>
              <address_line_4><xsl:value-of select="IssuingBankPrimeAdr5"/></address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <address_line_1><xsl:value-of select="IssuingBankAdr2"/></address_line_1>
              <address_line_2><xsl:value-of select="IssuingBankAdr3"/></address_line_2>
              <dom><xsl:value-of select="core:getDom(IssuingBankAdr4, IssuingBankAdr5)"/></dom>
            </xsl:otherwise>
          </xsl:choose>
          <reference><xsl:value-of select="IssuingBankRef"/></reference>
          <country><xsl:value-of select="IssuingBankCountryCode"/></country>
          <iso_code><xsl:value-of select="IssuingBankSWIFTBIC"/></iso_code>
          <phone><xsl:value-of select="IssuingBankTelephoneNo"/></phone>
          <fax><xsl:value-of select="IssuingBankFaxNo"/></fax>
          <telex><xsl:value-of select="IssuingBankTelex"/></telex>
          <email><xsl:value-of select="IssuingBankEmail"/></email>
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="'IssuingBank'"/>
          </xsl:call-template>
          <lei_code><xsl:value-of select="IssuingBankLEI"/></lei_code>
        </issuing_bank>
      </xsl:if>
      <advising_bank>
        <abbv_name><xsl:value-of select="AdvisingBankID"/></abbv_name>
        <xsl:if test="not(AdvisingBankMXName) or AdvisingBankMXName = ''">
          <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then AdvisingBankPrimeName else AdvisingBankName"/></name>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$mapAddressLine4">
            <address_line_1><xsl:value-of select="AdvisingBankPrimeAdr2"/></address_line_1>
            <address_line_2><xsl:value-of select="AdvisingBankPrimeAdr3"/></address_line_2>
            <dom><xsl:value-of select="AdvisingBankPrimeAdr4"/></dom>
            <address_line_4><xsl:value-of select="AdvisingBankPrimeAdr5"/></address_line_4>
          </xsl:when>
          <xsl:otherwise>
            <address_line_1><xsl:value-of select="AdvisingBankAdr2"/></address_line_1>
            <address_line_2><xsl:value-of select="AdvisingBankAdr3"/></address_line_2>
            <dom><xsl:value-of select="core:getDom(AdvisingBankAdr4, AdvisingBankAdr5)"/></dom>
          </xsl:otherwise>
        </xsl:choose>
        <reference><xsl:value-of select="AdvisingBankRef"/></reference>
        <country><xsl:value-of select="AdvisingBankCountry"/></country>
        <iso_code><xsl:value-of select="AdvisingBankSWIFTBIC"/></iso_code>
        <xsl:call-template name="mt-mx-address">
          <xsl:with-param name="party" select="'AdvisingBank'"/>
        </xsl:call-template>
        <lei_code><xsl:value-of select="AdvisingBankLEI"/></lei_code>
      </advising_bank>
      <advisethru_bank>
        <abbv_name><xsl:value-of select="AdviseThruID"/></abbv_name>
        <xsl:if test="not(AdviseThruMXName) or AdviseThruMXName = ''">
          <name><xsl:value-of select="if ($mapAddressLine4) then AdviseThruPrimeName else AdviseThruName"/></name>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$mapAddressLine4">
            <address_line_1><xsl:value-of select="AdviseThruPrimeAdr2"/></address_line_1>
            <address_line_2><xsl:value-of select="AdviseThruPrimeAdr3"/></address_line_2>
            <dom><xsl:value-of select="AdviseThruPrimeAdr4"/></dom>
            <address_line_4><xsl:value-of select="AdviseThruPrimeAdr5"/></address_line_4>
          </xsl:when>
          <xsl:otherwise>
            <address_line_1><xsl:value-of select="AdviseThruAdr2"/></address_line_1>
            <address_line_2><xsl:value-of select="AdviseThruAdr3"/></address_line_2>
            <dom><xsl:value-of select="core:getDom(AdviseThruAdr4, AdviseThruAdr5)"/></dom>
          </xsl:otherwise>
        </xsl:choose>
        <reference><xsl:value-of select="AdviseThruRef"/></reference>
        <country><xsl:value-of select="AdviseThruCountry"/></country>
        <iso_code><xsl:value-of select="AdviseThruBankSWIFTBIC"/></iso_code>
        <xsl:call-template name="mt-mx-address">
          <xsl:with-param name="party" select="'AdviseThru'"/>
        </xsl:call-template>
        <lei_code><xsl:value-of select="AdviseThruLEI"/></lei_code>
      </advisethru_bank>
      <xsl:if test="$SWIFT2023 = 'Y' and (AdviseThruLocalName or AdviseThruLocalPrimeName) and OurRequestTypeCodeSend = ('ICCA', 'ICCO', 'ISCA', 'ISCO')">
        <advisethru_bank_local xsi:nil="true">
          <abbv_name xsi:nil="true"><xsl:value-of select="AdviseThruLocalID"/></abbv_name>
          <xsl:if test="not(AdviseThruLocalMXName) or AdviseThruLocalMXName = ''">
            <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then AdviseThruLocalPrimeName else AdviseThruLocalName"/></name>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <address_line_1 xsi:nil="true"><xsl:value-of select="AdviseThruLocalPrimeAdr2"/></address_line_1>
              <address_line_2 xsi:nil="true"><xsl:value-of select="AdviseThruLocalPrimeAdr3"/></address_line_2>
              <dom xsi:nil="true"><xsl:value-of select="AdviseThruLocalPrimeAdr4"/></dom>
              <address_line_4 xsi:nil="true"><xsl:value-of select="AdviseThruLocalPrimeAdr5"/></address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <address_line_1 xsi:nil="true"><xsl:value-of select="AdviseThruLocalAdr2"/></address_line_1>
              <address_line_2 xsi:nil="true"><xsl:value-of select="AdviseThruLocalAdr3"/></address_line_2>
              <dom xsi:nil="true"><xsl:value-of select="core:getDom(AdviseThruLocalAdr4, AdviseThruLocalAdr5)"/></dom>
            </xsl:otherwise>
          </xsl:choose>
          <reference xsi:nil="true"><xsl:value-of select="AdviseThruLocalRef"/></reference>
          <country xsi:nil="true"><xsl:value-of select="AdviseThruLocalCountry"/></country>
          <iso_code xsi:nil="true"><xsl:value-of select="AdviseThruLocalBankSWIFTBIC"/></iso_code>
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="'AdviseThruLocal'"/>
          </xsl:call-template>
          <lei_code xsi:nil="true"><xsl:value-of select="AdviseThruLocalLEI"/></lei_code>
        </advisethru_bank_local>
      </xsl:if>
      <xsl:if test="RequestedConfirmParty">
        <adv_bank_conf_req><xsl:value-of select="if (RequestedConfirmParty = 'ADV') then 'Y' else 'N'"/></adv_bank_conf_req>
        <adv_thr_bank_conf_req><xsl:value-of select="if (RequestedConfirmParty = 'THB') then 'Y' else 'N'"/></adv_thr_bank_conf_req>
        <confirming_bank>
          <abbv_name xsi:nil="true"><xsl:value-of select="ConfirmingBankID"/></abbv_name>
          <xsl:if test="not(ConfirmingBankMXName) or ConfirmingBankMXName = ''">
            <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then ConfirmingBankPrimeName else ConfirmingBankName"/></name>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <address_line_1 xsi:nil="true"><xsl:value-of select="ConfirmingBankPrimeAdr2"/></address_line_1>
              <address_line_2 xsi:nil="true"><xsl:value-of select="ConfirmingBankPrimeAdr3"/></address_line_2>
              <dom xsi:nil="true"><xsl:value-of select="ConfirmingBankPrimeAdr4"/></dom>
              <address_line_4 xsi:nil="true"><xsl:value-of select="ConfirmingBankPrimeAdr5"/></address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <address_line_1 xsi:nil="true"><xsl:value-of select="ConfirmingBankAdr2"/></address_line_1>
              <address_line_2 xsi:nil="true"><xsl:value-of select="ConfirmingBankAdr3"/></address_line_2>
              <dom xsi:nil="true"><xsl:value-of select="core:getDom(ConfirmingBankAdr4, ConfirmingBankAdr5)"/></dom>
            </xsl:otherwise>
          </xsl:choose>
          <reference xsi:nil="true"><xsl:value-of select="ConfirmingBankRef"/></reference>
          <country xsi:nil="true"><xsl:value-of select="ConfirmingBankCountry"/></country>
          <iso_code xsi:nil="true"><xsl:value-of select="ConfirmingBankSWIFTBIC"/></iso_code>
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="'ConfirmingBank'"/>
          </xsl:call-template>
          <lei_code xsi:nil="true"><xsl:value-of select="ConfirmingBankLEI"/></lei_code>
        </confirming_bank>
        <req_conf_party_flag xsi:nil="true"><xsl:value-of select="if (RequestedConfirmParty = 'ADV') then 'Advising Bank' 
                                                                  else if (RequestedConfirmParty = 'THB') then 'Advise Thru Bank'
                                                                  else if (RequestedConfirmParty = 'OTH') then 'Other'
                                                                  else ''"/>
        </req_conf_party_flag>
      </xsl:if>
      <xsl:variable name="boComment">
        <xsl:value-of select="if (NotesToIssuingBank != '') then
                                if (OurRequestTypeCodeSend = ('ICCA', 'ICCO', 'ISCA', 'ISCO')) then concat('Notes To Issuing Bank: ', NotesToIssuingBank, '&#10;')
                                else concat('Notes To Advising Bank: ', NotesToIssuingBank, '&#10;')
                              else ''"/>
        <xsl:value-of select="if (BankComment != '') then concat('Bank Comment: ', BankComment, '&#10;') else ''"/>
        <xsl:value-of select="if (ResponseToInstructingParty != '') then concat('Response To Instructing Party: ', ResponseToInstructingParty, '&#10;') else ''"/>
        <xsl:value-of select="if (ResponseToSender != '') then concat('Response To Sender:', ResponseToSender, '&#10;') else ''"/>
        <xsl:value-of select="if (AddConditions != '') then concat('Additional Conditions: ', AddConditions, '&#10;') else ''"/>
        <xsl:value-of select="if (InstructionsForSwift != '') then concat('Instructions For SWIFT: ', InstructionsForSwift, '&#10;') else ''"/>
        <xsl:value-of select="if (GoodsCode != '') then concat('Goods Code: ', GoodsCode, '&#10;') else ''"/>
        <xsl:value-of select="if (GoodsCodeDesc != '') then concat('Goods Code Description: ', GoodsCodeDesc, '&#10;') else ''"/>
        <xsl:value-of select="if (GoodsDescription != '') then concat('Goods Description: ', GoodsDescription, '&#10;') else ''"/>
        <xsl:value-of select="if (Documents != '') then concat('Documents: ', Documents, '&#10;') else ''"/>
        <xsl:value-of select="if (AddInformation != '') then concat('Additional Information: ', AddInformation, '&#10;') else ''"/>
        <xsl:value-of select="if (RenewDate != '') then ('Renew Date: ', core:dateFormatTIPlusToCC(RenewDate, 'RenewDate'), '&#10;') else ''"/>
        <xsl:value-of select="if (GatewayTransactionRefusedReason != '') then concat('Reason For Refusal: ', GatewayTransactionRefusedReason, '&#10;') else ''"/>
      </xsl:variable>
      <bo_comment><xsl:value-of select="core:getFormattedNarrative($boComment)"/></bo_comment>
      <free_format_text><xsl:value-of select="if (InstructionFromInstructingParty != '') then InstructionFromInstructingParty
                                              else InstructionsReceived"/></free_format_text>
      <amd_details><xsl:value-of select="core:getFormattedNarrative(AmendNarrative)"/></amd_details>
      <narrative_transfer_conditions><xsl:value-of select="core:getFormattedNarrative(TransferConditions)"/></narrative_transfer_conditions>
      <narrative_additional_amount><xsl:value-of select="AddAmountAndDetails"/></narrative_additional_amount>
      <narrative_text_undertaking><xsl:value-of select="core:getFormattedNarrative(UndertakingTermsCond)"/></narrative_text_undertaking>
      <narrative_underlying_transaction_details><xsl:value-of select="core:getFormattedNarrative(UnderlyingTrnDetails)"/></narrative_underlying_transaction_details>
      <narrative_presentation_instructions><xsl:value-of select="core:getFormattedNarrative(DocPresentationInstruction)"/></narrative_presentation_instructions>
      <!-- Linked Licenses -->
      <xsl:call-template name="linked-licenses"/>
      <!-- Cross Reference -->
      <xsl:if test="$messageName = ('ACW', 'AMB', 'AMC', 'AMJ', 'AMK')">
        <xsl:call-template name="cross-references">
          <xsl:with-param name="prodCode" select="'BG'" />
          <xsl:with-param name="typeCode" select="'02'"/>
        </xsl:call-template>
      </xsl:if>
      <!-- Charges -->
      <xsl:if test="(Provisional = 'N' and FinalWording = 'Y') or (Provisional = 'N') or not(Provisional)">
        <xsl:call-template name="charges">
          <xsl:with-param name="amendApprovalRequired" select="(ApprovalRequired = 'Y')"/>
        </xsl:call-template>
      </xsl:if>
      <!-- Attachments -->
      <xsl:if test="not(Provisional = 'Y' and $sequence = '1' and $messageName = ('ACK', 'CRT'))">
        <xsl:call-template name="attachments"/>
      </xsl:if>
    </bg_tnx_record>
  </xsl:template>
  <!--  <xsl:include href="../custom/outgoing/TFUTIDET_to_bg_tnx_record_custom.xsl"/>  -->
  <xsl:include href="../commons/TIPlusCommons.xsl"/>
</xsl:stylesheet>