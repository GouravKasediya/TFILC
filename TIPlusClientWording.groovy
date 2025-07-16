package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult

import groovy.util.logging.Slf4j
import groovy.util.XmlSlurper
import groovy.util.slurpersupport.GPathResult;

import groovy.xml.XmlUtil

import javax.annotation.Nonnull

@Slf4j
class TIPlusClientWording implements GProcessor {
	
	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		return message
			.result()
			.messageBody(processClientWordingMessage(message))
			.buildAsList()
	}
	
	/**
	 * Updates the message's message name to identify it for Client Wording flow 
	 * 
	 * @param message
	 * @return
	 */
	private String processClientWordingMessage(@Nonnull GMessage message) {
		GPathResult msgXml = new XmlSlurper(false, false).parseText(message.messageBody)
		
		msgXml.MessageName = getFCCMessageName(msgXml.MessageName.toString())
		
		log.info "Client Wording processing for message Message Name: ${msgXml.MessageName}, Transaction Reference: ${msgXml.MasterRef}"
		
		return (String) groovy.xml.XmlUtil.serialize(msgXml)
	}
	
	/**
	 * Returns Client Wording message name based on the original message name
	 * 
	 * @param messageName
	 * @return
	 */
	private String getFCCMessageName(String messageName) {
		switch (messageName) {
			case ["TFILCACK", "TFILCCRT"]:
				return "TFILCACW"
			case ["TFIGTACK", "TFIGTCRT"]:
				return "TFIGTACW"
			case ["TFUTIACK", "TFUTICRT"]:
				return "TFUTIACW"
			case ["TFISBACK", "TFISBCRT"]:
				return "TFISBACW"
			default:
				return messageName
		}
	}
}