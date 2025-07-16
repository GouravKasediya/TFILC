package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult

import groovy.util.logging.Slf4j
import groovy.util.XmlSlurper
import groovy.util.slurpersupport.GPathResult

import javax.annotation.Nonnull


@Slf4j
class TISyncReqMapper implements GProcessor {
	private final String SERVICE = "TISync"
	private final String REPLY_FORMAT = "STATUS"

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		return message
				.result()
				.messageBody(updateMessageForRequest(message))
				.buildAsList()
	}

	/**
	 * Updates a TI incoming XML to trigger the application's response
	 * feature.
	 * 
	 * @param message the incoming message to be updated
	 * @return the updated message
	 */
	private String updateMessageForRequest(@Nonnull GMessage message) {
		GPathResult xml = new XmlSlurper(false, false).parseText(message.messageBody)

		xml.RequestHeader.Service = SERVICE
		xml.RequestHeader.ReplyFormat = REPLY_FORMAT
		xml.RequestHeader.CorrelationId = message.getMessageId()

		log.info "Updated RequestHeader for TI Response"

		return (String) groovy.xml.XmlUtil.serialize(xml)
	}
}