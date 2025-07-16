package com.misys.tiplus2.ticc.groovy.router

import com.misys.tiplus2.ticc.MappingParameters
import com.misys.tiplus2.ticc.customisation.CustomMappingParameters

import com.misys.tools.integration.api.annotation.InjectResource
import com.misys.tools.integration.api.callback.GRouteCallback
import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult
import com.misys.tools.integration.api.message.GStatus
import com.misys.tools.integration.impl.api.component.resource.properties.GPropertiesResourceImpl
import com.misys.tools.integration.impl.api.component.resource.cache.GSimpleCacheResourceImpl

import java.io.File

import javax.annotation.Nonnull
import javax.annotation.Nullable

import groovy.util.XmlSlurper
import groovy.util.slurpersupport.GPathResult;
import groovy.util.logging.Slf4j

/**
 * Determines the specific mapping script to execute depending on the FFC message's product_code value.
 * 
 * TODO: Extend a common class which implements GProcess and GRouteCallback.
 */
@Slf4j
class FCCToFTIMappingSelector implements GProcessor, GRouteCallback {

	@InjectResource(required = true)
	GSimpleCacheResourceImpl messageCache

	@InjectResource(required = true)
	GPropertiesResourceImpl customisation

	private static final String CACHE_HANDLER = "groovy/com/misys/tiplus2/ticc/groovy/router/CacheHandler.groovy"

	private static final String INVALID_MESSAGE_TYPE_MSG = "Unrecognized FCC message type "

	File cacheHandlerFile = new File(CACHE_HANDLER);
	Class groovyClass = new GroovyClassLoader(getClass().getClassLoader()).parseClass(cacheHandlerFile);
	GroovyObject cacheHandler = (GroovyObject) groovyClass.newInstance();

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {

		GPathResult fccMsg = new XmlSlurper().parseText(message.messageBody)
		def isAckNackEnabled = message.getProperty("acknack") == "Y" ? true : false

		// ACK / NACK Service - Response to TI
		if (isAckNackEnabled && fccMsg.status.text().toUpperCase() in ["ACK", "NACK"]){
			return processAckNackResponse(message, fccMsg.bo_ref_id.toString())
		}

		return processMappingScriptSelection(message, fccMsg)

	}

	/**
	 * Retrieves ack/nack related properties from the cache and assign it
	 * to the resulting GResult.
	 * 
	 */
	private List<GResult> processAckNackResponse(@Nonnull GMessage message, String bORefId) {
		GResult.Builder gResult = message.result()

		def cachedReqMsg = cacheHandler.GetFromCache(messageCache, bORefId)

		return gResult
				.messageBody(message.messageBody)
				.property("ccIsACKNACKResponse", "Y")
				.property("rService", cachedReqMsg.getProperty("rService").toString())
				.property("rOperation", cachedReqMsg.getProperty("rOperation").toString())
				.property("rCorrelationID", cachedReqMsg.getProperty("rCorrelationID").toString())
				.property("rTargetSystem", cachedReqMsg.getProperty("rTargetSystem").toString())
				.property("rSourceSystem", cachedReqMsg.getProperty("rSourceSystem").toString())
				.property("jmsCorrelationID", cachedReqMsg.getProperty("jmsCorrelationID").toString())
				.property("rServiceRequest", cachedReqMsg.getProperty("rServiceRequestHeader").toString())
				.property("ZoneID", cachedReqMsg.getProperty("ZoneID").toString())
				.buildAsList()
	}

