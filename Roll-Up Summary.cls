### Count total Contacts on an Account and store it in a custom field.


trigger ContactTrigger on Contact (after insert, after update, after delete,after undelete) {
   
    if(Trigger.isAfter){
        if(Trigger.isInsert){
        	ContactHandler.updateContactCount(Trigger.new,null);
        }
        if(Trigger.isDelete){
            ContactHandler.updateContactCount(null,Trigger.old);
        }
        if(Trigger.isUpdate){
            ContactHandler.updateContactCount(Trigger.new, Trigger.old);
        }
        if(Trigger.isUndelete){
        	ContactHandler.updateContactCount(Trigger.new, null);
    	}
    }
}

public class ContactHandler {

public static void updateContactCount(List<Contact> newList, List<Contact> oldList){

    Set<Id> accountIds = new Set<Id>();

    // Collect affected Account Ids
    if(newList != null){
        for(Contact con : newList){
            if(con.AccountId != null){
                accountIds.add(con.AccountId);
            }
        }
    }

    // For update, collect old Account Ids as well
    // (Contact may move from Account A to Account B)
    if(oldList != null){
        for(Contact con : oldList){
            if(con.AccountId != null){
                accountIds.add(con.AccountId);
            }
        }
    }

    Map<Id,Integer> conCount = new Map<Id,Integer>();

    // Get Contact count per Account
    for(AggregateResult agg : [
        SELECT COUNT(Id) cnt, AccountId accId
        FROM Contact
        WHERE AccountId IN :accountIds
        GROUP BY AccountId
    ]){
        conCount.put(
            (Id)agg.get('accId'),
            (Integer)agg.get('cnt')
        );
    }

    List<Account> accToUpdate = new List<Account>();

    // Prepare Account records with latest count
    for(Id accId : accountIds){

        Integer countVal = 0;

        if(conCount.containsKey(accId)){
            countVal = conCount.get(accId);
        }

        Account acc = new Account();
        acc.Id = accId;
        acc.Total_Contacts__c = countVal;

        accToUpdate.add(acc);
    }

    // Update Accounts in bulk
    if(!accToUpdate.isEmpty()){
        update accToUpdate;
    }
   }
}
