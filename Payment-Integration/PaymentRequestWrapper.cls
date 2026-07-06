public class PaymentRequestWrapper {

    /*
     * Wrapper Class
     * -------------
     * This class is used to generate the JSON request body
     * that will be sent to the external Payment API.
     *
     * JSON Structure:
     *
     * {
     *     "customer": {
     *         "name": "Rahul",
     *         "email": "rahul@gmail.com"
     *     },
     *     "payment": {
     *         "amount": 2500,
     *         "currencyy": "INR"
     *     }
     * }
     */

    // Represents the top-level "customer" object.
    public Customer customer;

    // Represents the top-level "payment" object.
    public Payment payment;

    /*
     * Inner class representing:
     *
     * "customer": {
     *      "name": "...",
     *      "email": "..."
     * }
     */
    public class Customer {
        public String name;
        public String email;
    }

    /*
     * Inner class representing:
     *
     * "payment": {
     *      "amount": 2500,
     *      "currencyy": "INR"
     * }
     */
    public class Payment {
        public Integer amount;
        public String currencyy;
    }

    /*
     * ---------------------------------------------------------
     * Example Usage
     * ---------------------------------------------------------
     *
     * PaymentRequestWrapper request = new PaymentRequestWrapper();
     *
     * request.customer = new PaymentRequestWrapper.Customer();
     * request.customer.name = 'Rahul';
     * request.customer.email = 'rahul@gmail.com';
     *
     * request.payment = new PaymentRequestWrapper.Payment();
     * request.payment.amount = 2500;
     * request.payment.currencyy = 'INR';
     *
     * String jsonBody = JSON.serializePretty(request);
     */

    /*
     * Serialized JSON Output
     * ---------------------------------------------------------
     *
     * {
     *     "customer": {
     *         "name": "Rahul",
     *         "email": "rahul@gmail.com"
     *     },
     *     "payment": {
     *         "amount": 2500,
     *         "currencyy": "INR"
     *     }
     * }
     */
}
