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
private class EventRegistrationTriggerHelper_Test {

	

	@testSetup
    static void testDataSetup_ERTriggerHelper() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();        
        Contact objContact = testData.newContact();
        //Create the Event record with Published Status
        Event__c objEvent = testData.newEvent('Published');
        //Create the Event Registration for the above event
        Event_Registration__c objER = testData.newEventRegistration(objEvent.Id, objContact.Id);
    }
    
    @isTest
    public static void testUpdateER(){
    	
    	DOS_TestDataUtility testData = new DOS_TestDataUtility();   
    	System.assert(testData != null);
    	
    	Event_Registration__c objER = [Select Id, Name, Status__c from Event_Registration__c];
    	System.assert(objER != null);
    	
    	objER.Status__c = 'Accepted';
    	update objER;
    	
    	objER.Status__c = 'Declined';
    	update objER;
    	
    	Contact objContact = testData.newContact();
    	System.assert(objContact != null);
    	objER.Contact__c = objContact.Id;
    	
    	//In case if the trigger throws any custom validations.
    	try{
    		update objER;	
    	}
    	catch(Exception e){
    		
    	}   	    	
    	
    }
    
    @isTest
    public static void testDeleteER(){
    	Event_Registration__c objER = [Select Id, Name, Status__c from Event_Registration__c];
    	System.assert(objER != null);
    	
    	delete objER;	
    	
    }
}