package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult

import groovy.util.XmlSlurper
import groovy.util.slurpersupport.GPathResult
import groovy.util.logging.Slf4j

import javax.annotation.Nonnull
import javax.annotation.Nullable

@Slf4j
class CollectionsAttachmentHandler implements GProcessor {

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {

		GPathResult fccMsg = new XmlSlurper().parseText(message.messageBody)

		return message
				.result()
				.messageBody(processCollectionAttachments(fccMsg))
				.buildAsList()
	}

	/**
	 * Checks for attachments attached to collection documents and appends related 
	 * fields to the source FFC XML message
	 * 
	 * @param fccMsg
	 * @return the modified FFC XML containing the appended attachment data 
	 */
	private static String processCollectionAttachments(GPathResult fccMsg) {

		String id = ""
		String firstMail = ""
		String secondMail = ""
		String total = ""
		String code = ""
		String documentDate = ""
		String documentFaceReference = ""
		boolean hasMatch = false;

		fccMsg.'**'
				.findAll { it.name() == 'attachment' }
				.each {
					id = it.attachment_id.text()
					log.debug "Attachment Id :: ${id}"

					// Find where the attachment is attached to
					fccMsg.'**'
							.findAll { it.name() == 'document' }
							.findAll { it.mapped_attachment_id.text().contains(id) }
							.each {
								log.debug "Found a document where this attachment ${id} is attached to"
								hasMatch = true
								code = it.code.text()
                                documentDate = it.doc_date.text()
                                documentFaceReference = it.doc_no.text()
								firstMail =  it.first_mail.text()
								secondMail = it.second_mail.text()
								total = it.total.text()
							}
					if (hasMatch) {
						it.appendNode(new XmlSlurper().parseText("<RefDocCode>$code</RefDocCode>"))
                        it.appendNode(new XmlSlurper().parseText("<DocumentDate>$documentDate</DocumentDate>"))
                        it.appendNode(new XmlSlurper().parseText("<DocumentFaceReference>$documentFaceReference</DocumentFaceReference>"))
						it.appendNode(new XmlSlurper().parseText("<FirstMail>$firstMail</FirstMail>"))
						it.appendNode(new XmlSlurper().parseText("<SecondMail>$secondMail</SecondMail>"))
						it.appendNode(new XmlSlurper().parseText("<Total>$total</Total>"))
						hasMatch = false
					}
				}

		return (String) groovy.xml.XmlUtil.serialize( fccMsg )
	}
}
