Scenario: When an Account is created, automatically create a default Contact.


trigger AccountTrigger on Account (after insert) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AccountHandler.createContact(Trigger.new);
        }
    }
}

public class AccountHandler {

    public static void createContact(List<Account> accList){

        List<Contact> contactToCreate = new List<Contact>();

        for(Account acc : accList){

            // Skip Accounts without a valid Name
            if(String.isBlank(acc.Name)){
                continue;
            }

            Contact con = new Contact();
            con.LastName = acc.Name;
            con.AccountId = acc.Id;

            contactToCreate.add(con);
        }

        // Bulk insert Contacts
        if(!contactToCreate.isEmpty()){
            insert contactToCreate;
        }
    }
}
