@IsTest
private class AchilleApiKeyRestServiceTest {
    @TestSetup
    static void setup() {
        // Créer l'utilisateur Achille
        TestUtils.createAchilleUser();
    }
    
    @IsTest
    static void testCreateApiKeySuccess() {
        System.runAs(TestUtils.getAchilleUser()) {
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf('{"apiKey": "test-api-key-123"}');
            RestContext.request = req;
            RestContext.response = new RestResponse();
            
            Test.startTest();
            AchilleApiKeyRestService.ResponseWrapper response = AchilleApiKeyRestService.createApiKey();
            Test.stopTest();
            
            System.assertEquals(true, response.success, 'La création de l\'API Key devrait réussir');
            System.assertEquals('success', response.message, 'Le message devrait indiquer un succès');
        }
    }
    
    @IsTest
    static void testCreateApiKeyMissingKey() {
        System.runAs(TestUtils.getAchilleUser()) {
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf('{"someOtherField": "value"}');
            RestContext.request = req;
            RestContext.response = new RestResponse();
            
            Test.startTest();
            AchilleApiKeyRestService.ResponseWrapper response = AchilleApiKeyRestService.createApiKey();
            Test.stopTest();
            
            System.assertEquals(false, response.success, 'La création devrait échouer sans apiKey');
            System.assertEquals('Le champ apiKey est requis dans le body', response.message, 'Le message devrait indiquer l\'erreur');
        }
    }
    
    @IsTest
    static void testCreateApiKeyInvalidJson() {
        System.runAs(TestUtils.getAchilleUser()) {
            RestRequest req = new RestRequest();
            req.requestBody = Blob.valueOf('invalid json');
            RestContext.request = req;
            RestContext.response = new RestResponse();
            
            Test.startTest();
            AchilleApiKeyRestService.ResponseWrapper response = AchilleApiKeyRestService.createApiKey();
            Test.stopTest();
            
            System.assertEquals(false, response.success, 'La création devrait échouer avec un JSON invalide');
            System.assert(response.message.startsWith('Erreur:'), 'Le message devrait indiquer une erreur');
        }
    }
    
    @IsTest
    static void testCreateAchilleInfos() {
        System.runAs(TestUtils.getAchilleUser()) {
            Test.startTest();
            String result = AchilleApiKeyRestService.createAchilleInfos('test-api-key-123');
            Test.stopTest();
            
            System.assertEquals('success', result, 'La création des infos Achille devrait réussir');
        }
    }
    
    @IsTest
    static void testGetNamespacePrefix() {
        System.runAs(TestUtils.getAchilleUser()) {
            Test.startTest();
            String prefix = AchilleApiKeyRestService.getNamespacePrefix();
            Test.stopTest();
            
            // Le préfixe devrait être vide dans un contexte de test sans package
            System.assertEquals('', prefix, 'Le préfixe devrait être vide dans un contexte de test');
        }
    }
    
    @IsTest
    static void testResponseWrapperConstructor() {
        System.runAs(TestUtils.getAchilleUser()) {
            Test.startTest();
            AchilleApiKeyRestService.ResponseWrapper wrapper = new AchilleApiKeyRestService.ResponseWrapper();
            Test.stopTest();
            
            System.assertEquals(true, wrapper.success, 'Le succès devrait être true par défaut');
            System.assertEquals('', wrapper.message, 'Le message devrait être vide par défaut');
        }
    }
} 