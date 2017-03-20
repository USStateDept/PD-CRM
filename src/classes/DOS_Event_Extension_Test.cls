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
@isTest(SeeAlldata=true)
private class DOS_Event_Extension_Test {

    static testMethod void test_DOS_Event_Extension() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();
        Contact objContact = testData.newContact();
        Contact objContact1 = testData.newContact();
        Event__c objEvent = testData.newEvent('Published'); 
        Event_Registration__c objER = testData.newEventRegistration(objEvent.Id, objContact.Id);
        objEvent.Show_Map__c = true;
        objEvent.No_of_guests_allowed__c = '2';
        update objEvent;
        
        Event__c objEvent1 = testData.newEvent('Cancelled');
        objEvent1.Show_Map__c = false;
        update objEvent1;
        Event_Registration__c objER1 = testData.newEventRegistration(objEvent1.Id, objContact.Id);
        
        Event__c objEvent2 = testData.newEvent('Published');
        objEvent2.Show_Map__c = false;
        objEvent2.Maximum_Registration__c = 1;
        update objEvent2;
        Event_Registration__c objER2 = testData.newEventRegistration(objEvent2.Id, objContact.Id);
        //objER2.Contact__c = objContact1.Id;
        //update objER2;
                       
        User testUser = testData.newUser();
        
        Test.startTest(); 
        //System.runAs(testUser)      	
        {     	
	      PageReference pageRef = Page.EventRSVPPageLanding;
	      Test.setCurrentPage(pageRef);	      
	      ApexPages.Standardcontroller sc = new ApexPages.StandardController(objEvent);
	      ApexPages.currentPage().getParameters().put('id',objEvent.id);
	     // ApexPages.currentPage().getParameters().put('erid',objER.id);	      
	      DOS_Event_Extension objLanding = new DOS_Event_Extension(sc);
	      objLanding.addGuest();
	      objLanding.onAccept();
	      objLanding.onDecline();
	      objLanding.LastName = 'testLastname';
	      objLanding.Email = 'test@Lastname.com';
	      
	      //Update contact
	      //objContact.Email = objLanding.Email;
	      //update objContact; 
	      	      	      	
	      objLanding.onAccept();
	      objLanding.Email = 'testLastname.com';
	      objLanding.onAccept();	 
	      objLanding.isEventRegistrationExists(objEvent.Id,objContact.Id);
	      System.assert(objLanding != null);  
	      ApexPages.Standardcontroller sc1 = new ApexPages.StandardController(objEvent1);
	      ApexPages.currentPage().getParameters().put('id',objEvent1.id);  
	      ApexPages.currentPage().getParameters().put('erid',objER1.id);
	      DOS_Event_Extension objLanding1 = new DOS_Event_Extension(sc1);	       
	      objLanding1.onAccept(); 
	      objLanding1.onDecline();
	      PageReference pageRef1 = Page.EventRSVPPageLanding;
	      Test.setCurrentPage(pageRef1);      
	      ApexPages.Standardcontroller sc2 = new ApexPages.StandardController(objEvent1);	        
	      DOS_Event_Extension objLanding2 = new DOS_Event_Extension(sc2); 
	      
	      ApexPages.Standardcontroller sc3 = new ApexPages.StandardController(objEvent2);
	      ApexPages.currentPage().getParameters().put('id',objEvent2.id);  
	      ApexPages.currentPage().getParameters().put('erid',objER2.id);
	      DOS_Event_Extension objLanding3 = new DOS_Event_Extension(sc3);	       
	     
        }       	
        Test.stopTest();
    }
}