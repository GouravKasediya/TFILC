package com.misys.tiplus2.ticc.groovy.router

import java.util.List

import com.misys.tools.integration.api.annotation.InjectResource
import com.misys.tools.integration.api.callback.GRouteCallback
import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GProperties
import com.misys.tools.integration.api.message.GResult
import com.misys.tools.integration.api.message.GStatus
import com.misys.tools.integration.impl.api.component.resource.cache.GSimpleCacheResourceImpl
import com.misys.tools.integration.impl.api.component.resource.properties.GPropertiesResourceImpl

import javax.annotation.Nonnull
import javax.annotation.Nullable

import com.misys.tiplus2.ticc.MappingParameters
import com.misys.tiplus2.ticc.customisation.CustomMappingParameters
import com.misys.tiplus2.ticc.GlobalFunctions

import groovy.util.XmlSlurper
import groovy.util.slurpersupport.GPathResult
import groovy.xml.XmlUtil
import groovy.util.logging.Slf4j

/**
 * Determines where the message will be routed before being transformed and what script/s (plural considering customized mappings) will be
 * used to transform it. Also responsible for storing messages for Acknowledgement / Non-acknowledgement flows.
 * 
 * Renamed from FTI_to_FCC_MappingSelector.groovy
 * 
 * @author mdelator
 *
 */
@Slf4j
class FTIToFCCMappingSelector implements GProcessor, GRouteCallback {

	@InjectResource(required = true)
	GSimpleCacheResourceImpl messageCache

	@InjectResource(required = true)
	GPropertiesResourceImpl customisation

	// TODO: Put to an external resource that would hold final variables
	private final static String CACHE_HANDLER = "groovy/com/misys/tiplus2/ticc/groovy/router/CacheHandler.groovy"
	private final static String DISCARD_TFSCFPGM_WARN_MSG = '\n' + "FTI FSCM Program Operation is delete. No need to relay this to FCC as Operation update handles the delete scenario for FSCM program onboarding." + '\n' + "Message will be discarded" + '\n'
	private final static String DISCARD_TFSCFPTY_WARN_MSG = "Counterparty addition was approved. No need to relay this to FCC as Buyer/Seller Relationship will then be created and updated the counterparty association status."
	
	// Route type property and different route types
	private final static String ROUTE_TYPE = "routeType"
	private final static String ROUTE_TYPE_CLIENT_WORDING = "clientWording"
	private final static String ROUTE_TYPE_DELAY = "delay"
	private final static String ROUTE_TYPE_DISCARD = "discard"
	private final static String ROUTE_TYPE_MAP = "map"
	private final static String ROUTE_TYPE_SPLIT = "split"
	private final static String ROUTE_TYPE_SPLIT_PAY_DRAFT = "splitPayColDraft"
	private final static String ROUTE_TYPE_SPLIT_ACC_DRAFT = "splitAccColDraft"
	private final static String ROUTE_TYPE_STANDBY_TO_UNDERTAKING_CONVERSION = "standbyToUndertakingConversion"
	private final static String ROUTE_TYPE_TISYNC = "tisync"

	File cacheHandlerFile = new File(CACHE_HANDLER)
	Class groovyClass = new GroovyClassLoader(getClass().getClassLoader()).parseClass(cacheHandlerFile)
	GroovyObject cacheHandler = (GroovyObject) groovyClass.newInstance()

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		GResult.Builder gResult = message.result()

		GPathResult msgXml = new XmlSlurper(false, false).parseText(message.messageBody)
		GPathResult msgXmlBody

		def zoneIdTag = new XmlSlurper().parseText("<ZoneID>" + message.getProperty("ZoneID") + "</ZoneID>")

		String ccMessageType = ""
		String custom = "N"
		String flow = message.getProperty("ZoneID") + "." + message.getProperty("FCCID")
		String mappingName = ""
		String messageName = ""
		String operation = ""
		String product = ""
		String serviceRequest = msgXml.name().toString().toUpperCase()
		String templateName = ""
		String transRef = ""

		boolean hasHeader = msgXml.RequestHeader.size() > 0 // Check if RequestHeader exists. Doesn't exist on responses
		boolean isAckNackEnabled = message.getProperty("acknack") == "Y" ? true : false

		MappingParameters.loadMappingParameters(flow)

