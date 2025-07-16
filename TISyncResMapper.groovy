package com.misys.tiplus2.ticc.groovy.router

import java.io.File;

import com.misys.tools.integration.api.annotation.InjectResource
import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult
import com.misys.tools.integration.impl.api.component.resource.cache.GSimpleCacheResourceImpl

import javax.annotation.Nonnull

import groovy.lang.GroovyObject;

import groovy.util.logging.Slf4j
import groovy.util.slurpersupport.GPathResult

import groovy.xml.StreamingMarkupBuilder

@Slf4j
class TISyncResMapper implements GProcessor {

	private final static String CACHE_HANDLER = "groovy/com/misys/tiplus2/ticc/groovy/router/CacheHandler.groovy"

	@InjectResource(required = true)
	GSimpleCacheResourceImpl messageCache

	File cacheHandlerFile = new File(CACHE_HANDLER)
	Class groovyClass = new GroovyClassLoader(getClass().getClassLoader()).parseClass(cacheHandlerFile)
	GroovyObject cacheHandler = (GroovyObject) groovyClass.newInstance()

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		GPathResult fccMsg = new XmlSlurper().parseText(message.messageBody)

		String responseCorrelationId = fccMsg.ResponseHeader.CorrelationId.toString()

		return message
				.result()
				.messageBody(createResponseMessage(fccMsg, responseCorrelationId))
				.property("resCorrelationId", responseCorrelationId)
				.buildAsList()
	}


	/**
	 * Constructs the response retrieved from the cache which is inserted during FCC to FTI flow  
	 * 
	 * @param fccXML
	 * @param responseCorrelationId
	 * @return
	 */
	private def createResponseMessage(GPathResult fccXML, String responseCorrelationId) {
		GPathResult cachedRequestXML =  new XmlSlurper().parseText(
				cacheHandler.GetFromCache(messageCache, responseCorrelationId)
				)

		String responseOperation = fccXML."ResponseHeader"."Operation".toString()

		String ccMessage = cachedRequestXML.name()
		def ccXML = ""
		def builder = new groovy.xml.StreamingMarkupBuilder()
		builder.encoding = "UTF-8"

		if (! isStaticData(cachedRequestXML)) {
			String referenceId = cachedRequestXML."ref_id".text()
			String transactionId = cachedRequestXML."tnx_id".text()
			String boRefId = cachedRequestXML."bo_ref_id".text()
			String boTnxId = cachedRequestXML."bo_tnx_id".text()

			boolean isAcknowledgement = fccXML."ResponseHeader"."Status".toString().equalsIgnoreCase("SUCCEEDED") ? true : false

			String narrativeMessageStatus = extractNarrativeFromDetails(fccXML).toString()
			String stat = isAcknowledgement ? "ACK" : "NACK"

			ccXML = {
				mkp.xmlDeclaration()
				transaction_acknowledgement() {
					ref_id( referenceId )
					tnx_id( transactionId )
					status ( stat )
					bo_ref_id( boRefId )
					bo_tnx_id( boTnxId )
					narrative_message_status( narrativeMessageStatus )
				}
			}

			log.info "Response Message Correlation Id :: ${responseCorrelationId}"
		}

		if (responseOperation == "SCFBuyerOrSeller"){
			String customerReference = cachedRequestXML."program_counterparty"."customer_reference".text()
			String programCode = cachedRequestXML."program_counterparty"."program_code".text()
			String cptyAbbvName = cachedRequestXML."static_beneficiary"."abbv_name".text()
			String operationType = cachedRequestXML."operation_type".text()
			String cptyAsscnStatus = operationType == "02" ? "I" : ""
			log.debug "Cpty Assn Stat :: ${cptyAsscnStatus}"

			ccXML = {
				mkp.xmlDeclaration()
				"${ccMessage}"(){
					program_counterparty {
						program_code(programCode)
						customer_reference(customerReference)
						prog_cpty_assn_status(cptyAsscnStatus)
						bo_status("03")
					}
					static_beneficiary { abbv_name("$cptyAbbvName") }
					operation_type(operationType)
				}
			}
		}

		cacheHandler.DeleteFromCache(messageCache, responseCorrelationId)
		return builder.bind(ccXML).toString()
	}

	/**
	 * Checks if tnx_type_code doesn't exist or blank in the message. CC outgoing static messages do not have these code 
	 * 
	 * @param cachedReceivedMsg
	 * @return
	 */
	private boolean isStaticData(GPathResult cachedReceivedMsg) {
		if (cachedReceivedMsg."tnx_type_code" == '' || cachedReceivedMsg."tnx_type_code" == null) {
			return true
		}
		return false
	}

	/**
	 * 
	 * Extracts Error or Warning from ServiceResponse.<br />
	 * Sample of tags' structure as follows:
	 * <pre>
	 * {@code
	 * ...
	 * <Details>
	 *    <Error>...</Error>
	 *    <Warning>...</Warning>
	 * </Details>
	 * ...
	 * }
	 * </pre>
	 * @param resMsg the response XML
	 * @return all strings within Error and Warning tags
	 */
	private String extractNarrativeFromDetails(def resMsg) {
		def boComment = resMsg.'**'.findAll { node ->
			node.name() in ['Error', 'Warning']
		}*.text()
		StringBuilder sbBoComment = new StringBuilder()
		String delim = ""
		for (String i: boComment) {
			sbBoComment.append(delim).append(i)
			delim = "\n"
		}

		return sbBoComment.toString()
	}
}