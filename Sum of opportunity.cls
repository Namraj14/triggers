Scenario: Write a trigger to sum opportunity amount and save it to account field

trigger OpportunityTrigger on Opportunity(
    after insert,
    after update,
    after delete,
    after undelete
){

    if(Trigger.isInsert || Trigger.isUndelete){
        OpportunityHandler.afterInsert(Trigger.new);
    }

    if(Trigger.isUpdate){
        OpportunityHandler.afterUpdate(
            Trigger.new,
            Trigger.oldMap
        );
    }

    if(Trigger.isDelete){
        OpportunityHandler.afterDelete(
            Trigger.old
        );
    }
}



public class OpportunityHandler {

    // Handles after insert and after undelete
    public static void afterInsert(List<Opportunity> newList){

        Set<Id> accIds = new Set<Id>();

        // Collect all impacted Account Ids
        for(Opportunity opp : newList){
            if(opp.AccountId != null){
                accIds.add(opp.AccountId);
            }
        }

        updateAccountTotals(accIds);
    }

    // Handles after update
    public static void afterUpdate(
        List<Opportunity> newList,
        Map<Id,Opportunity> oldMap
    ){

        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : newList){

            Opportunity oldOpp = oldMap.get(opp.Id);

            // Amount changed
            // Example: 400 -> 500
            if(opp.Amount != oldOpp.Amount){

                if(opp.AccountId != null){
                    accIds.add(opp.AccountId);
                }
            }

            // Account changed
            // Example: Account A -> Account B
            // Recalculate totals for BOTH Accounts
            if(opp.AccountId != oldOpp.AccountId){

                if(opp.AccountId != null){
                    accIds.add(opp.AccountId);
                }

                if(oldOpp.AccountId != null){
                    accIds.add(oldOpp.AccountId);
                }
            }
        }

        updateAccountTotals(accIds);
    }

    // Handles after delete
    public static void afterDelete(List<Opportunity> oldList){

        Set<Id> accIds = new Set<Id>();

        for(Opportunity opp : oldList){

            if(opp.AccountId != null){
                accIds.add(opp.AccountId);
            }
        }

        updateAccountTotals(accIds);
    }

    // Common method used by Insert/Update/Delete/Undelete
    private static void updateAccountTotals(Set<Id> accIds){

        if(accIds.isEmpty()){
            return;
        }

        List<Account> accToUpdate = new List<Account>();

        // Stores AccountId -> Total Opportunity Amount
        Map<Id,Decimal> accountAmountMap = new Map<Id,Decimal>();

        // Aggregate query calculates total Opportunity Amount per Account
        for(AggregateResult ar : [

            SELECT AccountId accId,
                   SUM(Amount) amt
            FROM Opportunity
            WHERE AccountId IN :accIds
            GROUP BY AccountId

        ]){

            accountAmountMap.put(
                (Id)ar.get('accId'),
                (Decimal)ar.get('amt')
            );
        }

        // Update every impacted Account
        for(Id accId : accIds){

            Decimal total = 0; //If all Opportunities were deleted, total remains 0

            // If Opportunities exist, use their sum
            if(accountAmountMap.containsKey(accId)){
                total = accountAmountMap.get(accId);
            }

            // If all Opportunities were deleted,
            // total remains 0
            accToUpdate.add(
                new Account(
                    Id = accId,
                    Sum_off_opportunity__c = total
                )
            );
        }

        if(!accToUpdate.isEmpty()){
            update accToUpdate;
        }
    }
}
