Trigger: When a Case is escalated, Salesforce must send the Case details to an external ticketing system. 
The callout can take several seconds and should not impact user experience.

trigger CaseTrigger on Case (after update) {
    
    Set<Id> caseIds = new Set<Id>();
    
    for(Case cs : Trigger.new){
        if(cs.Status == 'Escalated' && Trigger.oldMap.get(cs.Id).Status != 'Escalated'){
            caseIds.add(cs.Id);
        }
    }
    if(!caseIds.isEmpty()){
        System.enqueueJob(new CaseQueueable(caseIds));
    }
    	
    }

Class:

public class CaseQueueable implements Queueable, Database.AllowsCallouts{

    private Set<Id> caseIds;

    public CaseQueueable(Set<Id> ids){
        this.caseIds = ids;
    }

    public void execute(QueueableContext qc){

        List<Case> casesToSend = [
            SELECT Id,
                   CaseNumber,
                   Subject,
                   Description
            FROM Case
            WHERE Id IN :caseIds
        ];

        // Create Wrapper
        CaseRequestWrapper wrapper = new CaseRequestWrapper();
        wrapper.cases = casesToSend;

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:CaseAPI/caseEscalation');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody(JSON.serialize(wrapper));

        Http http = new Http();

        try{

            HttpResponse res = http.send(req);

            if(res.getStatusCode() >= 200 &&
               res.getStatusCode() < 300){

                System.debug('Cases sent successfully.');
            }
            else{

                System.debug('Request Failed');
                System.debug(res.getStatusCode());
                System.debug(res.getBody());
            }

        }
        catch(Exception e){

            System.debug(e.getMessage());

        }

    }

}


Wrapper
public class CaseRequestWrapper{
    public List<Case> cases;
}


1. Why would Queueable Apex be preferred over synchronous Apex?
Answer

Queueable Apex is preferred because it runs asynchronously, allowing long-running operations to execute in the background without making the user wait.

In scenarios like HTTP callouts, large data processing, or integrations, synchronous Apex increases transaction time and can cause users to experience delays or timeout errors.

Using Queueable provides:

Better user experience
Background processing
Support for HTTP callouts (Database.AllowsCallouts)
Separate governor limits from the original transaction
Ability to chain queueable jobs
Interview Answer

"I use Queueable Apex when the operation doesn't need to finish before the user receives a response. For example, if a Case is escalated and needs to be sent to an external system, I enqueue a Queueable job so the user doesn't wait for the API call to complete."

2. Why would Queueable be preferred over Future Methods?
Answer

Queueable Apex is more flexible and powerful than Future Methods.

Future Method	Queueable Apex
Primitive parameters only	Can accept complex objects and collections
Cannot chain jobs	Can chain Queueables
Limited monitoring	Job ID available for monitoring
Less flexible	Better for complex business logic
Supports callouts	Supports callouts
Interview Answer

"Queueable Apex is preferred because it supports complex data types like Lists, Sets, Maps, and wrapper classes, whereas Future Methods only accept primitive data types or collections of primitives. Queueable jobs can also be chained and monitored using the returned Job ID, making them more suitable for enterprise integrations."

3. How would you pass Case data to Queueable?

There are two common approaches.

Approach 1 (Recommended) — Pass Record IDs

Trigger

Set<Id> caseIds = new Set<Id>();

for(Case c : Trigger.new){
    caseIds.add(c.Id);
}

System.enqueueJob(new CaseQueueable(caseIds));

Queueable

public class CaseQueueable implements Queueable{

    private Set<Id> caseIds;

    public CaseQueueable(Set<Id> ids){
        this.caseIds = ids;
    }

    public void execute(QueueableContext qc){

        List<Case> cases = [
            SELECT Id, Subject
            FROM Case
            WHERE Id IN :caseIds
        ];

    }
}
Why is this preferred?
Fresh data is retrieved from the database.
Smaller data is passed between transactions.
Prevents stale data.
Follows Salesforce best practices.
Approach 2 — Pass the Case records directly
List<Case> casesToProcess = Trigger.new;

System.enqueueJob(new CaseQueueable(casesToProcess));

Queueable

public class CaseQueueable implements Queueable{

    private List<Case> cases;

    public CaseQueueable(List<Case> cases){
        this.cases = cases;
    }

    public void execute(QueueableContext qc){

    }

}

This works because Queueable can serialize complex objects.

However, it is generally not recommended because the data may become stale if the records are updated before the Queueable executes.

Interview Answer

"The recommended approach is to pass only the Case IDs to the Queueable and query the latest records inside the execute() method. This ensures that the Queueable works with the most recent committed data."

4. How would you log failures?

There are several ways.

Option 1 — Debug Logs
try{

    HttpResponse res = http.send(req);

}
catch(Exception e){

    System.debug(e.getMessage());

}

Useful only during development.

Option 2 — Custom Log Object ⭐ (Most Common)

Create a custom object

Integration_Log__c

Fields

Request__c
Response__c
Status_Code__c
Error_Message__c
Endpoint__c
Timestamp__c

Example

Integration_Log__c log = new Integration_Log__c();

log.Status_Code__c = res.getStatusCode();
log.Response__c = res.getBody();
log.Error_Message__c = e.getMessage();

insert log;
Option 3 — Platform Events

Publish an event whenever an integration fails.

Another process can notify admins or retry the integration.

Useful for enterprise applications.

Option 4 — Custom Exception Email

Send an email to administrators when an integration fails.

Option 5 — Retry Mechanism

Store failed records and retry them later using:

Scheduled Apex
Batch Apex
Another Queueable
Interview Answer

"In production, I wouldn't rely on debug logs because they aren't permanent. I'd log failures in a custom Integration Log object containing details such as the endpoint, request payload, response payload, status code, and exception message. This provides a complete audit trail for troubleshooting. Depending on the business requirement, I could also implement retries or notify administrators using Platform Events or email."

⭐ Senior-Level Interview Tip

If an interviewer asks:

"What would you pass to a Queueable: IDs or Case records?"

A strong answer is:

"Although Queueable supports complex objects like List<Case>, I generally pass only the record IDs. This keeps the serialized payload small and ensures the Queueable queries the most recent committed data when it executes. I only pass full objects if the data represents a snapshot that must not change before processing."
