Requirement: Whenever Order Status becomes Approved Send Order AND All Order Items to ERP.

/*
 * Trigger: OrderTrigger
 *
 * Purpose:
 *  - Detect when an Order status changes to 'Approved'
 *  - Enqueue a Queueable job to send the Order to an external ERP system
 *
 * Why Queueable?
 *  - Callouts cannot be made directly from triggers.
 *  - Queueable runs asynchronously and supports HTTP callouts.
 */

trigger OrderTrigger on Order (after update) {

    // Using Set to avoid duplicate Order Ids
    Set<Id> ids = new Set<Id>();

    for(Order o : Trigger.new){

        // Process only when Status changes to Approved
        if(o.Status == 'Approved'
           && Trigger.oldMap.get(o.Id).Status != 'Approved'){

            ids.add(o.Id);

        }
    }

    // Enqueue only if there are records to process
    if(!ids.isEmpty()){

        System.enqueueJob(new ERPQueueable(ids));

    }

}

/*
 * Class: ERPQueueable
 *
 * Purpose:
 *  - Sends approved Orders to an external ERP system.
 *
 * Implements:
 *  - Queueable
 *      Executes asynchronously.
 *
 *  - Database.AllowsCallouts
 *      Required to perform HTTP callouts.
 */

public class ERPQueueable implements Queueable, Database.AllowsCallouts{

    /*
     * Stores Order Ids received from the trigger.
     * This is an instance variable so the data is available
     * later when execute() runs.
     */
    private Set<Id> orderIds;

    /*
     * Constructor
     *
     * Automatically executed when
     * new ERPQueueable(ids)
     * is called.
     *
     * Used to store data inside the Queueable object.
     */
    public ERPQueueable(Set<Id> ids){

        this.orderIds = ids;

    }

    /*
     * execute() is automatically called by Salesforce
     * after the job reaches the queue.
     */
    public void execute(QueueableContext qc){

        /*
         * Query latest Order data instead of passing
         * complete Order records from the trigger.
         *
         * This avoids stale data and reduces serialization.
         */
        List<Order> orders = [

            SELECT Id,
                   OrderNumber,
                   EffectiveDate,
                   (SELECT Quantity,
                           UnitPrice
                    FROM OrderItems)

            FROM Order

            WHERE Id IN :orderIds

        ];

        HttpRequest req = new HttpRequest();

        // Named Credential endpoint
        req.setEndpoint('callout:ERP/orders');

        // HTTP Method
        req.setMethod('POST');

        // JSON Request
        req.setHeader('Content-Type','application/json');

        // Convert Apex objects into JSON
        req.setBody(JSON.serialize(orders));

        Http http = new Http();

        HttpResponse res = http.send(req);

        if(res.getStatusCode() == 200){

            System.debug('Order sent successfully');

            System.debug(res.getBody());

        }
        else{

            System.debug(res.getStatusCode());

            System.debug(res.getStatus());

            System.debug(res.getBody());

        }

    }

}

/*
===============================================================================
                                NOTES
===============================================================================

1. Why Queueable Apex?
   - Queueable Apex executes asynchronously.
   - It is commonly used for:
       • HTTP Callouts
       • Long-running operations
       • Processing large datasets
       • Integrations with external systems

2. Why use a Constructor?
   - The constructor stores data (Order Ids) inside the Queueable object.
   - Trigger variables exist only during trigger execution.
   - execute() runs later in a different transaction, so we must persist the data
     inside the Queueable object.

3. Why pass only Record IDs?
   - Reduces memory usage.
   - Prevents stale data.
   - Allows execute() to query the latest committed records.

4. Why query inside execute()?
   - The Queueable may run seconds later.
   - Querying inside execute() ensures the latest database values are used.

5. Why Database.AllowsCallouts?
   - Required whenever a Queueable makes HTTP or web service callouts.
   - Without it, Salesforce throws a Callout Exception.

6. Why use a Named Credential?
   - Avoids hardcoding URLs.
   - Securely stores authentication.
   - Easier to change endpoints across environments.

7. Queueable Governor Limits
   - Maximum 50 Queueable jobs can be enqueued in a single transaction.
   - A running Queueable can enqueue only ONE child Queueable (Queueable Chaining).

8. Trigger Considerations
   - Trigger.oldMap is available only in Update and Delete triggers.
   - Trigger.oldMap is NOT available in Insert triggers.

9. Production Best Practices
   - Wrap callouts in try-catch.
   - Log failures instead of using System.debug().
   - Handle different success codes (200, 201, 202).
   - Use Custom Metadata or Named Credentials for configuration.
   - Bulkify the trigger (never enqueue one Queueable per record).

10. Interview Points
    - Queueable is preferred over Future Methods because it supports:
        • Complex Objects
        • Job Monitoring
        • Chaining
        • Better Scalability
        • Callouts

===============================================================================
*/