	/**
	 * Extracts data from the source message XML via GPathResult to determine the correct mapping script
	 * to call for the specific flow.
	 */
	private List<GResult> processMappingScriptSelection(@Nonnull GMessage message, GPathResult fccMsg) {
		GResult.Builder gResult = message.result()

		String flow = message.getProperty("ZoneID") + '.' + message.getProperty("FCCID")
		MappingParameters.loadMappingParameters(flow)
		int tiVersion = Integer.parseInt(MappingParameters.getFTIVersion());

		String refId = fccMsg."ref_id".toString()
		String tnxTypeCode = fccMsg."tnx_type_code"
		String subTnxTypeCode = fccMsg."sub_tnx_type_code"
		String prodStatCode = fccMsg."prod_stat_code"
		String irTypeCode = fccMsg."ir_type_code"
		String bgReleaseFlag = fccMsg."bg_release_flag"
		String lcReleaseFlag = fccMsg."lc_release_flag"
		String programType = fccMsg."fscm_program"."program_type"
		String bkType = fccMsg."bk_type"
		String tiMsgType = ""
		String purpose = fccMsg."purpose"
		String attachmentHandling = ""
		String ccMsgType =  fccMsg.name()
		String product = message.getProperty("product")
		String transRef = fccMsg."ref_id"
		String mappingName = ""
		String finType = fccMsg."fin_type"
		
		boolean isUndertaking = purpose in ['01', '02', '03', '04', '05'] ? true : false

		String CCOutDLQErrorMessage = '\n' + "The FCC Outgoing Message with the product : " + message.getProperty("product") +
				" with the transaction reference : ${refId} does not have a matching routing configuration. The message will be placed to the Dead letter Queue." + '\n'

		log.info "Processing mapper routing for ${ccMsgType}"

		switch (ccMsgType) {
			case "program_counterparty_details":
				tiMsgType = getSCFMessageType(fccMsg)
				break
			case "bg_tnx_record":  // IMPORT GUARANTEE (IGT)
				tiMsgType = getIGTMessageType(tnxTypeCode, subTnxTypeCode, purpose, bgReleaseFlag, tiVersion, isUndertaking)
				break
			case "br_tnx_record":  // EXPORT GUARANTEE (EGT)
				tiMsgType = getEGTMessageType(tnxTypeCode, subTnxTypeCode, purpose, tiVersion, prodStatCode, isUndertaking)
				break
			case "cn_tnx_record":	// CREDIT NOTE
				tiMsgType = getCRNMessageType(tnxTypeCode)
				break
			case "ea_tnx_record":  // EXPORT OPEN ACCOUNT
				tiMsgType = getEOAMessageType(tnxTypeCode)
				break
			case "ec_tnx_record":  // EXPORT COLLECTION
				tiMsgType = getECOLMessageType(tnxTypeCode, tiVersion)
				if (tiMsgType == "TFECOLNEW" || tiMsgType == "TFECOLAMD" ) {
					attachmentHandling = "Y"
				}
				break
			case "el_tnx_record": // EXPORT LETTER OF CREDIT (ELC)
				tiMsgType = getELCMessageType(tnxTypeCode, subTnxTypeCode, prodStatCode)
				break
			case "ft_tnx_record":  // 	CUSTOMER PAYMENT
				tiMsgType = "TFCPCCRT"
				break
			case "ic_tnx_record": // IMPORT COLLECTION
				tiMsgType = getICOLMessageType(tnxTypeCode, subTnxTypeCode)
				break
			case ["in_tnx_record", "ip_tnx_record"]: // INVOICE
				tiMsgType = getINVMessageType(prodStatCode, product, programType)
				ccMsgType = getINVCCMessageType(tiMsgType)
				break
			case "io_tnx_record": // IMPORT OPEN ACCOUNT
				tiMsgType = getIOAMessageType(tnxTypeCode, subTnxTypeCode, prodStatCode)
				break
			case "ir_tnx_record": // CHEQUE
				tiMsgType = getCPIMessageType(irTypeCode)
				break
			case "lc_tnx_record": // IMPORT LETTER OF CREDIT(ILC)
				tiMsgType = getLCMessageType(tnxTypeCode, subTnxTypeCode)
				break
			case "ls_tnx_record": // LICENSE
				tiMsgType = getLICMessageType(tnxTypeCode, subTnxTypeCode)
				break
			case "sg_tnx_record": // SHIPPING GUARANTEE
				tiMsgType = getSHGMessageType(tnxTypeCode)
				break
			case "si_tnx_record": // IMPORT STANDBY LETTER OF CREDIT (ISB)
				tiMsgType = getISBMessageType(tnxTypeCode, subTnxTypeCode, tiVersion, lcReleaseFlag)
				break
			case "sr_tnx_record":  // EXPORT STANDBY LETTER OF CREDIT (ESB)
				tiMsgType = getESBMessageType( tnxTypeCode, prodStatCode, subTnxTypeCode, tiVersion)
				break
			case "tf_tnx_record": // FINANCE
				tiMsgType = getFINMessageType(tnxTypeCode, subTnxTypeCode, finType)
				break
			case "bk_tnx_record": // BULK FINANCE
				tiMsgType = getIBFMessageType(tnxTypeCode, bkType)
				break
			default:
				log.error INVALID_MESSAGE_TYPE_MSG + ccMsgType

				return gResult
						.failed()
						.property("transFlow", "[FCC-FTI]")
						.property("transRef", transRef)
						.property("failureCause", INVALID_MESSAGE_TYPE_MSG + ccMsgType)
						.buildAsList()
		}

		if (tiMsgType == "") {
			log.error CCOutDLQErrorMessage;

			return gResult
					.failed()
					.property("transFlow", "[FCC-FTI]")
					.property("transRef", transRef)
					.property("failureCause", "Unable to obtain corresponding FTI message type for ${ccMsgType}")
					.buildAsList()

		}

		mappingName = "${ccMsgType}_to_${tiMsgType}"
		log.info "Message will be mapped to :: ${mappingName}"

		// ACK/NACK Service - FCC to FTI flow - to await response
		if(message.getProperty("acknack") == "Y"){
			cacheHandler.InsertIntoCache(messageCache, message.messageBodyAsText, message.getMessageId())
			log.info "ACK NACK service is enabled for this message."
			log.debug "Message Id :: " + message.getMessageId()
		}

		log.info "FTIVersion is set as: " + MappingParameters.getFTIVersion();
		log.info "SWIFTVersion is set as: " + MappingParameters.getSWIFTVersion();

		String custom = "N"

		// Customisation
		def customisedMappings = customisation.getProperty("FromFCCtoFTICustomTemplates.list")

		if (customisedMappings != null && !customisedMappings.isEmpty()) {
			if (customisedMappings.contains(tiMsgType)) {
				custom = "Y"
				CustomMappingParameters.loadMappingParameters(flow)
				log.info "${mappingName} is declared configured for customisation and will be processed as one. Please make sure that you have created the respective customisation mapping for this: ${mappingName}_custom.xsl"
			}
		}

		log.info "Processing FCC outgoing message Message Name: ${ccMsgType}, Transaction Reference:  ${transRef}"

		return gResult
				.messageBody(message.messageBody)
				.property("transFlow", "[FCC-FTI]")
				.property("transRef", transRef)
				.property("ccMsgType",ccMsgType)
				.property("tiMsgType", tiMsgType)
				.property("attachmentHandling", attachmentHandling)
				.property("message", (String) groovy.xml.XmlUtil.serialize( fccMsg ))
				.property("custom", custom)
				.property("mappingName", mappingName) // Construct mappingName property here (e.g. in_tnx_record_to_TFBUYFIN)
				.buildAsList()
	}

