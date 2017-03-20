@isTest
public class PreferenceTriggerHelper_Test {
    static testmethod void testTriggerhandler() {
        Test.startTest();
        
        Account ac = new Account();
        ac.name='Mission ' + 'Germany';
        insert ac;
        
        Account ac1 = new Account();
        ac1.name='Mission ' + 'Austria';
        insert ac1;
        
        Contact ct = new Contact();
        ct.LastName='test';
        ct.AccountId = ac.id;
        ct.Email='test_lastn@mail.com';
        insert ct;
        
        Contact ct1 = new Contact();
        ct1.LastName='test1';
        ct1.AccountId = ac1.id;
        ct1.Email='test_lastn1@mail.com';
        insert ct1;
        
        Preference_Country__c objPrefCon = new Preference_Country__c();
        objPrefCon.Name = 'Austria';
        objPrefCon.Role__c = 'Mission_Austria';
        insert objPrefCon;
        String countryName = objPrefCon.Name;

        Preference_Country__c objPrefCon1 = new Preference_Country__c();
        objPrefCon1.Name = 'Indonesia';
        objPrefCon1.Role__c = 'Mission_Indonesia';        
        insert objPrefCon1;
        String countryName1 = objPrefCon1.Name;
        
        Preference__c objPref = new Preference__c();
        objPref.ContactName__c = ct.id;
        objPref.Country__c=countryName;
        insert objPref;
        
        objPref.Country__c=countryName1;
        update objPref;
        
        delete objPref;
        
        
        Test.stopTest();
        
    } 
}