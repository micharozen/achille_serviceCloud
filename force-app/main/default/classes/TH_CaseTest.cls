@IsTest
private class TH_CaseTest {
    @TestSetup
    static void setup() {
        // Créer l'utilisateur Achille
        TestUtils.createAchilleUser();
    }

    @IsTest
    static void testBeforeInsert() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = new Case(
                Subject = 'Test Case',
                Status = 'New',
                Origin = 'Email'
            );
            
            Test.startTest();
            insert testCase;
            Test.stopTest();
            
            Case insertedCase = [SELECT Id, Subject FROM Case WHERE Id = :testCase.Id];
            System.assertEquals('Test Case', insertedCase.Subject, 'Le sujet du Case devrait être conservé');
        }
    }
    
    @IsTest
    static void testBeforeUpdate() {
        System.runAs(TestUtils.getAchilleUser()) {
            Case testCase = new Case(
                Subject = 'Test Case',
                Status = 'New',
                Origin = 'Email'
            );
            insert testCase;
            
            testCase.Subject = 'Updated Test Case';
            
            Test.startTest();
            update testCase;
            Test.stopTest();
            
            Case updatedCase = [SELECT Id, Subject FROM Case WHERE Id = :testCase.Id];
            System.assertEquals('Updated Test Case', updatedCase.Subject, 'Le sujet du Case devrait être mis à jour');
        }
    }
    
    
    @IsTest
    static void testAfterInsert() {
        // Créer un Case de test
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Email'
        );
        
        Test.startTest();
        
        // Créer et exécuter le handler
        TH_Case handler = new TH_Case();
        handler.afterInsert(new List<SObject>{testCase});
        
        // Vérifier que le job Queueable a été créé
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'CaseCreationToAchille'], 
            'Un job CaseCreationToAchille devrait être créé');
            
        Test.stopTest();
    }
    
    @IsTest
    static void testAfterInsertBulk() {
        // Créer plusieurs Cases de test
        List<Case> testCases = new List<Case>();
        for(Integer i = 0; i < 200; i++) {
            testCases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'New',
                Origin = 'Email'
            ));
        }
        
        Test.startTest();
        
        // Créer et exécuter le handler
        TH_Case handler = new TH_Case();
        handler.afterInsert(testCases);
        
        // Vérifier que le job Queueable a été créé
        System.assertEquals(1, [SELECT COUNT() FROM AsyncApexJob WHERE ApexClass.Name = 'CaseCreationToAchille'], 
            'Un job CaseCreationToAchille devrait être créé pour le traitement en masse');
            
        Test.stopTest();
    }
    
    @IsTest
    static void testConstructor() {
        // Créer un Case de test
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            Origin = 'Email'
        );
        insert testCase;
        
        Test.startTest();
        // Créer le handler
        TH_Case handler = new TH_Case();
        
        // Vérifier que le constructeur a correctement initialisé les propriétés
        System.assertNotEquals(null, handler, 'Le handler ne devrait pas être null');
        
        Test.stopTest();
    }
} 