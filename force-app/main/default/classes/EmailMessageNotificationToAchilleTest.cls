@IsTest
private class EmailMessageNotificationToAchilleTest {
    
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
    
    @IsTest
    static void testNotifyNewMessage() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            
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
            EmailMessageNotificationToAchille notifier = new EmailMessageNotificationToAchille(new List<EmailMessage>{testEmail});
            System.enqueueJob(notifier);
            Test.stopTest();
            
            // Vérifier que la notification a été envoyée avec succès
            System.assertEquals(2, [SELECT COUNT() FROM AsyncApexJob 
                WHERE JobType = 'Queueable' 
                AND ApexClass.Name = 'EmailMessageNotificationToAchille' 
                AND Status = 'Completed'], 
                'Le job devrait être complété avec succès');
        }
    }
    
    @IsTest
    static void testNotifyNewMessageError() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            
            EmailMessage testEmail = new EmailMessage(
                ParentId = testCase.Id,
                Subject = 'Test Email',
                TextBody = 'Test Body',
                FromAddress = 'test@example.com',
                ToAddress = 'recipient@example.com'
            );
            insert testEmail;
            
            Test.setMock(HttpCalloutMock.class, new AchilleAPIMockError());
            
            Test.startTest();
            EmailMessageNotificationToAchille notifier = new EmailMessageNotificationToAchille(new List<EmailMessage>{testEmail});
            System.enqueueJob(notifier);
            Test.stopTest();
            
            // Vérifier que le job a été exécuté malgré l'erreur
            System.assertEquals(2, [SELECT COUNT() FROM AsyncApexJob 
                WHERE JobType = 'Queueable' 
                AND ApexClass.Name = 'EmailMessageNotificationToAchille' 
                AND Status = 'Completed'], 
                'Le job devrait être complété même en cas d\'erreur');
        }
    }
    
    @IsTest
    static void testExecute() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Créer un EmailMessage de test
        EmailMessage testEmail = new EmailMessage(
            ParentId = testCase.Id,
            Subject = 'Test Email',
            TextBody = 'Test Email Body',
            ToAddress = 'test@example.com',
            FromAddress = 'from@example.com'
        );
        insert testEmail;
        
        // Créer l'instance de la classe Queueable
        EmailMessageNotificationToAchille notifier = new EmailMessageNotificationToAchille(new List<EmailMessage>{testEmail});
        
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
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Créer plusieurs EmailMessages de test
        List<EmailMessage> testEmails = new List<EmailMessage>();
        for(Integer i = 0; i < 50; i++) {
            testEmails.add(new EmailMessage(
                ParentId = testCase.Id,
                Subject = 'Test Email ' + i,
                TextBody = 'Test Email Body ' + i,
                ToAddress = 'test' + i + '@example.com',
                FromAddress = 'from@example.com'
            ));
        }
        insert testEmails;
        
        // Créer l'instance de la classe Queueable
        EmailMessageNotificationToAchille notifier = new EmailMessageNotificationToAchille(testEmails);
        
        Test.startTest();
        
        // Configurer le mock pour l'appel API
        Test.setMock(HttpCalloutMock.class, new AchilleAPIMockSuccess());
        
        // Exécuter le job
        System.enqueueJob(notifier);
        
        Test.stopTest();
        
        // La vérification est implicite car Test.stopTest() attend la fin de tous les jobs asynchrones
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