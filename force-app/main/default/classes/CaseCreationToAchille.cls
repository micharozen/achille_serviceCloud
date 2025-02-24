public class CaseCreationToAchille implements Queueable, Database.AllowsCallouts {
    private List<Id> caseIds;
    
    public CaseCreationToAchille(List<Id> caseIds) {
        this.caseIds = caseIds;
    }
    
    public void execute(QueueableContext context) {
        for(Id caseId : this.caseIds) {
            try {
                Boolean isSuccess = AchilleAPIService.notifyNewMessage(caseId, '123');
                
                // Gestion de la réponse
                if(!isSuccess) {
                    System.debug('Error calling Achille API: ' + isSuccess);
                }
                
            } catch(Exception e) {
                System.debug('Error sending case to Achille: ' + e.getMessage());
                // Vous pouvez ajouter ici une logique de gestion des erreurs
                // comme la création d'un log d'erreur personnalisé
            }
        }
    }
} 