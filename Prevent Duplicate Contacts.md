### Scenario 1: Prevent users from creating a Contact with the same Email under the same Account

## Apex Trigger
Trigger Name: ContactTrigger

trigger ContactTrigger on Contact (before insert) {
    ContactHandler.beforeInsert(Trigger.new);
}

##  Apex Handler
Class Name: ContactHandler
Description: This class is foro ContactTrigger

public class ContactHandler {
    public static void beforeInsert(List<Contact> conList){
        Set<Id> accountId = new Set<Id>();
        Set<String> emails = new Set<String>();
        
        for(Contact con : conList){
            if(con.AccountId != null){
                accountId.add(con.AccountId);
            }
            if(con.Email != null){
                emails.add(con.Email);
            }
        }
        Set<String> existingKeys = new Set<String>();
        
        for(Contact con : [Select Id, Email, AccountId from Contact where Email IN :emails AND AccountId IN :accountId]){
            existingKeys.add(con.AccountId+'-'+con.Email.toLowerCase());
        }
        for(Contact cont : conList){
            if(cont.Email == null || cont.AccountId == null){
                continue;
            }
            String key = cont.AccountId +'-'+cont.Email.toLowerCase();
            
            if(existingKeys.contains(key)){
                cont.addError('Duplicate Contact');
            }
        }
    }

}
