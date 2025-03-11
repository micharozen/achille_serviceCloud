@IsTest
private class TriggerHandlerTest {
    @TestSetup
    static void setup() {
        // Créer l'utilisateur Achille
        TestUtils.createAchilleUser();
    }

    private class TestHandler extends TriggerHandler {
        public override void beforeInsert(List<SObject> newList) {
            for(SObject obj : newList) {
                Account acc = (Account)obj;
                if(acc.Name == null) acc.Name = 'Test Account';
            }
        }
        
        public override void beforeUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            for(SObject obj : newList) {
                Account acc = (Account)obj;
                Account oldAcc = (Account)oldMap.get(acc.Id);
                if(acc.Name != oldAcc.Name) {
                    acc.Description = 'Name changed from ' + oldAcc.Name + ' to ' + acc.Name;
                }
            }
        }
        
        public override void beforeDelete(List<SObject> oldList) {
            for(SObject obj : oldList) {
                Account acc = (Account)obj;
                if(acc.Name == 'Do Not Delete') {
                    acc.addError('This account cannot be deleted');
                }
            }
        }
        
        public override void afterInsert(List<SObject> newList) {
            List<Contact> contacts = new List<Contact>();
            for(SObject obj : newList) {
                Account acc = (Account)obj;
                contacts.add(new Contact(
                    AccountId = acc.Id,
                    LastName = 'Test Contact for ' + acc.Name
                ));
            }
            if(!contacts.isEmpty()) insert contacts;
        }
        
        public override void afterUpdate(List<SObject> newList, Map<Id, SObject> oldMap) {
            List<Task> tasks = new List<Task>();
            for(SObject obj : newList) {
                Account acc = (Account)obj;
                Account oldAcc = (Account)oldMap.get(acc.Id);
                if(acc.Name != oldAcc.Name) {
                    tasks.add(new Task(
                        WhatId = acc.Id,
                        Subject = 'Account name changed',
                        Description = 'Name changed from ' + oldAcc.Name + ' to ' + acc.Name
                    ));
                }
            }
            if(!tasks.isEmpty()) insert tasks;
        }
        
        public override void afterDelete(List<SObject> oldList) {
            List<Task> tasks = new List<Task>();
            for(SObject obj : oldList) {
                Account acc = (Account)obj;
                tasks.add(new Task(
                    Subject = 'Account deleted',
                    Description = 'Account ' + acc.Name + ' was deleted'
                ));
            }
            if(!tasks.isEmpty()) insert tasks;
        }
        
        public override void afterUndelete(List<SObject> newList) {
            List<Task> tasks = new List<Task>();
            for(SObject obj : newList) {
                Account acc = (Account)obj;
                tasks.add(new Task(
                    WhatId = acc.Id,
                    Subject = 'Account restored',
                    Description = 'Account ' + acc.Name + ' was restored'
                ));
            }
            if(!tasks.isEmpty()) insert tasks;
        }
    }
    
    @IsTest
    static void testBeforeInsert() {
        System.runAs(TestUtils.getAchilleUser()) {
            Account testAcc = new Account();
            
            Test.startTest();
            insert testAcc;
            Test.stopTest();
            
            Account insertedAcc = [SELECT Id, Name FROM Account WHERE Id = :testAcc.Id];
            System.assertEquals('Test Account', insertedAcc.Name, 'Le nom du compte devrait être défini');
        }
    }
    
    @IsTest
    static void testBeforeUpdate() {
        System.runAs(TestUtils.getAchilleUser()) {
            Account testAcc = new Account(Name = 'Original Name');
            insert testAcc;
            
            testAcc.Name = 'Updated Name';
            
            Test.startTest();
            update testAcc;
            Test.stopTest();
            
            Account updatedAcc = [SELECT Id, Name, Description FROM Account WHERE Id = :testAcc.Id];
            System.assertEquals('Name changed from Original Name to Updated Name', 
                updatedAcc.Description, 'La description devrait refléter le changement de nom');
        }
    }
    
    @IsTest
    static void testBeforeDelete() {
        System.runAs(TestUtils.getAchilleUser()) {
            Account testAcc = new Account(Name = 'Do Not Delete');
            insert testAcc;
            
            Test.startTest();
            Database.DeleteResult result = Database.delete(testAcc, false);
            Test.stopTest();
            
            System.assertEquals(false, result.isSuccess(), 'La suppression devrait échouer');
            System.assertEquals('This account cannot be deleted', 
                result.getErrors()[0].getMessage(), 'Le message d\'erreur devrait être correct');
        }
    }
    
    @IsTest
    static void testAfterInsert() {
        System.runAs(TestUtils.getAchilleUser()) {
            Account testAcc = new Account(Name = 'Test Account');
            
            Test.startTest();
            insert testAcc;
            Test.stopTest();
            
            List<Contact> contacts = [SELECT Id, LastName FROM Contact WHERE AccountId = :testAcc.Id];
            System.assertEquals(1, contacts.size(), 'Un contact devrait être créé');
            System.assertEquals('Test Contact for Test Account', 
                contacts[0].LastName, 'Le nom du contact devrait être correct');
        }
    }
    
    @IsTest
    static void testAfterUpdate() {
        System.runAs(TestUtils.getAchilleUser()) {
            Account testAcc = new Account(Name = 'Original Name');
            insert testAcc;
            
            testAcc.Name = 'Updated Name';
            
            Test.startTest();
            update testAcc;
            Test.stopTest();
            
            List<Task> tasks = [SELECT Id, Subject, Description FROM Task WHERE WhatId = :testAcc.Id];
            System.assertEquals(1, tasks.size(), 'Une tâche devrait être créée');
            System.assertEquals('Account name changed', tasks[0].Subject, 'Le sujet de la tâche devrait être correct');
        }
    }
    
    @IsTest
    static void testAfterDelete() {
        System.runAs(TestUtils.getAchilleUser()) {
            Account testAcc = new Account(Name = 'Test Account');
            insert testAcc;
            
            Test.startTest();
            delete testAcc;
            Test.stopTest();
            
            List<Task> tasks = [SELECT Id, Subject, Description FROM Task];
            System.assertEquals(1, tasks.size(), 'Une tâche devrait être créée');
            System.assertEquals('Account deleted', tasks[0].Subject, 'Le sujet de la tâche devrait être correct');
        }
    }
    
    @IsTest
    static void testAfterUndelete() {
        System.runAs(TestUtils.getAchilleUser()) {
            Account testAcc = new Account(Name = 'Test Account');
            insert testAcc;
            delete testAcc;
            
            Test.startTest();
            undelete testAcc;
            Test.stopTest();
            
            List<Task> tasks = [SELECT Id, Subject, Description FROM Task WHERE WhatId = :testAcc.Id];
            System.assertEquals(1, tasks.size(), 'Une tâche devrait être créée');
            System.assertEquals('Account restored', tasks[0].Subject, 'Le sujet de la tâche devrait être correct');
        }
    }
} 