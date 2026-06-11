Update Account to Customer if at least one Opportunity is Closed Won.

































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
