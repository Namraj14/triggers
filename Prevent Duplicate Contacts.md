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

    // Method called from before insert trigger
    public static void beforeInsert(List<Contact> conList){

        // Store unique Account Ids from incoming contacts
        Set<Id> accountId = new Set<Id>();

        // Store unique Emails from incoming contacts
        Set<String> emails = new Set<String>();

        // Collect AccountIds and Emails from Trigger.new
        for(Contact con : conList){

            // Add AccountId if present
            if(con.AccountId != null){
                accountId.add(con.AccountId);
            }

            // Add Email if present
            if(con.Email != null){
                emails.add(con.Email.toLowerCase());
            }
        }

        // Stores combinations of existing AccountId + Email
        // Example: 001xx000123-john@test.com
        Set<String> existingKeys = new Set<String>();

        // Query existing contacts having same Account and Email
        for(Contact con : [SELECT Id, Email, AccountId FROM Contact WHERE Email IN :emails AND AccountId IN :accountId]){
            existingKeys.add(con.AccountId + '-' + con.Email.toLowerCase());
        }

        // Validate incoming contacts against existing records
        for(Contact cont : conList){

            // Skip records that do not have Email or AccountId
            if(cont.Email == null || cont.AccountId == null){
                continue;
            }

            // Create unique key for incoming contact
            String key = cont.AccountId + '-' + cont.Email.toLowerCase();

            // If same Account + Email already exists
            if(existingKeys.contains(key)){

                // Prevent record from being inserted
                cont.addError('Duplicate Contact');
            }
        }
    }
}
