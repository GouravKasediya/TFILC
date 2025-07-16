package com.misys.tiplus2.ticc.groovy.router

import com.misys.tiplus2.ticc.MappingParameters;

import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult
import com.misys.tools.integration.api.message.GStatus

import groovy.util.XmlSlurper
import groovy.util.logging.Slf4j

import javax.annotation.Nonnull
import javax.annotation.Nullable

@Slf4j
class FCCNACKMapper implements GProcessor {

	private static final String NACK_WARNING_MESSAGE = "Non-acknowledgement is only applicable for FCC 5.5 and above. Set ACK_NACK in config.properties to N to hide this warning."
	private static final String NACK_XML_STATUS = "NACK"

	private static final String ROUTE_ERROR_MESSAGE = "Routing to error queue: "

	private static final String STATIC_NACK_UNSUPPORTED_MESSAGE = "program_counterparty_details messages are not supported for non-acknowledgement."

	// message properties in use
	private static final String ERROR_CAUSE = "errorCause"
	private static final String FAILURE_CAUSE = "failureCause"

	private static final int REQUIRED_VERSION = 55
	
	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		GResult.Builder gResult = message.result()

		if(isNACKMessageSupported()) {
			return gResult
					.messageBody(buildNackMessage(message))
					.buildAsList()
		} else {
			return gResult
					.error()
					.messageBody(message.messageBody)
					.buildAsList()
		}
	}


	/**
	*  Returns true if the FCC version integrated to the current TICC instance
	*  supports NACK Messaging
	*  
	*  @param message
	*  @return true if Acknowledgement / Non-acknowledgement is supported, else false
	*/
	private boolean isNACKMessageSupported(@Nonnull GMessage message) {

		if (MappingParameters.getFCCVersion().toInteger() < REQUIRED_VERSION) {
			log.warn NACK_WARNING_MESSAGE
			return false
		}

		return true
	}

	/**
	 *  Constructs the NACK XML message contents to be sent back to FCC
	 *  
	 *  @param message
	 */
	private String buildNackMessage(@Nonnull GMessage message) {
		def xmlMsg = new XmlSlurper().parseText(message.messageBody)
		def builder = new groovy.xml.StreamingMarkupBuilder()
		def nackMsg = ""

		String xmlMsgName = xmlMsg.name()
		String errorMessage = message.getProperty(ERROR_CAUSE)
		String failureMessage = message.getProperty(FAILURE_CAUSE)
		String narrativeMessageStatus = (errorMessage != null) ? errorMessage : failureMessage

		if (xmlMsgName != "program_counterparty_details") {
			nackMsg = {
				mkp.xmlDeclaration()
				transaction_acknowledgement() {
					ref_id( xmlMsg."ref_id".text() )
					tnx_id( xmlMsg."tnx_id".text() )
					status(NACK_XML_STATUS)
					bo_ref_id( xmlMsg."bo_ref_id".text() )
					bo_tnx_id( xmlMsg."bo_tnx_id".text() )
					narrative_message_status( narrativeMessageStatus )
				}
			}
		} else {
			// For static "transactions"
			log.error STATIC_NACK_UNSUPPORTED_MESSAGE
			return
		}

		return builder.bind(nackMsg).toString()
	}
}