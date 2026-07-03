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
