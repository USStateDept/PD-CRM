@isTest
public class SARF_Access_Assignment_Test {
    
    static testMethod void testAssignProfile(){
        
        Test.startTest();
        CMS_SARF__c sarf = createSARF('First', 'Last', 'firstlast@sarf.test', 'System Administrator', '');
        SARF_Access_Assignment aa = new SARF_Access_Assignment(sarf);
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'System Administrator');
        
        sarf.Role__c = 'Functional';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'System Administrator');
        
        sarf.Role__c = 'American Spaces Wash';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'IIP User');
        
        sarf.Role__c = 'American Spaces Site.com';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'Overage Authenticated Website user');
        
        sarf.Role__c = 'CMS Manager';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'System Administrator (mock)');
        
    	sarf.Role__c = 'CMS Team';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'CMS User');
        
        sarf.Role__c = 'CMS Support Services';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'System Administrator (mock)');
        
        sarf.Role__c = 'CONX Project Coordinator';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'IIP User');
        
        sarf.Role__c = 'CONX Producer';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'IIP User');
        
        sarf.Role__c = 'CONX General Queue';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'IIP User');
        
        sarf.Role__c = 'Editor';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'Publishing Editor');
        
        sarf.Role__c = 'Translator';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'Publishing Translator');
        
        sarf.Role__c = 'Copy Desk';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'Publishing Copy Desk');
        
        sarf.Role__c = 'Content Creator';
        aa.assignProfile();
        System.assertEquals(aa.getProfile(),'Publishing Content Creator');
        
        Test.stopTest();
    }
    
    static testMethod void testSetProfileAndPS(){
        Test.startTest();
        CMS_SARF__c sarf = createSARF('First', 'Last', 'firstlast@sarf.test', 'CMS Team', 'CMS User');
        SARF_Access_Assignment aa = new SARF_Access_Assignment(sarf);
        List<String> permSets = new List<String>();
        permSets.add('CMS Basic');
        permSets.add('CMS Report View');
        permSets.add('Enable SMS-based identity confirmation');
        aa.setPS(permSets);
        aa.setProfileAndPS('CMS User');
        Test.stopTest();
    }
    
    // Helper methods to create data
    static CMS_SARF__c createSARF(String firstName, String lastName, String email, String role, String profile){
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.First_Name__c = firstName;
        sarf.Last_Name__c = lastName;
        sarf.Email_Address__c = email;
        sarf.role__c = role;
        sarf.ProfileTemp__c = profile;
        insert sarf;
        return sarf;
    }

}