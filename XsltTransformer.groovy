package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.api.annotation.InjectProperty
import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult
import com.misys.tools.integration.api.validation.GFailures
import groovy.util.logging.Slf4j
import net.sf.saxon.TransformerFactoryImpl

import javax.annotation.Nonnull
import javax.xml.transform.*
import javax.xml.transform.stream.StreamResult
import javax.xml.transform.stream.StreamSource

/**
 * This GProcessor parses the XML body of the received messages and sets inputType and outputType
 * 
 * The transformation template used is identified by the value of xsltDirName and xsltFileName, supplied in the 
 * properties file where it is used
 **/
@Slf4j
class XsltTransformer implements GProcessor {

	// root directory where the XSLT scripts are kept
	@InjectProperty(required = true)
	String xsltDirName

	// simple expression to determine the the XSLT filename (relative to the xsltDirName) is expected
	// the expression can be a constant value e.g. 'my.xslt' or refer to message properties,
	// e.g. '${XsltName}'.
	@InjectProperty(required = true)
	String xsltFileName

	final Map<String, Templates> xsltCache = [:]

	@Override
	void onInitialize(@Nonnull GFailures failures) {
		File dir = new File(xsltDirName)
		if (!dir.isDirectory()) {
			failures.reportInvalidPropertyValue("xsltDirName", "directory does not exist")
		}
	}

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {
		def xml = message.messageBodyAsText

		String xslt = message.resolve(xsltFileName)

		if (!xslt) {
			log.error "Failed to transform: xsltFileName expression '${xslt}' could not be " +
					"resolved for message ${message.messageId}, " +
					"message properties: ${message.properties}"
			return message
					.result()
					.error()
					.messageBody(
					"failed to transform: xsltFileName expression '${xslt}' could not " +
					"be resolved")
					.buildAsList()
		}

		Templates templates = getTemplates(xslt)

		Transformer transformer = templates.newTransformer()

		Source xmlSource = new StreamSource(new StringReader(xml))

		StringWriter resultWriter = new StringWriter()
		Result result = new StreamResult(resultWriter)
		transformer.transform(xmlSource, result)

		log.info "XML body transformed via '${xslt}'"
		return message
				.result()
				.messageBody(
				resultWriter.toString()
				)
				.buildAsList()
	}

	/**
	 * Caching compiled XSLT as 'templates', greatly improves performance
	 * @param xsltName name of the XSLT file (relative to the xsltDir)
	 * @return compiled XSLT templates
	 * @throws IllegalArgumentException, TransformerConfigurationException
	 */
	Templates getTemplates(String xsltName) {
		Templates templates = xsltCache[xsltName]
		if (!templates) {
			File file = new File(xsltDirName, xsltName)
			if (!file.isFile()) {
				throw new IllegalArgumentException(
				"failed to transform: XSLT file not found ${file}")
			}
			TransformerFactory transFact = new TransformerFactoryImpl()
			Source xsltSource = new StreamSource(file)
			templates = transFact.newTemplates(xsltSource)
			xsltCache[xsltName] = templates
		}
		return templates
	}
}