Scenario: Update Account to Customer if at least one Opportunity is Closed Won.

trigger OpportunityTrigger on Opportunity (after insert, after update) {

    if(Trigger.isAfter){

        if(Trigger.isInsert){
            OpportunityHandler.handleInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            OpportunityHandler.handleUpdate(
                Trigger.new,
                Trigger.oldMap
            );
        }
    }
}
public class OpportunityHandler {

    // Handles Opportunities inserted directly as Closed Won
    public static void handleInsert(List<Opportunity> newList){

        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : newList){

            if(opp.StageName == 'Closed Won' &&
               opp.AccountId != null){

                accIds.add(opp.AccountId);
            }
        }

        updateAccounts(accIds);
    }

    // Handles Opportunities updated to Closed Won
    public static void handleUpdate(
        List<Opportunity> newList,
        Map<Id, Opportunity> oldMap
    ){

        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : newList){

            Opportunity oldOpp = oldMap.get(opp.Id);

            if(oldOpp.StageName != 'Closed Won' &&
               opp.StageName == 'Closed Won' &&
               opp.AccountId != null){

                accIds.add(opp.AccountId);
            }
        }

        updateAccounts(accIds);
    }

    // Common reusable method
    private static void updateAccounts(Set<Id> accIds){

        if(accIds.isEmpty()){
            return;
        }

        List<Account> accToUpdate = new List<Account>();

        for(Account acc : [
            SELECT Id, Account_Status__c
            FROM Account
            WHERE Id IN :accIds
        ]){

            if(acc.Account_Status__c != 'Customer'){

                acc.Account_Status__c = 'Customer';
                accToUpdate.add(acc);
            }
        }

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