	/**
	 * Implement GRouteCallback.route()
	 * Route messages to Dead Letter Queue for invalid scenarios,
	 * which are identified as FAILED messages. 
	 */
	@Override
	@Nonnull
	List<GResult> route(@Nonnull GMessage message, @Nonnull List<String> outQueueNames, @Nullable String errorQueueName) {
		GResult.Builder gResult = message.result()
		GStatus gStatus = message.getStatus()
		if (gStatus == GStatus.ERROR) {
			gResult.queueName(errorQueueName)
			log.info "Routing to error queue: ${errorQueueName}"
		} else if (gStatus == GStatus.FAILED) {
			gResult.queueName(outQueueNames.last())
			log.info "Routing to dead letter queue: " + outQueueNames.last()
		}
		else {
			gResult.queueName(outQueueNames.first())
			log.info "Routing to outgoing queue: " + outQueueNames.first()
		}

		return gResult
				.messageBody(message.messageBody)
				.buildAsList()
	}

	/**
	 * Determines the SCF TI message type (used for identifying mapping script)
	 * based on FFC source XML's prog_cpty_assn_status field.
	 * 
	 */
	private String getSCFMessageType(GPathResult fccMsg) {
		return (fccMsg."program_counterparty"."prog_cpty_assn_status" == "D") ? "SCFRelationship" : "SCFBuyerOrSeller";
	}

