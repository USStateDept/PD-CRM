@isTest
public class SARF_External_AMS_Controller_TEST {

    static testMethod void testSave(){
         
        // Create test SARF data
        CMS_SARF__c email1 = createSARF('FName1', 'LName1', 'same_email@sarf.test');         
        
        // Execute test
        Test.startTest();        
        
        Global_Variable__c baseUrlVariable = new Global_Variable__c();
        baseUrlVariable.Name = 'Salesforce Base URL';
        baseUrlVariable.value__c = 'https://iipstate--fullcopy.cs33.my.salesforce.com';
        insert baseUrlVariable;
        
        SARF_External_AMS_Controller uc = new SARF_External_AMS_Controller();        
        // with valid email
        uc.email = 'myemail@test.sarf'; 
        uc.lastName = 'LastName';
        uc.firstName = 'FirstName';
        uc.phone = '555-555-5555';
        uc.jobtitle = 'aTitle';
        uc.bureau = 'aBureau';
        uc.save(); 
        
        // with valid state email
        uc.email = 'myemail@state.gov'; 
        uc.lastName = 'LastName1';
        uc.firstName = 'FirstName1';
        uc.phone = '555-555-5555';
        uc.jobtitle = 'aTitle';
        uc.bureau = 'aBureau';
        uc.save(); 
        
        // with invalid email
        uc.email = 'myemail&test.sarfnew'; 
        uc.lastName = 'LastName';
        uc.firstName = 'FirstName';
        uc.phone = '555-555-5555';
        uc.jobtitle = 'aTitle';
        uc.bureau = 'aBureau';
        uc.save(); 
        
        Test.stopTest(); // stop test
     }
    
    
    // Helper method to create data
    static CMS_SARF__c createSARF(String firstName, String lastName, String email){
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.First_Name__c = firstName;
        sarf.Last_Name__c = lastName;
        sarf.Email_Address__c = email;
        insert sarf;
        return sarf;
    }
}