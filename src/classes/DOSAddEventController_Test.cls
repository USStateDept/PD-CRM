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
private class DOSAddEventController_Test {
	/*static testMethod void bulkTestForAddEvents(){
		// TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();
        
         List<Contact> conList = new List<Contact>();
         for(Integer i=0; i<50; i++){
         	Contact objContact = testData.newContact();
         	conList.add(objContact);
         }
        
        
        List<Event__c> lstEvents = testData.createMultipleEvents(50);
        
        Test.startTest();        	
	      PageReference pageRef = Page.DOSAddContactsToEventPage;
	      Test.setCurrentPage(pageRef);	   
	      ApexPages.StandardSetcontroller ssc = new ApexPages.StandardSetController(new List<Contact>());
	      ssc.setSelected(conList);
	      //ApexPages.Standardcontroller sc = new ApexPages.StandardController();
	      ApexPages.currentPage().getParameters().put('Id',lstEvents[0].id);
	      DOSAddEventController objAddEvent = new DOSAddEventController(ssc);
	      objAddEvent.getEvents();
	      objAddEvent.getStep();	      
	      objAddEvent.step1();	      
	      objAddEvent.openEvents[0].cSelect = true;
	      objAddEvent.openEvents[1].cSelect = true;
	      objAddEvent.nextEvent();
	      objAddEvent.nextLastEvent();
	      objAddEvent.previousEvent();
	      objAddEvent.previousFirstEvent();
	      objAddEvent.step4();
	      objAddEvent.finish();
	      objAddEvent.cancel();	            
	      System.assert(objAddEvent != null);       	
        Test.stopTest();
        
		
	}*/
    static testMethod void test_DOSAddEventController() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();
        Contact objContact = testData.newContact();
        Event__c objEvent = testData.newEvent('Published');
        
        User testUser = testData.newUser();
        
        Test.startTest();        	
	      PageReference pageRef = Page.DOSAddContactsToEventPage;
	      Test.setCurrentPage(pageRef);
	      List<Contact> conList = new List<Contact>();
	      conList.add(objContact);
	      ApexPages.StandardSetcontroller ssc = new ApexPages.StandardSetController(new List<Contact>());
	      ssc.setSelected(conList);
	      //ApexPages.Standardcontroller sc = new ApexPages.StandardController();
	      ApexPages.currentPage().getParameters().put('Id',objEvent.id);
	      DOSAddEventController objAddEvent = new DOSAddEventController(ssc);
	      objAddEvent.getEvents();
	      objAddEvent.getStep();
	      objAddEvent.step1();
	      objAddEvent.openEvents[0].cSelect = true;
	      objAddEvent.step4();
	      objAddEvent.finish();
	      objAddEvent.cancel();
	      	      
	      System.assert(objAddEvent != null);       	
        Test.stopTest();
        
    }
}