	/**
	 * Determines the Import Guarantee TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 * 
	 */
	private String getIGTMessageType(String tnxTypeCode, String subTnxTypeCode, String purpose, String bgReleaseFlag, int tiVersion, boolean isUndertaking) {
		switch (tnxTypeCode) {
			case "01":
				return isUndertaking ? "TFUTIAPP" : "TFIGTAPP"
			case "03":
				if ("Y" == bgReleaseFlag)
					return "TFIGTCAN"
				else // Amendment
					return isUndertaking ? "TFUTIAMN" : "TFIGTAMN"
			case "13":
				switch (subTnxTypeCode) {
					case "03": // Maintenance > Set Reference
						return isUndertaking ? "TFUTIAMN" : "TFIGTAMN"
					case ["88", "89"]:
						return isUndertaking ? "TFUTIAPP" : "TFIGTAPP"
					case ["08", "09", "20", "21", "62", "63"]:
						if (tiVersion >= 27)
							return isUndertaking ? "TFUTIPYR" : "TFIGTPYR"
					case "68":
						return "TFUTICAN"
					default:
						return isUndertaking ? "TFUTICOR" : "TFIGTCOR"
				}
			default:
				return ""
		}
	}

	/**
	 * Determines the Export Guarantee TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getEGTMessageType(String tnxTypeCode, String subTnxTypeCode, String purpose, int tiVersion, String prodStatCode, boolean isUndertaking) {
		switch(tnxTypeCode) {
			case ["03", "13"]:
				switch (subTnxTypeCode) {
					case "03":
						return isUndertaking ? "TFUTRAMD" : "TFEGTAMD"
					case ["24", "25"]:
						return isUndertaking ? "TFUTRCOR" : "TFEGTCOR"
					case ["66", "67"]:
						if (tiVersion >= 27) {
							switch (prodStatCode) {
								case "31":
									return isUndertaking ? "TFUTRBMR" : "TFEGTBMR"
								case "81":
									return isUndertaking ? "TFUTRBCR" : "TFEGTBCR"
								default:
									return ""
							}
						}
					default:
						return isUndertaking ? "TFUTRCOR" : "TFEGTCOR"
				}
			default:
				return ""
		}
	}

	/**
	 * Determines the Credit notes TI message type (used for identifying mapping script)
	 * based on the FCC source XML's tnx_type_code.
	 *
	 */
	private String getCRNMessageType(String tnxTypeCode) {
		switch(tnxTypeCode) {
			case ["01", "05"]:
				return "TFCRNNEW"
			default:
				return ""
		}
	}

	/**
	 * Determines the Export Open Account TI message type (used for identifying mapping script)
	 * based on the FCC source XML's tnx_type_code.
	 *
	 */
	private String getEOAMessageType(String tnxTypeCode) {
		switch(tnxTypeCode) {
			case ["30", "31", "38", "64", "65"]:
				return "TFEOACRE"
			default:
				return ""
		}
	}

	/**
	 * Determines the Export Collection TI message type (used for identifying mapping script)
	 * based on the FCC source XML's tnx_type_code and the current TI Version as per mapping.parameters.properties.
	 *
	 */
	private String getECOLMessageType(String tnxTypeCode, int tiVersion) {
		switch(tnxTypeCode) {
			case "01":
				return "TFECOLNEW"
			case "03":
				return (tiVersion >= 25) ? "TFECOLAMD" : "TFECOLAMR"
			case "13":
				return "TFECOLCOR"
			default:
				return ""
		}
	}

