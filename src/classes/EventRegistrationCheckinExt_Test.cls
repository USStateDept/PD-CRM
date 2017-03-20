/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EventRegistrationCheckinExt_Test {

    static testMethod void myUnitTest1() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();
        Contact objContact = testData.newContact();
        Contact objContact1 = testData.newContact();
        Event__c objEvent = testData.newEvent('Draft'); 
        objEvent.Show_Map__c = true;
        objEvent.No_of_guests_allowed__c = '2';
        update objEvent;
        
		Event_Registration__c objER = new Event_Registration__c();
		objER.Event__c = objEvent.Id;
		objER.Contact__c = objContact.Id;
		objER.Status__c = 'Accepted';
		insert objER;
		
        User testUser = testData.newUser();
        
        Test.startTest(); 
        //System.runAs(testUser)      	
        {     	
	      PageReference pageRef = Page.EventRegistrationCheckinPage;
	      Test.setCurrentPage(pageRef);	      
	      ApexPages.Standardcontroller sc = new ApexPages.StandardController(objEvent);
	      ApexPages.currentPage().getParameters().put('id',objEvent.id);
	      ApexPages.currentPage().getParameters().put('objectName','Event_registration__c');	      
	      ApexPages.currentPage().getParameters().put('fieldName','QR_Code_Id__c');
	      ApexPages.currentPage().getParameters().put('fieldValue',objER.Id);
	      EventRegistrationCheckinExt objLanding = new EventRegistrationCheckinExt(sc);
	      objLanding.checkIn();	     
        }       	
        Test.stopTest();
        
    }
    
    static testMethod void myUnitTest2() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();
        Contact objContact = testData.newContact();
        Contact objContact1 = testData.newContact();
        Event__c objEvent = testData.newEvent('Draft'); 
        objEvent.Show_Map__c = true;
        objEvent.No_of_guests_allowed__c = '2';
        update objEvent;
        
		Event_Registration__c objER1 = new Event_Registration__c();
		objER1.Event__c = objEvent.Id;
		objER1.Contact__c = objContact.Id;
		objER1.Status__c = 'Attended';
		insert objER1;
                       
        User testUser = testData.newUser();
        
        Test.startTest(); 
        //System.runAs(testUser)      	
        {     	
	      PageReference pageRef = Page.EventRegistrationCheckinPage;
	      Test.setCurrentPage(pageRef);	      
	      ApexPages.Standardcontroller sc = new ApexPages.StandardController(objEvent);
	      ApexPages.currentPage().getParameters().put('id',objEvent.id);
	      ApexPages.currentPage().getParameters().put('objectName','Event_registration__c');	      
	      ApexPages.currentPage().getParameters().put('fieldName','QR_Code_Id__c');
	      ApexPages.currentPage().getParameters().put('fieldValue',objER1.Id);
	      EventRegistrationCheckinExt objLanding = new EventRegistrationCheckinExt(sc);
	      objLanding.checkIn();	     
        }       	
        Test.stopTest();
        
    }    

}