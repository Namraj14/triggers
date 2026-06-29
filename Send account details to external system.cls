Scenario: Whenever a new Account is created, if the Account Type is "Customer", send the Account details to an external CRM using a POST REST API call.

trigger AccountTrigger on Account (after insert) {

    // Store Account Ids that need to be sent to the external system
    List<Id> accountIds = new List<Id>();

    // Loop through newly inserted Accounts
    for(Account acc : Trigger.new){

        // Only Customer Accounts should be integrated
        if(acc.Type == 'Customer'){
            accountIds.add(acc.Id);
        }
    }

    // Trigger should execute only after records are committed
    // because Callouts cannot be made directly from triggers.
    if(Trigger.isAfter){
        if(Trigger.isInsert){

            // Call Future Method for asynchronous callout
            AccountHandler.sendAccount(accountIds);
        }
    }
}



public class AccountHandler {

    // Future Method executes asynchronously.
    // callout=true allows HTTP callouts from this method.
    @future(callout=true)
    public static void sendAccount(List<Id> accountIds){

        // Query complete Account details because Future methods
        // can only receive primitive data types.
        List<Account> accList = [
            SELECT Id,
                   Name,
                   Phone,
                   Industry
            FROM Account
            WHERE Id IN :accountIds
        ];

        // Loop through every Account
        for(Account acc : accList){

            // Create HTTP Request object
            HttpRequest req = new HttpRequest();

            // Named Credential endpoint
            req.setEndpoint('callout:Dummyapi/accounts');

            // POST request because we're creating records
            req.setMethod('POST');

            // Inform API that request body is JSON
            req.setHeader('Content-Type','application/json');

            // Create request payload
            Map<String,Object> body = new Map<String,Object>();

            body.put('Name',acc.Name);
            body.put('Phone',acc.Phone);
            body.put('Industry',acc.Industry);

            // Convert Map into JSON String
            req.setBody(JSON.serialize(body));

            // Create Http object
            Http http = new Http();

            // Send request
            HttpResponse res = http.send(req);

            // Print response for debugging
            System.debug('Status Code : ' + res.getStatusCode());
            System.debug('Response Body : ' + res.getBody());
        }
    }
}
