public class AchilleAPIService {
    private static final String BASE_URL = 'callout:Achille';
    
    // Singleton pattern
    private static AchilleAPIService instance;
    
    public static AchilleAPIService getInstance() {
        if (instance == null) {
            instance = new AchilleAPIService();
        }
        return instance;
    }
    
    private class APIResponse {
        public Integer statusCode;
        public String body;
        public Boolean isSuccess;
        
        public APIResponse(Integer statusCode, String body, Boolean isSuccess) {
            this.statusCode = statusCode;
            this.body = body;
            this.isSuccess = isSuccess;
        }
    }
    
    /**
     * Méthode générique pour effectuer des appels HTTP
     * @param endpoint Le chemin de l'endpoint (sans le BASE_URL)
     * @param method La méthode HTTP (GET, POST, etc.)
     * @param body Le corps de la requête (optionnel)
     * @return APIResponse contenant le status code, le body et un indicateur de succès
     */
    private APIResponse call(String endpoint, String method, String body) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + endpoint);
        req.setMethod(method);
        
        // Définir le timeout à 120 secondes
        req.setTimeout(120000);
        
        // Ajouter le header Content-Type pour les requêtes POST
        if (method == 'POST') {
            req.setHeader('Content-Type', 'application/json');
            if (String.isNotBlank(body)) {
                req.setBody(body);
            }
        }
        
        try {
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Log de la réponse pour le débogage
            System.debug('Response Status: ' + res.getStatusCode());
            System.debug('Response Body: ' + res.getBody());
            
            return new APIResponse(
                res.getStatusCode(),
                res.getBody(),
                res.getStatusCode() >= 200 && res.getStatusCode() < 300
            );
        } catch(Exception e) {
            System.debug('Erreur HTTP: ' + e.getMessage());
            System.debug(e.getStackTraceString());
            return new APIResponse(500, e.getMessage(), false);
        }
    }
    
    /**
     * Vérifie la validité de l'API Key
     * @return Boolean indiquant si la clé est valide
     */
    @AuraEnabled
    public static Boolean checkApiKey() {
        return AchilleAPIService.getInstance().checkApiKeyImpl();
    }
    
    private Boolean checkApiKeyImpl() {
        APIResponse response = call('/webhooks/salesforce/v1/check', 'GET', null);
        return response.isSuccess;
    }
    
    /**
     * Notifie Achille d'un nouveau message
     * @param caseId L'ID du case
     * @param messageId L'ID du message
     * @return Boolean indiquant si la notification a réussi
     */
    @AuraEnabled
    public static Boolean notifyNewMessage(String caseId, String messageId) {
        return AchilleAPIService.getInstance().notifyNewMessageImpl(caseId, messageId);
    }
    
    private Boolean notifyNewMessageImpl(String caseId, String messageId) {
        Map<String, String> body = new Map<String, String>{
            'caseID' => caseId,
            'messageID' => messageId
        };
        
        APIResponse response = call(
            '/webhooks/salesforce/v1/webhook',
            'POST',
            JSON.serialize(body)
        );
        return response.isSuccess;
    }
    
    /**
     * Demande l'enrichissement d'un texte
     * @param caseId L'ID du case
     * @param text Le texte à enrichir
     * @return Le texte enrichi ou null en cas d'erreur
     */
    @AuraEnabled
    public static String enrichText(String caseId, String text) {
        return AchilleAPIService.getInstance().enrichTextImpl(caseId, text);
    }
    
    private String enrichTextImpl(String caseId, String text) {
        Map<String, String> body = new Map<String, String>{
            'caseID' => caseId,
            'text' => text
        };
        
        APIResponse response = call(
            '/webhooks/salesforce/v1/transforms-text-for-customer',
            'POST',
            JSON.serialize(body)
        );
        
        if (response.isSuccess) {
            return (String)JSON.deserializeUntyped(response.body);
        }
        return null;
    }
    
    public class CaseInfo {
        @AuraEnabled public Integer AISAT { get; set; }
        @AuraEnabled public Integer Urgency { get; set; }
        @AuraEnabled public Boolean IsRealCustomer { get; set; }
        @AuraEnabled public String LastMsgType { get; set; }
        @AuraEnabled public Integer LastMsgCode { get; set; }
        @AuraEnabled public String Answer { get; set; }
    }
    
    /**
     * Récupère les dernières informations d'un case
     * @param caseId L'ID du case
     * @return CaseInfo Les informations du case ou null en cas d'erreur
     */
    @AuraEnabled
    public static CaseInfo getCaseLastInfo(String caseId) {
        return AchilleAPIService.getInstance().getCaseLastInfoImpl(caseId);
    }
    
    private CaseInfo getCaseLastInfoImpl(String caseId) {
        APIResponse response = call(
            '/webhooks/salesforce/v1/case-last-info?cid=' + caseId,
            'GET',
            null
        );
        System.debug(JSON.serializePretty(response));
        if (response.isSuccess) {
            return (CaseInfo)JSON.deserialize(response.body, CaseInfo.class);
        } else if (response.statusCode == 404) {
            System.debug('Case non trouvé: ' + caseId);
        }
        return null;
    }
} 