	/**
	 * Determines the Export Letter of Credit TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getELCMessageType(String tnxTypeCode, String subTnxTypeCode, String prodStatCode) {
		switch(tnxTypeCode) {
			case "13":
				switch(subTnxTypeCode) {
					case "03":
						return "TFELCAMD"
					case "12":
						return "TFELCTRF"
					case "19":
						return "TFELCAOP"
					case ["46", "47"]:
						switch(prodStatCode) {
							case "12":
								return "TFELCPYR"
							case "31":
								return "TFELCBMR"
							case "81":
								return "TFELCBCR"
							default:
								return ""
						}
					case["08", "09"]:
						return "TFELCPYR"
					default:
						return "TFELCCOR"
				}
			default:
				return ""
		}
	}

	/**
	 * Determines the Import Collection TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getICOLMessageType(String tnxTypeCode, String subTnxTypeCode) {
		switch (tnxTypeCode) {
			case "13":
				switch(subTnxTypeCode) {
					case "03":
						return "TFICOLAMD"
					case "25":
						return "TFICOLPAY"
					default:
						return "TFICOLCOR"
				}
			default:
				return ""
		}
	}

	/**
	 * Determines the Invoice TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getINVMessageType(String prodStatCode, String product, String programType) {
		if (prodStatCode == "70" || prodStatCode == "48" || prodStatCode == "03"){
			return "TFINVNEW"
		}
		else if (product == "IN_APF" || product == "IN_IFP" || programType == "01" && prodStatCode == "54") { // BUYER CENTRIC FINANCE
			return "TFBUYFIN"
		}
		else if (product == "IN_DFP" || programType == "02" && prodStatCode == "54") {  // SELLER CENTRIC FINANCE
			return "TFSELFIN"
		}
		else if (prodStatCode == "D7") {  // FINANCE REPAYMENT
			if (programType == "01") {  // BUYER CENTRIC FINANCE REPAYMENT
				return "TFIRFRPY"
			}
			else if (programType == "02") {  // SELLER CENTRIC FINANCE REPAYMENT
				return "TFIDSRPY"
			}
			else
				return ""
		}
		else if (prodStatCode == "E2") { // INVOICE SETTLEMENT
			return "TFINVSET"
		}
		else {
			return ""
		}
	}

	/**
	 * Determines the Invoice CC message type (used for identifying mapping script)
	 * based on the passed TI message type.
	 *
	 */
	private String getINVCCMessageType(String tiMsgType) {
		switch(tiMsgType) {
			case "TFINVNEW":
				return "invoice"
			case ["TFBUYFIN", "TFSELFIN"]:
				return "invoice_single_finance_request"
			case ["TFIRFRPY", "TFIDSRPY"]:
				return "invoice_single_finance_repay"
			case "TFINVSET":
				return "ip_tnx_record"
			default:
				return ""
		}
	}

	/**
	 * Determines the Import Open Account TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getIOAMessageType(String tnxTypeCode, String subTnxTypeCode, String prodStatCode) {
		switch (tnxTypeCode) {
			case ["01", "30", "31", "38", "64", "65"]:
				return "TFIOACRE"
			case "03":
				switch (subTnxTypeCode) {
					case "69":
						switch (prodStatCode) {
							case "08":
								return "TFIOATBE"
							case "98":
								return "TFIOABRE"
							default:
								return ""
						}
					case "83":
						return "TFIOARSE"
					default:
						return ""
				}
			case "32":
				return "TFIOASRE"
			case "55":
				return "TFIOARPY"
			default:
				return ""
		}
	}

	/**
	 * Determines the CPI TI message type (used for identifying mapping script)
	 * based on the FCC source XML's ir_type_code field.
	 *
	 */
	private String getCPIMessageType(String irTypeCode) {
		switch (irTypeCode) {
			case "01":
				return "TFCPICOR"
			case "02":
				return "TFCHICOR"
			default:
				return ""
		}
	}

