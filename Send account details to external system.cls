Scenario: Whenever a new Account is created, if the Account Type is "Customer", send the Account details to an external CRM using a POST REST API call.

trigger AccountTrigger on Account (after insert) {

    // Store Account Ids that need to be sent to the external system
    List<Id> accountIds = new List<Id>();

    // Loop through newly inserted Accounts
    for(Account acc : Trigger.new){

        // Only Customer Accounts should be integrated
        if(acc.Type == 'Customer'){
            accountIds.add(acc.Id);
        }
    }

    // Trigger should execute only after records are committed
    // because Callouts cannot be made directly from triggers.
    if(Trigger.isAfter){
        if(Trigger.isInsert){

            // Call Future Method for asynchronous callout
            AccountHandler.sendAccount(accountIds);
        }
    }
}



public class AccountHandler {

    // Future Method executes asynchronously.
    // callout=true allows HTTP callouts from this method.
    @future(callout=true)
    public static void sendAccount(List<Id> accountIds){

        // Query complete Account details because Future methods
        // can only receive primitive data types.
        List<Account> accList = [
            SELECT Id,
                   Name,
                   Phone,
                   Industry
            FROM Account
            WHERE Id IN :accountIds
        ];

        // Loop through every Account
        for(Account acc : accList){

            // Create HTTP Request object
            HttpRequest req = new HttpRequest();

            // Named Credential endpoint
            req.setEndpoint('callout:Dummyapi/accounts');

            // POST request because we're creating records
            req.setMethod('POST');

            // Inform API that request body is JSON
            req.setHeader('Content-Type','application/json');

            // Create request payload
            Map<String,Object> body = new Map<String,Object>();

            body.put('Name',acc.Name);
            body.put('Phone',acc.Phone);
            body.put('Industry',acc.Industry);

            // Convert Map into JSON String
            req.setBody(JSON.serialize(body));

            // Create Http object
            Http http = new Http();

            // Send request
            HttpResponse res = http.send(req);

            // Print response for debugging
            System.debug('Status Code : ' + res.getStatusCode());
            System.debug('Response Body : ' + res.getBody());
        }
    }
}


# SOQL Querying Notes

## 1. What happens when we query a record?

When a SOQL query executes, Salesforce creates an **sObject in memory** and populates **only the fields that were queried**.

Example:

```apex
Account acc = [
    SELECT Id, Name
    FROM Account
    WHERE Id = :accountId
];
```

Memory contains:

Id
Name

It does **NOT** contain:

- Phone
- Industry
- Credit_Score__c

unless they were included in the SELECT statement.

---

## 2. Reading vs Writing Fields

### Reading a queried field ✅

```apex
System.debug(acc.Name);
```

Works because Name was queried.

---

### Reading a non-queried field ❌

```apex
System.debug(acc.Phone);
```

Throws

```
SObject row was retrieved via SOQL without querying the requested field
```

because Phone wasn't loaded into memory.

---

### Writing to a non-queried field ✅

```apex
acc.Phone = '9876543210';
update acc;
```

Works because Salesforce only needs:

- Record Id
- Field to update
- New value

You don't need the old value.

---

## 3. Do I need to query a field before updating it?

No.

This is perfectly valid.

```apex
Account acc = [
    SELECT Id, Name
    FROM Account
    WHERE Id = :accountId
];

acc.Credit_Score__c = 750;

update acc;
```

Only the Id is mandatory for updating.

---

## 4. Why does reading fail but writing work?

Reading

> "Tell me the current value."

Salesforce says:

> "I never loaded that field."

Writing

> "Replace the value with this."

Salesforce doesn't need the old value.

---

# Bind Variables (:)

## Correct

```apex
Id accountId = '001XXXXXXXXXXXX';

Account acc = [
    SELECT Id
    FROM Account
    WHERE Id = :accountId
];
```

The `:` is called the **Bind Operator**.

It tells SOQL to use the value stored in the Apex variable.

---

## Incorrect

```apex
Account acc = [
    SELECT Id
    FROM Account
    WHERE Id = accountId
];
```

This gives an error because SOQL thinks `accountId` is a field name.

---

## Why use : ?

Apex variables live in Apex memory.

SOQL cannot access them directly.

The `:` passes Apex variable values into the SOQL query.

```
Apex Variable
      │
      ▼
accountId
      │
      ▼
      :
      │
      ▼
SOQL Query
```

---

# Querying Collections

## Query using Set

```apex
Set<Id> accIds = new Set<Id>();

List<Account> accounts = [
    SELECT Id, Name
    FROM Account
    WHERE Id IN :accIds
];
```

---

## Query using List

```apex
List<Id> accIds = new List<Id>();

List<Account> accounts = [
    SELECT Id, Name
    FROM Account
    WHERE Id IN :accIds
];
```

---

# Query Single Record

```apex
Account acc = [
    SELECT Id, Name
    FROM Account
    WHERE Id = :accountId
];
```

Returns one Account.

If no record exists, a **QueryException** is thrown.

---

# Query Multiple Records

```apex
List<Account> accounts = [
    SELECT Id, Name
    FROM Account
];
```

Returns a List<Account>.

If no records exist, an empty list is returned.

---

# Best Practices

✔ Query only the fields you need.

✔ Never perform SOQL inside loops.

✔ Use bind variables (`:`) for Apex variables.

✔ Query only when you need to read existing values.

✔ You can update fields even if they weren't queried.

✔ Query multiple records at once for bulk processing.

✔ Always use collections (List/Set/Map) for bulkified code.

---

# Interview Questions

### Q1. What happens when a SOQL query executes?

An sObject is created in memory containing only the fields that were queried.

---

### Q2. Can you update a field that wasn't queried?

Yes.

As long as the record Id is available, you can assign a new value and perform an update.

---

### Q3. Why does reading an unqueried field throw an exception?

Because Salesforce never loaded that field into memory.

---

### Q4. What is the purpose of `:` in SOQL?

It is the **Bind Operator**.

It passes Apex variable values into the SOQL query.

---

### Q5. Why shouldn't SOQL be inside loops?

Because Salesforce has a governor limit of **100 SOQL queries per transaction**. Querying inside loops can quickly exceed this limit.
