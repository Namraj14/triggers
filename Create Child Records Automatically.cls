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

String.isBlank() - Only String has isBlank().
Returns true if the string is:
null
Empty ('')
Only spaces (' ')

String.isBlank(null);     // true
String.isBlank('');       // true
String.isBlank('   ');    // true
String.isBlank('John');   // false


String.isEmpty() - isEmpty() is not only for Strings
Returns true only if:
null
Empty ('')

String.isEmpty(null);    // true
String.isEmpty('');      // true
String.isEmpty('   ');   // false

if(contacts.isEmpty()){}
if(accountIds.isEmpty()){}
if(accMap.isEmpty()){

}
Null Check
if(acc.Name != null)
Checks only for null.

acc.Name = '';      // passes
acc.Name = '   ';   // passes

String.isBlank() is only for String variables.
For other data types, you typically use null checks and collection methods.
