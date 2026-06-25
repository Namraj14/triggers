Scenario: Prevent deletion of Closed Won Opportunities.

trigger OpportunityTrigger on Opportunity (before delete) {
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            OpportunityHandler.preventDeletion(Trigger.old);
        }
    }
}

public class OpportunityHandler {
    public static void preventDeletion(List<Opportunity> oppList){
        
        for(Opportunity opp : oppList){
            if(opp.StageName == 'Closed Won'){
                opp.addError('Opportunity Cannot be Delete');
            }
        }
	}
}


Note: addError() is used to prevent a record from being saved, updated, or deleted and display an error message to the user.
addError() can only be called on individual sObjects (e.g., Case, Account) or individual fields (e.g., case.Status.addError()) because addError() belongs to sObjects and fields, not collections such as List<sObject> or Map<Id, sObject>.1. sObjects (Account, Contact, Opportunity, etc.)
2. Fields (opp.Name.addError())
It cannot be called on:List, Set, Map, Id, String

opp.addError();          // YES
acc.addError();          // YES
opp.Name.addError();     // YES

List<Opportunity>.addError(); // NO
Set<Id>.addError();           // NO
Map<Id,Account>.addError();   // NO
