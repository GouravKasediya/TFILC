package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult

import javax.annotation.Nonnull
import javax.annotation.Nullable

import groovy.util.XmlSlurper
import groovy.util.logging.Slf4j
import groovy.util.slurpersupport.GPathResult;

import groovy.xml.XmlUtil

import org.apache.commons.lang.StringUtils;

@Slf4j
class FTINACKMapper implements GProcessor {

	private static final String XMLNS_ATTRIBUTE = "urn:control.services.tiplus2.misys.com"

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		return message
				.result()
				.messageBody(constructFTIACKNACKMessage(message))
				.property("jms.correlation.id", message.getProperty("jmsCorrelationID").toString())
				.buildAsList()
	}

	/**
	 * Constructs the XML message that will be sent to FTI based on message from FTI (TICC NACK to TI) or from FCC (FCC NACK to TI)
	 * @param message
	 * @return
	 */
	private String constructFTIACKNACKMessage(GMessage message) {
		String errorCause = message.getProperty("errorCause")
		String failureCause = message.getProperty("failureCause")
		String addInfo = ""
		String narrativeMessageStatus = ""
		String status = ""
		String subDetailsHeader = ""

		boolean isStaticDownload = message.getProperty("isStaticDownload") == "Y" ? true : false

		GPathResult fccMsg = new XmlSlurper().parseText(message.messageBody)

		String fccStatus = fccMsg.status.text().toUpperCase()
		String fccNarrativeStatus = fccMsg.narrative_message_status.text()

		if (! isStaticDownload) {
			if (fccMsg.narrative_message_status.isEmpty()) {
				narrativeMessageStatus = (errorCause != null) ? errorCause : failureCause
			} else {
				narrativeMessageStatus = (fccStatus == "ACK") ? fccNarrativeStatus : extractErrorMessage(fccNarrativeStatus)
			}
		}

		if (isStaticDownload || fccStatus == "ACK") {
			status = "SUCCEEDED"
			subDetailsHeader = "Info"
		} else {
			status = "FAILED"
			subDetailsHeader = "Error"
		}

		def builder = new groovy.xml.StreamingMarkupBuilder()

		log.info "Constructing response to FTI"

		return new groovy.xml.StreamingMarkupBuilder().bind({
			mkp.xmlDeclaration()
			ServiceResponse(xmlns: XMLNS_ATTRIBUTE){
				ResponseHeader() {
					Service( message.getProperty("rService") )
					Operation( message.getProperty("rOperation") )
					Status( status )
					Details() { "${subDetailsHeader}"(narrativeMessageStatus) }
					CorrelationId( message.getProperty("rCorrelationID") )
					TargetSystem( message.getProperty("rSourceSystem") )
					SourceSystem( message.getProperty("rTargetSystem") )
				}
			}
		}).toString()
	}

	/**
	 * Extracts the Error message in the XML
	 * @param narrative
	 * @return
	 */
	private String extractErrorMessage(String narrative) {
		StringBuilder sb = new StringBuilder();
		sb.append(StringUtils.substringBefore(narrative, "An Error occured"))
		// Capture data error (?)
		if (narrative.contains(" value: "))
			sb.append(StringUtils.substringBetween(narrative, ", value: ", ", object:"))
		// Capture unknown error
		else
			sb.append(StringUtils.substringBetween(narrative, "Error Details are :-", "Stack Trace"))

		return sb.toString()
	}
}