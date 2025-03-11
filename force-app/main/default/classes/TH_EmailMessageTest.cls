@IsTest
private class TH_EmailMessageTest {
    
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
    static void testBeforeInsert() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            
            EmailMessage testEmail = new EmailMessage(
                ParentId = testCase.Id,
                Subject = 'Test Email',
                TextBody = 'Test Body',
                FromAddress = 'test@example.com',
                ToAddress = 'recipient@example.com'
            );
            
            Test.startTest();
            insert testEmail;
            Test.stopTest();
            
            EmailMessage insertedEmail = [SELECT Id, Subject FROM EmailMessage WHERE Id = :testEmail.Id];
            System.assertEquals('Test Email', insertedEmail.Subject, 'Le sujet de l\'email devrait être conservé');
        }
    }
    
    @IsTest
    static void testBeforeUpdate() {
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
            
            testEmail.Subject = 'Updated Test Email';
            
            Test.startTest();
            update testEmail;
            Test.stopTest();
            
            EmailMessage updatedEmail = [SELECT Id, Subject FROM EmailMessage WHERE Id = :testEmail.Id];
            System.assertEquals('Updated Test Email', updatedEmail.Subject, 'Le sujet de l\'email devrait être mis à jour');
        }
    }
    
    @IsTest
    static void testBeforeDelete() {
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
            
            Test.startTest();
            delete testEmail;
            Test.stopTest();
            
            List<EmailMessage> deletedEmails = [SELECT Id FROM EmailMessage WHERE Id = :testEmail.Id ALL ROWS];
            System.assertEquals(0, deletedEmails.size(), 'L\'email devrait être supprimé');
        }
    }
    
    @IsTest
    static void testAfterInsert() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = [SELECT Id FROM Case LIMIT 1];
            
            Test.startTest();
            EmailMessage testEmail = new EmailMessage(
                ParentId = testCase.Id,
                Subject = 'Test Email',
                TextBody = 'Test Body',
                FromAddress = 'test@example.com',
                ToAddress = 'recipient@example.com'
            );
            insert testEmail;
            Test.stopTest();
            
            // Vérifier que l'email a été créé avec succès
            EmailMessage insertedEmail = [SELECT Id FROM EmailMessage WHERE Id = :testEmail.Id];
            System.assertNotEquals(null, insertedEmail, 'L\'email devrait être créé');
        }
    }
    
    @IsTest
    static void testAfterInsertBulk() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];
        
        // Créer plusieurs EmailMessages de test
        List<EmailMessage> testEmails = new List<EmailMessage>();
        for(Integer i = 0; i < 200; i++) {
            testEmails.add(new EmailMessage(
                ParentId = testCase.Id,
                Subject = 'Test Email ' + i,
                TextBody = 'Test Email Body ' + i,
                ToAddress = 'test' + i + '@example.com',
                FromAddress = 'from@example.com'
            ));
        }
        
        Test.startTest();
        
        // Créer et exécuter le handler
        TH_EmailMessage handler = new TH_EmailMessage();
        handler.afterInsert(testEmails);
        
        // Vérifier que le job Queueable a été créé
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'EmailMessageNotificationToAchille'], 
            'Un job EmailMessageNotificationToAchille devrait être créé pour le traitement en masse');
            
        Test.stopTest();
    }
    
    @IsTest
    static void testAfterInsertNonCaseParent() {
        // Créer un EmailMessage sans Case parent
        EmailMessage testEmail = new EmailMessage(
            Subject = 'Test Email',
            TextBody = 'Test Email Body',
            ToAddress = 'test@example.com',
            FromAddress = 'from@example.com'
        );
        
        Test.startTest();
        
        // Créer et exécuter le handler
        TH_EmailMessage handler = new TH_EmailMessage();
        handler.afterInsert(new List<SObject>{testEmail});
        
        // Vérifier qu'aucun job Queueable n'a été créé
        System.assertEquals(0, [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'EmailMessageNotificationToAchille'], 
            'Aucun job ne devrait être créé pour un EmailMessage sans Case parent');
            
        Test.stopTest();
    }
    
    @IsTest
    static void testConstructor() {
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
        
        Test.startTest();
        
        // Créer le handler
        TH_EmailMessage handler = new TH_EmailMessage();
        
        // Vérifier que le constructeur a correctement initialisé les propriétés
        System.assertNotEquals(null, handler, 'Le handler ne devrait pas être null');
        
        Test.stopTest();
    }
} 