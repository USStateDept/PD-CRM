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
private class CMCampaignBatch_Test {	
	
	@testSetup
    static void test_CMCampaignBatch() {
        // TO DO: implement unit test
        DOS_TestDataUtility testData = new DOS_TestDataUtility();        
        Contact objContact = testData.newContact();
        //Create the Event record with Published Status
        Event__c objEvent = testData.newEvent('Published');
        //Create the Event Registration for the above event
        Event_Registration__c objER = testData.newEventRegistration(objEvent.Id, objContact.Id);
        wbsendit__Campaign_Monitor_Campaign__c objCMC = testData.newCMCampaign();        
    }
    
    @isTest
    public static void testCMCampaignBatch(){
    	
    	List<wbsendit__Campaign_Monitor_Campaign__c> lstObjCMC = [Select Id, Name,wbsendit__Campaign_ID__c from wbsendit__Campaign_Monitor_Campaign__c];
    	System.assert(lstObjCMC.size() > 0);
    	
    	Test.startTest();
    	CMCampaignBatch objCMBatch = new CMCampaignBatch();
    	Database.executeBatch(objCMBatch);
    	//Database.BatchableContext ctx;
    	/*objCMBatch.start(ctx);
    	objCMBatch.execute(ctx,lstObjCMC);
    	objCMBatch.finish(ctx);*/
		Test.stopTest();   	
    	
    }
}