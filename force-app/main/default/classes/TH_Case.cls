public class TH_Case extends TriggerHandler {
    private List<Case> newCases;
    private Map<Id, Case> oldCases;
    
    public TH_Case() {
        this.newCases = (List<Case>) Trigger.new;
        this.oldCases = (Map<Id, Case>) Trigger.oldMap;
    }
    
    public override void afterInsert(List<SObject> newList) {
        List<Id> caseIds = new List<Id>();
        for(Case c : (List<Case>)newList) {
            caseIds.add(c.Id);
        }
        
        if(!caseIds.isEmpty()) {
            // Utilisation de Queueable au lieu de future
            System.enqueueJob(new CaseCreationToAchille(caseIds));
        }
    }
} 