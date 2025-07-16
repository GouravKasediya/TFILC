package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.messaging.MchMessage
import com.misys.tools.integration.messaging.MchTextMessage
import com.misys.tools.integration.messaging.MessageFactory

/* Converts incoming GMessage with the email contents into MchTextMessage.
   The current CamelDestination component of FFC only accepts MchTextMessage
   hence this class is needed.
*/

MchMessage msg = data

MchMessage email_msg = new MessageFactory().createMessage(MchTextMessage)
email_msg.setMessage(msg.getMessageAsText())

return email_msg