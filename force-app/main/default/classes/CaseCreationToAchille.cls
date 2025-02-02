public class CaseCreationToAchille implements Queueable, Database.AllowsCallouts {
    private List<Id> caseIds;
    private final String endpoint = 'https://1e44-78-245-25-38.ngrok-free.app/createCase';
    public CaseCreationToAchille(List<Id> caseIds) {
        this.caseIds = caseIds;
    }
    
    public void execute(QueueableContext context) {
        for(Id caseId : this.caseIds) {
            try {
                
                // Création de la requête HTTP
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint + '?caseId=' + caseId);
                request.setMethod('GET');
                request.setTimeout(120000); // 120 secondes timeout
                
                // Envoi de la requête
                HttpResponse response = http.send(request);
                
                // Gestion de la réponse
                if(response.getStatusCode() != 200) {
                    System.debug('Error calling Achille API: ' + response.getBody());
                }
                
            } catch(Exception e) {
                System.debug('Error sending case to Achille: ' + e.getMessage());
                // Vous pouvez ajouter ici une logique de gestion des erreurs
                // comme la création d'un log d'erreur personnalisé
            }
        }
    }
} 