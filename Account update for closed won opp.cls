Scenario: Update Account to Customer if at least one Opportunity is Closed Won.

trigger OpportunityTrigger on Opportunity (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            OpportunityHandler.closedWonOpp(Trigger.new, Trigger.oldMap);
        }
    }
}

public class OpportunityHandler {

    public static void closedWonOpp(
        List<Opportunity> newList,
        Map<Id, Opportunity> oldMap
    ){

        // Stores Account Ids for Opportunities that changed to Closed Won
        Set<Id> accIds = new Set<Id>();

        // Loop through all updated Opportunities
        for(Opportunity opp : newList){

            // Get the old version of the Opportunity
            Opportunity oldOpp = oldMap.get(opp.Id);

            // Check if Stage changed from anything to Closed Won
            if(oldOpp.StageName != 'Closed Won' &&
               opp.StageName == 'Closed Won' &&
               opp.AccountId != null){

                // Collect related Account Ids
                accIds.add(opp.AccountId);
            }
        }

        // Stores Accounts that need to be updated
        List<Account> accToUpdate = new List<Account>();

        // Single SOQL query (Bulkified)
        for(Account acc : [
            SELECT Id, Account_Status__c
            FROM Account
            WHERE Id IN :accIds
            AND Account_Status__c != null
        ]){

            // Skip update if Account is already a Customer
            if(acc.Account_Status__c != 'Customer'){

                // Update Account Status
                acc.Account_Status__c = 'Customer';

                // Add to update list
                accToUpdate.add(acc);
            }
        }

        // Perform DML only if there are records to update
        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
}
Important Interview Points
1. Trigger.oldMap is used to detect whether StageName changed.

2. Set<Id> prevents duplicate Account Ids.

3. SOQL is outside the Opportunity loop (Bulkified).

4. DML is outside all loops (Bulkified).

5. Account is updated only when:
   - Opportunity changes to Closed Won.
   - AccountId is present.
   - Account_Status__c is not already 'Customer'.

6. Maximum 1 SOQL and 1 DML regardless of whether
   1 or 200 Opportunities are processed.

Note: IN operator must be used with an iterable expression (that is a collection (List, Set, or query result).)
Use = instead of IN: for single Id
[SELECT Id, Account_Status__c
 FROM Account
 WHERE Id = :opp.AccountId
 AND Account_Status__c != null]

Use IN for collection
Set<Id> accIds = new Set<Id>{
    '001XXXXXXXXXXXX',
    '001YYYYYYYYYYYY'
};

List<Contact> cons = [
    SELECT Id
    FROM Contact
    WHERE AccountId IN :accIds
];
✅ accIds is iterable (a collection).

Rule to Remember
= → Single value
IN → Collection of values

Important
## Bad

for(Account acc : accounts){
    [SELECT Id FROM Contact WHERE AccountId = :acc.Id];
}

SOQL inside loop ❌

## Good

List<Contact> cons = [
    SELECT Id, AccountId
    FROM Contact
    WHERE AccountId IN :accountIds
];

for(Contact con : cons){
    ...
}

SOQL outside loop ✅

## Trigger.oldMap Availability

| Context | Available |
|----------|----------|
| Before Insert | ❌ |
| After Insert | ❌ |
| Before Update | ✅ |
| After Update | ✅ |
| Before Delete | ✅ |
| After Delete | ✅ |

Trigger.oldMap can only be used when a record already existed before the operation (Update/Delete).

For Insert triggers, there is no previous version of the record, so Trigger.old and Trigger.oldMap are not available.
