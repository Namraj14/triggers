public class PaymentResponseWrapper {

    /*
     * ========================================================================
     * PaymentResponseWrapper
     * ========================================================================
     * Purpose:
     * This wrapper class is used to deserialize the JSON response
     * received from an external Payment API.
     *
     * Instead of manually parsing the JSON string, Salesforce converts
     * the JSON directly into this Apex object using:
     *
     * JSON.deserialize(responseBody, PaymentResponseWrapper.class);
     *
     * ========================================================================
     * Expected JSON Response
     * ========================================================================
     *
     * {
     *     "transactionId": "TXN123456789",
     *     "status": "Success"
     * }
     *
     * Every JSON Key -> Apex Variable
     * The variable names must exactly match the JSON keys.
     * ========================================================================
     */


    //--------------------------------------------------------------------------
    // Maps to the JSON key:
    //
    // "transactionId": "TXN123456789"
    //--------------------------------------------------------------------------
    public String transactionId;


    //--------------------------------------------------------------------------
    // Maps to the JSON key:
    //
    // "status": "Success"
    //--------------------------------------------------------------------------
    public String status;



    /*
     * ========================================================================
     * Example Usage
     * ========================================================================
     *
     * HttpResponse res = http.send(request);
     *
     * PaymentResponseWrapper response =
     *     (PaymentResponseWrapper)
     *     JSON.deserialize(
     *         res.getBody(),
     *         PaymentResponseWrapper.class
     *     );
     *
     * System.debug(response.transactionId);
     * System.debug(response.status);
     *
     * ========================================================================
     */



    /*
     * ========================================================================
     * Example JSON Response
     * ========================================================================
     *
     * {
     *     "transactionId": "TXN123456789",
     *     "status": "Success"
     * }
     *
     * ========================================================================
     * After Deserialization
     * ========================================================================
     *
     * response.transactionId
     *      = "TXN123456789"
     *
     * response.status
     *      = "Success"
     *
     * ========================================================================
     * Important Notes
     * ========================================================================
     *
     * 1. Response wrappers are used to convert JSON into Apex objects.
     *
     * 2. The JSON keys must match the Apex variable names.
     *
     * 3. No 'new' keyword is required when using
     *    JSON.deserialize().
     *
     *    Salesforce automatically creates the object and populates
     *    its fields from the JSON response.
     *
     * 4. Response wrappers are commonly used for
     *      • REST API Responses
     *      • Third-party Integrations
     *      • HTTP Callouts
     *      • Complex JSON Parsing
     *
     * ========================================================================
     */

}
