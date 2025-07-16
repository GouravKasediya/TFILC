package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.api.annotation.InjectProperty
import com.misys.tools.integration.api.callback.GRouteCallback
import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult
import com.misys.tools.integration.api.message.GStatus
import com.misys.tools.integration.config.StringProperties
import com.misys.tools.integration.director.*
import com.misys.tiplus2.ticc.MappingParameters

import org.apache.commons.lang.StringUtils

import groovy.util.logging.Slf4j

import java.util.ArrayList
import java.util.List
import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.IOException

import javax.annotation.Nonnull
import javax.annotation.Nullable


@Slf4j
class EmailNotification implements GProcessor, GRouteCallback  {

	@InjectProperty(required = true)
	String instanceId

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		StringBuilder messageContentFromPropertyFile =  new StringBuilder()
		BufferedReader emailNotifPropertyFileReader = new BufferedReader(new FileReader("email-notification.properties"))

		// Read email notification contents from the email-notification.properties file
		try {
			String line = emailNotifPropertyFileReader.readLine()
			while (line != null) {
				messageContentFromPropertyFile.append(line)
				messageContentFromPropertyFile.append("\n")
				line = emailNotifPropertyFileReader.readLine()
			}

			log.info "Email notification message from email-notification.properties file are loaded successfully!"

			return message
					.result()
					.successful()
					.messageBody(buildEmailNotificationMessage(message, messageContentFromPropertyFile.toString()))
					.buildAsList()
		}
		catch(IOException e){
			log.error "Error reading email-notification.properties file : ${e}"
			return message
					.result()
					.failed()
					.property("errorCause", ${e})
					.buildAsList()
		} finally {
			emailNotifPropertyFileReader.close()
		}
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

	private String buildEmailNotificationMessage(@Nonnull GMessage message, String messageContentFromPropertyFile) {

		String transFlow = message.getProperty("transFlow")
		String product = message.getProperty("product")
		String messageName = message.getProperty("messageName")
		String transRef = message.getProperty("transRef")
		String errorCause = message.getProperty("errorCause")
		String routedError = message.getProperty("routedError")
		String zoneID = message.getProperty("ZoneID")
		String messageDescriptor = ""
		String fccVersion = ""
		String ftiVersion = ""
		String emailNotification = "Sent from TICC instance ID: ${instanceId}\n\n" + messageContentFromPropertyFile.substring(messageContentFromPropertyFile.indexOf("<start>\n"))
		ArrayList<String> failedPlaceHolders = new ArrayList<String>()
		String failedPlaceHoldersMessage = "PS: The following place-holders had failures on retrieving their values hence their original place-holder names were displayed on the notification above.\n"

		if (MappingParameters != null) {
			try {
				fccVersion = MappingParameters.getFCCVersion()
				ftiVersion = MappingParameters.getFTIVersion()
			}
			catch(Exception e){
				log.error "Failed to fetch FCC version and FTI version data due to: ${e}"
			}
		}
		// email notification keywords that will be replaced  by message properties

		if (emailNotification.contains("<transactionFlow>")){
			if (transFlow != null) {
				emailNotification = emailNotification.replace("<transactionFlow>", transFlow)
			} else {
				failedPlaceHolders.add("<transactionFlow>")
			}
		}

		if (emailNotification.contains("<messageDescriptor>")){
			messageDescriptor = getMessageDescriptor(transFlow, product, messageName)
			if (messageDescriptor != "") {
				emailNotification = emailNotification.replace("<messageDescriptor>", messageDescriptor)
			} else {
				failedPlaceHolders.add("<messageDescriptor>")
			}
		}

		if (emailNotification.contains("<transactionReference>")){
			if (transRef != null && transRef != "" ) {
				emailNotification = emailNotification.replace("<transactionReference>", transRef)
			} else {
				failedPlaceHolders.add("<transactionReference>")
			}
		}

		if (emailNotification.contains("<errorCause>")){
			if(errorCause != null){
				emailNotification = emailNotification.replace("<errorCause>", errorCause)
			} else if (routedError != null){
				emailNotification = emailNotification.replace("<errorCause>", routedError)
			} else {
				failedPlaceHolders.add("<errorCause>")
			}
		}

		if (emailNotification.contains("<messageID>")){
			emailNotification = emailNotification.replace("<messageID>", message.getMessageId())
		}

		if (emailNotification.contains("<ZoneID>")){
			if(zoneID != null) {
				emailNotification = emailNotification.replace("<ZoneID>", zoneID)
			} else {
				failedPlaceHolders.add("<ZoneID>")
			}
		}

		if (emailNotification.contains("<fccVersion>")){
			if (fccVersion != null && !fccVersion.isEmpty()) {
				emailNotification = emailNotification.replace("<fccVersion>", fccVersion)
			} else {
				failedPlaceHolders.add("<fccVersion>")
			}
		}

		if (emailNotification.contains("<ftiVersion>")){
			if (ftiVersion != null && !ftiVersion.isEmpty()) {
				emailNotification = emailNotification.replace("<ftiVersion>", ftiVersion)
			} else {
				failedPlaceHolders.add("<ftiVersion>")
			}
		}

		emailNotification = emailNotification.replace("<start>\n", "").replace("<end>", "")

		if (!failedPlaceHolders.isEmpty()) {
			for (String placeHolder : failedPlaceHolders) {
				failedPlaceHoldersMessage += placeHolder + '\n'
			}

			emailNotification += '\n' + failedPlaceHoldersMessage
		}

		return emailNotification
	}

	/**
	 * Gets the message descriptor based on the message flow.
	 * 
	 * @param transFlow
	 * @param product
	 * @param messageName
	 * @return
	 */
	private String getMessageDescriptor(String transFlow, String product, String messageName) {
		if (transFlow.equals('[FCC-FTI]')) {
			return  (product != null)? product : ""
		} else {
			return (messageName != null)? messageName : ""
		}
	}

}