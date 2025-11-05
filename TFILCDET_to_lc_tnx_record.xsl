<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:params="xalan://com.misys.tiplus2.ticc.MappingParameters"
                xmlns:core="xalan://com.misys.tiplus2.ticc.GlobalFunctions"
                exclude-result-prefixes="core params exsl">

  <xsl:template match="tfilcdet">
    <lc_tnx_record xsi:noNamespaceSchemaLocation="http://www.neomalogic.com/gtp/interfaces/xsd/lc.xsd"
                   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      <xsl:variable name="messageName" select="core:getSourceMessageType(MessageName)" />
      <xsl:variable name="FTIVersion"><xsl:value-of select="params:getFTIVersion()" /></xsl:variable>
      <xsl:variable name="FCCVersion"><xsl:value-of select="params:getFCCVersion()" /></xsl:variable>
      <xsl:variable name="SWIFT2018"><xsl:value-of select="params:getSWIFT2018()" /></xsl:variable>
      <xsl:variable name="mapAddressLine4" select="IssueBy != '4' and params:getMapAddressLine4() = 'Y'"/>
      <xsl:variable name="mapAlternateApplicantAsApplicant" select="params:getCCMapAlternateApplicantAsApplicant() = 'Y'
                                                                    and (AltApplicantPrimeName != '' or AltApplicantName != '')"/>
      <ref_id><xsl:value-of select="eBankMasterRef" /></ref_id>
      <bo_ref_id><xsl:value-of select="MasterRef" /></bo_ref_id>
      <bo_tnx_id><xsl:value-of select="EventRef" /></bo_tnx_id>
      <cust_ref_id><xsl:value-of select="ApplicantRef" /></cust_ref_id>
      <xsl:variable name="sequence" select="if (Sequence != '') then Sequence else '1'" />
      <tnx_id xsi:nil="true"><xsl:value-of select="if ( not($messageName = 'ACW' and $sequence = '1') ) then eBankEventRef else ''" /></tnx_id>
      <xsl:if test="IssueBy">
        <xsl:variable name="issueByCode"><xsl:value-of select="params:getCCAdviceMethodForProductCode(IssueBy, 'LC')"/></xsl:variable>
        <adv_send_mode xsi:nil="true"><xsl:value-of select="$issueByCode"/></adv_send_mode>
        <adv_send_mode_text xsi:nil="true"><xsl:value-of select="if ($issueByCode = '99') then IssueByDesc else ''"/></adv_send_mode_text>
      </xsl:if>
      <tnx_type_code><xsl:value-of select="params:getTransactionTypeCode(MessageName)" /></tnx_type_code>
      <sub_tnx_type_code><xsl:value-of select="if (ParentLCReference != '') then '06' else ''"/></sub_tnx_type_code>
      <prod_stat_code><xsl:value-of select="params:getProductStatCode($messageName,Provisional,FinalWording)" /></prod_stat_code>
      <tnx_stat_code>04</tnx_stat_code>
      <product_code>LC</product_code>
      <tnx_val_date xsi:nil="true"><xsl:value-of select="if (TransactionDate != '') then core:dateFormatTIPlusToCC(TransactionDate,'TransactionDate') else ''" /></tnx_val_date>
      <appl_date xsi:nil="true"><xsl:value-of select="if (ApplicationDate != '') then core:dateFormatTIPlusToCC(ApplicationDate,'ApplicationDate') else ''" /></appl_date>
      <iss_date xsi:nil="true"><xsl:value-of select="if (IssueDate != '') then core:dateFormatTIPlusToCC(IssueDate,'IssueDate') else ''" /></iss_date>
      <exp_date xsi:nil="true"><xsl:value-of select="if (ExpiryDate != '') then core:dateFormatTIPlusToCC(ExpiryDate,'ExpiryDate') else ''" /></exp_date>
      <last_ship_date xsi:nil="true"><xsl:value-of select="if (ShipmentDate != '') then core:dateFormatTIPlusToCC(ShipmentDate,'ShipmentDate') else ''" /></last_ship_date>
      <tnx_cur_code><xsl:value-of select="TnxCurrency" /></tnx_cur_code>
      <tnx_amt><xsl:value-of select="core:getCCAmount(TnxAmount, TnxCurrency)" /></tnx_amt>
      <lc_cur_code><xsl:value-of select="LCCurrency" /></lc_cur_code>
      <lc_amt><xsl:value-of select="core:getCCAmount(LCAmount, LCCurrency)" /></lc_amt>
      <lc_liab_amt><xsl:value-of select="if (Provisional = 'Y') then core:getCCAmount('0', LiabCurrency) else core:getCCAmount(LiabAmount, LiabCurrency)" /></lc_liab_amt>
      <lc_available_amt><xsl:value-of select="core:getCCAmount(AvailableAmt, AvailableCcy)" /></lc_available_amt>
      <lc_type>01</lc_type>
      <beneficiary_abbv_name xsi:nil="true"><xsl:value-of select="BeneficiaryId" /></beneficiary_abbv_name>
      <xsl:choose>
        <xsl:when test="$mapAddressLine4">
          <beneficiary_name xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeName" /></beneficiary_name>
          <beneficiary_address_line_1 xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeAdr2" /></beneficiary_address_line_1>
          <beneficiary_address_line_2 xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeAdr3" /></beneficiary_address_line_2>
          <beneficiary_dom xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeAdr4" /></beneficiary_dom>
          <beneficiary_address_line_4 xsi:nil="true"><xsl:value-of select="BeneficiaryPrimeAdr5" /></beneficiary_address_line_4>
        </xsl:when>
        <xsl:otherwise>
          <beneficiary_name xsi:nil="true"><xsl:value-of select="BeneficiaryName" /></beneficiary_name>
          <beneficiary_address_line_1 xsi:nil="true"><xsl:value-of select="BeneficiaryAdr2" /></beneficiary_address_line_1>
          <beneficiary_address_line_2 xsi:nil="true"><xsl:value-of select="BeneficiaryAdr3" /></beneficiary_address_line_2>
          <beneficiary_dom xsi:nil="true"><xsl:value-of select="core:getDom(BeneficiaryAdr4,BeneficiaryAdr5)" /></beneficiary_dom>
        </xsl:otherwise>
      </xsl:choose>
      <beneficiary_country xsi:nil="true"><xsl:value-of select="if ($messageName = ('CRT', 'ACK', 'MST')) then BenCountry else ''" /></beneficiary_country>
      <beneficiary_reference xsi:nil="true"><xsl:value-of select="BenRef" /></beneficiary_reference>
      <beneficiary_address>
        <xsl:call-template name="mt-mx-address">
          <xsl:with-param name="party" select="'Beneficiary'"/>
        </xsl:call-template>
      </beneficiary_address>
      <beneficiary_lei xsi:nil="true"><xsl:value-of select="BeneficiaryLEI" /></beneficiary_lei>
      <xsl:choose>
        <xsl:when test="$mapAlternateApplicantAsApplicant">
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <applicant_name xsi:nil="true"><xsl:value-of select="AltApplicantPrimeName" /></applicant_name>
              <applicant_address_line_1 xsi:nil="true"><xsl:value-of select="AltApplicantPrimeAdr2" /></applicant_address_line_1>
              <applicant_address_line_2 xsi:nil="true"><xsl:value-of select="AltApplicantPrimeAdr3" /></applicant_address_line_2>
              <applicant_dom xsi:nil="true"><xsl:value-of select="AltApplicantPrimeAdr4" /></applicant_dom>
              <applicant_address_line_4 xsi:nil="true"><xsl:value-of select="AltApplicantPrimeAdr5" /></applicant_address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <applicant_name xsi:nil="true"><xsl:value-of select="AltApplicantName" /></applicant_name>
              <applicant_address_line_1 xsi:nil="true"><xsl:value-of select="AltApplicantAdr2" /></applicant_address_line_1>
              <applicant_address_line_2 xsi:nil="true"><xsl:value-of select="AltApplicantAdr3" /></applicant_address_line_2>
              <applicant_dom xsi:nil="true"><xsl:value-of select="core:getDom(AltApplicantAdr4,AltApplicantAdr5)" /></applicant_dom>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <applicant_name xsi:nil="true"><xsl:value-of select="ApplicantPrimeName" /></applicant_name>
              <applicant_address_line_1 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr2" /></applicant_address_line_1>
              <applicant_address_line_2 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr3" /></applicant_address_line_2>
              <applicant_dom xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr4" /></applicant_dom>
              <applicant_address_line_4 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr5" /></applicant_address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <applicant_name xsi:nil="true"><xsl:value-of select="ApplicantName" /></applicant_name>
              <applicant_address_line_1 xsi:nil="true"><xsl:value-of select="ApplicantAdr2" /></applicant_address_line_1>
              <applicant_address_line_2 xsi:nil="true"><xsl:value-of select="ApplicantAdr3" /></applicant_address_line_2>
              <applicant_dom xsi:nil="true"><xsl:value-of select="core:getDom(ApplicantAdr4,ApplicantAdr5)" /></applicant_dom>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <applicant_country><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then AltApplicantCountry else ApplicantCountry" /></applicant_country>
      <xsl:variable name="referenceID" select="if ($mapAlternateApplicantAsApplicant) then PrincipalId else ApplicantId"/>
      <applicant_reference xsi:nil="true"><xsl:value-of select="($referenceID, ZoneID, MBE, BehalfOfBranch)" separator="." /></applicant_reference>
      <applicant_address>
        <xsl:choose>
          <xsl:when test="$mapAlternateApplicantAsApplicant">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'AltApplicant'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'Applicant'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </applicant_address>
      <applicant_lei xsi:nil="true"><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then AltApplicantLEI else ApplicantLEI" /></applicant_lei>
      <for_account_flag><xsl:value-of select="if (AltApplicantName != '') then 'Y' else ''" /></for_account_flag>
      <xsl:choose>
        <xsl:when test="$mapAlternateApplicantAsApplicant">
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <alt_applicant_name xsi:nil="true"><xsl:value-of select="ApplicantPrimeName" /></alt_applicant_name>
              <alt_applicant_address_line_1 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr2" /></alt_applicant_address_line_1>
              <alt_applicant_address_line_2 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr3" /></alt_applicant_address_line_2>
              <alt_applicant_dom xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr4" /></alt_applicant_dom>
              <alt_applicant_address_line_4 xsi:nil="true"><xsl:value-of select="ApplicantPrimeAdr5" /></alt_applicant_address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <alt_applicant_name xsi:nil="true"><xsl:value-of select="ApplicantName" /></alt_applicant_name>
              <alt_applicant_address_line_1 xsi:nil="true"><xsl:value-of select="ApplicantAdr2" /></alt_applicant_address_line_1>
              <alt_applicant_address_line_2 xsi:nil="true"><xsl:value-of select="ApplicantAdr3" /></alt_applicant_address_line_2>
              <alt_applicant_dom xsi:nil="true"><xsl:value-of select="core:getDom(ApplicantAdr4,ApplicantAdr5)" /></alt_applicant_dom>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <alt_applicant_name xsi:nil="true"><xsl:value-of select="AltApplicantPrimeName" /></alt_applicant_name>
              <alt_applicant_address_line_1 xsi:nil="true"><xsl:value-of select="AltApplicantPrimeAdr2" /></alt_applicant_address_line_1>
              <alt_applicant_address_line_2 xsi:nil="true"><xsl:value-of select="AltApplicantPrimeAdr3" /></alt_applicant_address_line_2>
              <alt_applicant_dom xsi:nil="true"><xsl:value-of select="AltApplicantPrimeAdr4" /></alt_applicant_dom>
              <alt_applicant_address_line_4 xsi:nil="true"><xsl:value-of select="AltApplicantPrimeAdr5" /></alt_applicant_address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <alt_applicant_name xsi:nil="true"><xsl:value-of select="AltApplicantName" /></alt_applicant_name>
              <alt_applicant_address_line_1 xsi:nil="true"><xsl:value-of select="AltApplicantAdr2" /></alt_applicant_address_line_1>
              <alt_applicant_address_line_2 xsi:nil="true"><xsl:value-of select="AltApplicantAdr3" /></alt_applicant_address_line_2>
              <alt_applicant_dom xsi:nil="true"><xsl:value-of select="core:getDom(AltApplicantAdr4,AltApplicantAdr5)" /></alt_applicant_dom>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <alt_applicant_country><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then ApplicantCountry else AltApplicantCountry" /></alt_applicant_country>
      <alt_applicant_cust_ref><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then ApplicantRef else AltApplicantRef" /></alt_applicant_cust_ref>
      <alt_applicant_address>
        <xsl:choose>
          <xsl:when test="$mapAlternateApplicantAsApplicant">
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'Applicant'"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'AltApplicant'"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </alt_applicant_address>
      <alt_applicant_lei><xsl:value-of select="if ($mapAlternateApplicantAsApplicant) then ApplicantLEI else AltApplicantLEI" /></alt_applicant_lei>
      <expiry_place xsi:nil="true"><xsl:value-of select="ExpiryPlace" /></expiry_place>
      <inco_term xsi:nil="true"><xsl:value-of select="Incoterm" /></inco_term>
      <inco_place xsi:nil="true"><xsl:value-of select="Incoplace" /></inco_place>
      <xsl:if test="PartShipment != ''">
          <part_ship_detl><xsl:value-of select="if ($SWIFT2018 = 'Y' and PartShipment = 'Conditional (See additional conditions)') then 'Conditional'
                                                else upper-case(PartShipment)" /></part_ship_detl>
      </xsl:if>
      <xsl:if test="TransShipment != ''">
        <tran_ship_detl><xsl:value-of select="if ($SWIFT2018 = 'Y' and TransShipment = 'Conditional (See additional conditions)') then 'Conditional'
                                              else upper-case(TransShipment)" /></tran_ship_detl>
      </xsl:if>
      <ship_from xsi:nil="true"><xsl:value-of select="ShipmentFrom" /></ship_from>
      <ship_loading xsi:nil="true"><xsl:value-of select="PortOfLoading" /></ship_loading>
      <ship_discharge xsi:nil="true"><xsl:value-of select="PortOfDischarge" /></ship_discharge>
      <ship_to xsi:nil="true"><xsl:value-of select="ShipmentTo" /></ship_to>
      <draft_term xsi:nil="true"><xsl:value-of select="if (MixedPaymentDtls != '' or TenorDesc != '' and TenorDesc != 'Sight') then core:getDraftTerm(MixedPaymentDtls,TenorDesc,TenorFrom,TenorDays) else ''"/></draft_term>
      <neg_tol_pct xsi:nil="true"><xsl:value-of select="core:getCCRoundPercent(Min)"/></neg_tol_pct>
      <pstv_tol_pct xsi:nil="true"><xsl:value-of select="core:getCCRoundPercent(Max)"/></pstv_tol_pct>
      <xsl:if test="$SWIFT2018 = 'N'">
        <max_cr_desc_code xsi:nil="true"><xsl:value-of select="if (Tolerance = 'N') then 3 else ''" /></max_cr_desc_code>
      </xsl:if>
      <xsl:variable name="availableBy" select="upper-case(AvailableBy)" />
      <cr_avl_by_code xsi:nil="true"><xsl:value-of select="if ($availableBy = 'S') then '01'
                                                           else if ($availableBy = 'A') then '02'
                                                           else if ($availableBy = 'N') then '03'
                                                           else if ($availableBy = 'D') then '04'
                                                           else if ($availableBy = 'M') then '05'
                                                           else if ($availableBy = 'E') then '06'
                                                           else ''" /></cr_avl_by_code>
      <irv_flag xsi:nil="true"><xsl:value-of select="if (Revocable = 'Y') then 'N' else if (Revocable = 'N') then 'Y' else ''" /></irv_flag>
      <ntrf_flag xsi:nil="true"><xsl:value-of select="if (Transferable = 'Y') then 'N' else if (Transferable = 'N') then 'Y' else ''" /></ntrf_flag>
      <cfm_inst_code xsi:nil="true"><xsl:value-of select="if (Confirmation = 'C') then '01'
                                                          else if (Confirmation = 'M') then '02'
                                                          else if (Confirmation = 'W') then '03'
                                                          else ''" /></cfm_inst_code>
      <xsl:if test="$SWIFT2018 = 'Y'">
        <req_conf_party_flag><xsl:value-of select="if (RequestedConfirmParty = 'ADV') then 'Advising Bank'
                                                   else if (RequestedConfirmParty = 'THB') then 'Advise Thru Bank'
                                                   else if (RequestedConfirmParty = 'OTH') then 'Other' else ''" />
        </req_conf_party_flag>
      </xsl:if>
      <corr_chrg_brn_by_code xsi:nil="true"><xsl:value-of select="if (OverseasChgsFor = 'A') then '01'
                                                                  else if (OverseasChgsFor = 'B') then '02'
                                                                  else ''" />
      </corr_chrg_brn_by_code>
      <open_chrg_brn_by_code xsi:nil="true"><xsl:value-of select="if (IssuanceChgsFor = 'A') then '01'
                                                                  else if (IssuanceChgsFor = 'B') then '02'
                                                                  else ''" />
      </open_chrg_brn_by_code>
      <cfm_chrg_brn_by_code><xsl:value-of select="if (ConfirmationCharges = 'A') then '01'
                                                  else if (ConfirmationCharges = 'B') then '02'
                                                  else ''" />
      </cfm_chrg_brn_by_code>
      <fee_act_no xsi:nil="true"><xsl:value-of select="ChargeAccount"/></fee_act_no>
      <maturity_date xsi:nil="true"><xsl:value-of select="if (MaturityDate != '') then core:dateFormatTIPlusToCC(MaturityDate,'MaturityDate') else ''" /></maturity_date>
      <applicable_rules><xsl:value-of select="if (ApplicableRules != '') then
                                                 if (ApplicableRules = 'EUCP LATEST VERSION') then '01'
                                                 else if (ApplicableRules = 'EUCPURR LATEST VERSION') then '02'
                                                 else if (ApplicableRules = 'ISP LATEST VERSION') then '03'
                                                 else if (ApplicableRules = 'UCP LATEST VERSION') then '04'
                                                 else if (ApplicableRules = 'UCPURR LATEST VERSION') then '05'
                                                 else if (ApplicableRules = 'URDG') then '06'
                                                 else if (ApplicableRules = 'ISPR') then '07'
                                                 else if (ApplicableRules = 'NONE') then '09'
                                                 else '99'
                                              else ''" /></applicable_rules>
      <applicable_rules_text xsi:nil="true"><xsl:value-of select="if (ApplicableRules != '') then core:getApplicableRulesText(ApplicableRules) else ''"/></applicable_rules_text>
      <!-- Additional fields for FCC versions 5.5 onwards -->
      <xsl:if test="$FCCVersion and $FCCVersion &gt;= 55">
        <xsl:variable name="isNegotiationSight" select="if ($availableBy = 'N' and TenorFrom = 'S' and (TenorDays = '' or TenorDays = '0')) then 'Y'
                                                        else 'N'"/>
        <tenor_type><xsl:value-of select="if ($availableBy = 'S' or $isNegotiationSight = 'Y') then '01'
                                          else if (TenorMaturityDate != '') then '02'
                                          else if ($availableBy = ('A', 'D') or TenorFrom != '') then '03'
                                          else ''"/></tenor_type>
        <tenor_maturity_date><xsl:value-of select="if (TenorMaturityDate != '') then core:dateFormatTIPlusToCC(TenorMaturityDate,'TenorMaturityDate') else ''"/></tenor_maturity_date>
        <xsl:if test="$isNegotiationSight = 'N'">
          <tenor_days><xsl:value-of select="TenorDays"/></tenor_days>
          <tenor_period><xsl:value-of select="if (TenorDays != '') then TenorPeriod else ''"/></tenor_period>
          <tenor_from_after><xsl:value-of select="if (FromAfter != '') then
                                                    if (FromAfter = 'F') then 'F'
                                                    else 'A'
                                                  else ''"/></tenor_from_after>
          <tenor_days_type><xsl:value-of select="if (TenorFrom != '') then
                                                   if (TenorFrom = 'A') then '01'
                                                   else if (TenorFrom = 'G') then '02'
                                                   else if (TenorFrom = 'E') then '03'
                                                   else if (TenorFrom = 'L') then '04'
                                                   else if (TenorFrom = 'I') then '05'
                                                   else if (TenorFrom = 'P') then '06'
                                                   else if (TenorFrom = 'S') then '07'
                                                   else if (TenorFrom = 'O') then
                                                     if (upper-case(TenorText) = 'ARRIVAL AND INSPECTION OF GOODS') then '08'
                                                     else '99'
                                                   else ''
                                                 else ''"/></tenor_days_type>
          <tenor_type_details><xsl:value-of select="if (TenorFrom = 'O') then TenorText else ''"/></tenor_type_details>
        </xsl:if>
        <!-- below are non existing tags in V5 -->
        <bo_event_no><xsl:value-of select="EventRef"/></bo_event_no>
        <extract_counterparty><xsl:value-of select="upper-case(ExtractCounterParty)" /></extract_counterparty>
        <country_of_origin><xsl:value-of select="OriginOfGoods"/></country_of_origin>
      </xsl:if>
      <revolving_flag><xsl:value-of select="upper-case(Revolving)" /></revolving_flag>
      <revolve_period><xsl:value-of select="Period"/></revolve_period>
      <revolve_frequency><xsl:value-of select="substring(Frequency,1,1)"/></revolve_frequency>
      <revolve_time_no><xsl:value-of select="Revolutions"/></revolve_time_no>
      <cumulative_flag><xsl:value-of select="upper-case(Cumulative)" /></cumulative_flag>
      <next_revolve_date><xsl:value-of select="if (NextDate != '') then core:dateFormatTIPlusToCC(NextDate, 'NextDate') else ''" /></next_revolve_date>
      <notice_days><xsl:value-of select="NoticeDays"/></notice_days>
      <charge_upto><xsl:value-of select="if (ChargeToExpiry = 'Y') then 'e'
                                         else if (ChargeToExpiry = 'N') then 'p'
                                         else ''" /></charge_upto>
      <xsl:if test="$SWIFT2018 = 'Y'">
        <period_presentation_days xsi:nil="true"><xsl:value-of select="PresentationDays"/></period_presentation_days>
      </xsl:if>
      <advising_bank>
        <xsl:if test="not(AdvisingBankMXName) or AdvisingBankMXName = ''">
          <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then AdvisingBankPrimeName else AdvisingBankName" /></name>
        </xsl:if>
      <xsl:choose>
        <xsl:when test="$mapAddressLine4">
          <address_line_1 xsi:nil="true"><xsl:value-of select="AdvisingBankPrimeAdr2" /></address_line_1>
          <address_line_2 xsi:nil="true"><xsl:value-of select="AdvisingBankPrimeAdr3" /></address_line_2>
          <dom xsi:nil="true"><xsl:value-of select="AdvisingBankPrimeAdr4"/></dom>
          <address_line_4 xsi:nil="true"><xsl:value-of select="AdvisingBankPrimeAdr5" /></address_line_4>
        </xsl:when>
        <xsl:otherwise>
          <address_line_1 xsi:nil="true"><xsl:value-of select="AdvisingBankAdr2" /></address_line_1>
          <address_line_2 xsi:nil="true"><xsl:value-of select="AdvisingBankAdr3" /></address_line_2>
          <dom xsi:nil="true"><xsl:value-of select="core:getDom(AdvisingBankAdr4, AdvisingBankAdr5)"/></dom>
        </xsl:otherwise>
      </xsl:choose>
        <reference xsi:nil="true"><xsl:value-of select="AdvisingBankId" /></reference>
        <xsl:call-template name="mt-mx-address">
          <xsl:with-param name="party" select="'AdvisingBank'"/>
        </xsl:call-template>
        <lei_code xsi:nil="true"><xsl:value-of select="AdvisingBankLEI" /></lei_code>
      </advising_bank>
      <advise_thru_bank xsi:nil="true">
        <xsl:if test="not(AdviseThruMXName) or AdviseThruMXName = ''">
          <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then AdviseThruPrimeName else AdviseThruName" /></name>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$mapAddressLine4">
            <address_line_1 xsi:nil="true"><xsl:value-of select="AdviseThruPrimeAdr2" /></address_line_1>
            <address_line_2 xsi:nil="true"><xsl:value-of select="AdviseThruPrimeAdr3" /></address_line_2>
            <dom xsi:nil="true"><xsl:value-of select="AdviseThruPrimeAdr4" /></dom>
            <address_line_4 xsi:nil="true"><xsl:value-of select="AdviseThruPrimeAdr5" /></address_line_4>
          </xsl:when>
          <xsl:otherwise>
            <address_line_1 xsi:nil="true"><xsl:value-of select="AdviseThruAdr2" /></address_line_1>
            <address_line_2 xsi:nil="true"><xsl:value-of select="AdviseThruAdr3" /></address_line_2>
            <dom xsi:nil="true"><xsl:value-of select="core:getDom(AdviseThruAdr4, AdviseThruAdr5)"/></dom>
          </xsl:otherwise>
        </xsl:choose>
        <reference xsi:nil="true"><xsl:value-of select="AdviseThruId" /></reference>
        <xsl:call-template name="mt-mx-address">
          <xsl:with-param name="party" select="'AdviseThru'"/>
        </xsl:call-template>
        <lei_code xsi:nil="true"><xsl:value-of select="AdviseThruLEI" /></lei_code>
      </advise_thru_bank>
      <xsl:if test="AvailableWith != ''">
        <credit_available_with_bank xsi:nil="true">
          <xsl:choose>
            <xsl:when test="AvailableWith = 'O'">
              <xsl:if test="not(AvailableWithBankMXName) or AvailableWithBankMXName = ''">
                <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then AvailableWithBankPrimeName else AvailableWithBankName"/></name>
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
              <lei_code xsi:nil="true"><xsl:value-of select="AvailableWithBankLEI" /></lei_code>
            </xsl:when>
            <xsl:otherwise>
              <name xsi:nil="true"><xsl:value-of select="if (AvailableWith = 'A') then 'Advising Bank'
                                                         else if (AvailableWith = 'I') then 'Issuing Bank'
                                                         else if (AvailableWith = 'S') then 'Ourselves'
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
      </xsl:if>
      <drawee_details_bank xsi:nil="true">
        <xsl:choose>
          <xsl:when test="DraftsDrawnOn = 'O'">
            <xsl:if test="not(DraftsDrawnOnBankMXName) or DraftsDrawnOnBankMXName = ''">
              <name><xsl:value-of select="if ($mapAddressLine4) then DraftsDrawnOnBankPrimeName else DraftsDrawnOnBankName" /></name>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="$mapAddressLine4">
                <address_line_1><xsl:value-of select="DraftsDrawnOnBankPrimeAdr2" /></address_line_1>
                <address_line_2><xsl:value-of select="DraftsDrawnOnBankPrimeAdr3" /></address_line_2>
                <dom><xsl:value-of select="DraftsDrawnOnBankPrimeAdr4" /></dom>
                <address_line_4><xsl:value-of select="DraftsDrawnOnBankPrimeAdr5" /></address_line_4>
              </xsl:when>
              <xsl:otherwise>
                <address_line_1><xsl:value-of select="DraftsDrawnOnBankAdr2" /></address_line_1>
                <address_line_2><xsl:value-of select="DraftsDrawnOnBankAdr3" /></address_line_2>
                <dom><xsl:value-of select="core:getDom(DraftsDrawnOnBankAdr4, DraftsDrawnOnBankAdr5)"/></dom>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="mt-mx-address">
              <xsl:with-param name="party" select="'DraftsDrawnOnBank'"/>
            </xsl:call-template>
            <lei_code xsi:nil="true"><xsl:value-of select="DraftsDrawnOnBankLEI" /></lei_code>
          </xsl:when>
          <xsl:otherwise>
            <name xsi:nil="true"><xsl:value-of select="if (DraftsDrawnOn = 'I') then 'Issuing Bank'
                                      else if (DraftsDrawnOn = 'A') then 'Advising Bank'
                                      else if (DraftsDrawnOn = 'S') then 'Issuing Bank'
                                      else if (DraftsDrawnOn = 'R') then 'Reimbursing'
                                      else if (DraftsDrawnOn = 'N') then ''
                                      else ''" /></name>
          </xsl:otherwise>
        </xsl:choose>
      </drawee_details_bank>
      <xsl:if test="$SWIFT2018 = 'Y' and RequestedConfirmParty = 'OTH'">
        <requested_confirmation_party xsi:nil="true">
          <xsl:if test="not(RequestedConfirmPartyMXName) or RequestedConfirmPartyMXName = ''">
            <name xsi:nil="true"><xsl:value-of select="if ($mapAddressLine4) then RequestedConfirmPartyPrimeName else RequestedConfirmPartyName"/></name>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="$mapAddressLine4">
              <address_line_1 xsi:nil="true"><xsl:value-of select="RequestedConfirmPartyPrimeAdr2"/></address_line_1>
              <address_line_2 xsi:nil="true"><xsl:value-of select="RequestedConfirmPartyPrimeAdr3"/></address_line_2>
              <dom xsi:nil="true"><xsl:value-of select="RequestedConfirmPartyPrimeAdr4"/></dom>
              <address_line_4 xsi:nil="true"><xsl:value-of select="RequestedConfirmPartyPrimeAdr5"/></address_line_4>
            </xsl:when>
            <xsl:otherwise>
              <address_line_1 xsi:nil="true"><xsl:value-of select="RequestedConfirmPartyAdr2"/></address_line_1>
              <address_line_2 xsi:nil="true"><xsl:value-of select="RequestedConfirmPartyAdr3"/></address_line_2>
              <dom xsi:nil="true"><xsl:value-of select="core:getDom(RequestedConfirmPartyAdr4, RequestedConfirmPartyAdr5)"/></dom>
            </xsl:otherwise>
          </xsl:choose>
          <iso_code xsi:nil="true"><xsl:value-of select="RequestedConfirmPartyBIC"/></iso_code>
          <xsl:call-template name="mt-mx-address">
            <xsl:with-param name="party" select="'RequestedConfirmParty'"/>
          </xsl:call-template>
          <lei_code xsi:nil="true"><xsl:value-of select="RequestedConfirmPartyLEI" /></lei_code>
        </requested_confirmation_party>
      </xsl:if>
      <!-- Linked Licenses -->
      <xsl:call-template name="linked-licenses" />
      <narrative_description_goods xsi:nil="true"><xsl:value-of select="Goods" /></narrative_description_goods>
      <narrative_documents_required xsi:nil="true"><xsl:value-of select="Documents" /></narrative_documents_required>
      <narrative_additional_instructions xsi:nil="true"><xsl:value-of select="AddConditions" /></narrative_additional_instructions>
      <xsl:if test="$SWIFT2018 = 'Y'">
        <narrative_special_beneficiary xsi:nil="true"><xsl:value-of select="SpecialPayConditionsBeneficiary"/></narrative_special_beneficiary>
        <narrative_special_recvbank xsi:nil="true"><xsl:value-of select="SpecialPayConditionsRcvBank"/></narrative_special_recvbank>
      </xsl:if>
      <narrative_additional_amount xsi:nil="true"><xsl:value-of select="if ($FTIVersion &gt;= 29) then AddAmountAndDetails else AddAmountText" /></narrative_additional_amount>
      <xsl:if test="$SWIFT2018 = 'Y'">
        <narrative_payment_instructions><xsl:value-of select="InstructionstoPayBank" /></narrative_payment_instructions>
      </xsl:if>
      <narrative_period_presentation xsi:nil="true">
        <xsl:if test="PresentationPeriod != ''"><xsl:value-of select="PresentationPeriod"/></xsl:if>
        <xsl:if test="($SWIFT2018 = '' or $SWIFT2018 = 'N') and PresentationDays != ''"><xsl:value-of select="PresentationDays"/> days</xsl:if>
      </narrative_period_presentation>
      <narrative_shipment_period xsi:nil="true"><xsl:value-of select="core:getFormattedNarrative(ShipmentPeriod)"/></narrative_shipment_period>
      <xsl:variable name="boComment">
        <xsl:value-of select="if (BankComment != '') then concat(BankComment, '&#10;') else ''"/>
        <xsl:value-of select="if (DraftsDrawnOnBankAddress != '') then concat('Drafts Drawn On Bank Address: ', '&#10;', DraftsDrawnOnBankAddress, '&#10;') else ''"/>
      </xsl:variable>
      <bo_comment><xsl:value-of select="core:getFormattedNarrative($boComment)" /></bo_comment>
      <xsl:if test="$SWIFT2018 = 'Y'">
        <free_format_text><xsl:value-of select="core:getFormattedNarrative(ApplicantInstructions)"/></free_format_text>
      </xsl:if>
      <action_req_code xsi:nil="true"><xsl:value-of select="if ( $messageName = 'ACW' and Provisional = 'Y' ) then '07' else ''" /></action_req_code>
      <xsl:if test="(Provisional='N' and FinalWording='Y') or (Provisional='N') or not(Provisional)">
      <!-- Cross Reference -->
      <xsl:if test="$messageName = 'ACW'">
        <xsl:call-template name="cross-references">
          <xsl:with-param name="prodCode" select="'LC'" />
          <xsl:with-param name="typeCode" select="'02'"/>
        </xsl:call-template>
      </xsl:if>
        <!-- Charges -->
        <xsl:call-template name="charges" />
      </xsl:if>
      <!-- Attachments -->
      <xsl:if test="not(Provisional = 'Y' and $sequence = '1' and $messageName = ('ACK', 'CRT'))">
        <xsl:call-template name="attachments" />
      </xsl:if>
      <parent_bo_ref_id><xsl:value-of select="ParentLCReference"/></parent_bo_ref_id>
      <!-- Additional fields for FCC versions 5.4 and below-->
      <xsl:if test="$FCCVersion and $FCCVersion &lt; 55">
        <xsl:if test="TenorDays != ''">
          <additional_field scope="master" name="tenor_days" type="string"><xsl:value-of select="TenorDays"/></additional_field>
        </xsl:if>
        <xsl:if test="TenorPeriod != ''">
          <additional_field scope="master" name="tenor_period" type="string"><xsl:value-of select="TenorPeriod"/></additional_field>
        </xsl:if>
        <xsl:if test="FromAfter != ''">
          <additional_field scope="master" name="tenor_from_after" type="string"><xsl:value-of select="if (upper-case(FromAfter) = 'F') then 'F' else 'A'" /></additional_field>
        </xsl:if>
        <xsl:if test="TenorFrom != ''">
          <additional_field scope="master" name="tenor_days_type" type="string">
            <xsl:value-of select="if (TenorFrom = 'A') then '01'
                                  else if (TenorFrom = 'G') then '02'
                                  else if (TenorFrom = 'E') then '03'
                                  else if (TenorFrom = 'L') then '04'
                                  else if (TenorFrom = 'I') then '05'
                                  else if (TenorFrom = 'P') then '06'
                                  else if (TenorFrom = 'S') then '07'
                                  else if (TenorFrom = 'O') then (if (upper-case(TenorText) = 'ARRIVAL AND INSPECTION OF GOODS') then '08' else '99')
                                  else ''" /></additional_field>
        </xsl:if>
        <xsl:if test="TenorText != ''">
          <additional_field scope="master" name="tenor_type_details" type="string"><xsl:value-of select="TenorText"/></additional_field>
        </xsl:if>
        <xsl:if test="TenorMaturityDate != ''">
          <additional_field scope="master" name="tenor_maturity_date" type="string">
            <xsl:value-of select="core:dateFormatTIPlusToCC(TenorMaturityDate,'TenorMaturityDate')"/>
          </additional_field>
        </xsl:if>
        <xsl:if test="EventRef != ''">
          <additional_field scope="master" name="bo_event_no" type="string"><xsl:value-of select="EventRef"/></additional_field>
        </xsl:if>
        <xsl:if test="TenorDesc != '' and TenorDesc = 'Sight'">
          <additional_field scope="master" name="tenor_type" type="string">01</additional_field>
        </xsl:if>
        <xsl:if test="TenorMaturityDate != ''">
          <additional_field scope="master" name="tenor_type" type="string">02</additional_field>
        </xsl:if>
        <xsl:if test="TenorDays != ''">
          <additional_field scope="master" name="tenor_type" type="string">03</additional_field>
        </xsl:if>
        <xsl:if test="ExtractCounterParty != ''">
          <additional_field scope="master" name="extract_counterparty" type="string">
            <xsl:value-of select="upper-case(ExtractCounterParty)" />
          </additional_field>
        </xsl:if>
        <xsl:if test="OriginOfGoods != ''">
          <additional_field scope="master" name="country_of_origin" type="string"><xsl:value-of select="OriginOfGoods"/></additional_field>
        </xsl:if>
      </xsl:if>
    <!--  <xsl:call-template name="additional-fields" />  -->
    <!--  <xsl:call-template name="customisation-fields" />  -->
    </lc_tnx_record>
  </xsl:template>

  <!--  <xsl:include href="../custom/outgoing/TFILCDET_to_lc_tnx_record_custom.xsl" />  -->
  <xsl:include href="../commons/TIPlusCommons.xsl" />
</xsl:stylesheet>