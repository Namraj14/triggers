# triggers

| Operation | `Trigger.new`           | `Trigger.old`    | `Trigger.newMap` | `Trigger.oldMap` |
| --------- | ----------------------- | ---------------- | ---------------- | ---------------- |
| Insert    | ✅ has new values        | ❌ not available  | ✅                | ❌                |
| Update    | ✅ has new values        | ✅ has old values | ✅                | ✅                |
| Delete    | ❌ not available         | ✅ has old values | ❌                | ✅                |
| Undelete  | ✅ has undeleted records | ❌ not available  | ✅                | ❌                |


# Trigger.old vs Trigger.oldMap

Both contain the old values of records before the update/delete operation, but the way you access records is different.
Trigger.old: Loop through records
Trigger.oldMap: Access directly using record Id

| Feature       | Trigger.old                         | Trigger.oldMap                  |
| ------------- | ----------------------------------- | ------------------------------- |
| Data Type     | `List<SObject>`                     | `Map<Id, SObject>`              |
| Access Method | Loop through records                | Access directly using record Id |
| Performance   | Slower for finding specific records | Faster lookup by Id             |
| Available In  | Update, Delete                      | Update, Delete                  |
| Example       | `for(Account a : Trigger.old)`      | `Trigger.oldMap.get(acc.Id)`    |

#### Using Trigger.old (loop through records)
for(Account oldAcc : Trigger.old){
    System.debug(oldAcc.Name);
}

#### Using Trigger.oldMap(Here you directly get the old version of a specific record using its Id.)
Account oldAcc = Trigger.oldMap.get(acc.Id);
System.debug(oldAcc.Name);

#### Most Common Interview Scenario
Compare old and new values during update:
for(Account acc : Trigger.new){
    Account oldAcc = Trigger.oldMap.get(acc.Id);

    if(acc.Name != oldAcc.Name){
        System.debug('Name changed');
    }
}


# Trigger.new vs Trigger.newMap

Both contain the new values of records being inserted or updated.
| Feature       | Trigger.new          | Trigger.newMap                            |
| ------------- | -------------------- | ----------------------------------------- |
| Data Type     | `List<SObject>`      | `Map<Id, SObject>`                        |
| Access Method | Loop through records | Access directly by Id                     |
| Available In  | Insert, Update       | Before Update, After Insert, After Update |
| Use Case      | Process all records  | Quickly find a specific record            |

Trigger.new (Used when you want to process every record in the trigger.)
Contains all new records as a list.
for(Account acc : Trigger.new){
    System.debug(acc.Name);
}

Trigger.newMap (Used when you need a specific record by Id.)
Contains new records as a map:
Account acc = Trigger.newMap.get(accountId);
System.debug(acc.Name);

Common Interview Example
Compare old and new values:
for(Account acc : Trigger.new){
    Account oldAcc = Trigger.oldMap.get(acc.Id);

    if(acc.Phone != oldAcc.Phone){
        System.debug('Phone changed');
    }
}
Here:

Trigger.new provides the current record.
Trigger.oldMap provides the previous version.

## Trigger Context Variables Availability

| Context | Trigger.new | Trigger.newMap | Trigger.old | Trigger.oldMap |
|----------|------------|------------|------------|------------|
| Before Insert | ✅ | ❌ | ❌ | ❌ |
| After Insert | ✅ | ✅ | ❌ | ❌ |
| Before Update | ✅ | ✅ | ✅ | ✅ |
| After Update | ✅ | ✅ | ✅ | ✅ |
| Before Delete | ❌ | ❌ | ✅ | ✅ |
| After Delete | ❌ | ❌ | ✅ | ✅ |
| After Undelete | ✅ | ✅ | ❌ | ❌ |

## Quick Memory Trick

### Insert
Only **new** records exist.

| Variable | Available |
|-----------|-----------|
| Trigger.new | ✅ |
| Trigger.newMap | ✅ (After Insert only) |
| Trigger.old | ❌ |
| Trigger.oldMap | ❌ |

### Update
Both **old** and **new** records exist.

| Variable | Available |
|-----------|-----------|
| Trigger.new | ✅ |
| Trigger.newMap | ✅ |
| Trigger.old | ✅ |
| Trigger.oldMap | ✅ |

### Delete
Only **old** records exist.

| Variable | Available |
|-----------|-----------|
| Trigger.new | ❌ |
| Trigger.newMap | ❌ |
| Trigger.old | ✅ |
| Trigger.oldMap | ✅ |

### Undelete
Records are being restored, so only **new** values exist.

| Variable | Available |
|-----------|-----------|
| Trigger.new | ✅ |
| Trigger.newMap | ✅ |
| Trigger.old | ❌ |
| Trigger.oldMap | ❌ |

## Key Difference

| Variable | Data Type | Description |
|-----------|-----------|-------------|
| Trigger.new | List<SObject> | New version of records |
| Trigger.newMap | Map<Id, SObject> | New records mapped by Id |
| Trigger.old | List<SObject> | Old version of records |
| Trigger.oldMap | Map<Id, SObject> | Old records mapped by Id |
