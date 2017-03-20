@isTest
public class SARF_External_User_Controller_TEST {

    
     static testMethod void testSave(){
         
        // Create test SARF data
        CMS_SARF__c email1 = createSARF('FName1', 'LName1', 'same_email@sarf.test');
         
        // Execute test
        Test.startTest();
        SARF_External_User_Controller uc = new SARF_External_User_Controller();
        uc.email = 'myemail@test.sarf';
        uc.lastName = 'LastName';
        uc.firstName = 'FirstName';
        uc.phone = '555-555-5555';
        uc.jobtitle = 'aTitle';
        uc.bureau = 'aBureau';
        uc.save();
        Test.stopTest();
     }
    
    
    // HELPER METHODS TO CREATE DATA
    static CMS_SARF__c createSARF(String firstName, String lastName, String email){
        CMS_SARF__c sarf = new CMS_SARF__c();
        sarf.First_Name__c = firstName;
        sarf.Last_Name__c = lastName;
        sarf.Email_Address__c = email;
        insert sarf;
        return sarf;
    }
    
}