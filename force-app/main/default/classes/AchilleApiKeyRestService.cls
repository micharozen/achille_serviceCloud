@RestResource(urlMapping='/createApiKey/*')
global class AchilleApiKeyRestService {
    

    @HttpPost
    global static ResponseWrapper createApiKey() {
        ResponseWrapper response = new ResponseWrapper();
        
        try {
            // Récupération du body
            String jsonBody = RestContext.request.requestBody.toString();
            Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonBody);
            
            if (!requestMap.containsKey('apiKey')) {
                response.success = false;
                response.message = 'Le champ apiKey est requis dans le body';
                return response;
            }
            
            String apiKey = (String)requestMap.get('apiKey');
            String result = createAchilleInfos(apiKey);
            
            response.success = result == 'success';
            response.message = result;
            
        } catch(Exception e) {
            response.success = false;
            response.message = 'Erreur: ' + e.getMessage();
        }
        
        return response;
    }
    
    public static String createAchilleInfos(String apiKey) {
        String namespacePrefix = getNamespacePrefix();
        
        Metadata.CustomMetadata customMetadata = new Metadata.CustomMetadata();
        customMetadata.fullName = namespacePrefix + 'AchilleInfos__mdt.DEFAULT';
        customMetadata.label = 'DEFAULT';
        
        Metadata.CustomMetadataValue apiKeyValue = new Metadata.CustomMetadataValue();
        apiKeyValue.field = namespacePrefix + 'ApiKey__c';
        apiKeyValue.value = apiKey;
        customMetadata.values.add(apiKeyValue);
        
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        mdContainer.addMetadata(customMetadata);
        
        if(!Test.isRunningTest()) {
            Id jobId = Metadata.Operations.enqueueDeployment(mdContainer, null);
        }
        
        return 'success';
    }
    
    global class ResponseWrapper {
        public Boolean success;
        public String message;
        
        public ResponseWrapper() {
            this.success = true;
            this.message = '';
        }
    }

    public static String getNamespacePrefix() {
        String namespace = AchilleApiKeyRestService.class.getName().substringBefore('AchilleApiKeyRestService').replace('.', '');
        return String.isNotBlank(namespace) ? namespace + '__' : '';
    }
} 