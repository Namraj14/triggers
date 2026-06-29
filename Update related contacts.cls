Scenario: Whenever an Account's Industry changes, update all related Contacts' Account_Industry__c field with the latest Account Industry.

trigger AccountTrigger on Account (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            AccountHandler.updateContact(Trigger.new,Trigger.oldMap);
        }
    }

}




public class AccountHandler {

    // This method is called from the trigger
    // newAccList  -> Contains the latest Account records (Trigger.new)
    // oldAccList  -> Contains the old Account values before update (Trigger.oldMap)
    public static void updateContact(List<Account> newAccList, Map<Id,Account> oldAccList){

        // Store only those Account Ids whose Industry has changed.
        // Using Set avoids duplicate Account Ids.
        Set<Id> accIds = new Set<Id>();

        // Loop through all updated Accounts
        for(Account acc : newAccList){

            // Get the old version of the same Account
            Account oldAcc = oldAccList.get(acc.Id);

            // Compare old and new Industry values
            // Only process Accounts where Industry has changed
            if(acc.Industry != oldAcc.Industry){
                accIds.add(acc.Id);
            }
        }

        // Optimization:
        // If no Account Industry changed, stop execution.
        // Prevents unnecessary SOQL query and DML.
        if(accIds.isEmpty()){
            return;
        }

        // Query all Contacts belonging to the modified Accounts.
        // Parent field (Account.Industry) is also queried
        // because we'll copy it into the Contact field.
        List<Contact> conList = [
            SELECT Id,
                   AccountId,
                   Account.Industry
            FROM Contact
            WHERE AccountId IN :accIds
        ];

        // Store Contacts that actually need updating
        List<Contact> conToUpdate = new List<Contact>();

        // Loop through all related Contacts
        for(Contact con : conList){

            // Create a new Contact object instead of modifying queried records.
            // This is a partial update pattern.
            Contact c = new Contact();

            // Id is mandatory while updating records
            c.Id = con.Id;

            // Copy the latest Account Industry into the custom Contact field
            c.Account_Industry__c = con.Account.Industry;

            // Add Contact to update list
            conToUpdate.add(c);
        }

        // Perform DML only if there are records to update
        if(!conToUpdate.isEmpty()){
            update conToUpdate;
        }

    }
}