	/**
	 * Determines the Import Letter of Credit TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getLCMessageType(String tnxTypeCode, String subTnxTypeCode) {
		switch (tnxTypeCode) {
			case "01":
				return (subTnxTypeCode == "06") ? "TFILCBTB" : "TFILCAPP"
			case "03":
				return "TFILCAMN"
			case "13":
				switch (subTnxTypeCode) {
					case "03":
						return "TFILCAMN"
					case ["08", "09", "62", "63"]:
						return "TFILCPYR"
					case "68":
						return "TFILCCAN"
					case ["88", "89"]:
						return "TFILCAPP"
					default:
						return "TFILCCOR"
				}
			default:
				return ""
		}
	}

	/**
	 * Determines the License TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getLICMessageType(String tnxTypeCode, String subTnxTypeCode) {
		switch (tnxTypeCode) {
			case "01":
				return "TFLICAPP"
			case "03":
				return "TFLICAMD"
			case "13":
				return (subTnxTypeCode == "96") ? "TFLICCAN" : "TFLICCOR"
			default:
				return ""
		}
	}

	/**
	 * Determines the Shipping Guarantee TI message type (used for identifying mapping script)
	 * based on the FCC source XML's tnx_type_code field.
	 *
	 */
	private String getSHGMessageType(String tnxTypeCode) {
		switch (tnxTypeCode) {
			case "01":
				return "TFSHGAPP"
			case "13":
				return "TFSHGCOR"
			default:
				return ""
		}
	}

	/**
	 * Determines the Import Standby LC TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getISBMessageType(String tnxTypeCode, String subTnxTypeCode, int tiVersion, String lcReleaseFlag) {
		switch (tnxTypeCode) {
			case "01":
				return "TFISBAPP"
			case "03":
				return ("Y" == lcReleaseFlag) ? "TFISBCAN" : "TFISBAMN"
			case "13":
				switch (subTnxTypeCode) {
					case ["03"]:
						return "TFISBAMN"
					case ["88", "89"]:
						return "TFISBAPP"
					case ["62", "63", "08", "09"]:
						return (tiVersion >= 27) ? "TFISBPYR" : ""
					default:
						return "TFISBCOR"
				}
			default:
				return ""
		}
	}

	/**
	 * Determines the Export Standby LC TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getESBMessageType(String tnxTypeCode, String prodStatCode, String subTnxTypeCode, int tiVersion) {
		switch (tnxTypeCode) {
			case ["03", "13"]:
				switch (subTnxTypeCode) {
					case "03":
						return "TFESBAMD"
					case ["66", "67"]:
						if (tiVersion >= 27) {
							switch (prodStatCode) {
								case "31":
									return "TFESBBMR"
								case "81":
									return "TFESBBCR"
								default:
									return ""
							}
						}
					default:
						return "TFESBCOR"
				}
			default:
				return ""
		}
	}

	/**
	 * Determines the Finance Standalone TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getFINMessageType(String tnxTypeCode, String subTnxTypeCode, String finType) {
		switch (tnxTypeCode) {
			case "01":
				return "TFFINNEW"
			case "13":
				if (subTnxTypeCode == "66" || subTnxTypeCode == "67") {
					return "TFFINNEW"
				}
				else if (finType == "99" && (subTnxTypeCode == "38" || subTnxTypeCode == "39")) {
					return "TFFSARPY"
				}
				else {
					return "TFFINCOR"
				}
			default:
				return ""
		}
	}

	/**
	 * Determines the Invoice Bulk Finance TI message type (used for identifying mapping script)
	 * based on the parameters sent to this method.
	 *
	 */
	private String getIBFMessageType(String tnxTypeCode, String bkType) {
		switch (tnxTypeCode) {
			case "01":
				switch (bkType) {
					case ["INFT", "IPFT"]:
						return "TFIBFCRE"
					case ["INRP", "IPRP"]:
						return "TFIBPCRE"
					default:
						return ""
				}
			default:
				return ""
		}
	}
}
