@IsTest
private class CaseCreationToAchilleTest {
    
    @TestSetup
    static void setup() {
        // Créer l'utilisateur Achille
        TestUtils.createAchilleUser();

        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = new Case(
                Subject = 'Test Case',
                Status = 'New',
                Origin = 'Email'
            );
            insert testCase;
        }
    }
    
    @IsTest
    static void testNotifyNewCase() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
            
            Test.startTest();
            CaseCreationToAchille notifier = new CaseCreationToAchille(new List<Id>{testCase.Id});
            System.enqueueJob(notifier);
            Test.stopTest();
            
            // Vérifier que la notification a été envoyée avec succès
            System.assertEquals(2, [SELECT COUNT() FROM AsyncApexJob 
                WHERE JobType = 'Queueable' 
                AND ApexClass.Name = 'CaseCreationToAchille' 
                AND Status = 'Completed'], 
                'Le job devrait être complété avec succès');
        }
    }
    
    @IsTest
    static void testNotifyNewCaseError() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockError());
            
            Test.startTest();
            CaseCreationToAchille notifier = new CaseCreationToAchille(new List<Id>{testCase.Id});
            System.enqueueJob(notifier);
            Test.stopTest();
            
            // Vérifier que le job a été exécuté malgré l'erreur
            System.assertEquals(2, [SELECT COUNT() FROM AsyncApexJob 
                WHERE JobType = 'Queueable' 
                AND ApexClass.Name = 'CaseCreationToAchille' 
                AND Status = 'Completed'], 
                'Le job devrait être complété même en cas d\'erreur');
        }
    }
    
    @IsTest
    static void testNotifyNewCaseWithEmailMessage() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = new Case(
                Subject = 'Test Case',
                Status = 'New',
                Origin = 'Email'
            );
            insert testCase;
            
            EmailMessage testEmail = new EmailMessage(
                ParentId = testCase.Id,
                Subject = 'Test Email',
                TextBody = 'Test Body',
                FromAddress = 'test@example.com',
                ToAddress = 'recipient@example.com'
            );
            insert testEmail;
            
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
            
            Test.startTest();
            CaseCreationToAchille notifier = new CaseCreationToAchille(new List<Id>{testCase.Id});
            System.enqueueJob(notifier);
            Test.stopTest();
            
            // Vérifier que la notification a été envoyée avec succès
            System.assertEquals(3, [SELECT COUNT() FROM AsyncApexJob 
                WHERE JobType = 'Queueable' 
                AND ApexClass.Name = 'CaseCreationToAchille' 
                AND Status = 'Completed'], 
                'Le job devrait être complété avec succès');
        }
    }
    
    @IsTest
    static void testExecute() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Créer l'instance de la classe Queueable
        CaseCreationToAchille notifier = new CaseCreationToAchille(new List<Id>{testCase.Id});
        
        Test.startTest();
        
        // Configurer le mock pour l'appel API
        Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
        
        // Exécuter le job
        System.enqueueJob(notifier);
        
        Test.stopTest();
        
        // La vérification est implicite car Test.stopTest() attend la fin de tous les jobs asynchrones
    }
    
    @IsTest
    static void testExecuteBulk() {
        // Créer plusieurs Cases de test
        List<Case> testCases = new List<Case>();
        List<Id> caseIds = new List<Id>();
        
        for(Integer i = 0; i < 50; i++) {
            testCases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'New',
                Origin = 'Email'
            ));
        }
        insert testCases;
        
        for(Case c : testCases) {
            caseIds.add(c.Id);
        }
        
        // Créer l'instance de la classe Queueable
        CaseCreationToAchille notifier = new CaseCreationToAchille(caseIds);
        
        Test.startTest();
        
        // Configurer le mock pour l'appel API
        Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
        
        // Exécuter le job
        System.enqueueJob(notifier);
        
        Test.stopTest();
        
        // La vérification est implicite car Test.stopTest() attend la fin de tous les jobs asynchrones
    }
    
    @IsTest
    static void testExecuteWithError() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Créer l'instance de la classe Queueable
        CaseCreationToAchille notifier = new CaseCreationToAchille(new List<Id>{testCase.Id});
        
        Test.startTest();
        
        // Configurer le mock pour simuler une erreur API
        Test.setMock(HttpCalloutMock.class, new AchilleAPIMockError());
        
        // Exécuter le job
        System.enqueueJob(notifier);
        
        Test.stopTest();
        
        // La vérification est implicite car Test.stopTest() attend la fin de tous les jobs asynchrones
        // et nous vérifions que le code gère correctement les erreurs
    }
    
    // Classes Mock
    private class AchilleAPIMockSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"success":true}');
            return res;
        }
    }
    
    private class AchilleAPIMockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error":"Internal Server Error"}');
            return res;
        }
    }
} 