public class ERPQueueable implements Queueable, Database.AllowsCallouts {

    // Stores the Order record Ids received from the Trigger
    private Set<Id> orderIds;

    /**
     * Constructor
     * Receives the Order Ids from the Trigger and stores them
     * so they can be used inside the execute() method.
     */
    public ERPQueueable(Set<Id> ids) {
        this.orderIds = ids;
    }

    /**
     * Executes asynchronously after being placed in the Queue.
     */
    public void execute(QueueableContext qc) {

        // Query the required Order records.
        // Id is required because the records will be updated later.
        List<Order> orders = [
            SELECT Id,
                   Account.Name,
                   Account.Email__c,
                   TotalAmount
            FROM Order
            WHERE Id IN :orderIds
        ];

        // Create one Http object and reuse it for every callout.
        Http http = new Http();

        // Process each Order individually.
        for (Order ord : orders) {

            /*
             * -------------------------------
             * Build Request JSON
             * -------------------------------
             */

            // Create the outer wrapper object.
            PaymentRequestWrapper requestWrapper =
                new PaymentRequestWrapper();

            // Create the nested Customer object.
            requestWrapper.customer =
                new PaymentRequestWrapper.Customer();

            // Populate customer details.
            requestWrapper.customer.name =
                ord.Account.Name;

            requestWrapper.customer.email =
                ord.Account.Email__c;

            // Create the nested Payment object.
            requestWrapper.payment =
                new PaymentRequestWrapper.Payment();

            // Populate payment details.
            requestWrapper.payment.amount =
                Integer.valueOf(ord.TotalAmount);

            requestWrapper.payment.currency =
                'INR';

            /*
             * -------------------------------
             * Configure HTTP Request
             * -------------------------------
             */

            HttpRequest req = new HttpRequest();

            // Named Credential endpoint.
            req.setEndpoint('callout:PaymentGateway/payment');

            req.setMethod('POST');

            req.setHeader(
                'Content-Type',
                'application/json'
            );

            // Convert wrapper object into JSON.
            req.setBody(
                JSON.serialize(requestWrapper)
            );

            /*
             * -------------------------------
             * Send Callout
             * -------------------------------
             */

            HttpResponse res = http.send(req);

            /*
             * -------------------------------
             * Handle Response
             * -------------------------------
             */

            if (res.getStatusCode() == 200) {

                // Convert JSON response into Apex object.
                PaymentResponseWrapper responseWrapper =
                    (PaymentResponseWrapper)
                    JSON.deserialize(
                        res.getBody(),
                        PaymentResponseWrapper.class
                    );

                // Update Order fields using values returned by the API.
                ord.Transaction_Id__c =
                    responseWrapper.transactionId;

                ord.Payment_Status__c =
                    responseWrapper.status;

                System.debug('Order sent successfully.');
                System.debug('Response: ' + res.getBody());

            } else {

                // Log API failure details.
                System.debug('Status Code: ' + res.getStatusCode());
                System.debug('Status: ' + res.getStatus());
                System.debug('Error Response: ' + res.getBody());

            }
        }

        /*
         * Update all Orders in a single DML statement.
         * This follows Apex bulkification best practices.
         */
        update orders;
    }
}
