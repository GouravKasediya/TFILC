package com.misys.tiplus2.ticc.groovy.router

import com.misys.tools.integration.api.component.GProcessor
import com.misys.tools.integration.api.message.GMessage
import com.misys.tools.integration.api.message.GResult

import groovy.util.logging.Slf4j
import groovy.util.XmlSlurper
import groovy.util.slurpersupport.GPathResult;

import groovy.xml.XmlUtil

import javax.annotation.Nonnull
/**
 * Prepares the FTI standby to undertaking conversion message
 * by grouping related Master records within TransactionDetails block based on customer reference and product
 *
 * @author sanavaro
 *
 */
@Slf4j
class FTIStandbyToUndertakingConversion implements GProcessor {

    @Nonnull
    @Override
    List<GResult> consumeProduce(@Nonnull GMessage message) {

        return message
            .result()
            .messageBody(processStandbyToUndertakingConversionMessage(message))
            .buildAsList()
    }

    /**
     * @param message   the TFSBYCNV message
     * @return message  the TFSBYCNV message containing Master records within TransactionDetails blocks based on customer reference and product
     */
    private String processStandbyToUndertakingConversionMessage(@Nonnull GMessage message) {
        Node messageXML = new XmlParser(false, false).parseText(message.messageBody)
        String zoneID = messageXML.ZoneID.text()
        ArrayList<String> customerReferenceProducts = new ArrayList<String>()

        processMessageAttributes(messageXML, zoneID, customerReferenceProducts)
        reconstructMessageFromAttributes(messageXML, customerReferenceProducts)

        return (String) groovy.xml.XmlUtil.serialize(messageXML)
    }

    /**
     * Adds a customer_reference_product attribute to each Standby to Undertaking Conversion Master record.
     * <p>
     * Stores unique customer_reference_product attribute values in an array list.
     *
     * @param messageXML          the TFSBYCNV message
     * @param zoneID              the ZoneID element value in TFSBYCNV message
     * @param customerReferences  an array list to store unique customer references and products
     */
    private void processMessageAttributes(Node messageXML, String zoneID, ArrayList<String> customerReferenceProducts) {
        String customerReferenceProduct
        log.info "Updating standby to undertaking conversion \"Master\" records with customer reference and product attribute"

        messageXML.Master.each {
            customerReferenceProduct = it.@customer_mnemonic.toString()
                                .concat(".")
                                .concat(zoneID)
                                .concat(".")
                                .concat(it.@main_banking_entity.toString())
                                .concat(".")
                                .concat(it.@behalf_of_branch.toString())
                                .concat("-")
                                .concat(it.@product.toString())

            it.@customer_reference_product = customerReferenceProduct

            if (customerReferenceProducts.size > 0) {
                if(!customerReferenceProducts.contains(customerReferenceProduct)) {
                    customerReferenceProducts.add(customerReferenceProduct)
                }
            } else {
                customerReferenceProducts.add(customerReferenceProduct)
            }
        }

    }

    /**
     * Reconstructs the Standby to Undertaking Conversion message based on customer_reference_product attribute
     *
     * @param messageXML                 the TFSBYCNV message containing Master records with customer_reference_product attribute
     * @param customerReferenceProducts  the array list with unique customer references
     */
    private void reconstructMessageFromAttributes(Node messageXML, ArrayList<String> customerReferenceProducts) {
        log.info "Reconstructing standby to undertaking conversion message based on customer reference and product attribute"

        String currentCustomerReferenceProduct
        Node currentTransactionDetailsNode

        customerReferenceProducts.each {
            currentCustomerReferenceProduct = it

            currentTransactionDetailsNode = new NodeBuilder().TransactionDetails(customer_reference_product: it) {}
            messageXML.children().add(0, currentTransactionDetailsNode)

            log.info "Processing standby to undertaking conversion message for customer reference and product: $currentCustomerReferenceProduct"

            messageXML.Master.each {
                if (it.@customer_reference_product == currentCustomerReferenceProduct) {
                    log.debug "Moving the \"Master\" record with reference: " + it.@reference.toString() +
                              " within TransactionDetails customer_reference_product: $currentCustomerReferenceProduct"

                    messageXML.TransactionDetails[0].children().add(0, it)
                    def parent = it.parent()
                    parent.remove(it)
                }
            }
        }
    }
}