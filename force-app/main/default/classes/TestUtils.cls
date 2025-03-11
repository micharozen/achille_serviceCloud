public with sharing class TestUtils {
    

    public static User createAchilleUser(){
        Profile p = [SELECT Id FROM Profile LIMIT 1];

        // Créer un utilisateur de test avec le permission set upplawUser
        User achilleUser = new User(
            Alias = 'achille',
            Email = 'achilleuser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Achille',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'achilleuser' + UserInfo.getOrganizationId() + '@testorg.com'
        );
        insert achilleUser;

        // Assigner le permission set upplawUser
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'AchilleUser'];
        insert new PermissionSetAssignment(AssigneeId = achilleUser.Id, PermissionSetId = ps.Id);

        return achilleUser;
    }

    public static User getAchilleUser(){
        return [SELECT Id FROM User WHERE Alias = 'achille' LIMIT 1];
    }

}
