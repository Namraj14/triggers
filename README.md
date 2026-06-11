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

Using Trigger.old (loop through records)
for(Account oldAcc : Trigger.old){
    System.debug(oldAcc.Name);
}

Using Trigger.oldMap(Here you directly get the old version of a specific record using its Id.)
Account oldAcc = Trigger.oldMap.get(acc.Id);
System.debug(oldAcc.Name);

Most Common Interview Scenario
Compare old and new values during update:
for(Account acc : Trigger.new){
    Account oldAcc = Trigger.oldMap.get(acc.Id);

    if(acc.Name != oldAcc.Name){
        System.debug('Name changed');
    }
}
