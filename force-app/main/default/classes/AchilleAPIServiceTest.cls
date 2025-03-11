@IsTest
private class AchilleAPIServiceTest {
    @TestSetup
    static void setup() {
        // Créer l'utilisateur Achille
        TestUtils.createAchilleUser();
        
        // Créer un Case de test
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = new Case(
                Subject = 'Test Case',
                Status = 'New',
                Origin = 'Email'
            );
            insert testCase;
        }
    }
    
    // Test du singleton pattern
    @IsTest
    static void testGetInstance() {
        System.runAs(TestUtils.getAchilleUser()) {
            Test.startTest();
            AchilleAPIService instance1 = AchilleAPIService.getInstance();
            AchilleAPIService instance2 = AchilleAPIService.getInstance();
            Test.stopTest();
            
            System.assertNotEquals(null, instance1, 'L\'instance ne devrait pas être null');
            System.assertEquals(instance1, instance2, 'Les instances devraient être identiques (singleton)');
        }
    }
    
    // Test de la vérification de l'API Key
    @IsTest
    static void testCheckApiKey() {
        System.runAs(TestUtils.getAchilleUser()) {
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
            
            Test.startTest();
            Boolean result = AchilleAPIService.checkApiKey();
            Test.stopTest();
            
            System.assertEquals(true, result, 'La vérification de l\'API Key devrait réussir');
        }
    }
    
    // Test de la notification d'un nouveau message
    @IsTest
    static void testNotifyNewMessage() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
            
            Test.startTest();
            Boolean result = AchilleAPIService.notifyNewMessage(testCase.Id, '00X123456789ABCDE');
            Test.stopTest();
            
            System.assertEquals(true, result, 'La notification du nouveau message devrait réussir');
        }
    }
    
    // Test de l'enrichissement de texte
    @IsTest
    static void testEnrichText() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
            
            Test.startTest();
            String result = AchilleAPIService.enrichText(testCase.Id, 'Test text to enrich');
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Le texte enrichi ne devrait pas être null');
        }
    }
    
    // Test de récupération des informations du Case
    @IsTest
    static void testGetCaseLastInfo() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
            
            Test.startTest();
            AchilleAPIService.CaseInfo result = AchilleAPIService.getCaseLastInfo(testCase.Id);
            Test.stopTest();
            
            System.assertNotEquals(null, result, 'Les informations du Case ne devraient pas être null');
        }
    }
    
    // Test des erreurs d'API
    @IsTest
    static void testAPIErrors() {
        System.runAs(TestUtils.getAchilleUser()) {
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockError());
            
            Test.startTest();
            Boolean checkResult = AchilleAPIService.checkApiKey();
            Test.stopTest();
            
            System.assertEquals(false, checkResult, 'La vérification devrait échouer en cas d\'erreur');
        }
    }
    
    // Classe Mock pour simuler les réponses API réussies
    private class AchilleAPIMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            
            // Adapter la réponse en fonction de l'endpoint
            if (req.getEndpoint().endsWith('/check')) {
                res.setBody('true');
            } else if (req.getEndpoint().endsWith('/webhook')) {
                res.setBody('{"success":true}');
            } else if (req.getEndpoint().endsWith('/transforms-text-for-customer')) {
                res.setBody('"Texte enrichi"');
            } else if (req.getEndpoint().contains('/case-last-info')) {
                res.setBody('{"AISAT":80,"Urgency":2,"IsRealCustomer":true,"LastMsgType":"customer","LastMsgCode":1,"Answer":"Test answer"}');
            }
            
            return res;
        }
    }
    
    // Classe Mock pour simuler les erreurs API
    private class AchilleAPIMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }
} 