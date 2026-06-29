Scenario

User clicks "Fetch Credit Score" button

↓

Salesforce calls external Credit Score API (GET)

↓

API returns the customer's credit score

↓

Update Account.Credit_Score__c

public with sharing class CreditScoreService {

    // Method receives Account Id from LWC/Aura/Visualforce
    public static void getCreditScore(Id accountId){

        // Query the Account.
        // Only Id and Name are required.
        Account acc = [
            SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
        ];

        // Create HTTP Request
        HttpRequest req = new HttpRequest();

        // Named Credential endpoint.
        // Append Account Name as URL parameter/path variable.
        req.setEndpoint('callout:DummyAPI/creditscore/' + acc.Name);

        // GET is used to retrieve data.
        req.setMethod('GET');

        // Create Http object
        Http http = new Http();

        // Send request
        HttpResponse res = http.send(req);

        // Continue only if request succeeded
        if(res.getStatusCode() == 200){

            // Convert JSON response into Apex Map
            Map<String,Object> response =
                (Map<String,Object>)JSON.deserializeUntyped(res.getBody());

            // Extract score from JSON
            acc.Credit_Score__c =
                Integer.valueOf(response.get('score'));

            // Save updated credit score
            update acc;
        }
    }
}
