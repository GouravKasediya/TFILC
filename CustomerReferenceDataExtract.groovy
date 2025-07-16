package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.api.callback.GRouteCallback
import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult
import com.misys.tools.integration.api.message.GStatus

import javax.annotation.Nonnull
import javax.annotation.Nullable

import groovy.util.XmlSlurper
import groovy.util.logging.Slf4j

/*
 * Extracts and saves the customer reference by its parts and saves it as the message's property
 * 
 * TODO: Extend a common class which implements GProcess and GRouteCallback.
 */
@Slf4j
class CustomerReferenceDataExtract implements GProcessor, GRouteCallback {
	
	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		GResult.Builder gResult = message.result()
		
		def fccMsg = new XmlSlurper().parseText(message.messageBody)
		String product = fccMsg."product_code"
		String fscmProgrammeCode = fccMsg."fscm_program"."program_code"
		String custRefXmlTag = ""
		String custRef = ""
		String zoneId = ""
		
		// ACKNOWLEDGEMENT / NON-ACKNOWLEDGEMENT
		// Checks whether message is a response message from FCC to TI. Immediately returns message.
		if (fccMsg.status.text().toUpperCase() in ["ACK", "NACK"]) {
			log.debug "FCC Response message: ${fccMsg.status}"
			return gResult
					.messageBody(message.messageBody)
					.buildAsList()
		}
		
		if (fscmProgrammeCode == '' || fscmProgrammeCode == null) { // FSCM programme implementation of FCC 5.4 and below
			fscmProgrammeCode = fccMsg."fscm_programme_code"
		
			// DETERMINE IF BUYER CENTRIC, SELLER CENTRIC OR SIMPLY INVOICE VIA FSCMPROGRAMME
			if (fscmProgrammeCode == '02') {
				product += '_DFP'
			} else if (fscmProgrammeCode == '03') {
				product += '_IFP'
			} else if (fscmProgrammeCode == '04') {
				product += '_APF'
			}
		}
		
		log.debug "Product of the transaction :: ${product}"
		
		/*
		 * For new core/customisation product codes, just add them to the specified cases below.
		 * Take note of the respective field where the customer reference value is being placed
		 * E.g. For LC, the customer reference is being placed to the applicant_reference field
		 * by FCC
		*/
		
		if (fccMsg.name() == "program_counterparty_details") {
			custRef = fccMsg."program_counterparty"."customer_reference"
		}
		//	TODO: Can be modified to use key-value pairs. Set custRef and custRefXmlTag based on the key
		else {
			switch (product) {
				case ["LC", "BG", "LS", "SG", "SI", "FT", "TF"]:
					custRef = fccMsg."applicant_reference"
					custRefXmlTag = "applicant_reference"
					break
				case ["BR", "EL", "IR", "SR"]:
					custRef = fccMsg."beneficiary_reference"
					custRefXmlTag = "beneficiary_reference"
					break
				case ["CN"]:
					custRef = (fscmProgrammeCode == '' || fscmProgrammeCode == null) ? fccMsg."seller_reference" : fccMsg."fscm_program"."customer_reference"
					custRefXmlTag = (fscmProgrammeCode == '' || fscmProgrammeCode == null) ? "seller_reference" : "fscm_program><customer_reference/></fscm_program"
				case ["IN", "IP"]:
					custRef = (fscmProgrammeCode == '' || fscmProgrammeCode == null) ? fccMsg."buyer_reference" : fccMsg."fscm_program"."customer_reference"
					custRefXmlTag = (fscmProgrammeCode == '' || fscmProgrammeCode == null) ? "buyer_reference" : "fscm_program><customer_reference/></fscm_program"
					break
				case ["IN_APF", "IN_IFP", "IO"]:
					custRef = fccMsg."buyer_reference"
					custRefXmlTag = "buyer_reference"
					break
				case ["EA", "IN_DFP"]:
					custRef = fccMsg."seller_reference"
					custRefXmlTag = "seller_reference"
					break
				case ["EC"]:
					custRef = fccMsg."drawer_reference"
					custRefXmlTag = "drawer_reference"
					break
				case ["IC"]:
					custRef = fccMsg."drawee_reference"
					custRefXmlTag = "drawee_reference"
					break
				case ["BK"]:
					custRef = (fccMsg."product_file_set"."in_tnx_record"."fscm_program"."customer_reference"[0] == '' || fccMsg."product_file_set"."in_tnx_record"."fscm_program"."customer_reference"[0] == null) ?
								fccMsg."product_file_set"."ip_tnx_record"."fscm_program"."customer_reference"[0] :
								fccMsg."product_file_set"."in_tnx_record"."fscm_program"."customer_reference"[0]

					custRefXmlTag = "fscm_program><customer_reference/></fscm_program"
					break
				default:
					log.error "Customer Reference field was not determined. The product code ${product} is not recognized by the codes."
					return gResult
							.failed()
							.property("failureCause", "Unrecognized product_code: ${product}")
							.buildAsList()
			}
		}
		log.debug "Customer reference: ${custRef}"
		
		if (!custRef.isEmpty()) {
			zoneId = custRef.split("\\.")[1]
			log.debug "Extracted Zone Id ${zoneId} from customer reference: ${custRef}"
		} else {
			log.error "The respective customer reference XML tag <${custRefXmlTag}> for the product ${product} is blank. Please review the customer reference configuration in FCC."
			return gResult
					.failed()
					.property("failureCause", "The respective customer reference XML tag <${custRefXmlTag}> for the product ${product} is blank")
					.buildAsList()
		}
		log.info "Customer, Product Code, and Zone ID extracted from reference"
		return gResult
				.messageBody(message.messageBody)
				.property("product", product)
				.property("custRef", custRef) // not used outside this class
				.property("ZoneID", zoneId)
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
}