		if (isAckNackEnabled && serviceRequest == "SERVICEREQUEST") {
			gResult.properties( getAckNackResponseProperties(message, msgXml) )
		}

		// TODO: Refactor append zone id. Append based on template?
		if (hasHeader) {
			operation = msgXml.RequestHeader.Operation.toString()
			msgXml.children()[1].appendNode(zoneIdTag)
			msgXmlBody = new XmlSlurper().parseText( XmlUtil.serialize(msgXml.children()[1]) )
		} else {
			if (! isTISync(msgXml)) {
				msgXml.appendNode(zoneIdTag)
			}
			msgXmlBody = new XmlSlurper(false, false).parseText( XmlUtil.serialize(msgXml) )
		}

		if (isTISync(msgXml)) {
			messageName = msgXmlBody.ResponseHeader.Operation.toString().toUpperCase()
		} else {
			messageName = msgXmlBody.MessageName.isEmpty() ? operation : msgXmlBody.MessageName.toString()
			product = GlobalFunctions.getSourceProductCode(messageName)
			transRef = msgXmlBody.MasterRef.toString()
		}

		String TIOutDLQErrorMessage = '\n' + "The FTI Outgoing Message " +
				" with the transaction reference : ${transRef}" +
				" does not have a matching routing configuration. The message will be placed to the Dead letter Queue." + '\n'

		templateName = msgXmlBody.name().toString().toUpperCase()

		gResult
				.property("messageName", messageName)
				.property("templateName", templateName)

		if (templateName == "SERVICERESPONSE") {
			return gResult
					.property(ROUTE_TYPE, ROUTE_TYPE_TISYNC)
					.messageBody(message.messageBody)
					.buildAsList()
		} else {
			GProperties prop = getTemplateNameMapProperties(templateName, product, msgXmlBody)
			if (prop == null)
				return gResult
						.failed()
						.property(ROUTE_TYPE, ROUTE_TYPE_MAP)
						.property("transFlow", "[FTI-FCC]")
						.property("transRef", transRef)
						.property("failureCause", "Unable to obtain corresponding FCC Message type from ${templateName}")
						.buildAsList()
			else
				gResult.properties( prop )

			// Append zone id where it is needed for product that cannot include a Zone ID
			// TODO: Put this in a function. Note: appendNode has void return
			// TODO: Must be a way to map Zone ID for these templates without appending
			switch (templateName){
				case "TFLNLNK":
					msgXmlBody.LinkedLicenses.appendNode(zoneIdTag)
				case "TFCUSREF":
					msgXmlBody.ReferenceBlock.appendNode(zoneIdTag)
				case "TFSCFPGM":
					if (msgXmlBody.SCFProgramme.Operation != "delete")
						msgXmlBody.SCFProgramme.appendNode(zoneIdTag)
					else break
				case "TFSCFPTY":
					if(msgXmlBody.SCFBuyerOrSeller.Operation != "insert")
						msgXmlBody.SCFBuyerOrSeller.appendNode(zoneIdTag)
					else break
				case "TFSCFMAP":
					msgXmlBody.SCFProgrammeRelationship.appendNode(zoneIdTag)
			}
		}

		GResult r = gResult.build()
		templateName = r.getProperty("templateName")
		ccMessageType = r.getProperty("ccMessageType")
		// TODO: Remove templateName and ccMessageType in the property. Seems not used anywhere else
		mappingName = "${templateName}_to_${ccMessageType}"

		if (isAckNackEnabled) {
			// Insert a copy of the pre-final message (for this class) which contains both the properties and the XML message
			cacheHandler.InsertIntoCache(messageCache, gResult.build(), msgXmlBody.MasterRef.toString())
			gResult.property("isStaticDownload", GlobalFunctions.isFTIStaticDownload(operation) ? "Y" : "N")

			log.info "ACK NACK service is enabled for this message."
		}

		log.info "FCCVersion is set as: " + MappingParameters.getFCCVersion() + ", FCCPatch is set as: " + MappingParameters.getFCCPatch()
		log.info "FTIVersion is set as: " + MappingParameters.getFTIVersion() + ", FTIPatch is set as: " + MappingParameters.getFTIPatch()
		log.info "SWIFTVersion is set as: " + MappingParameters.getSWIFTVersion()


		// Customisation
		def customisedMappings = customisation.getProperty("FromFTItoFCCCustomTemplates.list")

