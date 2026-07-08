Trigger: When a Case is escalated, Salesforce must send the Case details to an external ticketing system. 
The callout can take several seconds and should not impact user experience.

trigger CaseTrigger on Case (after update) {
    
    Set<Id> caseIds = new Set<Id>();
    
    for(Case cs : Trigger.new){
        if(cs.Status == 'Escalated' && Trigger.oldMap.get(cs.Id).Status != 'Escalated'){
            caseIds.add(cs.Id);
        }
    }
    if(!caseIds.isEmpty()){
        System.enqueueJob(new CaseQueueable(caseIds));
    }
    	
    }

Class:

public class CaseQueueable implements Queueable, Database.AllowsCallouts{

    private Set<Id> caseIds;

    public CaseQueueable(Set<Id> ids){
        this.caseIds = ids;
    }

    public void execute(QueueableContext qc){

        List<Case> casesToSend = [
            SELECT Id,
                   CaseNumber,
                   Subject,
                   Description
            FROM Case
            WHERE Id IN :caseIds
        ];

        // Create Wrapper
        CaseRequestWrapper wrapper = new CaseRequestWrapper();
        wrapper.cases = casesToSend;

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:CaseAPI/caseEscalation');
        req.setMethod('POST');
        req.setHeader('Content-Type','application/json');
        req.setBody(JSON.serialize(wrapper));

        Http http = new Http();

        try{

            HttpResponse res = http.send(req);

            if(res.getStatusCode() >= 200 &&
               res.getStatusCode() < 300){

                System.debug('Cases sent successfully.');
            }
            else{

                System.debug('Request Failed');
                System.debug(res.getStatusCode());
                System.debug(res.getBody());
            }

        }
        catch(Exception e){

            System.debug(e.getMessage());

        }

    }

}


Wrapper
public class CaseRequestWrapper{
    public List<Case> cases;
}
