Scenario: A client wants to prevent users from closing a Case if the Case Owner is still a Queue. 
Cases must only be closed after they are assigned to an individual agent.

trigger CaseTrigger on Case (before update) {
    	if(Trigger.isBefore && Trigger.isUpdate){
   			 CaseHandler.preventCaseClose(trigger.new,trigger.oldMap);
    }
}

public class CaseHandler {

    public static void preventCaseClose(List<Case> newCase, Map<Id, Case> oldCase) {

        // Stores OwnerIds of Cases that are being closed
        Set<Id> ownerIds = new Set<Id>();

        for (Case cs : newCase) {

            // Get the old version of the Case to compare values
            Case oldCs = oldCase.get(cs.Id);

            // Process only when Status changes to Closed
            if (cs.Status == 'Closed' && oldCs.Status != 'Closed') {
                ownerIds.add(cs.OwnerId);
            }
        }

        // Stores OwnerIds that belong to Queues
        Set<Id> queueOwnerIds = new Set<Id>();

        // Query Group object because Queue records are stored as Groups with Type = 'Queue'
        for (Group g : [
            SELECT Id
            FROM Group
            WHERE Id IN :ownerIds
            AND Type = 'Queue'
        ]) {
            queueOwnerIds.add(g.Id);
        }

        // Prevent Case closure if the Owner is still a Queue
        for (Case c : newCase) {

            if (c.Status == 'Closed' &&
                oldCase.get(c.Id).Status != 'Closed' &&
                queueOwnerIds.contains(c.OwnerId)) {

                // addError() stops the record from being saved and displays the message to the user
                c.addError('Case cannot be closed as the owner is still a Queue. Please assign it to an individual agent.');
            }
        }
    }
}