		if (customisedMappings != null && !customisedMappings.isEmpty()) {
			if (customisedMappings.contains(templateName)) {
				custom = "Y"
				CustomMappingParameters.loadMappingParameters(flow)
				log.info "${mappingName} is declared configured for customisation and will be processed as one. Please make sure that you have created the respective customisation mapping for this: ${mappingName}_custom.xsl"
			}
		}

		log.info "Processing FCC outgoing message Message Name: ${ccMessageType}, Transaction Reference: ${transRef}"

		return gResult
				.property("transFlow", "[FTI-FCC]")
				.property("mappingName", mappingName)
				.property("custom", custom)
				.messageBody( (String) groovy.xml.XmlUtil.serialize(msgXmlBody) )
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
	 * Returns the ACK NACK Properties for generating required for the response
	 * 
	 * TODO: Revisit in ACK NACK refactor. Maybe possible to remove some property or send the whole Header instead
	 * 
	 * @param message
	 * @param msgXml
	 * @return
	 */
	private GProperties getAckNackResponseProperties(@Nonnull GMessage message, GPathResult msgXml) {
		GProperties prop = new GProperties()
		prop.put("rService", msgXml.RequestHeader.Service.toString())
		prop.put("rOperation", msgXml.RequestHeader.Operation.toString())
		prop.put("rCorrelationID", msgXml.RequestHeader.CorrelationId.toString())
		prop.put("rTargetSystem", msgXml.RequestHeader.TargetSystem.toString())
		prop.put("rSourceSystem", msgXml.RequestHeader.SourceSystem.toString())
		prop.put("jmsCorrelationID", message.getProperty("jms.correlation.id"))
		prop.put("rServiceRequestHeader", msgXml.ServiceRequest.toString())
		prop.put("ZoneID", message.getProperty("ZoneID"))
		return prop
	}

	/**
	 * Checks if a TI response message (TI Sync)
	 * @param argMainMsg
	 * @return
	 */
	private boolean isTISync(def msgXml) {
		return msgXml.ResponseHeader.Service.toString()
				.equalsIgnoreCase("TISync") ?
				true : false
	}

