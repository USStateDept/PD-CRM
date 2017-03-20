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
private class DOS_EventDeepCloneUtility_Test {

    static testMethod void test_CloneEvent() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();
        
        Account objAccount = testData.newAccount();
        Contact objContact = testData.newContact();
        Contact objContact1 = testData.newContact();
        Event__c objEvent = testData.newEvent('Published'); 
        Event_Registration__c objER = testData.newEventRegistration(objEvent.Id, objContact.Id);
        objEvent.Show_Map__c = true;
        update objEvent; 
        Event_Registration__c objER1 = testData.newEventRegistration(objEvent.Id, objContact1.Id);       
                              
        User testUser = testData.newUser();
        
        Test.startTest(); 
        //System.runAs(testUser)      	
        {     	
	      PageReference pageRef = Page.DOS_CloneEvent;
	      Test.setCurrentPage(pageRef);	      
	      ApexPages.Standardcontroller sc = new ApexPages.StandardController(objEvent);
	      ApexPages.currentPage().getParameters().put('Id',objEvent.id);	      
	      DOS_EventDeepCloneUtility objLanding = new DOS_EventDeepCloneUtility(sc);
	      objLanding.cloneEvent(); 
	      
        }       	
        Test.stopTest();        
    }
    
}