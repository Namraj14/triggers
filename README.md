# triggers

| Operation | `Trigger.new`           | `Trigger.old`    | `Trigger.newMap` | `Trigger.oldMap` |
| --------- | ----------------------- | ---------------- | ---------------- | ---------------- |
| Insert    | ✅ has new values        | ❌ not available  | ✅                | ❌                |
| Update    | ✅ has new values        | ✅ has old values | ✅                | ✅                |
| Delete    | ❌ not available         | ✅ has old values | ❌                | ✅                |
| Undelete  | ✅ has undeleted records | ❌ not available  | ✅                | ❌                |