	/**
	 * Returns the properties assigned to the message for a given template, <code>templateName</code></br />
	 * Disregarding the message's product-event, this sets the following property:
	 * <ul>
	 * 	<li>ccMessageType</li>
	 *  <li>routeType</li>
	 *  <li>cwSequence</li>
	 *  <li>provisional</li>
	 *  <li>templateName</li>
	 * </ul>
	 * 
	 * @param templateName
	 * @param product
	 * @param xml
	 * @return
	 */
	GProperties getTemplateNameMapProperties(String templateName, String product, GPathResult xml) {
		GProperties prop = new GProperties()
		
		int fccVersion = Integer.parseInt(MappingParameters.getFCCVersion())
		int fccPatch = Integer.parseInt(MappingParameters.getFCCPatch())
		
		switch(templateName){
			// IMPORT LETTER OF CREDIT (ILC)
			case [
				"TFILCAMJ",
				"TFILCAMK",
				"TFILCGEN",
				"TFILCPAY"
			]:
				prop.put("ccMessageType", "lc_tnx_record")
				break

			// products with provisional/client wording
			case [
				"TFILCDET",
				"TFIGTDET",
				"TFISBDET",
				"TFUTIDET"
			]:
				if (templateName == "TFILCDET") {
					prop.put("ccMessageType", "lc_tnx_record")
				} else if (templateName in ["TFIGTDET", "TFUTIDET"]){
					prop.put("ccMessageType", "bg_tnx_record")
				} else if (templateName == "TFISBDET"){
					prop.put("ccMessageType", "si_tnx_record")
				}

				prop.put(ROUTE_TYPE, ROUTE_TYPE_CLIENT_WORDING)
				prop.put("cwSequence", (xml.Sequence && xml.Sequence != "1")? xml.Sequence.toString() : "1")
				prop.put("provisional", (xml.Provisional && xml.Provisional == "Y")? xml.Provisional.toString() :"N")
				break

			// EXPORT LETTER OF CREDIT (ELC)
			case [
				"TFELCDET",
				"TFELCAMJ",
				"TFELCGEN",
				"TFELCPAY"
			]:
				prop.put("ccMessageType", "el_tnx_record")
				break

			// IMPORT GUARANTEE (IGT) / ISSUED UNDERTAKING (UTI)
			case [
				"TFIGTGEN",
				"TFIGTPAY",
				"TFUTIGEN",
				"TFUTIPAY"
			]:
				prop.put("ccMessageType", "bg_tnx_record")
				break

			// EXPORT GUARANTEE (EGT) / RECEIVED UNDERTAKING (UTR)
			case [
				"TFEGTDET",
				"TFEGTGEN",
				"TFEGTPAY",
				"TFUTRDET",
				"TFUTRGEN",
				"TFUTRPAY"
			]:
				prop.put("ccMessageType", "br_tnx_record")
				break

			// SHIPPING GUARANTEE (SHG)
			case [
				"TFSHGDET",
				"TFSHGAMD",
				"TFSHGGEN",
				"TFSHGREL",
				"TFSHGRET"
			]:
				prop.put("ccMessageType", "sg_tnx_record")
				break

			// IMPORT STANDBY LETTER OF CREDIT (ISB)
			case ["TFISBGEN", "TFISBPAY"]:
				prop.put("ccMessageType", "si_tnx_record")
				break

			// EXPORT STANDBY LETTER OF CREDIT(ESB)
			case [
				"TFESBDET",
				"TFESBGEN",
				"TFESBPAY"
			]:
				prop.put("ccMessageType", "sr_tnx_record")
				break

			// IMPORT AND EXPORT COLLECTION (ICC, IDC, OCC, ODC)
			case "TFCOLDET":
				if (product == "COL"){
					prop.put("templateName", "TFCOLDET")
					prop.put("ccMessageType", "collections")
				}
				break
			case "TFCOLGEN":
				if (product in ["ICC", "IDC"]){
					prop.put("templateName", "TFICOLGEN")
					prop.put("ccMessageType", "ic_tnx_record")
				} else if(product in ["OCC", "ODC"]){
					prop.put("templateName", "TFECOLGEN")
					prop.put("ccMessageType", "ec_tnx_record")
				} else if(product == "COL") {
					prop.put("templateName", "TFCOLGEN")
					prop.put("ccMessageType", "collections")
				}
				break
			case "TFCOLPAY":
				if (product in ["ICC", "IDC"]){
					prop.put("templateName", "TFICOLPAY")
					prop.put("ccMessageType", "ic_tnx_record")
				} else if(product in ["OCC", "ODC"]){
					prop.put("templateName", "TFECOLPAY")
					prop.put("ccMessageType", "ec_tnx_record")
				}
				if (fccVersion < 62 || (fccVersion == 62 && fccPatch < 4)) {
					prop.put(ROUTE_TYPE, ROUTE_TYPE_SPLIT_PAY_DRAFT)
				}
				break
			case "TFCOLAMD":
				if (product in ["ICC", "IDC"]){
					prop.put("templateName", "TFICOLAMD")
					prop.put("ccMessageType", "ic_tnx_record")
				} else if(product in ["OCC", "ODC"]){
					prop.put("templateName", "TFECOLAMD")
					prop.put("ccMessageType", "ec_tnx_record")
				}
				break
			case "TFCOLACC":
				if (product in ["ICC", "IDC"]){
					prop.put("templateName", "TFICOLACC")
					prop.put("ccMessageType", "ic_tnx_record")
				} else if (product in ["OCC", "ODC"]){
					prop.put("templateName", "TFECOLACC")
					prop.put("ccMessageType", "ec_tnx_record")
				}
				if (fccVersion < 62 || (fccVersion == 62 && fccPatch < 4)) {
					prop.put(ROUTE_TYPE, ROUTE_TYPE_SPLIT_ACC_DRAFT)
				}
				break

			// LICENSE (LN, LIC)
			case ["TFLNDET", "TFLICGEN"]:
				prop.put("ccMessageType", "ls_tnx_record")
				break

			// LINKED-LICENSES (LN)
			case "TFLNLNK":
				prop.put("ccMessageType", "ls_tnx_record")
				prop.put(ROUTE_TYPE, ROUTE_TYPE_SPLIT)
				break

			// FINANCE (FIN)
			case ["TFFINDET", "TFFINGEN"]:
				prop.put("ccMessageType", "tf_tnx_record")
				break

			// INVOICE (INV)
			case ["TFINVDET", "TFINVGEN"]:
				prop.put("ccMessageType", "invoice")
				break

			// INVOICE SETTLEMENT (INV)
			case "TFINVSET":
				prop.put("ccMessageType", "invoice_settlement")
				prop.put(ROUTE_TYPE, ROUTE_TYPE_DELAY)
				log.warn "Processing TFINVSET after a short delay."
				break

			// INVOICE SINGLE FINANCE REQUEST (INVFIN)
			case ["TFINVFINDET", "TFINVFINGEN"]:
				prop.put("ccMessageType", "invoice_single_finance_request")
				prop.put(ROUTE_TYPE, ROUTE_TYPE_DELAY)
				log.warn "Processing TFINVFINDET after a short delay."
				break

			// BUYER OR SELLER CENTRIC SINGLE FINANCE REPAYMENT (INVFIN)
			case "TFINVFINRPY":
				prop.put("ccMessageType", "invoice_single_finance_repay")
				break

			// CHEQUE/CUSTOMER PAYMENT (CHI)
			case [
				"TFCHIDET",
				"TFCHIGEN",
				"TFCPIDET",
				"TFCPIGEN"
			]:
				prop.put("ccMessageType", "ir_tnx_record")
				break

			// CLEAN PAYMENTS (CPC)
			case ["TFCPCDET", "TFCPCGEN"]:
				prop.put("ccMessageType", "ft_tnx_record")
				break

			// IMPORT OPEN ACCOUNT (IOA)
			case [
				"TFIOADET",
				"TFIOAAMD",
				"TFIOAPAY"
			]:
				prop.put("ccMessageType", "io_tnx_record")
				break

			// EXPORT OPEN ACCOUNT (EOA)
			case "TFEOADET":
				prop.put("ccMessageType", "ea_tnx_record")
				break

			// CURRENCY DOWNLOAD
			case "TFCASCCY":
				prop.put("ccMessageType", "currency_records")
				break

			// EXCHANGE RATES DOWNLOAD
			case "TFCASEXR":
				prop.put("ccMessageType", "exchange_rate_records")
				break

			// PRE-ALLOCATED REFERENCES DOWNLOAD
			case "TFCUSREF":
				prop.put("ccMessageType", "assigned_references")
				break

			// STANDBY TO UNDERTAKING CONVERSION
			case "TFSBYCNV":
				prop.put("ccMessageType", "migrate_records")
				prop.put(ROUTE_TYPE, ROUTE_TYPE_STANDBY_TO_UNDERTAKING_CONVERSION)
				break

			// FSCM PROGRAMME DOWNLOAD
			case "TFSCFPGM":
				if (xml.SCFProgramme.Operation == "delete") {
					prop.put(ROUTE_TYPE, ROUTE_TYPE_DISCARD)
					log.warn DISCARD_TFSCFPGM_WARN_MSG
				} else {
					prop.put("ccMessageType", "fscm_program_details")
				}
				break

			// FSCM COUNTERPARTY DOWNLOAD
			case "TFSCFPTY":
				if(xml.SCFBuyerOrSeller.Operation == "insert") { // Approved in MakerChecker (or automatically downloaded from TI)
					prop.put(ROUTE_TYPE, ROUTE_TYPE_DISCARD)
					log.warn DISCARD_TFSCFPTY_WARN_MSG
				} else { // Rejected in MakerChecker or Updated then Approved in MakerChecker (or automatically downloaded from TI)
					prop.put("ccMessageType", "program_counterparty_details")
				}
				break

			// FSCM COUNTERPARTY RELATIONSHIP DOWNLOAD
			case "TFSCFMAP":
				prop.put("ccMessageType", "program_counterparty_details")
				break

			//CREDIT NOTES (CRN)
			case "TFCRNDET":
				prop.put("ccMessageType", "cn_tnx_record")
				break

			// BULK FINANCE (BF)
			case "TFIBFDET":
				prop.put("ccMessageType", "bk_tnx_record")
				break

			//BULK PAYMENT (IBP)
			case "TFIBPDET":
				prop.put("ccMessageType", "bk_tnx_record")
				break

			// INVALID TEMPLATE NAME
			default:
				return null
		}

		// add default routeType map
		prop.putIfAbsent(ROUTE_TYPE, ROUTE_TYPE_MAP)

		return prop
	}

	// TODO: Print all properties for debugging
}
