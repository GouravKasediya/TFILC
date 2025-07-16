package com.misys.tiplus2.ticc.groovy.router


import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult

import groovy.util.logging.Slf4j

import javax.annotation.Nonnull
import javax.annotation.Nullable

@Slf4j
class ErrorHandler implements GProcessor {

	// Assumed end of every exception with a detail message
	private static final String END_OF_EXCEPTION_TYPE = "Exception - "

	@Nonnull
	@Override
	List<GResult> consumeProduce(@Nonnull GMessage message) {

		log.info "An unexpected error has occurred while processing the message. "   +
				"The XML message will be placed to the dead letter queue. Details " +
				"about the error can be seen on the property 'errorCause'"

		return message
				.result()
				.failed()
				.messageBody(message.getErrorCause().getMessageBodyAsText())
				.property("errorCause", extractErrorFromStackTrace(message.getMessageBodyAsText()))
				.buildAsList()

	}

	/**
	 * Returns the details message of an Exception <br/>
	 * If there is no such message, the whole first line is returned
	 * 
	 * @param stackTrace
	 * @return
	 */
	private String extractErrorFromStackTrace(String stackTrace) {
		// Retrieves start of the detail message given the assumed END_OF_EXCEPTION_TYPE
		// else the whole first line which contains the type of Exception
		int startIndex = stackTrace.contains(END_OF_EXCEPTION_TYPE) ? stackTrace.indexOf(END_OF_EXCEPTION_TYPE) + END_OF_EXCEPTION_TYPE.length() - 1 : 0

		return 	stackTrace.substring(
					startIndex,
					stackTrace.indexOf(System.lineSeparator()) // assumes that the stack trace is a multi-line string
				).trim()
	}
}